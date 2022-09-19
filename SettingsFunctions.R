createPatientLevelPredictionModuleSpecifications <- function(
  modelDesignList
) {
  #analysis <- list()
  #for (name in names(formals(createCohortDiagnosticsModuleSpecifications))) {
  #  analysis[[name]] <- get(name)
  #}
  
  specifications <- list(
    module = "PatientLevelPredictionModule",
    version = "0.0.5",
    remoteRepo = "github.com",
    remoteUsername = "jreps",
    settings = modelDesignList
  )
  class(specifications) <- c("PatientLevelPredictionModuleSpecifications", "ModuleSpecifications")
  return(specifications)
}