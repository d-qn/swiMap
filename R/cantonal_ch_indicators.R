##' Swiss cantonal indicators
##'
##' Load socio-demographic data by the Swiss Statistical Office.   
##'
##' Run processPortraitsRegionauxCantons() to generate a readable csv file for loadCantonsCHportraits
##'
##' @rdname cantonal_ch_indicators
##' @param file the name of the csv file processed by processPortraitsRegionauxCantons to load
##' @return a data.frame
##' @export
##' @examples
##' \dontrun{
##' cantonalI <- loadCantonsCHportraits()
##' }
loadCantonsCHportraits <- function(file = "cantonal_CH_2016_indicators_je-f-21.03.02.csv") {
  data.path <- dir(system.file("extdata", package="swiMap"), file, full.names = T)
  data.read <- read.csv(data.path, stringsAsFactors = F, check.names = FALSE, header = T, row.names = 1)
  data.read
}

##' Process Portraits régionaux de la Suisse canton xls
##' @rdname cantonal_ch_indicators
##' @param file the raw excel file name from the Swiss Statistical office with indicators by canton
##' @param output the output file name to be saved in the package inst/extdata
##' @return NULL
##' @import tidyr dplyr readxl
##' @seealso \url{https://www.bfs.admin.ch/bfs/en/home/statistics/catalogues-databases.assetdetail.je-f-21.03.02.html}
##' @export
##' @examples
##' \dontrun{
##' swiMap:::processPortraitsRegionauxCantons()
##' }
processPortraitsRegionauxCantons <- function(
  file = 'je-f-21.03.02.xls', 
  output = 'cantonal_CH_2016_indicators_je-f-21.03.02.csv'  
) {
  
  out.path <- paste0(getwd(), "/inst/extdata/", output)
  data.path <- dir(system.file("extdata", package="swiMap"), file, full.names = T)
  
  xls.read <- read_excel(data.path, skip = 1)
  # discard NA rows
  na.row <- apply(xls.read, 1, function(l) all(is.na(l)))
  xls.read <- xls.read[!na.row,]
  
  # find table end, starts with '1) Selon la typologie '
  na.from <- grep("1) Selon la typologie", unlist(xls.read[,1]), fixed = T)
  xls.read <- xls.read[-(na.from:nrow(xls.read)),]
  
  # Find the rows that are titles for subsequent rows (i.e. NA rows except first column)
  na.row <- apply(xls.read, 1, function(l) all(is.na(l[-1])))
  xls.read <- xls.read[!na.row,]
  
  # relabel columsn and drop Suisse and year of data
  colnames(xls.read) <- xls.read[1,]
  colnames(xls.read)[1] <- 'indicator'
  xls.read <- xls.read[-1,]
  xls.read <- xls.read %>% select(-`Années`, -Suisse)
  
  # Find the rows that are titles for subsequent rows (i.e. NA rows except first column)
  na.row <- apply(xls.read, 1, function(l) all(is.na(l[-1])))
  xls.read <- xls.read[!na.row,]
  # drop the rows showing the % difference between 2 time perids
  xls.read <- xls.read %>% filter(!grepl('Variation en %', indicator))
  
  # drop some absolute indicators
  xls.read <- xls.read %>% filter(!grepl('(Part des surfaces bio dans la surface agricole utile totale en %|Etablissements, total|Taux de logements occupés par leur propriétaire 2)|Arrivées dans les hôtels et établissements de cure en milliers|Nuitées dans les hôtels et établissements de cure en milliers|Secteur primaire|Secteur secondaire|Secteur tertiaire|Emplois, total en milliers|Etablissements, total)', indicator, fixed = T))
  xls.read <- xls.read %>% filter(!grepl('(Emplois, total en milliers|Secteur primaire|Secteur secondaire|Secteur tertiaire|Part des surfaces bio dans la surface agricole utile totale en %|Etablissements, total|Taux de logements occupés par leur propriétaire 2)|Arrivées dans les hôtels et établissements de cure en milliers|Nuitées dans les hôtels et établissements de cure en milliers|Etablissements, total)', indicator))
  
  # rename some columns
  xls.read$indicator[grep("par km²", xls.read$indicator)] <- 'Population par km2'
  xls.read$indicator[grep("^selon", xls.read$indicator)] <- paste0("Infractions en % de la population totale ", xls.read$indicator[grep("^selon", xls.read$indicator)])
  # remove suffix number
  xls.read$indicator[grep("\\d\\)", xls.read$indicator, perl = T)] <- gsub(" \\d\\)", "", xls.read$indicator[grep("\\d\\)", xls.read$indicator, perl = T)])
  
  # make the data long
  df <- apply(t(xls.read[,-1]), 2, function(cl)  as.numeric(gsub("\\((.*)\\)", "\\1", cl)))
  colnames(df) <- unlist(xls.read[,1], use.names = F)
  rownames(df) <- colnames(xls.read[,-1])
  
  # order canton alphabetically
  write.csv(df[order(rownames(df)),], file = out.path, row.names = T)
  cat("\n\n ------ \n Saved in:" , out.path)
}

