# ============================================================
# Etape 3 : ordre d'integration (ADF + KPSS), par sous-periode
# ============================================================
library(urca)

racine <- "/Users/julien/Documents/IFP/Econometrie/Projet_Econometrie_ENM_2025-2026"
out    <- file.path(racine, "rendu_julien")

periodes <- list(
  "Complet (2015-2026)" = "donnees_propres.csv",
  "P1 (2015-2019)"      = "donnees_propres-P1.csv",
  "P2 (2020.6-2026)"    = "donnees_propres-P2.csv"
)

# ADF (H0 = racine unitaire) : stationnaire si tau < cv5%
adf_v <- function(x) {
  t <- ur.df(x, type = "drift", selectlags = "AIC")
  ifelse(t@teststat[1] < t@cval[1, "5pct"], "STAT", "I(1)")
}
# KPSS (H0 = stationnaire) : non stationnaire si LM > cv5%
kpss_v <- function(x) {
  k <- ur.kpss(x, type = "mu")
  ifelse(k@teststat > k@cval[1, "5pct"], "NON-STAT", "STAT")
}

for (lab in names(periodes)) {
  df <- read.csv(file.path(out, periodes[[lab]]))
  S  <- list(lFR = log(df$FR), lDE = log(df$DE), lGaz = log(df$Gaz))
  cat("\n================", lab, "(", nrow(df), "obs ) ================\n")
  cat(sprintf("%-5s | %-11s | %-9s | %-11s\n", "serie", "ADF niveau", "KPSS niv.", "ADF diff."))
  for (n in names(S)) {
    cat(sprintf("%-5s | %-11s | %-9s | %-11s\n",
                n, adf_v(S[[n]]), kpss_v(S[[n]]), adf_v(diff(S[[n]]))))
  }
}
cat("\nLecture : niveau I(1)/NON-STAT + diff STAT => serie I(1).\n")
