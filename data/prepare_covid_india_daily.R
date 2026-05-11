# prepare_covid_india_daily.R
# Build the workshop's COVID-19 India daily-cases CSV from JHU CSSE.
# JHU CSSE published cumulative confirmed cases by country, daily, from
# 2020-01-22 to 2023-03-09 — covering all three Indian waves.

suppressPackageStartupMessages({
  library(readr)
  library(dplyr)
  library(tidyr)
  library(lubridate)
})

jhu_url <- paste0(
  "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/",
  "csse_covid_19_data/csse_covid_19_time_series/",
  "time_series_covid19_confirmed_global.csv"
)

jhu_wide <- read_csv(jhu_url, show_col_types = FALSE)

india_long <- jhu_wide |>
  filter(`Country/Region` == "India") |>
  select(-`Province/State`, -`Country/Region`, -Lat, -Long) |>
  pivot_longer(
    everything(),
    names_to  = "date_chr",
    values_to = "cumulative_confirmed"
  ) |>
  mutate(
    date = mdy(date_chr),
    cumulative_confirmed = as.integer(cumulative_confirmed)
  ) |>
  arrange(date) |>
  mutate(
    daily_confirmed = pmax(0L, cumulative_confirmed - lag(cumulative_confirmed, default = 0L))
  ) |>
  select(date, daily_confirmed, cumulative_confirmed)

write_csv(india_long, here::here("data", "covid_india_daily.csv"))

message("Wrote ", nrow(india_long), " rows. Range: ",
        format(min(india_long$date)), " to ", format(max(india_long$date)))
