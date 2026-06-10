library(urca)

racine <- "/Users/julien/Documents/IFP/Econometrie/Projet_Econometrie_ENM_2025-2026"
out <- file.path(racine, "rendu_julien")

df <- read.csv(file.path(out, "donnees_propres.csv"))
df$lFR <- log(df$FR)
df$lDE <- log(df$DE)

## ---- ETAPE 1 : relation de long terme FR ~ DE ----
eg2 <- lm(lFR ~ lDE, data = df)
cat("===== Relation de long terme FR ~ DE =====\n")
print(round(coef(eg2), 4))
cat(sprintf("\nlFR = %.3f + %.3f*lDE + residu\n\n", coef(eg2)[1], coef(eg2)[2]))

## ---- ETAPE 2 : ADF sur les residus ----
res <- residuals(eg2)
adf_res <- ur.df(res, type = "none", selectlags = "AIC")
tau <- adf_res@teststat[1]
cat(sprintf("ADF sur residus : tau = %.3f\n\n", tau))

# Valeurs critiques Engle-Granger pour 2 variables (avec constante) :
cv_eg <- c("1%" = -3.90, "5%" = -3.34, "10%" = -3.04)
cat("Valeurs critiques Engle-Granger (2 var.) :\n"); print(cv_eg)
concl <- ifelse(tau < cv_eg["5%"], "tau < cv5% -> residus STATIONNAIRES -> COINTEGRATION (marches 
couples)", "tau > cv5% -> PAS de cointegration")
cat("\n-> ", concl, "\n")