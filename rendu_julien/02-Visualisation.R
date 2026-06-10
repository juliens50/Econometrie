racine <- "/Users/julien/Documents/IFP/Econometrie/Projet_Econometrie_ENM_2025-2026"
out <- file.path(racine, "rendu_julien")

df <- read.csv(file.path(out, "donnees_propres.csv"))
df$Date <- as.Date(df$Date)

# Colonnes en log
df$lFR  <- log(df$FR)
df$lDE  <- log(df$DE)
df$lGaz <- log(df$Gaz)

# Graphique des 3 prix en log
png(file.path(out, "fig1_series_log.png"), width = 1100, height = 550)
plot(df$Date, df$lFR, type = "l", col = "blue",
      xlab = "Date", ylab = "log(prix)",
      main = "Prix en log : France, Allemagne, Gaz (2015-2026)",
      ylim = range(c(df$lFR, df$lDE, df$lGaz)))
lines(df$Date, df$lDE,  col = "red")
lines(df$Date, df$lGaz, col = "darkgreen", lwd = 1.5)
legend("topleft", c("Elec France", "Elec Allemagne", "Gaz TTF"),
        col = c("blue", "red", "darkgreen"), lwd = 2, bty = "n")
dev.off()
cat("-> fig1_series_log.png ecrit\n")

