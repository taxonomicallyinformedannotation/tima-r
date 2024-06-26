#' @title Import spectra
#'
#' @description This function imports spectra from a file (.mgf or .sqlite)
#'
#' @param file File path of the spectrum file to be imported
#'
#' @return Spectra object containing the imported spectra
#'
#' @export
#'
#' @examples NULL
import_spectra <- function(file) {
  file_ext <-
    stringi::stri_replace_all_regex(
      str = file,
      pattern = ".*\\.",
      replacement = "",
      vectorize_all = FALSE
    )

  switch(
    EXPR = file_ext,
    "mgf" = {
      MsBackendMgf::readMgf(f = file) |>
        Spectra::Spectra() |>
        cleanup_spectra()
    },
    "msp" = {
      MsBackendMsp::readMsp(f = file) |>
        Spectra::Spectra() |>
        cleanup_spectra()
    },
    # "sqlite" = {
    #   CompoundDb::CompDb(x = file) |>
    #     CompoundDb::Spectra() |>
    #     Spectra::setBackend(Spectra::MsBackendMemory())
    # },
    "rds" = {
      readRDS(file = file) |>
        data.frame() |>
        Spectra::Spectra() |>
        cleanup_spectra()
    }
  )
}
