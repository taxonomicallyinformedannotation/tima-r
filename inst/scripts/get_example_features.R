start <- Sys.time()

require(
  package = "timaR",
  quietly = TRUE
)

paths <- parse_yaml_paths()

log_debug(
  "This script",
  crayon::green("downloads an example of minimal feature table \n")
)
log_debug("Authors: ", crayon::green("AR"), "\n")
log_debug("Contributors: ...")

get_file(
  url = paths$urls$examples$features,
  export = paths$data$source$features
)

end <- Sys.time()

log_debug("Script finished in", crayon::green(format(end - start)))
