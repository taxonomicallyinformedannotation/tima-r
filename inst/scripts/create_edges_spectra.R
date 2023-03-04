start <- Sys.time()

require(
  package = "timaR",
  quietly = TRUE
)

# step <- "create_edges_spectra"
# paths <- parse_yaml_paths()
# params <- get_params(step = step)

log_debug(
  "This script",
  crayon::green("performs spectral similarity calculation to create edges. \n")
)
log_debug("Authors: ", crayon::green("AR"), "\n")
log_debug("Contributors: ...")

# create_edges_spectra()
targets::tar_make(names = matches("features_edges_spectra"))

end <- Sys.time()

log_debug("Script finished in", crayon::green(format(end - start)))