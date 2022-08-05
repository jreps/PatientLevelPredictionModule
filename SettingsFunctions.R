createPatientLevelPredictionModuleSpecifications <- function(
  modelDesignList
) {
  #analysis <- list()
  #for (name in names(formals(createCohortDiagnosticsModuleSpecifications))) {
  #  analysis[[name]] <- get(name)
  #}
  
  specifications <- list(
    module = "PatientLevelPredictionModule",
    version = "0.0.1",
    remoteRepo = "github.com",
    remoteUsername = "ohdsi",
    settings = modelDesignList
  )
  class(specifications) <- c("PatientLevelPredictionModuleSpecifications", "ModuleSpecifications")
  return(specifications)
}