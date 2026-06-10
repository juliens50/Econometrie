# =====================================================================
# Projet Econometrie ENM 2025-2026
# Etape 2 : tests de racine unitaire (ordre d'integration)
# ADF (urca), Phillips-Perron, KPSS sur niveaux (log) et diff. premieres
# =====================================================================

library(urca)
library(tseries)

racine <- "/Users/julien/Documents/IFP/Econometrie/Projet_Econometrie_ENM_2025-2026"
out <- file.path(racine, "rendu")

df <- read.csv(file.path(out, "echantillon_commun_R.csv"))
series <- list(lFR = df$lFR, lDE = df$lDE, lGAS = df$lGAS)

## ---- Helper : extraire stat ADF et valeurs critiques (urca) ----------
adf_line <- function(x, type, name) {
  # type = "drift" (constante) ou "trend" (constante + tendance)
  t <- ur.df(x, type = type, selectlags = "AIC")
  stat <- t@teststat[1]                     # statistique tau
  cv <- t@cval[1, ]                          # 1%, 5%, 10%
  rej5 <- ifelse(stat < cv["5pct"], "STATIONNAIRE", "racine unitaire")
  sprintf("ADF[%s] %-5s : tau = %7.3f | cv5%% = %6.3f -> %s",
          type, name, stat, cv["5pct"], rej5)
}

## ---- Helper : KPSS (H0 = stationnaire, inverse de ADF) ---------------
kpss_line <- function(x, name) {
  k <- ur.kpss(x, type = "mu")               # niveau-stationnaire
  stat <- k@teststat
  cv5 <- k@cval[1, "5pct"]
  concl <- ifelse(stat > cv5, "NON stationnaire", "stationnaire")
  sprintf("KPSS  %-5s : LM  = %7.3f | cv5%% = %6.3f -> %s",
          name, stat, cv5, concl)
}

## =====================================================================
## 1. NIVEAUX (log des prix)
## =====================================================================
cat("=====================================================\n")
cat(" TESTS SUR LES NIVEAUX (log des prix)\n")
cat("=====================================================\n")
for (n in names(series)) {
  cat(adf_line(series[[n]], "drift", n), "\n")
  cat(adf_line(series[[n]], "trend", n), "\n")
  cat(kpss_line(series[[n]], n), "\n")
  cat("-----------------------------------------------------\n")
}

## =====================================================================
## 2. DIFFERENCES PREMIERES
## =====================================================================
cat("\n=====================================================\n")
cat(" TESTS SUR LES DIFFERENCES PREMIERES\n")
cat("=====================================================\n")
for (n in names(series)) {
  dx <- diff(series[[n]])
  cat(adf_line(dx, "drift", paste0("d.", n)), "\n")
  cat(kpss_line(dx, paste0("d.", n)), "\n")
  cat("-----------------------------------------------------\n")
}

cat("\nConclusion attendue : series I(1) (racine unitaire en niveau,\n")
cat("stationnaires en difference premiere) -> cointegration possible.\n")
