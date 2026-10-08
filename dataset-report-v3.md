# Football Intelligence App — Dataset & ML System Report

> **Project direction:** Football Player Intelligence / Scouting Analytics  
> **Primary goal:** Build a real usable football-data application, not a technology showcase.  
> **V1 principle:** Data quality → entity resolution → useful product feature → ML → API → LLM layer.  
> **Current priority:** **Audit the actual dataset coverage before training any model.**

---

## 1. Executive Summary

The original plan mixed three different problems:

1. **Player intelligence / scouting**
2. **Market-value prediction**
3. **Match prediction / betting / CLV**

These should not be treated as one ML problem.

For the current project, the recommended direction is:

```text
Football data
    ↓
Entity resolution
    ↓
Canonical football data model
    ↓
Player / team features
    ↓
┌───────────────────────────────────────┐
│                                       │
│  Player Search                        │
│  Player Similarity                    │
│  Player Replacement / Scouting        │
│  League Analytics                     │
│  Market Value Prediction (experiment) │
│                                       │
└───────────────────────────────────────┘
    ↓
FastAPI
    ↓
Frontend / App
    ↓
Optional LLM Football Analyst
```

The most important change is that **market-value prediction is no longer the product's single V1 objective**.

The first question is not:

> "Which model should I train?"

It is:

> **"Do my sources contain enough consistent player-season/player-match data to support the product I want to build?"**

Therefore, **Data Audit is Phase 0**.

---

# 2. Product Goal

## 2.1 What is the end product?

The primary deliverable is a **portfolio-quality football intelligence application** that is designed as a realistic product, even if it is initially used by the developer rather than by paying customers.

There are therefore two success criteria:

### Product criterion

A real user should be able to perform a useful scouting/analysis task:

```text
search player
→ inspect profile
→ compare players
→ find similar players
→ find replacement candidates
→ inspect team/league context
```

### Portfolio criterion

The system should demonstrate Senior/Fresher+ Data/ML engineering competence:

```text
data ingestion
→ entity resolution
→ data quality
→ feature engineering
→ leakage-safe ML
→ evaluation
→ API
→ usable frontend
```

Do not claim that the application has validated commercial value unless it is actually tested with external users.

## 2.2 Core product

The application should behave as a lightweight football intelligence/scouting platform.

A user should be able to:

- search for a player;
- inspect player performance;
- find similar players;
- search for replacement candidates;
- compare players;
- inspect team/league context;
- optionally ask an LLM questions about the structured football data.

Example:

```text
User:
"Find me players similar to Bukayo Saka,
age < 24, playing in leagues outside the Premier League,
and show the best 10 alternatives."

        ↓

Search / filters
        ↓

Feature store
        ↓

Player similarity / ranking
        ↓

Candidate players
        ↓

FastAPI
        ↓

Frontend
```

This gives the user visible product value without requiring an unreliable market-value prediction model.

---

# 3. What Is NOT the V1 Goal

Do not combine all of the following into the first version:

```text
Player similarity
+ transfer prediction
+ market value prediction
+ match prediction
+ betting
+ CLV
+ league simulation
+ RAG
+ LLM fine-tuning
+ pgvector
+ MLflow
+ DVC
+ LiteLLM
+ real-time data
```

That creates a large technology stack before the data has been validated.

The project should instead grow incrementally.

---

# 4. Product Roadmap

## V1 — Player Intelligence

```text
Player Search
    ↓
Player Profile
    ↓
Player Similarity
    ↓
Replacement Search
```

Primary value:

- searchable player database;
- player comparison;
- similar-player recommendations;
- scouting filters.

---

## V1.5 — League / Team Analytics

Add:

- league table;
- team form;
- fixtures/results;
- team strength;
- basic league comparison;
- player/team aggregates.

Potential future features:

- Elo;
- Poisson-based goal modelling;
- season simulation.

These are separate from player similarity and should not block V1.

---

## V2 — Market Value Experiment

Predict:

```text
current-season information
        ↓
next-season Transfermarkt market-value estimate
```

This is a supervised ML experiment.

It should be treated as:

> **Prediction of a market-value estimate**

not:

> "prediction of the true economic value of a player."

---

## V3 — LLM Football Analyst

Only after the structured system works:

```text
User
 ↓
LLM
 ↓
structured tool call
 ↓
FastAPI
 ↓
ML / feature layer
 ↓
JSON
 ↓
LLM explanation
 ↓
User
```

The LLM should explain/query the football system, not replace the numerical model.

---

# 4.5 Decision Thresholds for the Data Audit

The audit must end in a decision, not just a spreadsheet.

The following are **project thresholds**, not universal industry standards. They are intentionally conservative enough to prevent building a model on a tiny or badly joined dataset.

## 4.5.1 Core GO / NO-GO thresholds

### Player-season coverage

For the initial market-value experiment:

```text
GO:
≥ 5,000 usable player-season rows
with the required performance + target fields

WARNING:
2,000–4,999 usable rows

NO-GO:
< 2,000 usable rows
```

If the number is below 2,000:

```text
do not build the final model
→ expand historical coverage
→ add another compatible performance source
→ or reduce the modelling claim
```

### High-minute coverage

For robust season-level player modelling:

```text
Target:
≥ 3,000 player-seasons with ≥ 900 minutes
```

If fewer than:

```text
2,000 player-seasons ≥ 900 minutes
```

then the similarity/model population is considered too thin for broad multi-league claims.

The 900-minute threshold is a modelling policy, not a statement that players below 900 minutes are useless. Low-minute players can still be shown in the app, but their similarity should carry a lower confidence indicator.

### Entity-resolution rate

For players required by the core dataset:

```text
GO:
≥ 95% automatic/verified match rate

WARNING:
90–94.9%

NO-GO:
< 90%
```

For a critical target subset (players with market value + performance data), aim for:

```text
≥ 97%
```

If below 90%, stop feature engineering and improve identity resolution or change source.

### Feature completeness

For the V1 similarity feature set:

```text
GO:
≥ 90% non-null coverage for required features
on the intended player population

WARNING:
80–89.9%

NO-GO:
< 80%
```

Do not fill structural missingness with arbitrary zeroes.

### Current-season coverage

For each V1 supported competition:

```text
GO:
≥ 95% fixture coverage
and
≥ 90% player-stat coverage
for the required fields

WARNING:
80–89.9% player-stat coverage

NO-GO:
< 80% player-stat coverage
```

If the provider fails this test, do not advertise that competition as fully supported.

## 4.5.2 Similarity evaluation threshold

A similarity model needs an internal test set before it can be called useful.

Build a small benchmark of:

```text
50–100 anchor players
```

For each anchor, define:

```text
2–5 expected similar players
```

using one of:

- same role/position;
- same tactical role;
- same player archetype;
- known public comparisons from reputable football analysis.

This is not a perfect ground truth. It is a **weak benchmark** designed to detect obviously bad embeddings.

Measure:

```text
Precision@5
Recall@10
MRR
```

For the initial baseline, set:

```text
GO:
Precision@5 ≥ 0.50

WARNING:
0.35–0.49

NO-GO:
< 0.35
```

Do not claim "the model understands football similarity" from this benchmark. It only establishes whether the system is directionally useful.

## 4.5.3 Market-value model threshold

The first baseline is:

```text
next_value = current_value
```

The ML model must beat it on the untouched temporal test set.

Recommended decision rule:

```text
GO:
≥ 10% relative MAE improvement over current-value baseline

WARNING:
0–9.9%

NO-GO:
≤ 0%
```

If the model does not beat the baseline, keep the experiment as a negative/diagnostic result rather than forcing a model into the app.

## 4.5.4 Threshold philosophy

These thresholds should be configurable in:

```text
configs/data_quality.yaml
```

Example:

```yaml
entity_resolution:
  go: 0.95
  no_go: 0.90

player_season_rows:
  go: 5000
  no_go: 2000

player_seasons_900min:
  go: 3000
  no_go: 2000

similarity_precision_at_5:
  go: 0.50
  no_go: 0.35

market_value_relative_mae_improvement:
  go: 0.10
  no_go: 0.00
```

The numbers can be revised after the first audit, but **the revision itself must be documented**.

# 5. Phase 0 — Data Audit

This is the first implementation phase.

Before writing a LightGBM model, measure the actual data.

## 5.1 Required audit questions

For every source:

| Question | Metric |
|---|---|
| How many players? | unique player count |
| How many teams? | unique team count |
| How many competitions? | unique competition count |
| How many seasons? | season coverage |
| How many matches? | match count |
| How many player-seasons? | actual player-season coverage |
| How many player-matches? | actual player-match coverage |
| How many have market value? | target coverage |
| How many have minutes? | sample-size coverage |
| How many have advanced stats? | feature coverage |
| How many players match across sources? | entity-resolution rate |
| How many player-seasons have all required features? | usable training rows |
| How many have next-season target? | label coverage |

The most important table is:

```text
source A
    +
source B
    +
source C
    ↓
player identity resolution
    ↓
player × season
    ↓
complete rows
```

---

## 5.2 Coverage report

Create a table such as:

| Source | Seasons | Competitions | Players | Player-Seasons | Advanced Stats | Market Value |
|---|---:|---:|---:|---:|---|---|
| Transfermarkt | ? | ? | ? | ? | Basic | Yes |
| StatsBomb | ? | ? | ? | ? | Event-level | No |
| Kaggle Events | ? | ? | ? | ? | Event-derived | No |
| European Soccer DB | ? | ? | ? | ? | Limited | No |
| FBref | ? | ? | ? | ? | Depending on current availability | No |
| The Analyst | ? | ? | ? | ? | Advanced | No |

Do not fill these values from assumptions.

They must come from the actual downloaded datasets.

---

# 6. Data Sources

## 6.1 Transfermarkt — Core Source

Primary uses:

- player identity;
- teams;
- competitions;
- transfers;
- historical/current market-value information;
- basic player information;
- career/club history.

Transfermarkt is particularly useful because the product needs a football entity layer.

### Important limitation

Transfermarkt market value is an **estimated market-value measure**, not a transaction price and not ground-truth player value.

Therefore:

```text
Transfermarkt MV
≠
actual transfer fee
≠
true economic value
```

The ML target should be named carefully:

```text
next_season_market_value_estimate
```

rather than:

```text
true_player_value
```

### Data-access warning

Do not assume that scraping is automatically acceptable.

Before building a scraper:

1. inspect the current Terms of Service;
2. check whether an official/licensed access method exists;
3. inspect existing community datasets;
4. inspect their licenses and update frequency;
5. document provenance.

A community dataset can be useful, but its license and freshness must be verified before using it as the production source.

---

# 6.5 Transfermarkt Data-Access Action Plan

"Check the Terms of Service" is not enough. The project should make an explicit data-access decision.

Before ingestion:

1. Open the current Transfermarkt Terms of Service / robots/access policies.
2. Determine whether automated collection is permitted for the intended use.
3. Record the relevant URL, access date and conclusion in:
   ```text
   reports/source_provenance.md
   ```
4. Search for an official/licensed API or dataset option.
5. Evaluate community datasets such as `transfermarkt-datasets` for:
   - license;
   - source provenance;
   - update date;
   - player/team ID stability;
   - historical market-value coverage.
6. If a community dataset is used, retain its original version/snapshot.
7. Do not build the project around proxy rotation, CAPTCHA bypasses or methods intended to defeat access controls.

## Decision tree

```text
Can we obtain the required Transfermarkt-derived data
under acceptable terms?
        │
       YES
        ↓
Use the permitted/licensed dataset
        │
       NO
        ↓
Can a community dataset with acceptable license/provenance
provide the required historical fields?
        │
   ┌────┴────┐
  YES        NO
   ↓          ↓
Use it     Remove TM dependency
           or reduce product claim
```

The project must remain useful if Transfermarkt data is unavailable.

For example:

```text
Player Intelligence V1
→ performance + context

Market-value experiment
→ only when a legally usable target dataset exists
```

# 7. StatsBomb Open Data

Potential role:

- event-level football data;
- passes;
- shots;
- carries;
- pressure;
- locations;
- player actions;
- event-derived performance features.

StatsBomb Open Data is useful for demonstrating event-level football analytics.

## Critical limitation

Open data does **not** represent a complete global football database.

Coverage varies by:

- competition;
- season;
- men's/women's football;
- tournament;
- available match collection.

Therefore:

> Do not assume that StatsBomb Open Data gives complete player-season coverage for every league.

The audit must determine which `player × season` rows are actually available.

Also verify the current repository/location and data-access terms before implementation rather than relying on an old project document.

---

# 7.5 Current-Season Data Strategy

Historical/open datasets are sufficient for research, but they are not enough for a product that claims to show **current-season football information**.

For the current date of this project, the target current season is **2026/27**. The application must therefore separate:

```text
historical research data
        vs
current-season application data
```

## 7.5.1 Recommended strategy

Use a dedicated football-data API for current-season fixtures, squads, player statistics, standings and match updates.

One practical candidate is **Sportmonks Football API**. Its current published plans include player/team statistics, fixtures, standings and current football data. The Starter plan is currently listed at €29/month month-to-month (or €24/month when billed yearly) for 5 leagues; Growth is €99/month for 30 leagues; Pro is €249/month for 120 leagues. It also offers a free tier for testing, while xG/other advanced metrics are available depending on plan/add-ons. citeturn0search1turn0search2

Another practical candidate is **API-Football**. Its current pricing page lists a free plan with 100 requests/day and a Pro plan at $19/month with 7,500 requests/day; the API includes fixtures, standings, player data, transfers, events, lineups and statistics, with historical-season limitations on the free plan. citeturn0search8turn0search10

These are **candidates, not automatic final choices**. Before paying, compare the exact leagues, player-stat fields, historical depth, rate limits, ID stability, terms of use and data licensing against the project's requirements.

## 7.5.2 Cost decision

For a portfolio prototype:

```text
Option A — $0
Use free API tier
+ open/historical datasets
+ limit V1 to supported leagues

Option B — low-cost production-like prototype
Use API-Football Pro
≈ $19/month

Option C — broader scouting prototype
Use Sportmonks Starter
≈ €29/month
5 selected leagues

Option D — multi-league product
Sportmonks Growth / Pro
≈ €99 / €249 per month
```

Prices are current published prices and can change; record the provider pricing page and access date in `source_provenance.md`.

## 7.5.3 Current-season ingestion cadence

The application should distinguish between data types:

| Data | Suggested refresh |
|---|---|
| Fixtures | daily |
| Results | after matches |
| Standings | after matches |
| Player season stats | daily / after matches |
| Match events | after match or near-real-time if required |
| Squad/transfers | daily during transfer windows |
| Injuries | daily if provider supports them |
| Market value | only when a trustworthy snapshot/update is available |

Do not poll an API every few seconds just because it supports live data. V1 does not need live match-centre infrastructure.

## 7.5.4 Current-season data contract

Every current-season record should carry:

```text
source
provider
provider_version
retrieved_at
event_date
season
competition_id
source_player_id
source_team_id
```

For statistics that can change after provider corrections, retain:

```text
retrieved_at
```

so that the application can reproduce what it showed at a given time.

## 7.5.5 Do not mix current and historical data blindly

A safe architecture is:

```text
Historical layer
    ├── Transfermarkt/community datasets
    ├── StatsBomb Open Data
    └── Kaggle

Current-season layer
    └── licensed/current football API

                 ↓

Canonical entities
                 ↓

Unified feature layer
```

The current API becomes the **freshness layer**, not necessarily the only historical source.

## 7.5.6 Provider-selection test

Before committing to a paid provider, run a 1–3 day proof of concept against the exact leagues the app will support.

Measure:

```text
league coverage
player coverage
player-stat completeness
match coverage
ID stability
API latency
rate-limit headroom
data freshness
entity matching rate
cost per required season/league
```

The cheapest API is not necessarily the cheapest solution if its player IDs cannot be joined reliably to the rest of the dataset.

## 7.5.7 Product freshness statement

Until a current-season provider is connected, the application should explicitly say:

> "Historical / research dataset — not a live 2026/27 database."

Do not present stale historical data as current information.

# 8. Kaggle Datasets

Kaggle datasets can be useful for experimentation and historical coverage, but they should be treated as **datasets to audit**, not automatically authoritative sources.

## 8.1 European Soccer Database

Link:

https://www.kaggle.com/datasets/hugomathien/soccer

Useful for:

- historical matches;
- teams;
- players;
- basic player attributes;
- match results;
- historical football modelling experiments.

Potential role:

```text
baseline / historical support dataset
```

Do not assume that its coverage or player attributes are sufficient for the final application.

---

## 8.2 Football Match Events

Link:

https://www.kaggle.com/datasets/secareanualin/football-events

Potential role:

- historical match events;
- event-derived player statistics;
- exploratory modelling.

Important limitation:

The dataset is historical and event data quality/granularity is not equivalent to modern tracking/event providers.

Do not treat it as equivalent to licensed Opta/StatsBomb event data.

---

## 8.3 International Football Results

Link:

https://www.kaggle.com/datasets/martj42/international-football-results-from-28-07-95

Potential role:

- international match history;
- national-team analytics;
- separate international-football experiments.

It is not a core source for club-player scouting.

---

## 8.4 StatsBomb 360 Kaggle Dataset

Link:

https://www.kaggle.com/datasets/statsbomb/statsbomb-360

The original project notes referred to this as "Wyscout Soccer Data", but the linked dataset is StatsBomb 360.

Therefore the documentation must use the actual dataset identity rather than the old label.

Potential role:

- spatial/event analysis;
- 360 contextual data;
- advanced football analytics experiments.

Coverage must be audited before using it for player-season modelling.

---

## 8.5 FBref Dataset

Link:

https://www.kaggle.com/datasets/vivovinco/fbref-2023-24-season

Potential role:

- supplementary player/team statistics;
- season-level football analysis.

However, **current FBref data availability and provider coverage must be verified directly before making FBref a dependency**.

Do not assume an old project document accurately describes the current advanced-stat coverage.

---

# 9. The Analyst

The Analyst can be useful as a reference for:

- football analytics concepts;
- metric definitions;
- tactical/statistical interpretation;
- methodology inspiration.

However:

> Do not make The Analyst a core scraped production data source unless data access/licensing explicitly permits it.

For the application, licensed/open data should be preferred.

The Analyst can be used as:

```text
methodology/reference
```

rather than:

```text
production database
```

---

# 10. Football-Data.co.uk

Link:

https://www.football-data.co.uk/

This source becomes relevant if the project later becomes:

```text
match prediction
+
betting
+
odds modelling
+
CLV
```

It is **not necessary for the current Player Intelligence V1**.

Therefore:

```text
Player Intelligence V1
→ don't add odds just because they exist

Betting / Match Prediction V2+
→ evaluate Football-Data as a dedicated source
```

This keeps the data architecture aligned with the product.

---

# 11. GitHub Football Analytics Repositories

Examples from the original research:

- `schochastics/football-data`
- `an-introduction-to-football-analytics`

These are useful for:

- learning;
- feature engineering ideas;
- methodology;
- schema ideas;
- examples of football analytics workflows.

They should not automatically become production data sources.

Treat them as:

```text
reference / learning
```

not:

```text
authoritative production database
```

---

# 12. Recommended Data Architecture

The canonical data model should separate dimensions, facts, and ML features.

```text
DIMENSIONS
──────────

dim_player
dim_team
dim_competition


FACT TABLES
───────────

fact_player_match
fact_player_season

fact_team_match
fact_team_season

fact_transfer
fact_market_value

fact_event
```

Then:

```text
FACT TABLES
     ↓
FEATURE ENGINEERING
     ↓
ML FEATURE TABLES
```

---

# 13. Player Identity Resolution

This is one of the hardest parts of the project.

Different sources can represent the same player differently:

```text
Source A:
Kevin De Bruyne

Source B:
Kevin De Bruyne

Source C:
K. De Bruyne
```

Names are not reliable primary keys.

The system should create:

```text
canonical_player_id
```

and a mapping table:

```text
player_identity_map
```

Example:

| canonical_player_id | source | source_player_id | source_name |
|---|---|---|---|
| P000001 | transfermarkt | ... | Kevin De Bruyne |
| P000001 | statsbomb | ... | Kevin De Bruyne |
| P000001 | kaggle | ... | K. De Bruyne |

The same concept applies to teams and competitions.

---

# 13.5 Phase 0–2 Time Budget and Fallback Plan

Entity resolution is a known schedule risk.

Do not assume:

```text
source A IDs
+
source B IDs
=
easy join
```

Plan for it explicitly.

## Expected timeline

| Phase | Target | Time budget |
|---|---|---:|
| Source inventory | identify schemas/licensing/coverage | 0.5–1 day |
| Raw ingestion | download + normalize file formats | 0.5–1 day |
| Coverage audit | player-season/player-match counts | 0.5–1 day |
| Initial entity matching | ID/name/DOB/team rules | 1–2 days |
| Manual ambiguity review | inspect difficult matches | 1 day |
| Canonical schema | dimensions/facts | 1 day |
| Feature baseline | first player-season table | 1 day |

Target:

```text
Phase 0–2 ≈ 4–7 focused working days
```

If it exceeds **7 working days without reaching the GO thresholds**, stop expanding the matcher indefinitely.

## Fallback ladder

### Fallback A — Restrict scope

Instead of:

```text
all leagues
```

use:

```text
5–10 well-covered competitions
```

and make the scope explicit.

### Fallback B — Use a single current-season provider

If cross-source entity resolution is the bottleneck:

```text
current API
→ canonical player/team IDs
→ app
```

Use historical datasets separately for research.

### Fallback C — Reduce the feature set

If advanced event features cannot be matched reliably:

```text
basic player stats
+
minutes
+
age
+
position
+
team/competition context
```

can still support V1 search and a basic similarity baseline.

### Fallback D — Abandon a source

If a source repeatedly produces:

```text
< 90% entity resolution
```

or unacceptable missingness, remove it.

Do not keep a bad source merely because it looks sophisticated.

## Stop condition

The project is allowed to proceed with fewer sources if:

```text
canonical IDs are reliable
+
required features are sufficiently complete
+
V1 product works
```

More sources are not automatically better.

# 14. Entity Resolution Strategy

Do not start with fuzzy matching alone.

Recommended hierarchy:

```text
1. Official/source ID
        ↓
2. Stable external ID
        ↓
3. Name + date of birth
        ↓
4. Name + team + season
        ↓
5. Fuzzy matching
        ↓
6. Manual review for ambiguous cases
```

Every automatic match should ideally have:

```text
match_method
match_confidence
review_status
```

Example:

```text
canonical_player_id = P00123
match_method = name_dob
confidence = 0.99
review_status = verified
```

---

# 15. Data Lineage

Every derived dataset should know where it came from.

Recommended metadata:

```text
source
source_version
ingestion_timestamp
data_as_of
season
competition
raw_file
transformation_version
```

This is especially important for market values.

---

# 16. Snapshot Principle

Avoid mixing today's information with historical observations.

Bad:

```text
2020 player-season
+
2026 market value
```

Good:

```text
2020 player-season
+
market value available at the prediction date
```

Every feature should answer:

> **Was this information actually available at prediction time?**

---

# 17. Player-Match Layer

Do not jump directly from raw event data to player-season.

Recommended:

```text
raw event
    ↓
player-match aggregation
    ↓
player-season aggregation
```

Example player-match features:

```text
minutes
goals
assists
shots
xG
xA
passes
progressive passes
progressive carries
pressures
tackles
interceptions
key passes
touches
```

The exact available fields depend on the source.

---

# 18. Player-Season Layer

Aggregate player-match information into:

```text
player × season × competition
```

Potential features:

### Production

```text
goals
assists
xG
xA
shots
shots_on_target
```

### Creation

```text
key_passes
progressive_passes
progressive_carries
shot_creating_actions
```

### Defensive

```text
tackles
interceptions
pressures
recoveries
```

### Usage

```text
minutes
starts
appearances
substitute_appearances
```

---

# 19. Per-90 Is Not Enough

A player with:

```text
3 goals
300 minutes
```

and another with:

```text
15 goals
2500 minutes
```

cannot be compared purely by per-90 statistics.

Therefore include:

```text
raw totals
per-90 values
minutes
starts
appearances
```

Potentially apply minimum-minute thresholds or shrinkage when producing similarity scores.

Example:

```text
minutes < 450
→ low confidence
```

This threshold should be treated as a configurable modelling choice, not a universal truth.

---

# 20. League and Team Context

Raw player statistics cannot always be compared directly across competitions.

Add context features such as:

```text
competition
league_strength
team_strength
opponent_strength
team_possession_context
```

Potential relative features:

```text
player_xG90
league_median_xG90

relative_xG =
player_xG90 / league_median_xG90
```

This helps answer:

> "How dominant was this player relative to the environment?"

rather than only:

> "How large was the raw number?"

---

# 21. Player Form

The player-season table is useful but does not capture current form.

Eventually create rolling features:

```text
last_5_matches
last_10_matches
season_to_date
```

Example:

```text
goals_last_5
xG_last_5
minutes_last_5
progressive_actions_last_5
```

This becomes especially important for a live application.

---

# 22. Player Similarity — Core V1 ML Feature

Player similarity should be the first ML-oriented product feature.

Basic pipeline:

```text
player statistics
       ↓
minimum-minute filter
       ↓
context normalization
       ↓
feature scaling
       ↓
player vector
       ↓
similarity
```

Baseline:

```text
cosine similarity
```

Potential later methods:

- PCA;
- UMAP for visualization;
- clustering;
- learned embeddings;
- metric learning.

Do not start with deep learning unless the baseline is inadequate.

---

# 23. Similarity Should Have Constraints

"Who is similar to Player X?" is only the first use case.

The useful scouting query is:

> "Who can replace Player X?"

Therefore candidate ranking should support:

```text
position
age
league
minutes
market value
contract status
performance
style
team
```

Example:

```text
Target:
Saka

Constraints:
age < 24
RW/RM
market value < €40M
outside Premier League
minimum 1200 minutes

        ↓

candidate ranking
```

This is more valuable as a product than a generic cosine-similarity page.

---

# 24. Market Value Prediction — V2 Experiment

Target:

```text
Y =
log1p(next_season_market_value)
```

Input:

```text
current-season features
```

Potential feature groups:

```text
age
position
minutes
goals
assists
xG
xA
progression
defensive actions
team strength
competition
current market value
transfer history
```

But every feature must pass the temporal leakage test.

---

# 25. Baselines

Do not start with a complex model.

Baseline 1:

```text
next_market_value = current_market_value
```

Baseline 2:

```text
Ridge Regression
```

Main model:

```text
LightGBM
```

Alternative:

```text
CatBoost
```

XGBoost can also be tested if justified.

The first question is:

> Does the ML model beat the trivial current-value baseline?

If not, the model is not providing useful predictive value.

---

# 26. Market Value Is a Difficult Target

Transfermarkt market value is highly autocorrelated.

Therefore a model can appear strong simply by learning:

```text
current value
    →
future value
```

This is why the baseline is critical.

Run ablation experiments:

```text
A: current market value only

B: performance only

C: market value + performance

D: market value + performance + context
```

Compare all four.

This tells us what the model is actually learning.

---

# 27. Evaluation Split

Do not use a random train/test split for the main forecasting experiment.

Recommended:

```text
Train:
older seasons

Validation:
later season

Test:
latest historical season
```

Example:

```text
Train      2015–2020
Validation 2021
Test       2022
```

The exact years depend on actual available data.

---

# 28. Two Generalization Questions

There are two different evaluation settings.

## Setting A — Future prediction

The same player can appear across seasons.

```text
Player A 2019 → train
Player A 2020 → test
```

This is valid for:

> "Predict the future of a player we already know."

## Setting B — Cold-start player

The player does not appear in training.

```text
Train players
        ↓
Previously unseen test players
```

This answers:

> "Can the model generalize to a player it has never seen?"

These should not be confused.

---

# 29. Survivorship and Missing Labels

Not every player-season has a next-season market value.

Reasons include:

```text
retirement
league exit
dataset coverage
missing observation
transfer outside coverage
```

Do not blindly:

```python
dropna(target)
```

without understanding why the target is missing.

Document the label policy.

---

# 30. Evaluation Metrics

For regression:

```text
MAE
RMSE
R²
```

For log-target models, also provide user-friendly metrics in the original monetary scale.

For example:

```text
median absolute error
percentage error by value bucket
```

Break results into groups:

```text
< €5M
€5–20M
€20–50M
€50–100M
> €100M
```

This is much easier to interpret than reporting only:

```text
MAE(log1p(MV)) = ...
```

---

# 31. Error Analysis

Do not stop at one score.

Inspect:

```text
largest underpredictions
largest overpredictions
young players
older players
high-value players
low-value players
different positions
different competitions
```

Questions:

- Does the model systematically underestimate young players?
- Does it overvalue attackers?
- Does it fail outside top leagues?
- Does it simply reproduce current market value?
- Does it fail when a player changes clubs?
- Does performance data improve predictions?

---

# 32. League Analytics

League analytics is a separate branch of the system.

Potential data model:

```text
team_match
    ↓
team_season
    ↓
league_table
```

Features:

```text
points
wins
draws
losses
goals_for
goals_against
goal_difference
form
home_form
away_form
```

Later:

```text
Elo
Poisson
season simulation
```

Do not force league simulation into the player-intelligence model.

---

# 33. Match Prediction / Betting

This should be considered a separate project branch.

If eventually implemented:

```text
team strength
+
recent form
+
player availability
+
match context
+
odds
        ↓
match probability
```

Then evaluate:

```text
Log Loss
Brier Score
ROC-AUC
Calibration
CLV
```

Football-Data.co.uk becomes relevant here.

It should not be added to the Player Intelligence V1 simply because it is available.

---

# 34. Storage

For V1:

```text
Raw files
   ↓
Parquet
   ↓
DuckDB
```

This is sufficient for a personal/portfolio-scale analytics system.

Recommended project structure:

```text
data/
├── raw/
├── interim/
├── processed/
├── features/
└── snapshots/
```

Use immutable snapshots where possible.

---

# 35. Recommended Technology Stack

## V1

```text
Python
Pandas / Polars
Parquet
DuckDB
scikit-learn
LightGBM
FastAPI
```

Optional:

```text
Pydantic
Docker
```

## Do NOT require initially

```text
MLflow
DVC
PostgreSQL
pgvector
LiteLLM
Kubernetes
model registry
feature store
```

These are useful only when the project develops a real need for them.

---

# 36. MLflow / DVC Decision

Add MLflow when:

```text
multiple experiments
+
multiple model versions
+
need reproducibility
```

Add DVC when:

```text
dataset versions become difficult to manage with Git
```

Do not add them simply because:

> "A senior ML project should have MLflow/DVC."

The correct principle is:

> **Use infrastructure to solve an observed problem.**

---

# 37. LLM Architecture

The LLM should be an application layer.

Correct:

```text
User
 ↓
LLM
 ↓
Tool / function call
 ↓
FastAPI
 ↓
Football data / ML model
 ↓
Structured JSON
 ↓
LLM
 ↓
Natural-language explanation
```

Example:

User:

> "Find me 5 players similar to Saka under €30M."

LLM:

```json
{
  "tool": "find_similar_players",
  "player": "Saka",
  "max_market_value": 30000000,
  "limit": 5
}
```

FastAPI executes the actual query/model.

The LLM should not invent the candidates.

---

# 38. RAG vs ML

This project does **not** require document chunking + LLM fine-tuning.

Wrong architecture:

```text
football CSV
    ↓
chunks
    ↓
embedding
    ↓
LLM fine-tuning
    ↓
predict market value
```

Correct architecture:

```text
structured football data
        ↓
feature engineering
        ↓
ML model
        ↓
prediction
```

RAG is useful later for:

- metric definitions;
- competition rules;
- club/player documentation;
- scouting reports;
- methodology documents.

But numerical predictions should come from structured data and ML models.

---

# 39. Fine-Tuning

Do not fine-tune an LLM for:

```text
market value prediction
player similarity
team strength
```

Use:

```text
LightGBM
CatBoost
Ridge
similarity algorithms
```

Fine-tuning may become useful later for a specific language/task behavior, but it is not necessary for the core football analytics problem.

---

# 40. Optional LiteLLM Layer

LiteLLM can be introduced later:

```text
FastAPI
    ↓
LiteLLM
    ├── OpenAI
    ├── Anthropic
    ├── Gemini
    └── local model
```

For V1, if one model is enough:

```text
FastAPI → chosen LLM provider
```

is simpler.

---

# 41. Recommended End-to-End Architecture

```text
                       DATA SOURCES
                            │
             ┌──────────────┼──────────────┐
             ↓              ↓              ↓
        Transfermarkt   StatsBomb      Kaggle
             │              │              │
             └──────────────┼──────────────┘
                            ↓
                       RAW DATA
                            ↓
                  DATA QUALITY CHECKS
                            ↓
                  ENTITY RESOLUTION
                            ↓
                  CANONICAL DATA MODEL
                            ↓
             ┌──────────────┼──────────────┐
             ↓              ↓              ↓
       player_match    player_season    team_match
             │              │              │
             └──────────────┼──────────────┘
                            ↓
                     FEATURE LAYER
                            ↓
       ┌────────────────────┼────────────────────┐
       ↓                    ↓                    ↓
 Player Search         Similarity          ML Experiments
       │                    │                    │
       │              Replacement          Market Value
       │                Ranking              Prediction
       └────────────────────┼────────────────────┘
                            ↓
                         FastAPI
                            ↓
                        Frontend
                            │
                     optional later
                            ↓
                     LLM Football Analyst
```

---

# 42. Project Directory

Recommended:

```text
football-intelligence/
│
├── data/
│   ├── raw/
│   ├── interim/
│   ├── processed/
│   ├── features/
│   └── snapshots/
│
├── notebooks/
│   ├── 01_data_audit.ipynb
│   ├── 02_entity_resolution.ipynb
│   ├── 03_player_eda.ipynb
│   ├── 04_similarity_baseline.ipynb
│   └── 05_market_value_experiment.ipynb
│
├── src/
│   ├── ingestion/
│   ├── cleaning/
│   ├── entity_resolution/
│   ├── features/
│   ├── similarity/
│   ├── models/
│   ├── evaluation/
│   └── api/
│
├── tests/
│
├── configs/
│
├── reports/
│
├── app/
│
├── requirements.txt
└── README.md
```

---

# 43. Phase-by-Phase Implementation Plan

## Phase 0 — Data Audit

Deliverables:

```text
dataset_inventory.csv
coverage_report.md
player_season_coverage.csv
source_provenance.md
```

Questions answered:

```text
What data do I actually have?
How much overlaps?
Which leagues/seasons are usable?
```

---

## Phase 1 — Canonical Data Model

Build:

```text
dim_player
dim_team
dim_competition

fact_player_match
fact_player_season
fact_team_match
fact_team_season
fact_transfer
fact_market_value
```

Deliverable:

```text
clean, queryable football database
```

---

## Phase 2 — Entity Resolution

Build:

```text
player_identity_map
team_identity_map
competition_identity_map
```

Measure:

```text
automatic_match_rate
manual_review_rate
unmatched_rate
```

---

## Phase 3 — Player Search

Build:

```text
search_player()
get_player_profile()
filter_players()
compare_players()
```

This creates the first useful application layer.

---

## Phase 4 — Player Similarity

Baseline:

```text
normalized feature vector
        ↓
cosine similarity
```

Then add:

```text
position constraint
age constraint
minutes threshold
competition constraint
market-value constraint
```

---

## Phase 5 — Replacement Ranking

Input:

```text
target player
constraints
```

Output:

```text
candidate
similarity
performance
age
market value
competition
explanation
```

This is the first feature that resembles a real scouting workflow.

---

## Phase 6 — Market Value Experiment

Build:

```text
baseline
→ Ridge
→ LightGBM
→ CatBoost
```

Use temporal evaluation.

Run ablations.

Perform error analysis.

Only keep the model if it beats the baseline meaningfully.

---

## Phase 7 — League Analytics

Add:

```text
league table
team form
team strength
fixtures
results
```

Then consider:

```text
Elo
Poisson
simulation
```

---

## Phase 8 — FastAPI

Example endpoints:

```text
GET /players
GET /players/{id}
GET /players/{id}/similar
POST /players/compare
POST /players/replacements
GET /teams/{id}
GET /competitions/{id}
POST /models/market-value/predict
```

---

## Phase 9 — LLM Analyst

Example:

```text
POST /assistant/query
```

The LLM translates natural language into structured tool calls.

The deterministic backend executes the actual operation.

---

# 44. Data Quality Checks

Every ingestion pipeline should validate:

```text
null rates
duplicate IDs
duplicate matches
invalid dates
invalid seasons
invalid player-team relationships
negative minutes
minutes > match duration
impossible scores
duplicate market-value snapshots
```

For example:

```python
assert minutes >= 0
assert goals >= 0
assert assists >= 0
```

Use source-specific validation rules where appropriate.

---

# 45. Leakage Checklist

For every feature ask:

> Could this information have been known at the prediction timestamp?

Dangerous examples:

```text
future transfer
future market value
end-of-season statistics
post-season team position
future injury
future contract status
```

If predicting next season:

```text
prediction_date
        ↓
only information before this date
```

This rule should be enforced in the feature pipeline, not just remembered manually.

---

# 46. Product Metrics

Do not evaluate only ML metrics.

For the app:

### Search

```text
search latency
result relevance
```

### Similarity

```text
top-k relevance
expert/scout evaluation
```

### Replacement

```text
candidate relevance
constraint satisfaction
```

### Market value

```text
MAE
RMSE
baseline improvement
calibration by value bucket
```

A good ML score that produces useless scouting candidates is still a weak product.

---

# 47. Senior-Level Review Checklist

Before calling the project "done", verify:

### Data

- [ ] Actual source provenance documented
- [ ] Licenses/access terms checked
- [ ] Coverage measured
- [ ] Missingness measured
- [ ] Entity resolution measured
- [ ] Snapshots/versioning defined

### ML

- [ ] Baseline exists
- [ ] Temporal split exists
- [ ] Leakage audit exists
- [ ] Feature ablation exists
- [ ] Error analysis exists
- [ ] Performance segmented by league/position/value

### Product

- [ ] Search works
- [ ] Player profile works
- [ ] Similarity works
- [ ] Replacement search works
- [ ] Constraints work
- [ ] Results are explainable

### Engineering

- [ ] Canonical schema exists
- [ ] Reproducible pipeline exists
- [ ] FastAPI exists
- [ ] Tests exist
- [ ] API does not depend on LLM hallucinations

### LLM

- [ ] LLM is optional
- [ ] Tool calls are structured
- [ ] Numerical data comes from backend
- [ ] LLM does not invent statistics

---

# 48. What Should NOT Be Implemented Yet

Until data coverage is proven, do not spend significant time on:

```text
❌ LLM fine-tuning
❌ RAG over CSV files
❌ LiteLLM
❌ pgvector
❌ Kubernetes
❌ complex MLOps
❌ deep learning for tabular data
❌ betting/CLV
❌ season simulation
```

The priority is:

```text
DATA
  ↓
DATA QUALITY
  ↓
ENTITY RESOLUTION
  ↓
PLAYER INTELLIGENCE
  ↓
PRODUCT
  ↓
ML EXPERIMENTS
  ↓
LLM
```

---

# 49. Final Recommended Scope

## Core V1

```text
Football Player Intelligence

1. Player database
2. Player search
3. Player profile
4. Player comparison
5. Similar player search
6. Replacement candidate ranking
7. Basic team/league context
```

## ML

```text
Primary:
player similarity

Secondary:
market-value prediction experiment
```

## Backend

```text
Python
DuckDB
Parquet
FastAPI
```

## Frontend

Any practical web stack.

## LLM

Optional analyst layer.

## Later

```text
MLflow
DVC
PostgreSQL
pgvector
LiteLLM
advanced league modelling
real-time data
```

---

# 50. The Most Important Next Step

Do **not** start training LightGBM.

Start with:

```text
01_data_audit.ipynb
```

and produce:

```text
01_data_audit.ipynb
reports/
├── coverage_report.md
├── player_season_coverage.csv
├── entity_resolution_report.csv
├── data_quality_report.md
└── source_provenance.md
```

The audit must end with a machine-readable:

```text
GO
WARNING
NO-GO
```

for every critical source and metric.



```text
                    SOURCE AUDIT
                         │
       ┌─────────────────┼─────────────────┐
       ↓                 ↓                 ↓
   Coverage          Overlap           Quality
       │                 │                 │
       └─────────────────┼─────────────────┘
                         ↓
               player × season table
                         ↓
              usable-row percentage
                         ↓
                 GO / NO-GO
```

The key number is:

> **How many genuinely usable `player × season` observations remain after entity resolution and required-feature filtering?**

Only after that number is known should the final feature set and ML target be locked.

---

# 51. Final Architecture in One Line

```text
Transfermarkt + StatsBomb/Kaggle
→ canonical football entities
→ player-match / player-season data
→ leakage-safe features
→ player search + similarity + replacement ranking
→ optional market-value ML
→ FastAPI
→ frontend
→ optional LLM Football Analyst
```

## Core principle

> **Do not build an impressive ML stack around insufficient data. Build a reliable football-data foundation first, then add the smallest model that creates measurable product value.**


---

# 52. Immediate Work Package — Start Building, Stop Speculating

The project is now ready to move from architecture to measurement.

## Task 1 — Inventory every source

Create:

```text
reports/source_inventory.csv
```

Fields:

```text
source
dataset_name
url
license
access_method
download_date
latest_available_season
competitions
player_data
match_data
event_data
market_value
current_season
notes
```

Do not fill unknown fields with assumptions.

Use:

```text
UNKNOWN
```

until verified.

---

## Task 2 — Download only the minimum viable sources

Initial experiment:

```text
Historical:
Transfermarkt-derived usable dataset
StatsBomb Open Data
1–2 Kaggle datasets where useful

Current:
one current-season API candidate
```

Do not download ten datasets before knowing which ones overlap.

---

## Task 3 — Build coverage matrix

Generate:

```text
competition × season × source
```

Example:

| Competition | Season | TM | StatsBomb | Kaggle | Current API |
|---|---|---|---|---|---|
| Premier League | 2024/25 | ? | ? | ? | ? |
| Premier League | 2025/26 | ? | ? | ? | ? |
| Premier League | 2026/27 | ? | ? | ? | ? |

This immediately exposes the biggest data gap.

---

## Task 4 — Build first identity matcher

Start with deterministic rules:

```text
source ID
→ exact normalized name + DOB
→ name + team + season
```

Only then introduce fuzzy matching.

Output:

```text
player_identity_map.parquet
```

---

## Task 5 — Calculate the gates

At minimum:

```text
usable player-season count
player-seasons ≥900 minutes
entity-resolution rate
required-feature completeness
current-season coverage
```

Compare them against Section 4.5.

---

## Task 6 — Make the decision

### GO

If thresholds pass:

```text
continue to canonical schema
```

### WARNING

If close:

```text
restrict leagues
reduce feature set
or test another provider
```

### NO-GO

If badly below threshold:

```text
change data source
or change product scope
```

Do not proceed to model training merely because the code works.

---

# 53. Final Senior-Level Principle

The project should be judged in this order:

```text
                    1. DATA
                      ↓
             Is the data sufficient?
                      ↓
                 2. ENTITY
                      ↓
             Can sources be joined?
                      ↓
                 3. PRODUCT
                      ↓
           Is the output actually useful?
                      ↓
                  4. BASELINE
                      ↓
          Is ML better than something simple?
                      ↓
                 5. MODEL
                      ↓
           Does the model generalize?
                      ↓
                   6. API
                      ↓
              Can users consume it?
                      ↓
                    7. LLM
                      ↓
          Does natural language improve UX?
                      ↓
                   8. MLOps
                      ↓
         Is infrastructure now justified?
```

The project is **not** successful because it contains LightGBM, an LLM, RAG, Docker, MLflow or pgvector.

It is successful if:

```text
the data is trustworthy
        +
the joins are reliable
        +
the model beats appropriate baselines
        +
the similarity results are testable
        +
the product solves a recognizable scouting task
```

That is the standard to use for the rest of the implementation.
