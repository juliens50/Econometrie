# ============================================================
# Etape 5 : couplage FR <-> DE, Engle-Granger bivarie (Q2), par periode
#   lFR ~ lDE  puis ADF sur residus
# ============================================================
library(urca)

racine <- "/Users/julien/Documents/IFP/Econometrie/Projet_Econometrie_ENM_2025-2026"
out    <- file.path(racine, "rendu_julien")

periodes <- list(
  "Complet (2015-2026)" = "donnees_propres.csv",
  "P1 (2015-2019)"      = "donnees_propres-P1.csv",
  "P2 (2020.6-2026)"    = "donnees_propres-P2.csv"
)

cv5 <- -3.34   # valeur critique Engle-Granger, 2 variables, 5%

for (lab in names(periodes)) {
  df <- read.csv(file.path(out, periodes[[lab]]))
  df$lFR <- log(df$FR); df$lDE <- log(df$DE)

  eg  <- lm(lFR ~ lDE, data = df)
  tau <- ur.df(residuals(eg), type = "none", selectlags = "AIC")@teststat[1]
  co  <- coef(eg)
  verdict <- ifelse(tau < cv5, "COINTEGRATION (couples)", "pas de cointegration")

  cat("\n================", lab, "================\n")
  cat(sprintf("lFR = %.3f + %.3f*lDE   (elasticite FR/DE)\n", co[1], co[2]))
  cat(sprintf("ADF residus : tau = %.3f (cv5%% = %.2f) -> %s\n", tau, cv5, verdict))
}
