# ============================================================================
# SCRIPT: setup.R
# Purpose: Install all packages needed for the IDM_EFICON2024 workshop
# Usage:   source("setup.R")  or  Rscript setup.R
# ============================================================================

# ============================================================================
# 1. BOOTSTRAP pak
# ============================================================================
if (!requireNamespace("pak", quietly = TRUE)) {
  install.packages("pak", repos = "https://r-lib.github.io/p/pak/stable/")
}

# ============================================================================
# 2. CONFIGURE REPOSITORIES
# ============================================================================
## Epiverse-TRACE packages live on R-Universe; CRAN as fallback
options(repos = c(
  epiverse  = "https://epiverse-trace.r-universe.dev",
  reichlab  = "https://reichlab.r-universe.dev",
  ropensci  = "https://ropensci.r-universe.dev",
  CRAN      = "https://cloud.r-project.org"
))

# ============================================================================
# 3. PACKAGE LIST
# ============================================================================
## CRAN packages (general purpose, plotting, modelling)
cran_pkgs <- c(
  "tidyverse",     # dplyr, ggplot2, tidyr, readr, etc.
  "lubridate",     # already in tidyverse, listed for clarity
  "ggplot2",       # already in tidyverse, listed for clarity
  "scales",        # axis formatting
  "here",          # path management
  "deSolve",       # ODE solvers for SIR/SEIR
  "ggdag",         # DAG visualisation
  "EpiEstim",      # Rt estimation
  "incidence2",    # incidence objects
  "socialmixr",    # contact matrices
  "outbreaks"      # outbreak datasets
)

## Epiverse-TRACE packages (R-Universe)
epiverse_pkgs <- c(
  "epidemics",     # compartmental outbreak models
  "epiparameter",  # epidemiological parameter library
  "cleanepi",      # epidemiological data cleaning
  "linelist"       # tagged linelist objects
)

all_pkgs <- c(cran_pkgs, epiverse_pkgs)

# ============================================================================
# 4. INSTALL
# ============================================================================
message("Installing ", length(all_pkgs), " packages with pak...")

pak::pkg_install(all_pkgs, ask = FALSE, upgrade = FALSE)

# ============================================================================
# 5. VERIFY
# ============================================================================
installed <- vapply(all_pkgs, requireNamespace, logical(1), quietly = TRUE)

if (all(installed)) {
  message("All ", length(all_pkgs), " packages installed successfully.")
} else {
  missing <- all_pkgs[!installed]
  warning(
    "The following packages failed to install: ",
    paste(missing, collapse = ", ")
  )
}
