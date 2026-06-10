racine <- "/Users/julien/Documents/IFP/Econometrie/Projet_Econometrie_ENM_2025-2026"
out <- file.path(racine, "rendu_julien")

df <- read.csv(file.path(out, "donnees_propres.csv"))
df$lFR  <- log(df$FR)
df$lDE  <- log(df$DE)
df$lGaz <- log(df$Gaz)

# 1) Terme de correction d'erreur = residu de la relation de long terme
lr <- lm(lFR ~ lGaz + lDE, data = df)
df$ect <- residuals(lr)

# 2) Differences premieres + ECT retarde d'un jour
n <- nrow(df)
D <- data.frame(
  dlFR  = diff(df$lFR),
  dlDE  = diff(df$lDE),
  dlGaz = diff(df$lGaz),
  ect1  = df$ect[-n]        # ECT_{t-1} : ecart a l'equilibre de la veille
)

# 3) Qui s'ajuste a l'equilibre ? (vitesse d'ajustement lambda par variable)
cat("===== Vitesse d'ajustement a l'equilibre (lambda sur ECT_t-1) =====\n")
for (v in c("dlFR", "dlDE", "dlGaz")) {
  m <- lm(D[[v]] ~ D$ect1)
  co <- summary(m)$coefficients
  lambda <- co["D$ect1", "Estimate"]
  pval   <- co["D$ect1", "Pr(>|t|)"]
  verdict <- ifelse(pval < 0.05 & lambda < 0,
                    sprintf("s'ajuste : %.1f%% de l'ecart corrige/jour", -lambda*100),
                    "ne s'ajuste PAS (faiblement exogene -> mene)")
  cat(sprintf("%-6s : lambda = %7.4f | p = %.3g -> %s\n", v, lambda, pval,
verdict))
}

# 4) ECM complet pour la France (avec dynamique de court terme)
cat("\n===== ECM complet pour la France (court + long terme) =====\n")
ecm_fr <- lm(dlFR ~ ect1 + dlDE + dlGaz, data = D)
print(round(summary(ecm_fr)$coefficients, 4))
