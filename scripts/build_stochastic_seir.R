# Build a cached stochastic SEIR illustration: 100 trajectories at the same R0.
# Run once: Rscript scripts/build_stochastic_seir.R
# Output: images/stochastic_seir_trajectories.png

suppressPackageStartupMessages({
  library(tidyverse)
  library(here)
})

set.seed(42)

# ---- Parameters --------------------------------------------
N      <- 1000     # small population so stochasticity is visible
R0     <- 1.5
D      <- 7        # mean infectious period
sigma  <- 1 / 5    # 5-day latent
gamma  <- 1 / D
beta   <- R0 * gamma
I0     <- 5
t_end  <- 365
dt     <- 0.5
n_iter <- 100

# ---- Tau-leap simulator ------------------------------------
sim_one <- function(seed) {
  set.seed(seed)
  steps <- seq(0, t_end, by = dt)
  S <- N - I0; E <- 0; I <- I0; R <- 0
  out <- tibble(time = numeric(), I = integer(), R = integer())
  for (t in steps) {
    out <- bind_rows(out, tibble(time = t, I = I, R = R))
    if (I == 0 && E == 0) next                       # extinction; trajectory stays flat
    p_inf <- 1 - exp(-beta * I / N * dt)
    p_lat <- 1 - exp(-sigma * dt)
    p_rec <- 1 - exp(-gamma * dt)
    new_E <- rbinom(1, S, p_inf)
    new_I <- rbinom(1, E, p_lat)
    new_R <- rbinom(1, I, p_rec)
    S <- S - new_E
    E <- E + new_E - new_I
    I <- I + new_I - new_R
    R <- R + new_R
  }
  out
}

# ---- Run 100 iterations ------------------------------------
runs <- tibble(iter = seq_len(n_iter)) |>
  mutate(traj = map(iter, sim_one)) |>
  unnest(traj)

# Classify outcomes: extinct if final R is small, otherwise outbreak.
outcomes <- runs |>
  group_by(iter) |>
  summarise(final_R = max(R), .groups = "drop") |>
  mutate(outcome = if_else(final_R < 50, "fizzles out", "takes off"))

runs <- runs |> left_join(outcomes, by = "iter")

# ---- Plot --------------------------------------------------
# Plot takeoffs first (background), fizzles on top so they remain visible.
p <- ggplot() +
  geom_line(data = filter(runs, outcome == "takes off"),
            aes(time, I, group = iter),
            colour = "#d95f02", linewidth = 0.4, alpha = 0.45) +
  geom_line(data = filter(runs, outcome == "fizzles out"),
            aes(time, I, group = iter),
            colour = "#1b6dc4", linewidth = 0.9, alpha = 0.95) +
  annotate("text", x = 360, y = 78, label = "takes off",
           colour = "#d95f02", fontface = "bold", hjust = 1, size = 4.5) +
  annotate("text", x = 360, y = 4,  label = "fizzles out",
           colour = "#1b6dc4", fontface = "bold", hjust = 1, size = 4.5) +
  labs(x = "Day", y = "Infectious",
       title = "100 stochastic SEIR trajectories — same parameters, different futures",
       subtitle = sprintf("N = %s, R0 = %g, latent = 5 days, infectious = 7 days, I0 = %d",
                          format(N, big.mark = ","), R0, I0)) +
  theme_minimal(base_size = 14) +
  theme(plot.title = element_text(face = "bold"))

ggsave(here("images", "stochastic_seir_trajectories.png"),
       p, width = 9, height = 4.5, dpi = 140, bg = "white")

# Quick console summary
n_takeoff <- sum(outcomes$outcome == "takes off")
message(sprintf("wrote images/stochastic_seir_trajectories.png  (%d/%d trajectories took off, %d fizzled out)",
                n_takeoff, n_iter, n_iter - n_takeoff))
