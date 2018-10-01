# Clear out any existing global variables
library("dplyr")
library("tidyr")
rm(list = ls())

# Collect features and format them to make them suitable as column names
features <- read.table("features.txt", header = FALSE, col.names = c("id", "feature"), stringsAsFactors = FALSE)
features$feature <- gsub("\\(|\\)", "", features$feature)
features$feature <- gsub(",", "-", features$feature)

# Load and combine X data
xTrain <- read.table("train/X_train.txt", header = FALSE, col.names = c(features$feature))
xTest <- read.table("test/X_test.txt", header = FALSE, col.names = c(features$feature))
xFinal <- rbind(xTrain, xTest)

# Select only mean and std dev data
columnIndexes <- filter(features, grepl("mean|std", features$feature))$id
meanAndStdFinal <- select(xFinal, columnIndexes)

# Load and combine Y data
yTrain <- read.table("train/y_train.txt", header = FALSE, col.names = c("activity.id"))
yTest <- read.table("test/y_test.txt", header = FALSE, col.names = c("activity.id"))
yFinal <- rbind(yTrain, yTest)

# Load activity labels and merge with Y data
activities <- read.table("activity_labels.txt", header = FALSE, col.names = c("id", "activity"))
yFinal = inner_join(yFinal, activities, by = c("activity.id" = "id"))

# Load and combine subject data
subjectTrain <- read.table("train/subject_train.txt", header = FALSE, col.names = c("subject"))
subjectTest <- read.table("test/subject_test.txt", header = FALSE, col.names = c("subject"))
subjectFinal <- rbind(subjectTrain, subjectTest)

# Combine all the data and sort
dt <- cbind(subjectFinal, yFinal, meanAndStdFinal)
dt <- arrange(dt, subject, activity.id)

# Create a second, independent tidy data set with the average of each variable for each activity and each subject.
dt2 <- dt %>% group_by(subject, activity) %>% summarise_at(vars(4:82), mean)
write.table(dt2, "averages.txt")
write.csv(dt2, "averages.csv")
