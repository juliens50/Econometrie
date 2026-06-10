# =====================================================================
# Projet Econometrie ENM 2025-2026
# Etape 5 : diagnostics du modele (validation des residus)
#   - autocorrelation (Portmanteau / Breusch-Godfrey)
#   - normalite (Jarque-Bera multivarie)
#   - heteroscedasticite (ARCH multivarie)
#   - stabilite (racines du polynome caracteristique)
# =====================================================================

suppressMessages({ library(urca); library(vars) })

racine <- "/Users/julien/Documents/IFP/Econometrie/Projet_Econometrie_ENM_2025-2026"
out <- file.path(racine, "rendu")
df <- read.csv(file.path(out, "echantillon_commun_R.csv"))

Y    <- as.matrix(df[, c("lFR", "lDE", "lGAS")])
dums <- as.matrix(df[, c("crise", "covid")])
K <- 3

# Representation VAR en niveau (memes dynamiques que le VECM)
varlevel <- VAR(Y, p = K, type = "const", exogen = dums)

## ---- 1. Autocorrelation des residus ---------------------------------
cat("=====================================================\n")
cat(" 1. AUTOCORRELATION (Portmanteau ajuste, H0 = absence)\n")
cat("=====================================================\n")
pt <- serial.test(varlevel, lags.pt = 16, type = "PT.adjusted")
print(pt$serial)

## ---- 2. Normalite ----------------------------------------------------
cat("\n=====================================================\n")
cat(" 2. NORMALITE (Jarque-Bera multivarie, H0 = normalite)\n")
cat("=====================================================\n")
nt <- normality.test(varlevel)
print(nt$jb.mul$JB)

## ---- 3. Heteroscedasticite ------------------------------------------
cat("\n=====================================================\n")
cat(" 3. ARCH multivarie (H0 = homoscedasticite)\n")
cat("=====================================================\n")
at <- arch.test(varlevel, lags.multi = 5)
print(at$arch.mul)

## ---- 4. Stabilite ----------------------------------------------------
cat("\n=====================================================\n")
cat(" 4. STABILITE (modules des racines ; <1 = stable)\n")
cat("=====================================================\n")
rt <- roots(varlevel)
cat("Module des 6 plus grandes racines :\n")
print(round(head(sort(rt, decreasing = TRUE), 6), 4))

cat("\nLecture : pour des prix energetiques quotidiens, la non-normalite\n")
cat("et les effets ARCH (volatilite groupee) sont attendus et n'invalident\n")
cat("pas les estimateurs (consistants) ; a signaler comme limite.\n")
cat("\nEtape 5 terminee.\n")
