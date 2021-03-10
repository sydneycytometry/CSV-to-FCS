# FCS to CSV
    # Coverting .fcs file data into an .csv file
    # Thomas Ashhurst
    # 2017-09-13
    # github.com/sydneycytometry
    # .fcs file reading and writing adapted from https://gist.github.com/yannabraham/c1f9de9b23fb94105ca5


##### USER INPUT #####
    
    # Install packages if required
    rver = R.version
    if (rver$major < 3 || (rver$major == 3 && rver.minor <= 5)){
      # keep backwards compatibility for older R versions
      if(!require('flowCore')) {install.packages('flowCore')}
      if(!require('Biobase')) {install.packages('Biobase')}
    } else {
      # using BiocManager for future compatibility with R
      if(!requireNamespace("BiocManager", quietly = TRUE))
      {
        # there's usually no need to install from source, install remote packages instead
        install.packages("BiocManager", quiet = TRUE)
        # the update argument suppresses BiocManager's automated update dialog prompt
        if(!require('flowCore')) {BiocManager::install("flowCore", update = FALSE)}
        if(!require('Biobase')) {BiocManager::install("Biobase", update = FALSE)}
      }
    }
    if(!require('data.table')) {install.packages('data.table')}
    if(!require('rstudioapi')) {install.packages('rstudioapi')}
    
    # Load packages
    library('flowCore')
    library('Biobase')
    library('data.table')
    
    # In order for this to work, a) rstudioapi must be installed and b) the location of this .r script must be in your desired working directory
    dirname(rstudioapi::getActiveDocumentContext()$path)            # Finds the directory where this script is located
    setwd(dirname(rstudioapi::getActiveDocumentContext()$path))     # Sets the working directory to where the script is located
    getwd()
    PrimaryDirectory <- getwd()
    PrimaryDirectory
    
    # Use this to manually set the working directory
    #setwd("/Users/Tom/Desktop/Experiment")                          # Set your working directory here (e.g. "/Users/Tom/Desktop/") -- press tab when selected after the '/' to see options
    #getwd()                                                         # Check your working directory has changed correctly
    #PrimaryDirectory <- getwd()                                     # Assign the working directory as 'PrimaryDirectory'
    #PrimaryDirectory
    
    ## Use to list the .csv files in the working directory -- important, the only CSV files in the directory should be the one desired for analysis. If more than one are found, only the first file will be used
    FileNames <- list.files(path=PrimaryDirectory, pattern = ".fcs")     # see a list of CSV files
    as.matrix(FileNames) # See file names in a list
    
    ## Read data from Files into list of data frames
    DataList=list() # Creates and empty list to start 

    for (File in FileNames) { # Loop to read files into the list
      tempdata <- exprs(read.FCS(File, transformation = FALSE))
      tempdata <- tempdata[1:nrow(tempdata),1:ncol(tempdata)]
      File <- gsub(".fcs", "", File)
      DataList[[File]] <- tempdata
    }

    rm(tempdata)
    AllSampleNames <- names(DataList)
    
    ## Chech data quality
    head(DataList)

    
    
##### END USER INPUT #####
    
    x <- Sys.time()
    x <- gsub(":", "-", x)
    x <- gsub(" ", "_", x)
    
    newdir <- paste0("Output_FCS-to-CSV", "_", x)
    
    setwd(PrimaryDirectory)
    dir.create(paste0(newdir), showWarnings = FALSE)
    setwd(newdir)
    
    
    for(i in c(1:length(AllSampleNames))){
      data_subset <- DataList[i][[1]]
      data_subset <- as.data.frame(data_subset)
      colnames(data_subset)
      #data_subset <- rbindlist(as.list(data_subset$sample_data))
      dim(data_subset)
      a <- names(DataList)[i]

      write.csv(data_subset, paste0(a, ".csv"))
    }
    
