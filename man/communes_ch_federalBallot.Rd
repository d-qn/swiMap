% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/communes_ch_federalBallot.R
\name{loadCommunesCHFederalBallot}
\alias{loadCommunesCHFederalBallot}
\alias{processFederalBallotByCommunes}
\title{Federal ballot results by communes}
\usage{
loadCommunesCHFederalBallot(file = "federalBallot_communes.RData")


  processFederalBallotByCommunes(url = "https://www.pxweb.bfs.admin.ch/DownloadFile.aspx?file=px-x-1703030000_101",
  output = "federalBallot_communes.RData")
}
\arguments{
\item{file}{the name of the csv file processed by processFederalBallotByCommunes to load}

\item{url}{the URL to the px file with all federal ballots}

\item{output}{the output file name to be saved in the package inst/extdata}
}
\value{
a matrix, rownames are cantons (2 letters name) and colnames are federal ballot IDs. Check the attributes ballotName and date (same length as ncol) and communeName (same lenghth as nrow)
}
\description{
Load any federal ballots resuts by communes: https://www.pxweb.bfs.admin.ch/DownloadFile.aspx?file=px-x-1703030000_101

Process Portraits régionaux de la Suisse commune px file
This will download the px file from \url{https://www.bfs.admin.ch/bfs/en/home/statistics/politics/popular-votes.assetdetail.1363949.html}, process it and save it as a Rdata file
Necessary to run it before using loadCommunesCHFederalBallot
}
\details{
Run processFederalBallotByCommunes() to generate a readable csv file for loadCommunesCHFederalBallot
}
\examples{
\dontrun{
fBallot <- loadCommunesCHFederalBallot()
attr(fBallot, "ballotName")
# get only naturalisation facilitée ballots
cidx <- match(c("3150", "4110", "5100", "5110"), colnames(fBallot))
attr(fBallot, "ballotName")[cidx]
fBallot[,cidx]
# Plot maps
require(rgdal)
require(rgeos)
require(ggplot2)
require(maptools)
require(dplyr)

# get canton shapefiles as a data.frame
path.ch <- getPathShp('CH')
layers <-  ogrListLayers(path.ch)
mu <- readOGR(path.ch, layer = 'municipalities')
mu.df <- formatShp(mu) \%>\% select(long, lat, group, BFS_NUMMER)
r.idx <- match(mu.df$BFS_NUMMER, rownames(fBallot))
# duplicate commune data.frame for each ballot
df <- do.call(rbind, lapply(cidx, function(idx) {
  value <- fBallot[,idx]
  res <- mu.df
  res$value <- value[r.idx]
  res$ballot <- attr(fBallot, "ballotName")[idx]
  res$date <- attr(fBallot, "date")[idx]
  res
}))
# plot maps
brks <- seq(from = 0, to = 1, length.out = 11) * 100
df$bins <- cut(df$value, breaks = brks, right = F)
df$ballot <- factor(df$ballot, levels = attr(fBallot, "ballotName")[cidx])
ggplot(df, aes(x = long, y = lat, group = group)) + geom_polygon(size = 0, aes(fill = bins)) +
theme_minimal() + theme(legend.position = "bottom", panel.grid = element_blank(), 
axis.ticks = element_blank(), axis.title = element_blank(), axis.text = element_blank()) +
facet_wrap(~ ballot) + scale_fill_brewer(palette = "BrBG" , drop = F) + 
coord_quickmap(expand = F)
}
\dontrun{
processFederalBallotByCommunes()
}
}
\seealso{
\url{https://www.bfs.admin.ch/bfs/en/home/statistics/politics/popular-votes.assetdetail.1363949.html}
}
