start <- Sys.time()

require(
  package = "timaR",
  quietly = TRUE
)

paths <- parse_yaml_paths()

log_debug(
  "This script",
  crayon::green("Prepares spectra from MONA (MassBank of North America) \n"),
  crayon::red("They have to be previously downloaded manually. \n")
)
log_debug("Authors: ", crayon::green("AR"), "\n")
log_debug("Contributors: ...")

#' @title Prepare MONA
#'
#' @param input Input file
#' @param output_pos Output for positive spectra
#' @param output_neg Output for negative spectra
#' @param export_sqlite Boolean. Save as sqlite instead of mgf
#'
#' @return NULL
#'
#' @export
#'
#' @examples NULL
prepare_mona <-
  function(input = paths$data$source$libraries$spectra$exp$mona_lcmsms,
           output_pos = paths$data$interim$libraries$spectra$exp$mona$pos,
           output_neg = paths$data$interim$libraries$spectra$exp$mona$neg) {
    log_debug("Loading standardization function (temp)")
    source(file = "inst/scripts/standardize.R")

    ## SDF import from zip not working
    log_debug("Loading spectra (might take long)")
    mona_data <-
      CompoundDb::import_mona_sdf(x = input, nonStop = TRUE)

    cpd <- mona_data$compound

    spctra <- mona_data$msms_spectrum

    log_debug("Adding metadata")
    spctra_enhanced <- spctra |>
      tidytable::left_join(cpd) |>
      tidytable::filter(spectrum_type == "MS2") |>
      ## COMMENT (AR): CURATING NON-STANDARD InChIs
      tidytable::mutate(inchi = gsub(
        pattern = "InChI=1/",
        replacement = "InChI=1S/",
        x = inchi,
        fixed = TRUE
      )) |>
      ## COMMENT (AR): Dropped the idea
      ## too many things to do (mainly replace u by ?)
      ## COMMENT (AR): No way
      tidytable::mutate(inchi = gsub(
        pattern = " ",
        replacement = "",
        x = inchi,
        fixed = TRUE
      )) |>
      tidytable::filter(!is.na(smiles) | !is.na(inchi)) |>
      ## COMMENT (AR): FILTERING INVALID InChIs
      tidytable::filter(grepl(
        pattern = "InChI=1S/",
        x = inchi,
        fixed = TRUE
      )) |>
      tidytable::filter(!grepl(
        pattern = ".",
        x = inchi,
        fixed = TRUE
      )) |>
      tidytable::mutate(ionmode = ifelse(
        test = polarity == 1,
        yes = "POSITIVE",
        no = "NEGATIVE"
      )) |>
      ## COMMENT (AR): FILTERING MISSING PRECURSOR MZS
      tidytable::filter(!is.na(precursor_mz))

    log_debug("Standardizing chemical structures without stereo")
    inchis <- unique(spctra_enhanced$inchi)

    df_clean <- lapply(X = inchis, FUN = standardize_inchi) |>
      tidytable::bind_rows()

    spctra_enhanced <- spctra_enhanced |>
      tidytable::left_join(df_clean)

    log_debug("Cleaning charges")
    spctra_enhanced_1 <- spctra_enhanced |>
      tidytable::filter(
        grepl(pattern = "]\\+\\+", x = precursor_type, perl = TRUE) |
          grepl(pattern = "]2\\+", x = precursor_type, perl = TRUE)
      ) |>
      tidytable::mutate(precursorCharge = 2L)
    spctra_enhanced_2 <- spctra_enhanced |>
      tidytable::filter(
        grepl(pattern = "]\\+$", x = precursor_type, perl = TRUE) |
          grepl(pattern = "]1\\+", x = precursor_type, perl = TRUE) |
          grepl(pattern = "M\\+H$", x = precursor_type, perl = TRUE) |
          grepl(pattern = "M\\+K$", x = precursor_type, perl = TRUE) |
          grepl(pattern = "M\\+Na$", x = precursor_type, perl = TRUE) |
          grepl(pattern = "M\\+NH4$", x = precursor_type, perl = TRUE) |
          grepl(pattern = "M\\+$", x = precursor_type, perl = TRUE)
      ) |>
      tidytable::mutate(precursorCharge = 1L)
    spctra_enhanced_3 <- spctra_enhanced |>
      tidytable::filter(
        grepl(pattern = "]\\-\\-", x = precursor_type, perl = TRUE) |
          grepl(pattern = "]2\\-", x = precursor_type, perl = TRUE)
      ) |>
      tidytable::mutate(precursorCharge = -2L)
    spctra_enhanced_4 <- spctra_enhanced |>
      tidytable::filter(
        grepl(pattern = "]\\-$", x = precursor_type, perl = TRUE) |
          grepl(pattern = "]1\\-", x = precursor_type, perl = TRUE) |
          grepl(pattern = "M\\-H$", x = precursor_type, perl = TRUE) |
          grepl(pattern = "M\\+Cl$", x = precursor_type, perl = TRUE)
      ) |>
      tidytable::mutate(precursorCharge = -1L)

    spctra_enhanced_5 <- spctra_enhanced |>
      tidytable::anti_join(spctra_enhanced_1) |>
      tidytable::anti_join(spctra_enhanced_2) |>
      tidytable::anti_join(spctra_enhanced_3) |>
      tidytable::anti_join(spctra_enhanced_4) |>
      tidytable::mutate(diff = exactmass - precursor_mz) |>
      tidytable::mutate(precursorCharge = ifelse(
        test = ionmode == "POSITIVE",
        yes = 1L,
        no = -1L
      ))

    log_debug(
      nrow(spctra_enhanced_5),
      "spectra were not unambiguously attributed,",
      "trying the same by default base on ion type,",
      "might induce some errors"
    )

    spctra_enhanced_final <- tidytable::bind_rows(
      spctra_enhanced_1,
      spctra_enhanced_2,
      spctra_enhanced_3,
      spctra_enhanced_4,
      spctra_enhanced_5
    ) |>
      tidytable::filter(!is.na(inchikey_no_stereo))

    log_debug("Formatting")
    colnames_mona <- c(
      colname_collision_energy = "collision_energy",
      colname_compound_id = NA,
      colname_exact_mass = "exactmass",
      colname_formula = "formula",
      colname_inchi = "inchi_no_stereo",
      colname_inchikey = "inchikey_no_stereo",
      colname_mode = "ionmode",
      colname_name = "inchikey_no_stereo",
      colname_precursorMz = "precursor_mz",
      colname_precursorCharge = "precursorCharge",
      colname_smiles = "smiles_no_stereo",
      colname_spectrum_id = NA,
      colname_splash = NA,
      colname_synonyms = NA
    )

    log_debug("Positive")
    spectra_harmonized_pos <- spctra_enhanced_final |>
      harmonize_spectra(
        colnames = colnames_mona,
        mode = "pos"
      )

    log_debug("Negative")
    spectra_harmonized_neg <- spctra_enhanced_final |>
      harmonize_spectra(
        colnames = colnames_mona,
        mode = "neg"
      )

    log_debug("Exporting")
    export_spectra_2(
      file = output_pos,
      spectra = spectra_harmonized_pos,
      meta = NULL
    )
    export_spectra_2(
      file = output_neg,
      spectra = spectra_harmonized_neg,
      meta = NULL
    )
  }

prepare_mona()

end <- Sys.time()

log_debug("Script finished in", crayon::green(format(end - start)))
