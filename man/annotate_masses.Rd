% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/annotate_masses.R
\name{annotate_masses}
\alias{annotate_masses}
\title{Annotate masses}
\usage{
annotate_masses(
  features = get_params(step = "annotate_masses")$files$features$prepared,
  filter_nitro = get_params(step = "annotate_masses")$options$nitrogen_rule,
  output_annotations = get_params(step =
    "annotate_masses")$files$annotations$prepared$structural$ms1,
  output_edges = get_params(step = "annotate_masses")$files$networks$spectral$edges$raw,
  name_source = get_params(step = "annotate_masses")$names$source,
  name_target = get_params(step = "annotate_masses")$names$target,
  library = get_params(step = "annotate_masses")$files$libraries$sop$merged$keys,
  str_stereo = get_params(step =
    "annotate_masses")$files$libraries$sop$merged$structures$stereo,
  str_met = get_params(step =
    "annotate_masses")$files$libraries$sop$merged$structures$metadata,
  str_nam = get_params(step =
    "annotate_masses")$files$libraries$sop$merged$structures$names,
  str_tax_cla = get_params(step =
    "annotate_masses")$files$libraries$sop$merged$structures$taxonomies$cla,
  str_tax_npc = get_params(step =
    "annotate_masses")$files$libraries$sop$merged$structures$taxonomies$npc,
  name = get_params(step = "annotate_masses")$files$libraries$adducts$prepared,
  adducts_list = get_params(step = "annotate_masses")$ms$adducts,
  adducts_neg = get_params(step = "annotate_masses")$files$libraries$adducts$neg,
  adducts_pos = get_params(step = "annotate_masses")$files$libraries$adducts$pos,
  adducts_masses_list = system.file("extdata", "adducts.tsv", package = "timaR"),
  clusters_neg = get_params(step = "annotate_masses")$ms$clusters$neg,
  clusters_pos = get_params(step = "annotate_masses")$ms$clusters$pos,
  clusters_list = system.file("extdata", "clusters.tsv", package = "timaR"),
  neutral_losses_list = system.file("extdata", "neutral_losses.tsv", package = "timaR"),
  ms_mode = get_params(step = "annotate_masses")$ms$polarity,
  tolerance_ppm = get_params(step = "annotate_masses")$ms$tolerances$mass$ppm$ms1,
  tolerance_rt = get_params(step = "annotate_masses")$ms$tolerances$rt$minutes
)
}
\arguments{
\item{features}{Table containing your previous annotation to complement}

\item{filter_nitro}{Filter according to Nitrogen rule. Boolean}

\item{output_annotations}{Output for mass based structural annotations}

\item{output_edges}{Output for mass based edges}

\item{name_source}{Name of the source features column}

\item{name_target}{Name of the target features column}

\item{library}{Library containing the keys}

\item{str_stereo}{File containing structures stereo}

\item{str_met}{File containing structures metadata}

\item{str_nam}{File containing structures names}

\item{str_tax_cla}{File containing Classyfire taxonomy}

\item{str_tax_npc}{File containing NPClassifier taxonomy}

\item{name}{Name of the adducts library}

\item{adducts_list}{List of adducts to be used}

\item{adducts_neg}{Negative adducts to be used}

\item{adducts_pos}{Positive adducts to be used}

\item{adducts_masses_list}{Adducts masses}

\item{clusters_neg}{Negative clusters to be used}

\item{clusters_pos}{Positive clusters to be used}

\item{clusters_list}{List of clusters to be used}

\item{neutral_losses_list}{List of neutral losses to be used}

\item{ms_mode}{Ionization mode. Must be 'pos' or 'neg'}

\item{tolerance_ppm}{Tolerance to perform annotation. Should be <= 10 ppm}

\item{tolerance_rt}{Tolerance to group adducts. Should be <= 0.1min}
}
\value{
A table containing MS1 annotations based on exact mass
}
\description{
This function annotates masses
}
\examples{
NULL
}
