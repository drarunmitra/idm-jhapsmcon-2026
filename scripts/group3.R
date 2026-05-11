# group3.R — Ebola-like SIR
# ============================================================
# Run this script line by line with Cmd/Ctrl + Enter.
# Before you look at the plot, predict on paper:
#   1. On which day does I peak?
#   2. How many people end up in R (final size)?
# Then compare with the plot.
# ============================================================

library(deSolve)
library(tidyverse)

# ---- 1. Disease parameters --------------------------------
R0 <- 2         # basic reproduction number
D  <- 10        # mean infectious duration (days)

beta  <- R0 / D
gamma <- 1 / D

# ---- 2. Population ----------------------------------------
N  <- 1e6       # one million people
I0 <- 10        # 10 initial infectious

# ---- 3. SIR model -----------------------------------------
sir_eq <- function(t, y, params) {
  with(as.list(c(y, params)), {
    dS <- -beta * S * I / N
    dI <-  beta * S * I / N - gamma * I
    dR <-  gamma * I
    list(c(dS, dI, dR))
  })
}

# ---- 4. Simulate ------------------------------------------
out <- ode(
  y     = c(S = N - I0, I = I0, R = 0),
  times = 0:365,
  func  = sir_eq,
  parms = c(beta = beta, gamma = gamma, N = N)
) |>
  unclass() |>
  as.data.frame() |>
  as_tibble()

# ---- 5. Inspect peak + final size -------------------------
out |>
  summarise(
    peak_day        = time[which.max(I)],
    peak_infectious = round(max(I)),
    final_size      = round(max(R))
  )

# ---- 6. Plot ----------------------------------------------
out |>
  pivot_longer(c(S, I, R), names_to = "compartment") |>
  mutate(compartment = factor(compartment, levels = c("S", "I", "R"))) |>
  ggplot(aes(time, value, colour = compartment)) +
  geom_line(linewidth = 1.2) +
  scale_colour_manual(values = c(S = "#1b9e77", I = "#d95f02", R = "#7570b3")) +
  labs(x = "Day", y = "People", colour = NULL,
       title = paste0("Ebola-like SIR  (R0 = ", R0, ", D = ", D, " days)")) +
  theme_minimal(base_size = 14)


# ============================================================
# BONUS — Extend to SEIR (σ = 1/5)
# What changed? What didn't?
# ============================================================

seir_eq <- function(t, y, params) {
  with(as.list(c(y, params)), {
    dS <- -beta * S * I / N
    dE <-  beta * S * I / N - sigma * E
    dI <-  sigma * E - gamma * I
    dR <-  gamma * I
    list(c(dS, dE, dI, dR))
  })
}

seir_out <- ode(
  y     = c(S = N - I0, E = 0, I = I0, R = 0),
  times = 0:365,
  func  = seir_eq,
  parms = c(beta = beta, gamma = gamma, sigma = 1/5, N = N)
) |>
  unclass() |>
  as.data.frame() |>
  as_tibble()

bind_rows(
  out      |> transmute(time, model = "SIR",  I = as.numeric(I)),
  seir_out |> transmute(time, model = "SEIR", I = as.numeric(I))
) |>
  ggplot(aes(time, I, colour = model)) +
  geom_line(linewidth = 1.2) +
  scale_colour_manual(values = c(SIR = "#d95f02", SEIR = "#1b9e77")) +
  labs(x = "Day", y = "Infectious", colour = NULL,
       title = paste0("Ebola-like — SIR vs SEIR (latent period 5 days)")) +
  theme_minimal(base_size = 14)
