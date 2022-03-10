# Copyright 2022 Observational Health Data Sciences and Informatics
#
# This file is part of PatientLevelPredictionModule
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

#' @export
validate <- function(jobContext) {
  logStatus("Validate")
  # Verify the job context details - this feels like a task to centralize for
  # all modules
  checkmate::assert_list(x = jobContext)
  
  if (is.null(jobContext$databaseDetails)) {
    stop("databaseDetails not found in job context")
  }
  
  if (is.null(jobContext$logSettings)) {
    stop("logSettingsnot found in job context")
  }
  
  if (is.null(jobContext$analysis)) {
    stop("Analysis not found in job context")
  }
  if (is.null(jobContext$splitSettings)) {
    stop("Split Settings not found in job context")
  }
  
  if (is.null(jobContext$saveDirectory)) {
    stop("saveDirectory not found in job context")
  }
  
  plpAnalysis <- PatientLevelPrediction::loadPlpAnalysesJson(jsonObject = jobContext)

  invisible(plpAnalysis)
}

#' @export
execute <- function(jobContext) {
  logStatus("Execute")
  # Establish the connection and ensure the cleanup is performed

  databaseDetails <- do.call(
    PatientLevelPrediction::createDatabaseDetails,
    jobContext$databaseDetails
  )
  
  modelDesignList <- jobContext$analysis
  
  splitSettings <- jobContext$splitSettings
    
  logSettings <- do.call(
    PatientLevelPrediction::createLogSettings,
    jobContext$logSettings
  )

  # code to run plp
  PatientLevelPrediction::runMultiplePlp(
    databaseDetails = databaseDetails, 
    modelDesignList = modelDesignList, 
    splitSettings = splitSettings, 
    logSettings = logSettings, 
    saveDirectory = jobContext$saveDirectory
    )
}

#' @export
exportResults <- function(jobContext) {
  logStatus("Export data") 
  return(NULL)
}

#' @export
importResults <- function(jobContext) {
  return(NULL)
}
