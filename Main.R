# Copyright 2022 Observational Health Data Sciences and Informatics
#
# This file is part of CohortGeneratorModule
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Module methods -------------------------
getModuleInfo <- function() {
  checkmate::assert_file_exists("MetaData.json")
  return(ParallelLogger::loadSettingsFromJson("MetaData.json"))
}

# Module methods -------------------------
execute <- function(jobContext) {
  rlang::inform("Validating inputs")
  inherits(jobContext, 'list')

  if (is.null(jobContext$settings)) {
    stop("Analysis settings not found in job context")
  }
  if (is.null(jobContext$sharedResources)) {
    stop("Shared resources not found in job context")
  }
  if (is.null(jobContext$moduleExecutionSettings)) {
    stop("Execution settings not found in job context")
  }
  
  workFolder <- jobContext$moduleExecutionSettings$workSubFolder
  resultsFolder <- jobContext$moduleExecutionSettings$resultsSubFolder
  
  rlang::inform("Executing PLP")
  moduleInfo <- getModuleInfo()
  
  # Creating database details
  databaseDetails <- PatientLevelPrediction::createDatabaseDetails(
    connectionDetails = jobContext$moduleExecutionSettings$connectionDetails, 
    cdmDatabaseSchema = jobContext$moduleExecutionSettings$cdmDatabaseSchema,
    cohortDatabaseSchema = jobContext$moduleExecutionSettings$workDatabaseSchema,
    cdmDatabaseName = jobContext$moduleExecutionSettings$connectionDetailsReference, 
    cohortTable = jobContext$moduleExecutionSettings$cohortTableNames$cohortTable, 
    outcomeDatabaseSchema = jobContext$moduleExecutionSettings$workDatabaseSchema, 
    outcomeTable = jobContext$moduleExecutionSettings$cohortTableNames$cohortTable
  )
  
  # find where cohortDefinitions are as sharedResources is a list
  ind <- which(unlist(lapply(jobContext$sharedResources, function(x) 'cohortDefinitions' %in% names(x))))[1]
                
  # run the models
  PatientLevelPrediction::runMultiplePlp(
    databaseDetails = databaseDetails, 
    modelDesignList = jobContext$settings, 
    cohortDefinitions = jobContext$sharedResources[[ind]]$cohortDefinitions,
    saveDirectory = workFolder
      )
  
  # Export the results
  rlang::inform("Export data to csv files")

  sqliteConnectionDetails <- DatabaseConnector::createConnectionDetails(
    dbms = 'sqlite',
    server = file.path(workFolder, "sqlite","databaseFile.sqlite")
  )
    
  PatientLevelPrediction::extractDatabaseToCsv(
    connectionDetails = sqliteConnectionDetails, 
    databaseSchemaSettings = PatientLevelPrediction::createDatabaseSchemaSettings(
      resultSchema = 'main', # sqlite settings
      tablePrefix = '', # sqlite settings
      targetDialect = 'sqlite', 
      tempEmulationSchema = NULL
    ), 
    csvFolder = file.path(workFolder, 'results'),
    fileAppend = 'plp_'
  )
  
  # Export the resultsDataModelSpecification.csv
  resultsDataModel <- CohortGenerator::readCsv(
    file = system.file(
      "settings/resultsDataModelSpecification.csv",
      package = "PatientLevelPrediction"
    ),
    warnOnCaseMismatch = FALSE
  )
  
  # add the prefix to the tableName column
  resultsDataModel$tableName <- paste0(moduleInfo$TablePrefix, resultsDataModel$tableName)
  
  CohortGenerator::writeCsv(
    x = resultsDataModel,
    file = file.path(resultsFolder, "resultsDataModelSpecification.csv"),
    warnOnCaseMismatch = FALSE,
    warnOnFileNameCaseMismatch = FALSE,
    warnOnUploadRuleViolations = FALSE
  )  
  
  # Zip the results
  rlang::inform("Zipping csv files")
  DatabaseConnector::createZipFile(
    zipFile = file.path(resultsFolder, 'results.zip'),
    files = file.path(workFolder, 'results')
  )
  
  
}