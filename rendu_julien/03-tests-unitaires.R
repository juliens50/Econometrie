library(urca)

racine <- "/Users/julien/Documents/IFP/Econometrie/Projet_Econometrie_ENM_2025-2026"
out <- file.path(racine, "rendu_julien")

df <- read.csv(file.path(out, "donnees_propres.csv"))
df$lFR  <- log(df$FR)
df$lDE  <- log(df$DE)
df$lGaz <- log(df$Gaz)

# moyenne et variance non constantes ?
df$annee <- format(as.Date(df$Date), "%Y")

cat("===== Moyenne et ecart-type par annee (log des prix) =====\n")
for (v in c("lFR", "lDE", "lGaz")) {
  m <- tapply(df[[v]], df$annee, mean)   # moyenne par annee
  s <- tapply(df[[v]], df$annee, sd)     # ecart-type par annee
  cat("\n---", v, "---\n")
  print(round(rbind(moyenne = m, ecart_type = s), 2))
}

# Tests Unitaires : ADF + KPSS
series <- list(lFR = df$lFR, lDE = df$lDE, lGaz = df$lGaz)

# --- Helper ADF : H0 = racine unitaire (I(1)) ---
adf_line <- function(x, type, nom) {
  t    <- ur.df(x, type = type, selectlags = "AIC")
  stat <- t@teststat[1]
  cv5  <- t@cval[1, "5pct"]
  concl <- ifelse(stat < cv5, "STATIONNAIRE", "racine unitaire (I(1))")
  sprintf("ADF[%-5s] %-5s : tau = %7.3f | cv5%% = %7.3f -> %s",
          type, nom, stat, cv5, concl)
}

# --- Helper KPSS : H0 = stationnaire (inverse d'ADF) ---
kpss_line <- function(x, nom) {
  k    <- ur.kpss(x, type = "mu")
  stat <- k@teststat
  cv5  <- k@cval[1, "5pct"]
  concl <- ifelse(stat > cv5, "NON stationnaire", "stationnaire")
  sprintf("KPSS        %-5s : LM  = %7.3f | cv5%% = %7.3f -> %s",
          nom, stat, cv5, concl)
}

# ----------------- NIVEAUX -----------------
cat("\n================ NIVEAUX (log des prix) ================\n")
for (n in names(series)) {
  cat(adf_line(series[[n]], "drift", n), "\n")  
  cat(adf_line(series[[n]], "trend", n), "\n") 
  cat(kpss_line(series[[n]], n), "\n")
  cat("--------------------------------------------------------\n")}


cat("\n========== DIFFERENCES PREMIERES (variations) ==========\n")
for (n in names(series)) {
  dx <- diff(series[[n]])
  cat(adf_line(dx, "drift", paste0("d.", n)), "\n")
  cat(kpss_line(dx, paste0("d.", n)), "\n")
  cat("--------------------------------------------------------\n")
}

# On valide, toutes nos données sont I(1) condition nécessaire mais pas suffisante pour qu'il y est un équilibre de long terme
