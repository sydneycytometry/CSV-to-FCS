# CSV to FCS
    # Coverting .csv file data into an .fcs file
    # Thomas Ashhurst
    # 2017-09-13
    # github.com/sydneycytometry
    # .fcs file reading and writing adapted from https://gist.github.com/yannabraham/c1f9de9b23fb94105ca5


##### USER INPUT #####

    # Install packages if required
    if(!require('flowCore')) {install.packages('flowCore')}
    if(!require('Biobase')) {install.packages('Biobase')}

    # Load packages
    library('flowCore')
    library('Biobase')

    # Set working directory
    getwd()
    setwd("/Users/Tom/Desktop/SampleFolder/CSV-to-FCS/") # set to your desired working folder (directory)
    PrimaryDirectory <- getwd()

    # Find file names of .csv files in the current working directory
    FileNames <- list.files(path=PrimaryDirectory, pattern = ".csv")
    FileNames

    # Chose which .csv file to read into 'data' -- rename 'sample_data.csv' to whatever file you want to read
    data <- read.csv("sample_data.csv", row.names = NULL) # if the first column contains names for each row, then change "row.names = NULL" to "row.names = 1" 
    data

    # Give a name for your output .fcs file (don't foret to add '.fcs' at the end of the name)
    fcsfilename <- "sample_data.fcs"


##### END USER INPUT #####


    # Convert data to matrix
    data <- as.matrix(data)

    # Check data and data column names -- for this script to work, the first row must be the column names
    head(data)
    dimnames(data)[[2]]

    # Create FCS file metadata - column names with descriptions
    metadata <- data.frame(name=dimnames(data)[[2]],
                       desc=paste('this is column',dimnames(data)[[2]],'from your CSV')
                       )

    metadata

    # Create FCS file metadata - ranges, min, and max settings
    metadata$range <- apply(apply(data,2,range),2,diff)
    metadata$minRange <- apply(data,2,min)
    metadata$maxRange <- apply(data,2,max)

    metadata$range
    metadata$minRange
    metadata$maxRange

    # Create flowframe with tSNE data
    data.ff <- new("flowFrame",
              exprs=data,
              parameters=AnnotatedDataFrame(metadata)
              )

    data.ff

    # Create an 'output' folder
    setwd(PrimaryDirectory)
    dir.create("Output", showWarnings = FALSE)
    setwd("Output")

    # Save flowframe as .fcs file -- save data (with new tSNE parameters) as FCS
    write.FCS(data.ff, fcsfilename)

    setwd(PrimaryDirectory)
