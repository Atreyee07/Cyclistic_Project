getwd()
setwd("C:/Users/KIIT/Desktop/Cyclist_Project")
getwd()
jan_df<-read.csv("datasets/202401-divvy-tripdata.csv")
head(jan_df)
feb_df<-read.csv("datasets/202402-divvy-tripdata.csv")
march_df<-read.csv("datasets/202403-divvy-tripdata.csv")
april_df<-read.csv("datasets/202404-divvy-tripdata.csv")
may_df<-read.csv("datasets/202405-divvy-tripdata.csv")
df_five_months<-rbind(jan_df,feb_df,march_df,april_df,may_df)
packages <- c(
  "tidyverse", "dplyr", "tidyr", "lubridate" , "janitor",
  "ggplot2")
install.packages(packages)

library(tidyverse)
library(dplyr)
library(tidyr)
library(lubridate)
library(janitor)
library(ggplot2)

#Correcting all the date formats
df_five_months$started_at <- ymd_hms(df_five_months$started_at)
df_five_months$ended_at <- ymd_hms(df_five_months$ended_at)

#Removed all rows that contain NA
df_five_months_clean <- na.omit(df_five_months)

#Added a new column ride_length
df_five_months_clean <- df_five_months_clean %>%
  mutate(ride_length = ended_at - started_at)

# Add new column day_of_week with Sunday as 1 and Saturday as 7
df_five_months_clean <- df_five_months_clean %>%
  mutate(day_of_week = wday(started_at)) %>% 
  mutate(day_of_week = ifelse(day_of_week == 1, 7, day_of_week - 1)) 

colnames(df_five_months_clean)

#converting ride_length to numeric
df_five_months_clean <- df_five_months_clean %>%
  mutate(ride_length = as.numeric(ride_length))

#converted the ride_lengths in minutes
df_five_months_clean<-df_five_months_clean %>%
  mutate(ride_length = ride_length/60)

#Filtering only the positive ride lengths
df_five_months_clean <- df_five_months_clean %>%
  filter(ride_length >= 0)

#Seperated casual rider and member rider
casual_riders<-df_five_months_clean%>% filter(member_casual == "casual")
member_riders<-df_five_months_clean%>% filter(member_casual == "member")
head(casual_riders)
head(member_riders)

#Calculating Stats for both member and casual rider
statistics <- df_five_months_clean %>%
  group_by(member_casual) %>%
  summarize(
    mean_ride_length = mean(ride_length),
    median_ride_length = median(ride_length),
    sd_ride_length = sd(ride_length),
    min_ride_length = min(ride_length),
    max_ride_length = max(ride_length)
  )
print(statistics)

# Calculate average ride lengths
avg_ride_len <- df_five_months_clean %>%
  group_by(member_casual) %>%
  summarise(mean_length = mean(ride_length, na.rm = TRUE),
            median_length = median(ride_length, na.rm = TRUE),
            sd_length = sd(ride_length, na.rm = TRUE),
            min_length = min(ride_length, na.rm = TRUE),
            max_length = max(ride_length, na.rm = TRUE))

print(avg_ride_len)

# Plotting the average ride lengths
ggplot(avg_ride_len, aes(x = member_casual, y = mean_length, fill = member_casual)) +
  geom_bar(stat = "identity") +
  scale_fill_manual(values = c("casual" = "orange", "member" = "violet")) +
  labs(title = "Average Ride Length by User Type", x = "User Type", y = "Average Ride Length (minutes)") +
  theme_minimal()
# Count the number of rides by user type
freq_of_ride <- df_five_months_clean %>%
  group_by(member_casual) %>%
  summarise(ride_count = n())

print(freq_of_ride)

# Plotting the frequency of rides
ggplot(freq_of_ride, aes(x = member_casual, y = ride_count, fill = member_casual)) +
  geom_bar(stat = "identity") +
  scale_fill_manual(values = c("casual" = "orange", "member" = "violet")) +
  coord_flip() +
  labs(title = "Frequency of Rides by User Type", x = "User Type", y = "Number of Rides") +
  theme_minimal()

# Count the number of rides by day of the week and user type
ride_count_wrt_day <- df_five_months_clean %>%
  group_by(day_of_week, member_casual) %>%
  summarise(ride_count = n())

print(ride_count_wrt_day)

# Plotting the frequency of rides by day of the week
ggplot(ride_count_wrt_day, aes(x = day_of_week, y = ride_count, fill = member_casual)) +
  geom_bar(stat = "identity", position = "dodge") +
  scale_fill_manual(values = c("casual" = "orange", "member" = "violet")) +
  labs(title = "Frequency of Rides by Day of Week and User Type", x = "Day of Week", y = "Number of Rides") +
  theme_minimal()


