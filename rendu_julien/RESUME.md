# Projet économétrie ENM — résumé

Étude des relations d'équilibre entre les prix day-ahead de l'électricité
**France**, **Allemagne** et le prix du gaz **TTF**.

## Données
- Source : prix élec européens (xlsx) + gaz TTF (xls), fusionnés par date.
- Échantillon = **jours ouvrés où les 3 prix existent** (le gaz, coté seulement
  en semaine, impose son calendrier). Prix en **log** (coefficients = élasticités).
- 1 prix allemand négatif (21/04/2020, surproduction Covid) supprimé.

### Sous-échantillons (analyse de robustesse)
| Échantillon | Période | Obs |
|---|---|---|
| **Complet** | 02/01/2015 → 06/03/2026 | 2 825 |
| **P1** | 2015 → 2019 (avant Covid/crise) | 1 264 |
| **P2** | juin 2020 → 2026 (après le creux Covid) | 1 459 |

Le creux Covid (jan–mai 2020, 102 obs) est **exclu** : on coupe la série en deux
régimes propres plutôt que de mélanger un épisode atypique.

## Démarche (scripts)
| Script | Étape |
|---|---|
| `01-Donnees.R` | Lecture, nettoyage, découpage → 3 CSV (complet, P1, P2) |
| `02-Visualisation.R` | Graphique des 3 séries en log |
| `03-tests-unitaires.R` | Moyenne/variance + racine unitaire ADF + KPSS (échantillon complet) |
| `04-Cointegration.R` | Cointégration Engle-Granger 3 variables (Q1), par période |
| `05-FR_et_DE.R` | Cointégration bivariée FR-DE (Q2), par période |
| `06-Dynamique_prix.R` | Modèle à correction d'erreur (Q3), par période |

## Ordre d'intégration (étape 03, échantillon complet)
- Moyenne et variance par année nettement instables → non-stationnarité.
- **KPSS** rejette la stationnarité pour **les 3 séries** ; **ADF** rejette la
  racine unitaire pour l'élec FR/DE (forte **réversion quotidienne** d'un bien
  non stockable) mais pas pour le gaz.
- Conflit ADF/KPSS assumé → **toutes les séries traitées I(1)** (KPSS + merit
  order + co-mouvement). Différences premières stationnaires → I(1).

## Résultats par question et par période

### Q1 — Équilibre entre les 3 prix (Engle-Granger : `lFR ~ lGaz + lDE`)
| Échantillon | Relation de long terme | τ (résidus) | cv 5 % | Verdict |
|---|---|---|---|---|
| Complet | lFR = 0,62 + **0,298**·lGaz + **0,618**·lDE | −13,87 | −3,74 | **COINT** |
| P1 | lFR = 0,11 + **0,374**·lGaz + **0,719**·lDE | −11,06 | −3,74 | **COINT** |
| P2 | lFR = −0,03 + **0,248**·lGaz + **0,784**·lDE | −10,63 | −3,74 | **COINT** |

→ **Cointégration dans tous les cas** : l'équilibre des 3 prix est **robuste**.

### Q2 — Couplage FR ↔ DE (Engle-Granger : `lFR ~ lDE`)
| Échantillon | Élasticité FR/DE | τ (résidus) | cv 5 % | Verdict |
|---|---|---|---|---|
| Complet | **0,885** | −14,51 | −3,34 | **COINT** |
| P1 | **0,854** | −11,02 | −3,34 | **COINT** |
| P2 | **1,025** | −11,55 | −3,34 | **COINT** |

→ Couplage **confirmé partout**, et **resserré après 2020** (élasticité ~1:1).

### Q3 — Dynamique (ECM : vitesse d'ajustement λ + court terme)
| Échantillon | λ France | λ Allemagne | λ Gaz | Rappel ECM France |
|---|---|---|---|---|
| Complet | −0,17 (s'ajuste) | +0,06 (s'ajuste) | ≈0 **n.s.** | −0,20 |
| P1 | −0,15 (s'ajuste) | +0,19 (s'ajuste) | ≈0 **n.s.** | −0,22 |
| P2 | −0,16 (s'ajuste) | +0,10 (s'ajuste) | ≈0 **n.s.** | −0,21 |

(λ gaz non significatif partout ; λ Allemagne positif = stabilisant car le DE
entre avec un signe négatif dans la relation d'équilibre.)

→ **Le gaz mène (exogène) sur les 3 échantillons** ; l'électricité s'ajuste
(~15-17 %/jour pour la France). Conclusion **stable**.

## Comparaison des périodes — ce qui change
- **Couplage FR-DE renforcé après 2020** : élasticité de long terme 0,85 → **1,03**
  et co-mouvement de court terme (dlDE dans l'ECM France) 0,43 → **0,54**.
- **Effet direct du gaz affaibli en P2** : son élasticité de long terme baisse
  (0,37 → 0,25) et sa variation **quotidienne** n'agit plus significativement sur
  la France (significative en P1, p=0,0006 ; non significative en P2). Le gaz reste
  le moteur via le **long terme**, mais l'influence passe de plus en plus par le
  **marché couplé** plutôt que par le choc journalier brut.
- **Mécanismes inchangés** : cointégration, hiérarchie (gaz mène / élec suit) et
  vitesse de rappel (~20 %/jour) sont **stables** dans tous les régimes.

## Conclusion
Les trois prix sont liés par un **équilibre de long terme robuste** (merit order +
couplage de marché), valable avant comme après le choc Covid/crise. Le **gaz**
pilote le niveau ; l'**électricité** s'ajuste vite ; les marchés **FR et DE** sont
intégrés, et de **plus en plus** (quasi 1:1) sur la période récente.

## Limites
- Conflit ADF/KPSS (séries traitées I(1) par choix justifié).
- Engle-Granger : une seule relation de cointégration testée (Johansen donnerait
  le nombre exact de relations).
- Découpage Covid : la coupure jan–mai 2020 est un choix ; un modèle à dummies
  sur échantillon complet donnerait une alternative.
