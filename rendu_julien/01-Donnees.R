library(readxl)

racine  <- "/Users/julien/Documents/IFP/Econometrie/Projet_Econometrie_ENM_2025-2026"
fichier <- file.path(racine, "rendu_julien", "Data.xlsx")

brut <- read_excel(fichier, sheet = "DATA FINALES", skip = 3, col_names = FALSE)

df <- data.frame(
  Date = brut[[7]],
  FR = as.numeric(brut[[3]]),
  DE = as.numeric(brut[[6]]),
  Gaz = as.numeric(brut[[8]])
)

df$Date <- as.Date(df$Date)

df <- df[df$FR > 0 & df$DE > 0 & df$Gaz > 0, ]

write.csv(df, file.path(racine, "rendu_julien", "donnees_propres.csv"), row.names = FALSE)
cat("-> donnees_propres.csv ecrit\n")