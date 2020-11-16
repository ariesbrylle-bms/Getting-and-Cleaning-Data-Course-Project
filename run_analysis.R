# set project directory
dataDir <- "~/Documents/Coursera/Getting and Cleaning Data Course Project/Project"
setwd(dataDir)

# load library
library(dplyr)

# download dataset
# NOTE: Run this part of script if data folder is not yet in the project directory
dataURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(dataURL, destfile = "data.zip")
unzip("data.zip")
file.remove("data.zip")

# import dataset
x_train <- read.table(paste0(dataDir, "/UCI HAR Dataset/train/X_train.txt"))
y_train <- read.table(paste0(dataDir, "/UCI HAR Dataset/train/Y_train.txt"))
subject_train <- read.table(paste0(dataDir, "/UCI HAR Dataset/train/subject_train.txt"))

x_test <- read.table(paste0(dataDir, "/UCI HAR Dataset/test/X_test.txt"))
y_test <- read.table(paste0(dataDir, "/UCI HAR Dataset/test/Y_test.txt"))
subject_test <- read.table(paste0(dataDir, "/UCI HAR Dataset/test/subject_test.txt"))

#### 1. Merges the training and the test sets to create one data set. ####
# merge x_y train/test
train_df <- cbind(x_train, y_train, subject_train)
test_df <- cbind(x_test, y_test, subject_test)

# merge train and test data
final_df <- rbind(train_df, test_df)

#### 2. Extracts only the measurements on the mean and standard deviation for each measurement ####
features <- read.table(paste0(dataDir, "/UCI HAR Dataset/features.txt"))
features <- rbind(features, data.frame("V1" = 562, "V2" = "ActivityId"))
features <- rbind(features, data.frame("V1" = 563, "V2" = "Subject"))
features$V2 <- gsub("-mean", "Mean", features$V2)
features$V2 <- gsub("-std", "Std", features$V2)
features$V2 <- gsub("[-()]", "", features$V2)

#### 3. Appropriately labels the data set with descriptive variable names. ####
colnames(final_df) <- features$V2

selectedCols <- grep("(Mean|Std|Subject|ActivityId).*", as.character(features[,2]))
selectedColNames <- features[selectedCols, 2]
final_df <- select(final_df, selectedColNames)

#### 4. Uses descriptive activity names to name the activities in the data set ####
activityLabel <- read.table(paste0(dataDir, "/UCI HAR Dataset/activity_labels.txt"))
activityLabel[,2] <- as.character(activityLabel[,2])
colnames(activityLabel) <- c("id","Activity")

final_df <- merge(final_df, activityLabel, by.x = "ActivityId","id") %>% select(-ActivityId)

#### 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
tidy_df <- aggregate( . ~ Subject + Activity, data = final_df, FUN = mean )
write.table( tidy_df, "tidy_dataset.txt", row.names = FALSE )




