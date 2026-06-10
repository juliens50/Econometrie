# =====================================================================
# Projet Econometrie ENM 2025-2026
# Relation d'equilibre prix elec FR / DE (day-ahead) et gaz TTF
# Etape 1 : construction de l'echantillon, descriptives, graphiques
# =====================================================================

## ---- 0. Packages -----------------------------------------------------
need <- c("readxl", "dplyr", "tidyr", "ggplot2", "lubridate")
for (p in need) if (!requireNamespace(p, quietly = TRUE))
  install.packages(p, repos = "https://cloud.r-project.org")
invisible(lapply(need, library, character.only = TRUE))

# Donnees sources a la racine du projet ; sorties dans le sous-dossier rendu/
racine <- "/Users/julien/Documents/IFP/Econometrie/Projet_Econometrie_ENM_2025-2026"
setwd(racine)
out <- file.path(racine, "rendu")  # dossier de sortie

## ---- 1. Lecture des donnees -----------------------------------------
# Electricite : fichier long (une ligne par pays x date)
elec <- read_excel("european_wholesale_electricity_price_data_daily.xlsx")
names(elec) <- c("Country", "ISO3", "Date", "Price")
elec$Date <- as.Date(elec$Date)

fr <- elec %>% filter(Country == "France")  %>% select(Date, FR = Price)
de <- elec %>% filter(Country == "Germany") %>% select(Date, DE = Price)

# Gaz TTF : entete sur 2 lignes, donnees a partir de la 3e
gas <- read_excel("Gas_price_2015-2026.xls", skip = 2,
                  col_names = c("Date", "GAS"))
gas$Date <- as.Date(gas$Date)
gas <- gas %>% filter(!is.na(Date))

## ---- 2. Echantillon commun (jointure interne sur la date) -----------
# Le gaz ne cote pas le week-end / jours feries -> on garde l'intersection
df <- fr %>%
  inner_join(de, by = "Date") %>%
  inner_join(gas, by = "Date") %>%
  arrange(Date)

cat("Echantillon commun :", nrow(df), "obs du",
    format(min(df$Date)), "au", format(max(df$Date)), "\n")

## ---- 3. Transformation log ------------------------------------------
# 1 valeur negative en DE (prix negatif, surplus renouvelable).
# On la ramene a un petit seuil positif pour permettre le passage au log.
seuil <- 0.5
df <- df %>% mutate(
  FR_adj = pmax(FR, seuil),
  DE_adj = pmax(DE, seuil),
  GAS_adj = pmax(GAS, seuil),
  lFR = log(FR_adj),
  lDE = log(DE_adj),
  lGAS = log(GAS_adj)
)

## ---- 4. Variables muettes de crise ----------------------------------
# Crise energetique : flambee du gaz mi-2021 -> detente courant 2023.
df <- df %>% mutate(
  # Crise energetique : flambee du gaz mi-2021 -> detente courant 2023
  crise = as.integer(Date >= as.Date("2021-07-01") &
                     Date <= as.Date("2023-06-30")),
  # Choc COVID : effondrement de la demande au 1er confinement (printemps 2020)
  covid = as.integer(Date >= as.Date("2020-03-01") &
                     Date <= as.Date("2020-05-31"))
)

write.csv(df, file.path(out, "echantillon_commun_R.csv"), row.names = FALSE)

## ---- 5. Statistiques descriptives -----------------------------------
desc <- df %>% select(FR, DE, GAS) %>%
  summarise(across(everything(),
    list(moy = mean, ecart = sd, min = min, med = median, max = max)))
print(round(t(desc), 2))

cat("\nCorrelations (niveaux):\n");  print(round(cor(df[, c("FR","DE","GAS")]), 3))
cat("\nCorrelations (logs):\n");     print(round(cor(df[, c("lFR","lDE","lGAS")]), 3))

## ---- 6. Graphiques ---------------------------------------------------
long <- df %>% select(Date, FR, DE, GAS) %>%
  pivot_longer(-Date, names_to = "serie", values_to = "prix")

p1 <- ggplot(long, aes(Date, prix, colour = serie)) +
  geom_line(linewidth = .3) +
  labs(title = "Prix day-ahead : electricite FR/DE et gaz TTF (niveaux)",
       y = "EUR/MWh", x = NULL, colour = NULL) +
  theme_minimal()
ggsave(file.path(out, "fig1_niveaux.png"), p1, width = 10, height = 5, dpi = 120)

longl <- df %>% select(Date, lFR, lDE, lGAS) %>%
  pivot_longer(-Date, names_to = "serie", values_to = "logprix")
p2 <- ggplot(longl, aes(Date, logprix, colour = serie)) +
  geom_line(linewidth = .3) +
  labs(title = "Prix en logarithme", y = "log(EUR/MWh)", x = NULL, colour = NULL) +
  theme_minimal()
ggsave(file.path(out, "fig2_logs.png"), p2, width = 10, height = 5, dpi = 120)

cat("\nGraphiques sauvegardes : fig1_niveaux.png, fig2_logs.png\n")
cat("Etape 1 terminee.\n")
