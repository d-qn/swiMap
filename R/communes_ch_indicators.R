##' Swiss communes socio-demographic indicators
##'
##' Load socio-demographic data by the Swiss Statistical Office.  
##' 
##' Run processPortraitsRegionauxCommune() to generate a readable csv file for loadCommunesCHportraits
##' 
##' @name communes_CH_indicators
##' @return a matrix
##' @seealso Office fédéral de la statistique > Les Régions > Communes > Données et explications (portraits): \url{https://www.bfs.admin.ch/bfs/fr/home/statistiques/statistique-regions/portraits-regionaux-chiffres-cles/communes.assetdetail.328133.html} \cr
##' The cleaning up of raw xls file: \itemize{
##'   \item Remove all the empty lines (header has 3 lines: Indicator type, indicator, year)
##'   \item Reorder the header for: indicator type, year, indicator
##'   \item Remove in the data table, the line for Switzerland 
##'   \item Remove the text at the bottom
##'   \item Save as csv
##' }
##' @details The matrix has the commune BFS code as rowname and 3 attributes: \itemize{
##' \item \code{communeName} the text name of the commune (same length as the matrix length)
##' \item \code{indicatorYear} & \code{indicatorGroup} respectively the year and the category of the communal indicator (both of same length as the matrix width). See \url{http://www.bfs.admin.ch/bfs/portal/fr/index/regionen/02/key.html}
##' }
##' @export
##' @examples
##' communeData <- loadCommunesCHportraits()
##' colnames(communeData)
##' rownames(communeData)
##' 
##' # Select only "surface" indicators
##' colIdx <- which(attr(communeData, "indicatorGroup") == "Surface")
##' head(communeData[,colIdx])
##' 
##' zipcode <- loadCHzipcode()
##' match(zipcode$Gemeindename, attr(communeData, "communeName"))
##' ##' \dontrun{
##'   colnames(data)
##'   g1 <- ggplot(data = as.data.frame(data), aes(x = `Etrangers en %`, y = UDC)) + 
##'   geom_point(aes(size = Habitants), alpha = 0.5, colour = swiTheme::swi_col[1]) 
##'   g1 + swiTheme::swi_theme()
##' }
##'
loadCommunesCHportraits <- function() {

  # get the path to communes data txt file 
  data.path <- dir(system.file("extdata", package="swiMap"), "communesCH_2016_indicators_je-f-21.03.01.csv", full.names = T)
  data.read <- read.csv(data.path, skip = 3, header = TRUE, stringsAsFactors = F, check.names = FALSE)
 
   # save ony the indicator values as a matrix
  data <- suppressWarnings(data.matrix(data.read[,-c(1:2)]))
  
  # rownames are commune BFS code
  rownames(data) <- data.read[,1]
  # attr communeName is the text name
  attr(data, "communeName") <- data.read[,2]
  
  metadata <- read.csv(data.path, nrows = 2, header = T, stringsAsFactors = F, check.names = FALSE)

  attr(data, "indicatorYear") <- unlist(metadata[2, -c(1:2)], use.names = F)
  attr(data, "indicatorGroup")<- unlist(metadata[1, -c(1:2)], use.names = F)
  
  stopifnot(
    length(attr(data, "communeName")) == nrow(data), 
    length(attr(data, "indicatorYear")) == ncol(data),
    length(attr(data, "indicatorYear")) == ncol(data)
  )
  data
}

##' Process Portraits régionaux de la Suisse commune xls
##' 
##' @rdname communes_CH_indicators
##' @param file the raw excel file name from the Swiss Statistical office with indicators by commune
##' @param output the output file name to be saved in the package inst/extdata
##' @return NULL
##' @seealso \url{http://opendata.admin.ch/de/dataset/ch-swisstopo-vd-ortschaftenverzeichnis_plz/resource/35001b61-e7c1-4124-89fa-17fac7b1139e} from: \url{http://opendata.admin.ch/de/dataset/ch-swisstopo-vd-ortschaftenverzeichnis_plz}
##' @import tidyr dplyr readxl
##' @export
##' @examples
##' \dontrun{
##' processPortraitsRegionauxCommune()
##' }
processPortraitsRegionauxCommune <- function(
  file = 'je-f-21.03.01.xls', 
  output = 'communesCH_2016_indicators_je-f-21.03.01.csv'
) {
  
  out.path <- paste0(getwd(), "/inst/extdata/", output)
  
  # get the path to communes data txt file 
  data.path <- dir(system.file("extdata", package="swiMap"), file, full.names = T)
  data.read <- readxl::read_excel(data.path, skip = 3, col_names = F)
  # discard empty lines
  row.idx <- apply(data.read, 1, function(ll) !all(is.na(ll)))
  data.read <- data.read[row.idx,]
  
  #headers
  header1 <- unlist(data.read[1,], use.names = F)
  header1 <- as.data.frame(header1) %>% 
    fill(header1) %>% 
    select(header1) %>% 
    unlist(use.names =F) %>% 
    as.character()
  header1 <- gsub(" 1)", "", header1, fixed = T)
  
  header2 <- unlist(data.read[2,], use.names = F)
  years <- unlist(data.read[3,], use.names = F)
  years <- suppressWarnings(ifelse(is.na(as.numeric(years)), years, as.numeric(years)))
  
  # reload data skipping everything until first commune
  data.read <- readxl::read_excel(data.path, skip = 9, col_names = F)
  # discard empty lines
  row.idx <- apply(data.read, 1, function(ll) !all(is.na(ll)))
  data.read <- data.read[row.idx,]
  
  data <- rbind(
    ifelse(is.na(header1), "", header1), 
    ifelse(is.na(years), "", years), 
    header2, data.read
  )
  write.csv(as.data.frame(data), file = out.path, row.names = F)
  cat("\n\n ------ \n Saved in:" , out.path)
}


##' Load the NPA/PLZ/ Zip code for Switzerland  
##' 
##' @rdname communes_CH_indicators
##' @return a data.frame
##' @seealso \url{http://opendata.admin.ch/de/dataset/ch-swisstopo-vd-ortschaftenverzeichnis_plz/resource/35001b61-e7c1-4124-89fa-17fac7b1139e} from: \url{http://opendata.admin.ch/de/dataset/ch-swisstopo-vd-ortschaftenverzeichnis_plz}
##' @export
loadCHzipcode <- function() {
  
  # get the path to communes data txt file 
  data.path <- dir(system.file("extdata", package="swiMap"), "PLZO_CSV_LV03.csv", full.names = T)
  read.csv(data.path, sep = ";", header = TRUE, stringsAsFactors = F, check.names = FALSE, encoding = "latin1")
}
