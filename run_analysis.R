run_analysis <- function ()
{
      ## Path to the directory containing the data sets
      path <- "./UCI HAR Dataset/"

      ## URL for the zip file containing the data
      fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
      
      ## Check to see if the data is already downloaded and unpacked.  
      ##  If not, download the file & unzip
      if (!file.exists(path))  {
            download.file(fileURL, destfile = "./run_data.zip", method="curl")
            unzip("./run_data.zip")
      }
      
      ##-------------------------------
      ## Read the test data
      ## Subject data - Identifiers for people acting as test subjects
      testSubjects <- read.table(file.path(path, "test", "subject_test.txt"))

      ## X data - Measurement data for various features of test
      testX <- read.table(file.path(path, "test", "X_test.txt"))
      
      ## Y data - Activity identifiers - identify what activity (i.e. Walking, Sitting, etc) are the 
      ## measurements for
      testY <- read.table(file.path(path, "test", "Y_test.txt"))
      
      ## Combine the test tables
      testData <- cbind (testSubjects, testY, testX)
      
      ##-------------------------------
      ## Read the training data
      ## Subject data - Identifiers for people acting as test subjects
      trainSubjects <- read.table(file.path(path, "train", "subject_train.txt"))
      
      ## X data - Measurement data for various features of test
      trainX <- read.table(file.path(path, "train", "X_train.txt"))
      
      ## Y data - Activity identifiers - identify what activity (i.e. Walking, Sitting, etc) are the 
      ## measurements for
      trainY <- read.table(file.path(path, "train", "Y_train.txt"))
      
      ## Combine the training tables
      trainData <- cbind (trainSubjects, trainY, trainX)
      
      ##------------------
      ## Merge all data
      allData <- rbind(trainData, testData)
      
      
      ## load column names from features file.  
      ## Feature file has listing of the columns for the X data
      ## Column 1 is column #
      ## Column 2 is the column name
      colNames <- read.table(file.path(path, "features.txt"))
      
      ## Add two new rows
      ## These are for the first two columns which are
      ## subject IDs and Activity Number
      colNames <- rbind (data.frame(V1=0, V2="Subject"),data.frame(V1=0, V2="ActivityNum"), colNames)
      
      ## apply column names to the merged data
      ## Now the data has descriptive column names
      colnames(allData) <- colNames[,2]
      
      ## Find all column names that have words "mean" or "std" in them.
      ## Choose those columns plus the first two (Subject ID and Activity Number)
      ## Store results in a new dataframe
      allData2 <- cbind(allData[,1:2], allData [, grepl("mean", names(allData)) | grepl("std",names(allData))])
      
      
      ## Add descriptive activity names
      ## First read the table containing the activity names and mapping to 
      ## Activity Numbers
      activityNames <- read.table(file.path(path, "activity_labels.txt"))
      colnames(activityNames) <- c("ActivityNum", "ActivityName")
      
      ## Merge activity names with the merged data
      allData2 <- merge (allData2, activityNames, by="ActivityNum", all=TRUE)
      
      ## Now we have all data merged, with only selected mean and std columns
      ## Also have Activity names in there.
      ## Now make the data tall and narrow, around Activity Name and Subject IDs
      meltedData <-melt(allData2, id=c("ActivityName", "Subject"))
      
      ## Finally, collapse all the mean and std variables into their mean
      ## per each reading of Activity Name and Subject
      meltedData <- cast(meltedData, ActivityName+Subject~variable, mean)
      
      ## Write out the file into a text file
      write.table(meltedData, file="./run_analysis.txt", row.name=FALSE)
      
      ## Return the final table
      meltedData
      
}

