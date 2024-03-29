% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/create_components.R
\name{create_components}
\alias{create_components}
\title{Create components}
\usage{
create_components(
  input = get_params(step = "create_components")$files$networks$spectral$edges$prepared,
  output = get_params(step = "create_components")$files$networks$spectral$components$raw
)
}
\arguments{
\item{input}{Input file(s) containing edges}

\item{output}{Output file.}
}
\description{
This function create components from edges
}
\examples{
NULL
}
