# CSV to FCS
    # Coverting .csv file data into an .fcs file
    # Thomas Ashhurst
    # 2017-09-13
    # github.com/sydneycytometry
    # .fcs file reading and writing adapted from https://gist.github.com/yannabraham/c1f9de9b23fb94105ca5


##### USER INPUT #####

    # Install packages if required
    # BiocManager is used to provide compatibility for flowCore for R version 3.6 and above.
    if (!requireNamespace("BiocManager", quietly = TRUE))
      install.packages("BiocManager")
    BiocManager::install("flowCore")
    BiocManager::install("Biobase")
    
    if(!require('data.table')) {install.packages('data.table')}

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
    FileNames <- list.files(path=PrimaryDirectory, pattern = "\\.csv$")     # see a list of CSV files
    as.matrix(FileNames) # See file names in a list
    
    ## Read data from Files into list of data frames
    DataList=list() # Creates and empty list to start 

    for (File in FileNames) { # Loop to read files into the list
      tempdata <- fread(File, check.names = FALSE)
      File <- gsub(".csv", "", File)
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

    newdir <- paste0("Output_CSV-to-FCS", "_", x)
    
    setwd(PrimaryDirectory)
    dir.create(paste0(newdir), showWarnings = FALSE)
    setwd(newdir)
    
    
    for(i in c(1:length(AllSampleNames))){
      data_subset <- DataList[i]
      data_subset <- rbindlist(as.list(data_subset))
      dim(data_subset)
      a <- names(DataList)[i]

      metadata <- data.frame(name=dimnames(data_subset)[[2]],desc=paste('column',dimnames(data_subset)[[2]],'from dataset'))
      
      ## Create FCS file metadata - ranges, min, and max settings
      #metadata$range <- apply(apply(data_subset,2,range),2,diff)
      metadata$minRange <- apply(data_subset,2,min)
      metadata$maxRange <- apply(data_subset,2,max)
      
      data_subset.ff <- new("flowFrame",exprs=as.matrix(data_subset), parameters=AnnotatedDataFrame(metadata)) # in order to create a flow frame, data needs to be read as matrix by exprs
      head(data_subset.ff)
      write.FCS(data_subset.ff, paste0(a, ".fcs"))
    }

    