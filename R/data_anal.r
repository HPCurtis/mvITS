library(cmdstanr)
library(dplyr)
library(tidyr)

# Import data----
# Import data seasonally adjusted from github repo.
df_sa <- read.csv("https://raw.githubusercontent.com/HPCurtis/causalcovidcattle/main/data/cattle_sa.csv")

# Remove the word words from column apart from state from the column names
names(df_sa) <- gsub("NumberSlaughteredCATTLEexclcalves", "", names(df_sa))
df_sa <- drop_na(df_sa)

# time of Covid lockdowns 
certain_date <- as.Date("2020-03-01")

# Add both the RowID and BeforeAfter columns
df_sa <- df_sa %>%
  mutate(
    t = row_number(),
    BeforeAfter = as.numeric(Date < certain_date)
  )

# Compile Stan model
file_path <- "/home/harrison/Desktop/gitHubRepos/mvITS/stan/mvITS.stan"
mod <- cmdstan_model(file_path)

# Generate matrices for experimental for each state 
dm <- model.matrix(NewSouthWales ~ 0 + t + BeforeAfter, data = df_sa)

# Dependent variable.
y <- as.matrix(scale(df_sa[, c("NewSouthWales", "Victoria", "Queensland","SouthAustralia" ,"WesternAustralia" ,"Tasmania" )]))

# Set up list for data input to Stan model
data = list(J = ncol(dm), K = ncol(y), N = nrow(y), y = y , x = as.matrix(dm), lkj = 2, sigma_sigma = 1)

fit <- mod$sample(
  data = data,
  chains = 4,
  parallel_chains = 4,
  refresh = 500 # print update every 500 iters
)

draws_arr <- fit$draws(format = "df") # or format="array"
str(draws_arr)
