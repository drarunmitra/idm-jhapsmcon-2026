# Infectious Disease Modelling in R — JHAPSMCON 2026

A one-day, beginner-friendly workshop on infectious disease modelling using R.
Materials for the 4ᵗʰ Annual Jharkhand State Conference of IAPSM (JHAPSMCON 2026).

🌐 **Website:** https://drarunmitra.github.io/idm-jhapsmcon-2026/

## What's in here

```
.
├── _quarto.yml                 # Quarto Website + revealjs format config
├── index.qmd                   # Landing page
├── setup.qmd                   # Install guide
├── code.qmd / dataset.qmd / resources.qmd / about.qmd
├── 01_foundations.qmd          # Slide deck — Foundations
├── 02_just_enough_r.qmd        # Slide deck — R basics + tidyverse + applied R_t
├── 03_compartmental_models.qmd # Slide deck — SIR / SEIR + extensions
├── 04_scenario_modelling.qmd   # Slide deck — Scenarios (epidemics + POLYMOD)
├── 05_dashboard.qmd            # Slide deck — AMCHSS dashboard walkthrough
├── setup.R                     # One-shot installer for all workshop packages
├── data/
│   ├── covid_india_daily.csv         # COVID-19 India daily cases (JHU CSSE)
│   └── prepare_covid_india_daily.R   # Rebuild script
├── scripts/
│   ├── group1.R · group2.R · group3.R · group4.R   # Compartmental group work
│   ├── scenario_explorer.R                          # Scenario-modelling hands-on
│   ├── build_sir_animation.R                        # Builds the SIR gganimate gif
│   └── build_stochastic_seir.R                      # Builds the 100-trajectory PNG
├── images/                     # Slide assets (illustrations, diagrams, photos)
└── _extensions/mcanouil/codefrag   # Quarto extension for progressive code annotations
```

## Building locally

```bash
# Render the website (all decks + pages)
quarto render

# Live preview (auto-rebuilds on change)
quarto preview
```

Rendered output lands in `_site/`. Open `_site/index.html` to browse.

## Publishing

The site is deployed to GitHub Pages via the `gh-pages` branch:

```bash
quarto publish gh-pages
```

## Licence

- **Code** (R scripts, Quarto source, configuration) — [MIT](LICENSE)
- **Slide content, prose, original images** — CC-BY-SA 4.0
- **Third-party assets** retain their original licences. See [about.qmd](about.qmd).

## Citation

If you reuse these materials in your teaching, please cite:

> Mitra Peddireddy, A. (2026). *Infectious Disease Modelling in R — JHAPSMCON 2026 Workshop.*
> https://github.com/drarunmitra/idm-jhapsmcon-2026

## Contact

Open an issue on this repository, or email Dr. Arun Mitra Peddireddy.
