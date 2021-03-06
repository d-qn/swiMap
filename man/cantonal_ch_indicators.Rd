% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/cantonal_ch_indicators.R
\name{loadCantonsCHportraits}
\alias{loadCantonsCHportraits}
\alias{processPortraitsRegionauxCantons}
\title{Swiss cantonal indicators}
\usage{

  loadCantonsCHportraits(file = "cantonal_CH_2016_indicators_je-f-21.03.02.csv")

processPortraitsRegionauxCantons(file = "je-f-21.03.02.xls",
  output = "cantonal_CH_2016_indicators_je-f-21.03.02.csv")
}
\arguments{
\item{file}{the name of the csv file processed by processPortraitsRegionauxCantons to load}

\item{output}{the output file name to be saved in the package inst/extdata}

\item{file}{the raw excel file name from the Swiss Statistical office with indicators by canton}
}
\value{
a data.frame
}
\description{
Load socio-demographic data by the Swiss Statistical Office.

Process Portraits régionaux de la Suisse canton xls
}
\details{
Run processPortraitsRegionauxCantons() to generate a readable csv file for loadCantonsCHportraits
}
\examples{
\dontrun{
cantonalI <- loadCantonsCHportraits()
}
\dontrun{
swiMap:::processPortraitsRegionauxCantons()
}
}
\seealso{
\url{https://www.bfs.admin.ch/bfs/en/home/statistics/catalogues-databases.assetdetail.je-f-21.03.02.html}
}
