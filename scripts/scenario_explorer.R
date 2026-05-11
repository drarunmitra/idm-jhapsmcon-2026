# scenario_explorer.R — COVID-like scenario hands-on (epidemics)
# ============================================================
# Run the SETUP block first, then jump to your pair's task.
# For each task:
#   1. Predict on paper before running.
#   2. Run.
#   3. Note peak day, peak infectious, final size.
#   4. Compare against the counterfactual.
# ============================================================

# ---- SETUP -------------------------------------------------

library(epidemics)
library(socialmixr)
library(tidyverse)

# Build the age-structured population from POLYMOD.
contact_data <- contact_matrix(
  socialmixr::polymod,
  age_limits = c(0, 20, 40),
  symmetric  = TRUE
)
contact_matrix    <- t(contact_data[["matrix"]])
demography_vector <- contact_data[["demography"]][["population"]]
names(demography_vector) <- rownames(contact_matrix)

initial_i <- 1e-6
init_row  <- c(S = 1 - initial_i, E = 0, I = initial_i, R = 0, V = 0)
initial_conditions <- rbind(init_row, init_row, init_row)
rownames(initial_conditions) <- rownames(contact_matrix)

uk_population <- population(
  name               = "Population",
  contact_matrix     = contact_matrix,
  demography_vector  = demography_vector,
  initial_conditions = initial_conditions
)

# Wrapper: pass `npi` (an intervention object) and/or `vac` (a vaccination
# object). Defaults = no intervention.
run_scenario <- function(npi = NULL, vac = NULL, t_end = 365) {
  args <- list(
    population          = uk_population,
    transmission_rate   = 0.3,        # COVID-like
    infectiousness_rate = 1 / 5,      # 5-day latent
    recovery_rate       = 1 / 7,      # 7-day infectious
    time_end            = t_end,
    increment           = 1.0
  )
  if (!is.null(npi)) args$intervention <- list(contacts = npi)
  if (!is.null(vac)) args$vaccination  <- vac
  do.call(model_default, args)
}

# Helpers.
total_I <- function(out) {
  out |> filter(compartment == "infectious") |>
    group_by(time) |> summarise(I = sum(value), .groups = "drop")
}

summarise_run <- function(out) {
  i <- total_I(out)
  r <- out |> filter(compartment == "recovered") |>
    group_by(time) |> summarise(R = sum(value), .groups = "drop")
  tibble(
    peak_day        = i$time[which.max(i$I)],
    peak_infectious = round(max(i$I)),
    final_size      = round(max(r$R))
  )
}

plot_vs_counter <- function(out, label = "your scenario") {
  bind_rows(
    total_I(counterfactual) |> mutate(scenario = "counterfactual"),
    total_I(out)            |> mutate(scenario = label)
  ) |>
    ggplot(aes(time, I, colour = scenario)) +
    geom_line(linewidth = 1.1) +
    scale_colour_manual(values = c("counterfactual" = "grey60",
                                   setNames("#5d519a", label))) +
    scale_y_continuous(labels = scales::comma) +
    labs(x = "Day", y = "Infectious", colour = NULL) +
    theme_minimal(base_size = 14) +
    theme(legend.position = "top")
}

# Counterfactual once — every task compares against this.
counterfactual <- run_scenario()
summarise_run(counterfactual)


# ============================================================
# Reusable building blocks for each task
# ============================================================

# Default lockdown used in slides.
lockdown_default <- intervention(
  name       = "Lockdown",
  type       = "contacts",
  reduction  = matrix(c(0.5, 0.5, 0.3)),
  time_begin = 30,
  time_end   = 90
)

# Default vaccination campaign used in slides.
campaign_default <- vaccination(
  name        = "Campaign",
  time_begin  = matrix(60,    nrow = 3),
  time_end    = matrix(360,   nrow = 3),
  nu          = matrix(0.005, nrow = 3)
)


# ============================================================
# TASKS — pick ONE for your pair, then report back.
# ============================================================

# ---- Pair A : weak lockdown -------------------------------
#   What if reduction is only c(0.3, 0.3, 0.2)?
weak_lockdown <- intervention(
  name = "Lockdown", type = "contacts",
  reduction  = matrix(c(0.3, 0.3, 0.2)),
  time_begin = 30, time_end = 90
)
out_A <- run_scenario(npi = weak_lockdown)
summarise_run(out_A)
plot_vs_counter(out_A, label = "weak NPI")


# ---- Pair B : long lockdown -------------------------------
#   Extend the lockdown window to days 30–150.
long_lockdown <- intervention(
  name = "Lockdown", type = "contacts",
  reduction  = matrix(c(0.5, 0.5, 0.3)),
  time_begin = 30, time_end = 150
)
out_B <- run_scenario(npi = long_lockdown)
summarise_run(out_B)
plot_vs_counter(out_B, label = "long NPI (30–150)")


# ---- Pair C : late lockdown -------------------------------
#   Start the lockdown on day 60 instead of day 30.
late_lockdown <- intervention(
  name = "Lockdown", type = "contacts",
  reduction  = matrix(c(0.5, 0.5, 0.3)),
  time_begin = 60, time_end = 120
)
out_C <- run_scenario(npi = late_lockdown)
summarise_run(out_C)
plot_vs_counter(out_C, label = "late NPI (60–120)")


# ---- Pair D : earlier vaccination -------------------------
#   Move the vaccination start from day 60 to day 30.
early_campaign <- vaccination(
  name = "Campaign",
  time_begin  = matrix(30,    nrow = 3),
  time_end    = matrix(360,   nrow = 3),
  nu          = matrix(0.005, nrow = 3)
)
out_D <- run_scenario(vac = early_campaign)
summarise_run(out_D)
plot_vs_counter(out_D, label = "early vaccination (day 30)")


# ---- Pair E : slower vaccination --------------------------
#   What if vaccination only reaches 0.1% per day?
slow_campaign <- vaccination(
  name = "Campaign",
  time_begin  = matrix(60,    nrow = 3),
  time_end    = matrix(360,   nrow = 3),
  nu          = matrix(0.001, nrow = 3)
)
out_E <- run_scenario(vac = slow_campaign)
summarise_run(out_E)
plot_vs_counter(out_E, label = "slow vaccination (0.001/day)")


# ---- Pair F : vaccination only, faster --------------------
#   No NPI, but double the vaccination rate.
fast_campaign <- vaccination(
  name = "Campaign",
  time_begin  = matrix(30,    nrow = 3),
  time_end    = matrix(360,   nrow = 3),
  nu          = matrix(0.010, nrow = 3)
)
out_F <- run_scenario(vac = fast_campaign)
summarise_run(out_F)
plot_vs_counter(out_F, label = "vaccination only, faster (0.01/day)")


# ============================================================
# YOUR OWN TWEAK — change one or more numbers below.
# ============================================================

# Example: combined NPI + vaccination, with a SHORT lockdown window.
my_npi <- intervention(
  name = "Lockdown", type = "contacts",
  reduction  = matrix(c(0.5, 0.5, 0.3)),
  time_begin = 30, time_end = 60
)
my_vac <- vaccination(
  name = "Campaign",
  time_begin  = matrix(30,    nrow = 3),
  time_end    = matrix(360,   nrow = 3),
  nu          = matrix(0.005, nrow = 3)
)
out_mine <- run_scenario(npi = my_npi, vac = my_vac)
summarise_run(out_mine)
plot_vs_counter(out_mine, label = "my tweak")
