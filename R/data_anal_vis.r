library(ggplot2)
library(dplyr)

# Import data----
# Import data seasonally adjusted from github repo.
df_sa <- read.csv("https://raw.githubusercontent.com/HPCurtis/causalcovidcattle/main/data/cattle_sa.csv")

# Remove the word words from column apart from state from the column names
names(df_sa) <- gsub("NumberSlaughteredCATTLEexclcalves", "", names(df_sa))
df_sa <- drop_na(df_sa)
df_sa <- df_sa[, !names(df_sa) %in% 'TotalState']
df_sa$Date <- as.Date(df_sa$Date)

#Generate long format of data frame for easier plotting below.
df_sa_long <- pivot_longer(df_sa, cols = -Date, names_to = "State", values_to = "Number_Slaughtered")
df_sa_long$State <- as.factor(df_sa_long$State)
df_sa_long$Date <- as.Date(df_sa_long$Date)

# Create the faceted plot using ggplot2
ggplot(df_sa_long, aes(x = Date, y = Number_Slaughtered)) +
  geom_line() +
  facet_grid(State ~ .) 


low_state = c("WesternAustralia", "Tasmania", "SouthAustralia")

for (state in low_state){ 
# Check plots for low prodcuing states
p <- ggplot(df_sa, aes_string(x = "Date", y = state)) +
  geom_line()
print(p)
} 
