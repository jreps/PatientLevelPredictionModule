modelDesign1 <- PatientLevelPrediction::createModelDesign(
  targetId = 1, 
  outcomeId = 2, 
  restrictPlpDataSettings = PatientLevelPrediction::createRestrictPlpDataSettings(), 
  populationSettings = PatientLevelPrediction::createStudyPopulationSettings(
    firstExposureOnly = T, 
    requireTimeAtRisk = F, 
    riskWindowStart = 1, 
    riskWindowEnd = 365), 
  covariateSettings = FeatureExtraction::createCovariateSettings(
    useDemographicsGender = T, 
    useDemographicsAge = T, 
    useConditionOccurrenceLongTerm = T), 
  featureEngineeringSettings = PatientLevelPrediction::createFeatureEngineeringSettings(),
  sampleSettings = PatientLevelPrediction::createSampleSettings(), 
  preprocessSettings = PatientLevelPrediction::createPreprocessSettings(
    normalize = T, 
    minFraction = 0.001
    ), 
  modelSettings = PatientLevelPrediction::setLassoLogisticRegression(), 
  runCovariateSummary = T
  )

jobContext$settings <- list(modelDesign1)

jobContext$logSettings <- list(
  verbosity = 'TRACE',
  logName = 'plp_module'
  )

cdmDatabaseName <- 'eunomia'
connectionDetails <- 'Eunomia::getEunomiaConnectionDetails()'
cdmDatabaseSchema <- "main"
cohortTable <- "cohort"

jobContext$databaseDetails <- list(
  connectionDetails = connectionDetails,
  cdmDatabaseSchema = cdmDatabaseSchema,
  cdmDatabaseName = cdmDatabaseName,
  tempEmulationSchema = cdmDatabaseSchema,
  cohortDatabaseSchema = cdmDatabaseSchema,
  cohortTable = cohortTable,
  outcomeDatabaseSchema = cdmDatabaseSchema,
  outcomeTable = cohortTable,
  cdmVersion = 5
)

jobContext$saveDirectory <- file.path(tempdir(), 'plp')

# save the json:
jobContextJson <- jsonlite::toJSON(
  x = jobContext, 
  pretty = T, 
  digits = 23, 
  auto_unbox=TRUE, 
  null = "null",
  keep_vec_names=TRUE # fixing issue with jsonlite dropping vector names
)

write(
  x = jobContextJson,
  file = file.path(getwd(),"extras","sample_analysis_specification.json")
)


