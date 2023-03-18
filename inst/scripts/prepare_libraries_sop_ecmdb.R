start <- Sys.time()

require(
  package = "timaR",
  quietly = TRUE
)

# step <- "prepare_libraries_sop_ecmdb"
# paths <- parse_yaml_paths()
# params <- get_params(step = step)

log_debug(
  "This script",
  crayon::green("prepares ecmdb structure-organism pairs \n")
)
log_debug("Authors: ", crayon::green("AR"), "\n")
log_debug("Contributors: ...")

# prepare_libraries_sop_ecmdb()
targets::tar_make(names = matches("library_sop_ecmdb_prepared"))

end <- Sys.time()

log_debug("Script finished in", crayon::green(format(end - start)))