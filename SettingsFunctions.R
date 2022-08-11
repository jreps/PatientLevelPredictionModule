createPatientLevelPredictionModuleSpecifications <- function(
  modelDesignList
) {
  #analysis <- list()
  #for (name in names(formals(createCohortDiagnosticsModuleSpecifications))) {
  #  analysis[[name]] <- get(name)
  #}
  
  specifications <- list(
    module = "PatientLevelPredictionModule",
    version = "0.0.1-1",
    remoteRepo = "github.com",
    remoteUsername = "anthonysena",
    settings = modelDesignList
  )
  class(specifications) <- c("PatientLevelPredictionModuleSpecifications", "ModuleSpecifications")
  return(specifications)
}