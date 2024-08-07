import::from(stringi, stri_detect_fixed, .into = environment())
import::from(stringi, stri_sub, .into = environment())
import::from(tidytable, across, .into = environment())
import::from(tidytable, distinct, .into = environment())
import::from(tidytable, everything, .into = environment())
import::from(tidytable, filter, .into = environment())
import::from(tidytable, mutate, .into = environment())
import::from(tidytable, na_if, .into = environment())
import::from(tidytable, select, .into = environment())
import::from(utils, unzip, .into = environment())

#' @title Prepare libraries of structure organism pairs HMDB
#'
#' @description This function prepares the HMDB structure-organism pairs
#'
#' @importFrom stringi stri_detect_fixed
#' @importFrom stringi stri_sub
#' @importFrom tidytable across
#' @importFrom tidytable distinct
#' @importFrom tidytable everything
#' @importFrom tidytable filter
#' @importFrom tidytable mutate
#' @importFrom tidytable na_if
#' @importFrom tidytable select
#' @importFrom utils unzip
#'
#' @include fake_sop_columns.R
#' @include get_params.R
#' @include round_reals.R
#' @include select_sop_columns.R
#'
#' @param input Input file
#' @param output Output file
#'
#' @return NULL
#'
#' @export
#'
#' @examples NULL
prepare_libraries_sop_hmdb <-
  function(input = get_params(step = "prepare_libraries_sop_hmdb")$files$libraries$sop$raw$hmdb,
           output = get_params(step = "prepare_libraries_sop_hmdb")$files$libraries$sop$prepared$hmdb) {
    if (file.exists(input)) {
      log_debug("Unzipping HMDB...")
      hmdb_prepared <- tryCatch(
        expr = {
          unzip(zipfile = input, exdir = dirname(input))
          hmdb_structures <- input |>
            gsub(
              pattern = ".zip",
              replacement = ".sdf",
              fixed = TRUE
            )
          log_debug(x = "Loading HMDB...")
          sdf_data <- readLines(con = hmdb_structures, warn = FALSE)

          find_fixed_pattern_line_in_file <- function(file, pattern) {
            return(file |>
              stri_detect_fixed(pattern = pattern) |>
              which())
          }

          return_next_line <- function(x, file) {
            file[x + 1]
          }

          patterns <- list(
            "id" = "> <DATABASE_ID>",
            "smiles" = "> <SMILES>",
            ## Not needed
            # "inchi" = "> <INCHI_IDENTIFIER>",
            "inchikey" = "> <INCHI_KEY>",
            "formula" = "> <FORMULA>",
            ## Because they do not have the same number of entries (weirdly...)
            # "mass" = "> <EXACT_MASS>",
            # "logp" = "> <JCHEM_LOGP>",
            "name" = "> <GENERIC_NAME>"
          )

          hmdb_df <- patterns |>
            lapply(FUN = find_fixed_pattern_line_in_file, file = sdf_data) |>
            lapply(FUN = return_next_line, file = sdf_data) |>
            data.frame()

          log_debug(x = "Formatting HMDB...")
          hmdb_prepared <- hmdb_df |>
            mutate(across(.cols = everything(), .fns = na_if, "")) |>
            filter(!is.na(inchikey)) |>
            mutate(
              structure_inchikey_2D = stri_sub(
                str = inchikey,
                from = 1,
                to = 14
              ),
              ## ISSUE see #19
              structure_smiles_2D = NA_character_,
              structure_exact_mass = NA_real_
            ) |>
            select(
              structure_name = name,
              structure_inchikey = inchikey,
              structure_smiles = smiles,
              structure_inchikey_2D,
              structure_smiles_2D,
              structure_molecular_formula = formula,
              structure_exact_mass
            ) |>
            mutate(
              structure_xlogp = NA_integer_,
              structure_taxonomy_npclassifier_01pathway = NA_character_,
              structure_taxonomy_npclassifier_02superclass = NA_character_,
              structure_taxonomy_npclassifier_03class = NA_character_,
              structure_taxonomy_classyfire_chemontid = NA_character_,
              structure_taxonomy_classyfire_01kingdom = NA_character_,
              structure_taxonomy_classyfire_02superclass = NA_character_,
              structure_taxonomy_classyfire_03class = NA_character_,
              structure_taxonomy_classyfire_04directparent = NA_character_,
            ) |>
            mutate(
              organism_name = "Homo sapiens",
              organism_taxonomy_ottid = 770315,
              organism_taxonomy_01domain = "Eukaryota",
              organism_taxonomy_02kingdom = "Metazoa",
              organism_taxonomy_03phylum = "Chordata",
              organism_taxonomy_04class = "Mammalia",
              organism_taxonomy_05order = "Primates",
              organism_taxonomy_06family = "Hominidae",
              organism_taxonomy_07tribe = NA_character_,
              organism_taxonomy_08genus = "Homo",
              organism_taxonomy_09species = "Homo sapiens",
              organism_taxonomy_10varietas = NA_character_,
              reference_doi = NA_character_
            ) |>
            round_reals() |>
            distinct()

          log_debug("Deleting unzipped file...")
          file.remove(hmdb_structures)
          hmdb_prepared
        },
        error = function(e) {
          log_debug("Something went wrong, see original error message:")
          log_debug(e)
          hmdb_prepared <- fake_sop_columns()
        }
      )
    } else {
      log_debug("Sorry, HMDB not found, returning an empty file instead")
      hmdb_prepared <- fake_sop_columns()
    }
    log_debug(x = "Exporting ...")
    export_output(x = hmdb_prepared, file = output)
    return(output)
  }
