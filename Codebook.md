#Codebook for run_analysis.R program

## run_analysis.R
This script does the following:

1. Merges the training and the test sets to create one data set.
2. Extracts only the measurements on the mean and standard deviation for each measurement. 
3. Uses descriptive activity names to name the activities in the data set
4. Appropriately labels the data set with descriptive variable names. 
5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

## Constants

Path for the data directory:

      path <- "./UCI HAR Dataset/"

URL for the zip file containing data for this project:

      fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"


## Downloading and unpacking the data
Check to see if the data already exists in the current directory.  If not, download and unpack the data.
```
      if (!file.exists(path))  {
            download.file(fileURL, destfile = "./run_data.zip", method="curl")
            unzip("./run_data.zip")
      }
```

## Reading in the files and merging them

Read the test files and then merge them.  There are 3 sets of files to merge:
1. Subjects - has IDs of the subjects that performed the tests
2. X Data - has the data output from the test experiments (to be analyzed)
3. Y Data - associated each line of output with a particular activity that the test subject was performing such as Walking, Lying.

Note the order of the columns here: Subject ID, Activity ID, and X measurement data.

      testSubjects <- read.table(file.path(path, "test", "subject_test.txt"))
      testX <- read.table(file.path(path, "test", "X_test.txt"))
      testY <- read.table(file.path(path, "test", "Y_test.txt"))

      testData <- cbind (testSubjects, testY, testX)
 
 Read the training files and then merge them.  Again 3 files to combine.
 
      trainSubjects <- read.table(file.path(path, "train", "subject_train.txt"))
      trainX <- read.table(file.path(path, "train", "X_train.txt"))
      trainY <- read.table(file.path(path, "train", "Y_train.txt"))

      trainData <- cbind (trainSubjects, trainY, trainX)

Merge the two sets of test and training files.

      allData <- rbind(trainData, testData)

## Use descriptive column names
From above, note that columns are in order of Subject ID, Activity ID, and all X measurement columns.
Create a matrix of column names that has the descriptive names for each column.
First grab the column names for the X measurement data from the features.txt file.  This file has 2 columns (see README file): Column # and Column Name.  We won't use the Column # but need the column names.

      colNames <- read.table(file.path(path, "features.txt"))

Now we need to add descriptive names for our first two columns of the merged data set, which are related to the Subject ID and Activity ID.  Insert those as the first two rows for the colNames.

      colNames <- rbind (data.frame(V1=0, V2="Subject"),data.frame(V1=0, V2="ActivityNum"), colNames)

Now we have the column names.  Apply it to our merged dataset.

      colnames(allData) <- colNames[,2]


## Select only mean and std columns
We need to work only with mean and std column sets.  Create a new dataframe which is the first two columns of the existing data frame plus any other column that has "mean" or "std" in the name.

      allData2 <- cbind(allData[,1:2], allData [, grepl("mean", names(allData)) | grepl("std",names(allData))])


## Add descriptive names to each activity
So far we only have Activity Ids (numbers from 1 to 6).  Need to add another column that has the names associated with each activity ID.  We will do this as a table join.  First load up the names of the activities and their IDs from the activity_labels.txt (see README file).  Add descriptive column names to it.  

      activityNames <- read.table(file.path(path, "activity_labels.txt"))
      colnames(activityNames) <- c("ActivityNum", "ActivityName")

Now join this table along the ActivityNum (which is the activity IDs) with the merged data set.  This gives us a new column called "ActivityName" that has the descriptive names for each activity in the dataset.

      allData2 <- merge (allData2, activityNames, by="ActivityNum", all=TRUE)


## Transform into tidy data set
Tidy data set can be interpretted in different ways.  There is a short discussion related to this topic and this course project under this link: 

https://class.coursera.org/getdata-014/forum/thread?thread_id=31

What we are looking for one row that collapses each measurement we have left in the file (all the means and standard deviations) into its mean for each pair of activity name and subject. 

First turn the data from wide and short into narrow and long, centered (or using Excel terminology "pivoted") around Activity Names and Subject IDs.

      meltedData <-melt(allData2, id=c("ActivityName", "Subject"))

Finally, collaps the measurements to their mean for each pair fo Activity Name and Subject ID:

      meltedData <- cast(meltedData, ActivityName+Subject~variable, mean)
 
## Write out the data and return the tidy data for further analysis as the return value of the script.

      write.table(meltedData, file="./run_analysis.txt", row.name=FALSE)
      meltedData

