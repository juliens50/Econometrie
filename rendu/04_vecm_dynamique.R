# =====================================================================
# Projet Econometrie ENM 2025-2026
# Etape 4 : VECM et dynamique des prix -> QUESTION 3
#   - estimation du VECM (rang r = 2)
#   - coefficients d'ajustement (vitesse de retour a l'equilibre)
#   - causalite de Granger
#   - fonctions de reponse impulsionnelle
# =====================================================================

suppressMessages({ library(urca); library(vars) })

racine <- "/Users/julien/Documents/IFP/Econometrie/Projet_Econometrie_ENM_2025-2026"
out <- file.path(racine, "rendu")
df <- read.csv(file.path(out, "echantillon_commun_R.csv"))

Y    <- as.matrix(df[, c("lFR", "lDE", "lGAS")])
dums <- as.matrix(df[, c("crise", "covid")])
K <- 3        # retards retenus a l'etape 3
r <- 2        # rang de cointegration retenu (seuil 1%)

## ---- 1. Estimation Johansen puis VECM via cajorls -------------------
joh <- ca.jo(Y, type = "trace", ecdet = "const", K = K,
             spec = "transitory", dumvar = dums)
vecm <- cajorls(joh, r = r)

cat("=====================================================\n")
cat(" RELATIONS DE LONG TERME (beta normalise, r =", r, ")\n")
cat("=====================================================\n")
print(round(vecm$beta, 4))

cat("\n=====================================================\n")
cat(" COEFFICIENTS D'AJUSTEMENT (alpha) + dynamique CT\n")
cat("=====================================================\n")
print(summary(vecm$rlm))

## ---- 2. Representation VAR pour causalite / IRF ---------------------
var_rep <- vec2var(joh, r = r)

cat("\n=====================================================\n")
cat(" CAUSALITE DE GRANGER (sur le VAR en niveau)\n")
cat("=====================================================\n")
# On reestime un VAR en differences pour les tests de causalite propres
varlevel <- VAR(Y, p = K, type = "const", exogen = dums)
for (v in c("lFR", "lDE", "lGAS")) {
  g <- causality(varlevel, cause = v)$Granger
  cat(sprintf("%-5s cause-t-il les autres ? F = %.2f, p = %.4g -> %s\n",
              v, g$statistic, g$p.value,
              ifelse(g$p.value < 0.05, "OUI (causalite)", "non")))
}

## ---- 3. Fonctions de reponse impulsionnelle -------------------------
cat("\nCalcul des IRF (choc gaz -> prix elec, horizon 20 j)...\n")
irf_gas <- irf(var_rep, impulse = "lGAS", response = c("lFR", "lDE"),
               n.ahead = 20, boot = TRUE, runs = 100)
png(file.path(out, "fig3_irf_gaz.png"), width = 1000, height = 450)
plot(irf_gas)
dev.off()

irf_de <- irf(var_rep, impulse = "lDE", response = c("lFR"),
              n.ahead = 20, boot = TRUE, runs = 100)
png(file.path(out, "fig4_irf_de_vers_fr.png"), width = 700, height = 450)
plot(irf_de)
dev.off()

cat("IRF sauvegardees : fig3_irf_gaz.png, fig4_irf_de_vers_fr.png\n")
cat("\nEtape 4 terminee.\n")
