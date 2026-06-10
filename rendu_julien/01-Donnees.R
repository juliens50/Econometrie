# ============================================================
# Etape 1 : lecture, nettoyage et decoupage en sous-echantillons
#   - Complet : 2015-2026
#   - P1      : 2015 -> 2019 (avant COVID)
#   - P2      : juin 2020 -> 2026 (apres le creux COVID)
#   (le creux COVID jan-mai 2020 est volontairement exclu)
# ============================================================
library(readxl)

racine  <- "/Users/julien/Documents/IFP/Econometrie/Projet_Econometrie_ENM_2025-2026"
fichier <- file.path(racine, "rendu_julien", "Data.xlsx")
out     <- file.path(racine, "rendu_julien")

brut <- read_excel(fichier, sheet = "DATA FINALES", skip = 3, col_names = FALSE)

# Colonnes utiles : 3 = France | 6 = Allemagne | 7 = Date | 8 = Gaz
df <- data.frame(
  Date = brut[[7]],
  FR  = as.numeric(brut[[3]]),
  DE  = as.numeric(brut[[6]]),
  Gaz = as.numeric(brut[[8]])
)
df$Date <- as.Date(df$Date)

# Suppression des prix <= 0 (le 21/04/2020 notamment), necessaire au log
df <- df[df$FR > 0 & df$DE > 0 & df$Gaz > 0, ]
cat("Echantillon complet :", nrow(df), "lignes\n")

# --- Decoupage en sous-periodes ---
P1 <- df[df$Date <= as.Date("2019-12-31"), ]
P2 <- df[df$Date >= as.Date("2020-06-01"), ]
cat("P1 (2015-2019)      :", nrow(P1), "lignes\n")
cat("P2 (2020.6-2026)    :", nrow(P2), "lignes\n")
cat("Exclu (COVID jan-mai 2020) :", nrow(df) - nrow(P1) - nrow(P2), "lignes\n")

# --- Sauvegardes ---
write.csv(df, file.path(out, "donnees_propres.csv"),    row.names = FALSE)
write.csv(P1, file.path(out, "donnees_propres-P1.csv"), row.names = FALSE)
write.csv(P2, file.path(out, "donnees_propres-P2.csv"), row.names = FALSE)
cat("-> 3 fichiers ecrits (complet, P1, P2)\n")
