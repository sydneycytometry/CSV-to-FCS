# FCS to CSV
    # Coverting .fcs file data into an .csv file
    # Thomas Ashhurst
    # 2017-09-13
    # github.com/sydneycytometry
    # .fcs file reading and writing adapted from https://gist.github.com/yannabraham/c1f9de9b23fb94105ca5


##### USER INPUT #####

    # Install packages if required
    if(!require('flowCore')) {install.packages('flowCore')}

    # Load packages
    library('flowCore')

    # Set working directory
    getwd()
    setwd("/Users/Tom/Desktop/SampleFolder/FCS-to-CSV/") # set to your desired working folder (directory)
    PrimaryDirectory <- getwd()

    # Find file names of .fcs files in the current working directory
    FileNames <- list.files(path=PrimaryDirectory, pattern = ".fcs")
    FileNames

    # Chose which .fcs file to read into 'data' -- rename 'sample_data.fcs' to whatever file you want to read
    data <- exprs(read.FCS("sample_data.fcs", transformation = FALSE))
    data

    # Give a name for your output .csv file (don't foret to add '.csv' at the end of the name)
    csvfilename <- "sample_data.csv"


##### END USER INPUT #####

    # Create an 'output' folder
    setwd(PrimaryDirectory)
    dir.create("Output", showWarnings = FALSE)
    setwd("Output")

    # Save flowframe as .fcs file -- save data (with new tSNE parameters) as FCS
    write.csv(data, csvfilename)

    setwd(PrimaryDirectory)
