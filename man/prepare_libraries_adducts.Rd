% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/prepare_libraries_adducts.R
\name{prepare_libraries_adducts}
\alias{prepare_libraries_adducts}
\title{Prepare libraries of adducts}
\usage{
prepare_libraries_adducts(
  str_met = get_params(step =
    "prepare_libraries_adducts")$files$libraries$sop$merged$structures$metadata,
  adducts_masses_list = system.file("extdata", "adducts.tsv", package = "timaR"),
  adducts_output_path = parse_yaml_paths()$data$interim$libraries$adducts$path,
  clusters_list = system.file("extdata", "clusters.tsv", package = "timaR"),
  output_name = get_params(step =
    "prepare_libraries_adducts")$files$libraries$adducts$prepared,
  masses_pos_output_path = get_params(step =
    "prepare_libraries_adducts")$files$libraries$adducts$pos,
  masses_neg_output_path = get_params(step =
    "prepare_libraries_adducts")$files$libraries$adducts$neg
)
}
\arguments{
\item{str_met}{File containing structures metadata}

\item{adducts_masses_list}{Table of adducts taken as input}

\item{adducts_output_path}{Path where the adducts will be saved}

\item{clusters_list}{Table of clusters taken as input}

\item{output_name}{Name of the file where adducts will be saved}

\item{masses_pos_output_path}{Path where pos adducts masses will be saved}

\item{masses_neg_output_path}{Path where neg adducts masses will be saved}
}
\description{
This function prepares adducts for further use
}
\examples{
NULL
}
