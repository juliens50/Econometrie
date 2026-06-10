# Projet économétrie ENM — résumé

Étude des relations d'équilibre entre les prix day-ahead de l'électricité
**France**, **Allemagne** et le prix du gaz **TTF**.

## Données
- Source : prix élec européens (xlsx) + gaz TTF (xls), fusionnés par date.
- Échantillon commun = **jours ouvrés où les 3 prix existent** : **2 825 obs**, du 02/01/2015 au 06/03/2026.
- 1 prix allemand négatif (21/04/2020, surproduction Covid) supprimé.
- Toutes les séries en **log** (→ coefficients = élasticités ; merit order devient linéaire).

## Démarche (scripts)
| Script | Étape |
|---|---|
| `01-Donnees.R` | Lecture, nettoyage, échantillon commun → `donnees_propres.csv` |
| `02-Visualisation.R` | Graphique des 3 séries en log (`fig1_series_log.png`) |
| `03-tests-unitaires.R` | Racine unitaire : ADF + KPSS (niveaux et différences) |
| `04-Cointegration.R` | Cointégration Engle-Granger à 3 variables (Q1) |
| `05-FR_et_DE.R` | Cointégration bivariée FR-DE (Q2) |
| `06-Dynamique_prix.R` | Modèle à correction d'erreur — dynamique (Q3) |

## Résultats

### Ordre d'intégration (étape 03)
- **Gaz : I(1)** (ADF et KPSS d'accord).
- **Élec FR / DE** : conflit ADF (stationnaire) vs KPSS (non stationnaire) →
  **retenues I(1)** (KPSS + merit order + co-mouvement ; l'ADF capte la
  réversion quotidienne d'un bien non stockable). Conflit documenté en limite.
- Les 3 séries sont stationnaires en différence première → **toutes I(1)**.

### Q1 — Équilibre entre les 3 prix → **OUI**
Relation de long terme : `lFR = 0,615 + 0,298·lGaz + 0,618·lDE`.
ADF sur résidus : **τ = −13,87** < −3,74 (5 %) → **cointégration**.

### Q2 — Couplage FR ↔ DE → **OUI**
Relation : `lFR = 0,480 + 0,885·lDE` (élasticité ~1 → marchés couplés).
ADF sur résidus : **τ = −14,51** < −3,34 (5 %) → **cointégration**.

### Q3 — Dynamique → **le gaz mène, l'élec s'ajuste**
Vitesses d'ajustement (λ sur l'écart à l'équilibre retardé) :
- **Gaz** : λ ≈ 0, non significatif → **faiblement exogène = moteur**.
- **France** : λ = −0,17 (signif.) → s'ajuste vite, **~17 %/jour**.
- **Allemagne** : λ = +0,06 (signif., signe stabilisant) → s'ajuste **~6 %/jour**.

ECM France : rappel à l'équilibre **−20 %/jour** ; co-mouvement court terme
fort avec l'Allemagne (+0,50 % pour +1 % DE le jour même) ; la variation
**quotidienne** du gaz n'a pas d'effet immédiat significatif (son influence
passe par le long terme et via l'Allemagne).

## Conclusion
Les trois prix sont liés par un **équilibre de long terme** (merit order +
couplage de marché). Le **gaz** est le fondamental qui pilote le niveau ;
l'**électricité** s'ajuste rapidement, et les marchés **FR et DE** sont
intégrés quasi 1:1.

## Limites
- Conflit ADF/KPSS sur l'électricité (traitée I(1) par choix justifié).
- Engle-Granger : une seule relation de cointégration testée (Johansen
  donnerait le nombre exact de relations).
