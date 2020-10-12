library(Epi786SecondRun)

# Optional: specify where the temporary files (used by the Andromeda package) will be created:
options(andromedaTempFolder = "D:/andromedaTemp")
path <- rstudioapi::getActiveProject()

# Maximum number of cores to be used:
maxCores <- parallel::detectCores()

# The folder where the study intermediate and result files will be written:
outputFolder <- paste0(path, "/results")
unlink(x = outputFolder, recursive = TRUE, force = TRUE)
dir.create(outputFolder, showWarnings = FALSE, recursive = TRUE)

# Details for connecting to the server:
connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = 'pdw',
                                                                server = "",
                                                                user = NULL,
                                                                password = NULL,
                                                                port = 17001)

a <- ROhdsiWebApi::getCdmSources(baseUrl = )
# The name of the database schema where the CDM data can be found:
cdmDatabaseSchema <- "cdm_premier_covid_v1240.dbo"

# The name of the database schema and table where the study-specific cohorts will be instantiated:
cohortDatabaseSchema <- "scratch.dbo"
cohortTable <- "cohort_epi786"

# Some meta-information that will be used by the export function:
databaseId <- "cdm_premier_covid_v1240"
databaseName <- "PremierCovid_v1240"
databaseDescription <- "PremierCovid_v1240"

# For Oracle: define a schema that can be used to emulate temp tables:
oracleTempSchema <- NULL

execute(connectionDetails = connectionDetails,
        cdmDatabaseSchema = cdmDatabaseSchema,
        cohortDatabaseSchema = cohortDatabaseSchema,
        cohortTable = cohortTable,
        oracleTempSchema = oracleTempSchema,
        outputFolder = outputFolder,
        databaseId = databaseId,
        databaseName = databaseName,
        databaseDescription = databaseDescription,
        createCohorts = TRUE,
        synthesizePositiveControls = TRUE,
        runAnalyses = TRUE,
        packageResults = TRUE,
        maxCores = maxCores)

resultsZipFile <- file.path(outputFolder, "export", paste0("Results_", databaseId, ".zip"))
dataFolder <- file.path(outputFolder, "shinyData")

# You can inspect the results if you want:
prepareForEvidenceExplorer(resultsZipFile = resultsZipFile, dataFolder = dataFolder)
launchEvidenceExplorer(dataFolder = dataFolder, blind = FALSE, launch.browser = FALSE)

# Upload the results to the OHDSI SFTP server:
privateKeyFileName <- ""
userName <- ""
uploadResults(outputFolder, privateKeyFileName, userName)
