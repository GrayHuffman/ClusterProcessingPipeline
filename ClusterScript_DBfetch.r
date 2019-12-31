
library(httr)
library(stringr)
library(readr)
library(googlesheets4)
library(dplyr)

options(httr_oauth_cache=T)

url <- "https://docs.google.com/spreadsheets/d/1q7ec_FAsfvBVbPezmMpPoVMd0B5jCcgqzIZL_tOxNmc/edit?usp=sharing"
print("post url")
if (interactive()) {
  sheets_deauth()
  sheets_user()

  DB2 <- read_sheet(url, sheet = "DB")
  print("post pull")
  write.csv(DB2, file = "MS_Runs_DB.csv", row.names = FALSE, quote=FALSE)
  print("post write")
} else {
  sheets_deauth()
  sheets_user()
  DB2 <- read_sheet(url, sheet = "DB")
  print("post pull")
  write.csv(DB2, file = "C:/Users/G.Huffman/Documents/AutoClusterPipeline/MS_Runs_DB.csv", row.names = FALSE, quote=FALSE)
}
#write.csv(DB2, file = "C:/Users/G.Huffman/Documents/AutoClusterPipeline/MS_Runs_DB.csv", row.names = FALSE, quote=FALSE)
