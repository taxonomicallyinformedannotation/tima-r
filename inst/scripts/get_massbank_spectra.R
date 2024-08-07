start <- Sys.time()

require(
  package = "tima",
  quietly = TRUE
)

log_debug(
  "This script",
  crayon::green("downloads MassBank spectra \n")
)
log_debug("Authors: ", crayon::green("AR"), "\n")
log_debug("Contributors: ...")

targets::tar_make(names = matches("lib_spe_exp_mb_raw"))

end <- Sys.time()

log_debug("Script finished in", crayon::green(format(end - start)))
