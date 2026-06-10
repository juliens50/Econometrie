# =====================================================================
# Projet Econometrie ENM 2025-2026
# Etape 3 : tests de cointegration
#   (a) Engle-Granger (regression statique + ADF sur residus)
#   (b) Johansen a 3 variables (lFR, lDE, lGAS) -> question 1
#   (c) Johansen bivarie (lFR, lDE)             -> question 2
# Series traitees comme I(1) ; dummies crise + covid en exogene.
# =====================================================================

suppressMessages({ library(urca); library(vars) })

racine <- "/Users/julien/Documents/IFP/Econometrie/Projet_Econometrie_ENM_2025-2026"
out <- file.path(racine, "rendu")
df <- read.csv(file.path(out, "echantillon_commun_R.csv"))

Y    <- as.matrix(df[, c("lFR", "lDE", "lGAS")])
dums <- as.matrix(df[, c("crise", "covid")])

## ---- 0. Choix du nombre de retards (VAR en niveau) -------------------
sel <- VARselect(Y, lag.max = 14, type = "const", exogen = dums)
cat("Nombre de retards optimal (criteres) :\n"); print(sel$selection)
K <- max(2, as.integer(sel$selection["SC(n)"]))   # SC parcimonieux, mini 2
cat("-> on retient K =", K, "retards pour Johansen\n\n")

## =====================================================================
## (a) ENGLE-GRANGER : lFR = a + b*lGAS + c*lDE + e ; ADF sur residus
## =====================================================================
cat("=====================================================\n")
cat(" (a) ENGLE-GRANGER (relation statique de long terme)\n")
cat("=====================================================\n")
eg <- lm(lFR ~ lGAS + lDE, data = df)
cat("Relation estimee : lFR = %.3f + %.3f*lGAS + %.3f*lDE\n" |>
      sprintf(coef(eg)[1], coef(eg)[2], coef(eg)[3]))
res <- residuals(eg)
adf_res <- ur.df(res, type = "none", selectlags = "AIC")
cat(sprintf("ADF sur residus : tau = %.3f | cv(1/5/10%%) = %s\n",
            adf_res@teststat[1], paste(adf_res@cval[1, ], collapse = " / ")))
cat("(Si tau < valeur critique de cointegration -> residus I(0) -> cointegration)\n")
cat("NB: valeurs critiques d'Engle-Granger specifiques (Phillips-Ouliaris) ci-dessous.\n")
po <- ca.po(Y, demean = "constant", type = "Pz")
print(summary(po)@teststat); print(po@cval)

## =====================================================================
## (b) JOHANSEN a 3 variables : lFR, lDE, lGAS  -> QUESTION 1
## =====================================================================
cat("\n=====================================================\n")
cat(" (b) JOHANSEN 3 variables (lFR, lDE, lGAS)\n")
cat("=====================================================\n")
# ecdet='const' : constante dans la relation de cointegration
joh_trace <- ca.jo(Y, type = "trace",  ecdet = "const", K = K, spec = "transitory", dumvar = dums)
joh_eigen <- ca.jo(Y, type = "eigen",  ecdet = "const", K = K, spec = "transitory", dumvar = dums)
cat("\n--- Test de la TRACE ---\n");            print(summary(joh_trace)@teststat); print(joh_trace@cval)
cat("\n--- Test de la valeur propre MAX ---\n"); print(summary(joh_eigen)@teststat); print(joh_eigen@cval)

cat("\n--- Vecteur(s) de cointegration normalise(s) (beta) ---\n")
print(round(cbind(joh_trace@V), 4))
cat("\n--- Coefficients d'ajustement (alpha) ---\n")
print(round(cbind(joh_trace@W), 4))

## =====================================================================
## (c) JOHANSEN bivarie : lFR, lDE -> QUESTION 2 (couplage FR/DE)
## =====================================================================
cat("\n=====================================================\n")
cat(" (c) JOHANSEN bivarie (lFR, lDE) - couplage des marches\n")
cat("=====================================================\n")
Y2 <- as.matrix(df[, c("lFR", "lDE")])
joh2 <- ca.jo(Y2, type = "trace", ecdet = "const", K = K, spec = "transitory", dumvar = dums)
print(summary(joh2)@teststat); print(joh2@cval)
cat("\nRelation FR/DE normalisee (beta) :\n"); print(round(joh2@V, 4))

cat("\nEtape 3 terminee.\n")
