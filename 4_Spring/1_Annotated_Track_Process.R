# ------------------------------------------------------------------------------
# GPS Track Processing for Migratory Behaviour Analysis (Post-Annotation)
# ------------------------------------------------------------------------------
# Author: Ali Moayedi
# Email: am636@st-andrews.ac.uk
# Date: October 2024
# 
# Description:
# This script processes GPS tracking data of greater white-fronted geese 
# (Anser albifrons) annotated with environmental (e.g., wind, elevation, 
# distance to coast) and geomagnetic variables using the MagGeo Tool.
# 
# Key steps include:
#   - Removing missing data produced during annotation.
#   - Ensuring consistent sampling intervals.
#   - Recalculating key movement parameters (speed, turn angles, headings).
#   - Filtering out speed-based outliers.
#   - Summarizing time intervals by individual.
# 
# Input:
#   - Annotated tracking data: 'Spring_Migration_Annotated.csv'.

# Note: 
# The annotated datasets ('Autumn_Migration_Annotated.csv' and 'Spring_Migration_Annotated.csv')
# along with identified 'Stopovers' are available in the Movebank study: 'Tracks of greater white-fronted
# geese annotated with geomagnetic and environmental information.' 
# Refer to the Movebank Data Repository for access details and the published paper 
# 'Multi-modal, interrelated navigation in migratory birds: a data mining study' for full methodology and preprocessing steps.

# Output:
#   - Final processed dataset: 'Autumn_FinalProcessed.csv'.
#   - Summarized time intervals: Printed summary by individual ('idyear').

# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Load Required Libraries
# ------------------------------------------------------------------------------
if (!requireNamespace("dplyr", quietly = TRUE)) install.packages("dplyr")
if (!requireNamespace("lubridate", quietly = TRUE)) install.packages("lubridate")
if (!requireNamespace("move", quietly = TRUE)) install.packages("move")

library(dplyr)      
library(lubridate)  
library(move)       


# ------------------------------------------------------------------------------
# Step 1: Remove Missing Data
# ------------------------------------------------------------------------------
rm(list = ls())

# Reload the filtered dataset
data <- read.csv("Spring_Migration_Annotated.csv")
data$timePosix <- as.POSIXct(data$timestamp, format = "%Y-%m-%d %H:%M:%S", tz = "UTC")


data1 <- data %>%
  arrange(individual.local.identifier, timestamp)


# Remove rows with missing values (produced during annotation)
data2 <- na.omit(data1) 



# ------------------------------------------------------------------------------
# Step 2: Calculate and Filter Time Intervals
# ------------------------------------------------------------------------------
# Calculate time intervals between GPS points
data3 <- data2 %>%
  group_by(idyear) %>%
  mutate(time_interval = difftime(lead(timePosix), timePosix, units = 'mins'))

# Filter out rows with missing time intervals (last points of trips)
data_filtered3 <- data3 %>% filter(!is.na(time_interval))



# Ensure consistent sampling intervals (minimum cumulative interval = 4 mins)
newdata <- data.frame()
newdata <- rbind(newdata, data_filtered3[1, ])
flag_index <- 1
i <- flag_index + 1

# Retain data points where time intervals between fixes are >= 4 minutes
while (i <= nrow(data_filtered3)) {
  print(i)
  if (data_filtered3$time_interval[i] >= 4) {
    newdata <- rbind(newdata, data_filtered3[i, ])
    flag_index <- i
    i <- i + 1
  } else {
    cumulative_interval <- data_filtered3$time_interval[i]
    j <- i + 1
    while (cumulative_interval < 4 && j < nrow(data_filtered3)) {
      cumulative_interval <- cumulative_interval + data_filtered3$time_interval[j]
      j <- j + 1
    }
    if (cumulative_interval >= 4) {
      newdata <- rbind(newdata, data_filtered3[i, ])
      flag_index <- j
      i <- j
    } else {
      break
    }
  }
}


write.csv(newdata, "Spring_Newinterval.csv", row.names = FALSE)



# ------------------------------------------------------------------------------
# Step 3: Calculate Movement Parameters
# ------------------------------------------------------------------------------
rm(list = ls())

# Reload the interval-filtered dataset
filtered_data <- read.csv("Spring_Newinterval.csv")

# Convert the data into a 'move' object
track_data <- move(x = filtered_data$location.long, y = filtered_data$location.lat, 
                   time = as.POSIXct(filtered_data$timestamp, format = "%Y-%m-%d %H:%M:%S", tz = "UTC"), 
                   proj = CRS("+proj=longlat +ellps=WGS84 +datum=WGS84"), 
                   data = filtered_data, animal = filtered_data$idyear)

# Calculate speed, turning angle, and heading using the move package
track_data$Calspeed2 <- unlist(lapply(speed(track_data), c, NA))
track_data$CalTurnangle2 <- unlist(lapply(turnAngleGc(track_data), function(x) c(NA, x, NA)))
track_data$CalHeading2 <- unlist(lapply(angle(track_data), c, NA))

# Convert 'move' object back to a data frame
track_df <- as.data.frame(track_data)

# Simplify column names and remove unnecessary columns
rownames(track_df) <- NULL
track_df$CalSpeed<- track_df$Calspeed2
track_df$CalTurnAngle<- track_df$CalTurnangle2
track_df$CalHeading<- track_df$CalHeading2
track_df <- track_df[, -c(19:27)]
track_df1 <- na.omit(track_df)




# --------------------------------------------------------------------------
# Step 4: Filter by Speed and Remove Outliers
# --------------------------------------------------------------------------

# Retain rows with speed > 1.6667 m/s (6 km/h)
track_df2 <- track_df1 %>%
  filter(CalSpeed > 1.6667) 

# Calculate mean and standard deviation for speed
col_mean <- mean(track_df2$CalSpeed, na.rm = TRUE)
col_sd <- sd(track_df2$CalSpeed, na.rm = TRUE)

# Calculate Z-scores to identify outliers
z_scores <- abs((track_df2$CalSpeed - col_mean) / col_sd)

# Retain non-outliers based on Z-scores (threshold = 3)
df_filtered <- track_df2[z_scores <= 3, ] # 152392




# --------------------------------------------------------------------------
# Step 5: Recalculate Movement Parameters Post-Filtering
# --------------------------------------------------------------------------
track_data2 <- move(x = df_filtered$location.long, y = df_filtered$location.lat,
                    time = as.POSIXct(df_filtered$timePosix, format = "%Y-%m-%d %H:%M:%S", tz = "UTC"),
                    proj = CRS("+proj=longlat +ellps=WGS84 +datum=WGS84"),
                    data =  df_filtered, animal = df_filtered$idyear)

track_data2$Calspeed2 <- unlist(lapply(speed(track_data2), c, NA))
track_data2$CalTurnangle2 <- unlist(lapply(turnAngleGc(track_data2), function(x) c(NA, x, NA)))
track_data2$CalHeading2 <- unlist(lapply(angle(track_data2), c, NA))


# Convert to data frame and normalize headings to 0–360 degrees
track_df2 <- as.data.frame(track_data2)

convert_heading <- function(heading) {
  ifelse(heading < 0, heading + 360, heading)
}

track_df2$CalHeading2 <- convert_heading(track_df2$CalHeading2)

# Simplify column names and remove unnecessary columns
rownames(track_df2) <- NULL
track_df2$CalSpeed<- track_df2$Calspeed2
track_df2$CalTurnAngle<- abs(track_df2$CalTurnangle2)
track_df2$CalHeading<- track_df2$CalHeading2
track_df2 <- track_df2[, -c( 19:27)]

# Remove rows with NA in specified columns
track_df2 <- na.omit(track_df2) 


# Save the final processed dataset
write.csv(track_df2, "Spring_FinalProcessed.csv", row.names = FALSE)


# --------------------------------------------------------------------------
# Step 6: Summarize Time Intervals
# --------------------------------------------------------------------------
rm(list = ls())

# Reload the processed data
df_filtered <- read.csv("Spring_FinalProcessed.csv")
df_filtered$timePosix <- as.POSIXct(df_filtered$timePosix, format = "%Y-%m-%d %H:%M:%S", tz = "UTC")

# Summarize the time intervals by individual at this stage
interval_summary <- df_filtered %>%
  group_by(idyear) %>%
  summarize(
    min_interval = min(difftime(timePosix, lag(timePosix), units = 'mins'), na.rm = TRUE),
    max_interval = max(difftime(timePosix, lag(timePosix), units = 'mins'), na.rm = TRUE),
    mean_interval = mean(difftime(timePosix, lag(timePosix), units = 'mins'), na.rm = TRUE),
    median_interval = median(difftime(timePosix, lag(timePosix), units = 'mins'), na.rm= TRUE)
  )

print(interval_summary)

# ------------------------------------------------------------------------------
# End of Script
# ------------------------------------------------------------------------------
