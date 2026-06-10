library(urca)

racine <- "/Users/julien/Documents/IFP/Econometrie/Projet_Econometrie_ENM_2025-2026"
out <- file.path(racine, "rendu_julien")

df <- read.csv(file.path(out, "donnees_propres.csv"))
df$lFR  <- log(df$FR)
df$lDE  <- log(df$DE)
df$lGaz <- log(df$Gaz)

## ---- ETAPE 1 : regression statique de long terme ----
eg <- lm(lFR ~ lGaz + lDE, data = df)
cat("===== Relation de long terme estimee (Engle-Granger) =====\n")
print(round(coef(eg), 4))
cat(sprintf("\nlFR = %.3f + %.3f*lGaz + %.3f*lDE + residu\n\n",
            coef(eg)[1], coef(eg)[2], coef(eg)[3]))


## ---- ETAPE 2 : ADF sur les residus (l'ecart a l'equilibre) ----
res <- residuals(eg)
adf_res <- ur.df(res, type = "none", selectlags = "AIC") 
tau <- adf_res@teststat[1]

cat("===== Test ADF sur les residus =====\n")
cat(sprintf("Statistique tau = %.3f\n\n", tau))

# Valeurs critiques d'Engle-Granger (MacKinnon), 3 variables, avec constante :
cv_eg <- c("1%" = -4.29, "5%" = -3.74, "10%" = -3.45)
cat("Valeurs critiques Engle-Granger (3 var.) :\n")
print(cv_eg)
concl <- ifelse(tau < cv_eg["5%"],
                "tau < cv5% -> residus STATIONNAIRES -> COINTEGRATION",
                "tau > cv5% -> residus I(1) -> PAS de cointegration")
cat("\n-> ", concl, "\n")

