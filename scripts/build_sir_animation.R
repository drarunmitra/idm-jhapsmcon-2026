# Build a cached SIR animation GIF for the workshop hook slide.
# Run once: Rscript scripts/build_sir_animation.R
# Output: images/sir_animation.gif (embedded in 02_compartmental_models.qmd)

suppressPackageStartupMessages({
  library(deSolve)
  library(tidyverse)
  library(gganimate)
  library(here)
})

sir <- function(t, y, p) with(as.list(c(y, p)), {
  list(c(-beta * S * I / N,
          beta * S * I / N - gamma * I,
          gamma * I))
})

out <- ode(
  y     = c(S = 999, I = 1, R = 0),
  times = 0:120,
  func  = sir,
  parms = c(beta = 0.4, gamma = 0.1, N = 1000)
) |>
  unclass() |> as.data.frame() |> as_tibble() |>
  pivot_longer(c(S, I, R), names_to = "compartment", values_to = "n") |>
  mutate(compartment = factor(compartment, levels = c("S", "I", "R")))

p <- ggplot(out, aes(time, n, colour = compartment)) +
  geom_line(linewidth = 1.4) +
  scale_colour_manual(values = c(S = "#1b9e77", I = "#d95f02", R = "#7570b3")) +
  labs(x = "Day", y = "People", colour = NULL,
       title = "SIR — N = 1000, β = 0.4, γ = 0.1, R₀ = 4") +
  theme_minimal(base_size = 14) +
  theme(legend.position = "top",
        plot.title = element_text(face = "bold")) +
  transition_reveal(time)

anim <- animate(p, fps = 20, duration = 6, width = 800, height = 450,
                renderer = gifski_renderer())

anim_save(here("images", "sir_animation.gif"), anim)
message("wrote images/sir_animation.gif")
