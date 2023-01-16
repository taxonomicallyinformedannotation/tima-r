% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/clean_bio.R
\name{clean_bio}
\alias{clean_bio}
\title{Clean bio}
\usage{
clean_bio(
  annotationTableWeightedBio = annotation_table_weighted_bio,
  structureOrganismPairsTable = structure_organism_pairs_table,
  edgesTable = edges_table,
  aNnOtAtE = annotate,
  candidatesInitial = candidates_initial,
  minimalMs1Bio = minimal_ms1_bio
)
}
\arguments{
\item{annotationTableWeightedBio}{Table containing your biologically weighted annotation}

\item{structureOrganismPairsTable}{Table containing the structure - organism pairs}

\item{edgesTable}{Table containing the edges between features}

\item{aNnOtAtE}{Boolean parameter indicating if you performed MS1 annotation completion}

\item{candidatesInitial}{Number of initial candidates to keep}

\item{minimalMs1Bio}{Minimal biological score to keep MS1 based annotation}
}
\value{
A table containing the biologically weighted annotation where only a given number of initial candidates are kept
}
\description{
This function cleans the results obtained after biological weighting
}
\examples{
NULL
}
\seealso{
weight_bio
}