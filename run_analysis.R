#Downloads file and stores it in DATA folder. Folder is then unzipped
if(!file.exists("./DATA")){dir.create("./DATA")}
download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",destfile = "./DATA/UCI.zip")
unzip("./DATA/UCI.zip")

#For 3 separate data sets (x,y,subject), combined training and test sets using rbind()
xtrain<-read.table("./UCI HAR Dataset/train/X_train.txt")
xtest<-read.table("./UCI HAR Dataset/test/X_test.txt")
xtotal<-rbind(xtrain,xtest)
ytrain<-read.table("./UCI HAR Dataset/train/y_train.txt")
ytest<-read.table("./UCI HAR Dataset/test/y_test.txt")
ytotal<-rbind(ytrain,ytest)
subjecttrain<-read.table("./UCI HAR Dataset/train/subject_train.txt")
subjecttest<-read.table("./UCI HAR Dataset/test/subject_test.txt")
subjecttotal<-rbind(subjecttrain,subjecttest)

#Uses the grep() function to return the row numbers where either "mean" or"std" is found
features<-read.table("./UCI HAR Dataset/features.txt")
mean<-grep("mean",features[,2])
sd<-grep("std",features[,2])

#Uses the numbers returned by grep to select the corresponding columns in the x dataset. Filtered by mean and std separately and then combined using cbind()
xtotalmean<-xtotal[,mean]
colnames(xtotalmean)<-features[mean,2]
xtotalsd<-xtotal[,sd]
colnames(xtotalsd)<-features[sd,2]
xextract<-cbind(xtotalmean,xtotalsd)

#Read the labels into R and removed the '_' symbol. Matched the number corresponding to each label for all of y.
alabels<-read.table("./UCI HAR Dataset/activity_labels.txt")
alabels[,2]<-gsub("_"," ",alabels[,2])
ytotal[,1]<-alabels[ytotal[,1],2]

#Renamed the columns of ytotal and subject total to "Activity Done" and "Subject" respectively and used cbind() to merge xtotal,ytotal,and subjecttotal
colnames(ytotal)<-"Activity Done"
colnames(subjecttotal)<-"Subject"
dataset<-cbind(subjecttotal,ytotal,xextract)
write.table(dataset,"./DATA/mergedtable.txt", row.name=FALSE)

#Used the aggregate() function to sort the data by subject and activity done and used FUN=mean to find the average for each combination of subject and activity
data2<-aggregate(dataset,by=list(dataset$Subject,dataset$`Activity Done`),FUN=mean)

#Since new columns are created through the aggregate() function, while others are empty, I delete the unnecessary columns and I rename the next two columns
data2$Subject<- NULL
data2$`Activity Done`<-NULL
names(data2)[1]<-paste("Subject")
names(data2)[2]<-paste("Actvity Done")
write.table(dataset,"./DATA/meantable.txt", row.name=FALSE)
