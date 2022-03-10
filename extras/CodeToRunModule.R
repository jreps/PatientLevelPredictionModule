# First start by constructing this jobContext object
# This would be done upstream by something like targets
exampleSpecificationPath <- file.path(getwd(), "extras","sample_analysis_specification.json")

jobContext <- PatientLevelPrediction::loadPlpAnalysesJson(exampleSpecificationPath)

# Probably worth logging the job context at this point before sensitive info
# is added to the context
#ParallelLogger::loadSettingsFromJson()
ParallelLogger::logDebug("jobContext = ", jobContext)
# Add the connection details
jobContext$databaseDetails$connectionDetails <- Eunomia::getEunomiaConnectionDetails()

# Now validate that the module has the necessary info 
# in the job context to execute
PatientLevelPredictionModule::validate(jobContext = jobContext)

# Execute the module
PatientLevelPredictionModule::execute(jobContext = jobContext)

# Export the results
PatientLevelPrediction::exportResults(jobContext = jobContext)

# For cleanup after the test
unlink(jobContext$saveDirectory, recursive = TRUE, force = TRUE)

# Run again using a "real" database
rsConnectionDetails <- DatabaseConnector::createConnectionDetails(dbms = "redshift",
                                                                  server = paste(keyring::key_get("OHDA_PROD_1_SERVER"), "ims_australia_lpd", sep = "/"),
                                                                  user = keyring::key_get("OHDA_PROD_1_USERNAME"),
                                                                  password = keyring::key_get("OHDA_PROD_1_PASSWORD"),
                                                                  extraSettings = "ssl=true&sslfactory=com.amazon.redshift.ssl.NonValidatingFactory")

jobContext$databaseDetails <- PatientLevelPrediction::createDatabaseDetails(
  connectionDetails = rsConnectionDetails, 
  cdmDatabaseSchema = "cdm_ims_australia_lpd_v1945",
  cohortDatabaseSchema = "scratch_asena5",
  cdmDatabaseName = 'ims_australia', 
  cohortTable = 'cohort', 
  outcomeDatabaseSchema = "scratch_asena5", 
  outcomeTable = 'cohort'
  )

# Now validate that the module has the necessary info 
# in the job context to execute
PatientLevelPredictionModule::validate(jobContext = jobContext)

# Execute the module
PatientLevelPredictionModule::execute(jobContext = jobContext)

# Export the results
PatientLevelPredictionModule::exportResults(jobContext = jobContext)

# For cleanup after the test
unlink(jobContext$saveDirectory, recursive = TRUE, force = TRUE)
