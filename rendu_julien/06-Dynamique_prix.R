# ============================================================
# Etape 6 : dynamique des prix - Modele a Correction d'Erreur (Q3)
#   Pour chaque periode : vitesse d'ajustement lambda de chaque prix
#   + ECM complet pour la France.
#   NB : le signe "stabilisant" de lambda depend du signe de la
#        variable dans la relation d'equilibre (ECT).
# ============================================================
racine <- "/Users/julien/Documents/IFP/Econometrie/Projet_Econometrie_ENM_2025-2026"
out    <- file.path(racine, "rendu_julien")

periodes <- list(
  "Complet (2015-2026)" = "donnees_propres.csv",
  "P1 (2015-2019)"      = "donnees_propres-P1.csv",
  "P2 (2020.6-2026)"    = "donnees_propres-P2.csv"
)

for (lab in names(periodes)) {
  df <- read.csv(file.path(out, periodes[[lab]]))
  df$lFR <- log(df$FR); df$lDE <- log(df$DE); df$lGaz <- log(df$Gaz)

  # Relation de long terme -> terme de correction d'erreur (ECT)
  lr  <- lm(lFR ~ lGaz + lDE, data = df)
  b   <- coef(lr)               # (Intercept, lGaz, lDE)
  df$ect <- residuals(lr)

  n <- nrow(df)
  D <- data.frame(
    dlFR  = diff(df$lFR), dlDE = diff(df$lDE), dlGaz = diff(df$lGaz),
    ect1  = df$ect[-n]
  )

  # Signe de chaque variable dans l'ECT (FR normalise a +1)
  theta <- c(dlFR = 1, dlDE = -unname(b["lDE"]), dlGaz = -unname(b["lGaz"]))

  cat("\n================", lab, "================\n")
  cat("Vitesse d'ajustement (lambda sur ECT_t-1) :\n")
  for (v in c("dlFR", "dlDE", "dlGaz")) {
    m  <- lm(D[[v]] ~ D$ect1)
    co <- summary(m)$coefficients
    lambda <- co["D$ect1", "Estimate"]; pval <- co["D$ect1", "Pr(>|t|)"]
    # stabilisant si theta * lambda < 0 (ramene l'ecart vers 0) et significatif
    stab <- (theta[[v]] * lambda < 0) && (pval < 0.05)
    cat(sprintf("  %-5s : lambda = %7.4f | p = %8.2g -> %s\n",
                v, lambda, pval,
                ifelse(stab, "s'ajuste (stabilisant)",
                       ifelse(pval >= 0.05, "ne s'ajuste pas (n.s. -> exogene/mene)",
                              "signe non stabilisant"))))
  }

  ecm_fr <- lm(dlFR ~ ect1 + dlDE + dlGaz, data = D)
  cat("ECM France (rappel + court terme) :\n")
  print(round(summary(ecm_fr)$coefficients[, c(1, 4)], 4))
}
