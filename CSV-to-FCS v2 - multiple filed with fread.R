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
    FileNames <- list.files(path=PrimaryDirectory, pattern = ".csv")     # see a list of CSV files
    
    ## File details
    file.type               <- ".csv"         # Specfiy file type (".csv" or ".fcs") -- readings .fcs files not currently functional
    data.name               <- "TA206-2_BM_LCMV"    # a new name for the data - suggest name is sampletype_date_time (e.g. liver_20180203_1400)
    
    ## Check the list of files
    FileNames <- list.files(path=PrimaryDirectory, pattern = file.type) # Generate list of files
    as.matrix(FileNames) # See file names in a list
    
    ## Read data from Files into list of data frames
    DataList=list() # Creates and empty list to start 
    Length_check = list() # creates an empty list
    ColName_check = list() 
    nrow_check = list()
    
    if (file.type == ".csv"){
      for (File in FileNames) { # Loop to read files into the list
        tempdata <- fread(File, check.names = FALSE)
        File <- gsub(".csv", "", File)
        DataList[[File]] <- tempdata
      }
      for(i in c(1:(length(DataList)))){Length_check[[i]] <- length(names(DataList[[i]]))} # creates a list of the number of columns in each sample
      for(i in c(1:(length(DataList)))){ColName_check[[i]] <- names(DataList[[i]])}
      name.table <- data.frame(matrix(unlist(ColName_check), nrow = length(DataList), byrow = T))
      for(i in c(1:(length(DataList)))){nrow_check[[i]] <- nrow(DataList[[i]])}
    }
  
    rm(tempdata)

    
    
    

##### END USER INPUT #####

    
    if(write.sep.files == 1){
      
      for (a in AllSampleNames) {
        
        data_subset <- subset(data, SampleName == a)
        dim(data_subset)
        
        ## write .csv
        write.csv(data_subset, file = paste(data.name, "_", a,".csv", sep = ""), row.names=FALSE)
        
        ## write .fcs
        metadata <- data.frame(name=dimnames(data_subset)[[2]],desc=paste('column',dimnames(data_subset)[[2]],'from dataset'))
        
        ## Create FCS file metadata - ranges, min, and max settings
        #metadata$range <- apply(apply(data_subset,2,range),2,diff)
        metadata$minRange <- apply(data_subset,2,min)
        metadata$maxRange <- apply(data_subset,2,max)
        
        data_subset.ff <- new("flowFrame",exprs=as.matrix(data_subset), parameters=AnnotatedDataFrame(metadata)) # in order to create a flow frame, data needs to be read as matrix by exprs
        head(data_subset.ff)
        write.FCS(data_subset.ff, paste0(data.name, "_", a, ".fcs"))
      }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    

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
