import::from(jsonlite, stream_in, .into = environment())
import::from(stringi, stri_sub, .into = environment())
import::from(tidytable, as_tidytable, .into = environment())
import::from(tidytable, distinct, .into = environment())
import::from(tidytable, mutate, .into = environment())
import::from(tidytable, rename, .into = environment())

#' @title Prepare libraries of structure organism pairs ECMDB
#'
#' @importFrom jsonlite stream_in
#' @importFrom stringi stri_sub
#' @importFrom tidytable as_tidytable
#' @importFrom tidytable distinct
#' @importFrom tidytable mutate
#' @importFrom tidytable rename
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
prepare_libraries_sop_ecmdb <-
  function(input = get_params(step = "prepare_libraries_sop_ecmdb")$files$libraries$sop$raw$ecmdb,
           output = get_params(step = "prepare_libraries_sop_ecmdb")$files$libraries$sop$prepared$ecmdb) {
    if (file.exists(input)) {
      log_debug(x = "Loading ECMDB resources")

      file <- gsub(
        pattern = ".zip",
        replacement = "",
        x = input,
        fixed = TRUE
      ) |>
        gsub(
          pattern = ".*/",
          replacement = "",
          perl = TRUE
        )

      ecmdb <- stream_in(
        con = unz(description = input, filename = file),
        verbose = FALSE
      ) |>
        data.frame() |>
        as_tidytable()

      log_debug(x = "Formatting ECMDB")
      ecmdb_prepared <- ecmdb |>
        mutate(
          structure_inchikey_2D = stri_sub(str = moldb_inchikey, from = 1, to = 14),
          ## ISSUE see #19
          structure_smiles_2D = NA_character_
        ) |>
        rename(
          structure_name = name,
          structure_inchikey = moldb_inchikey,
          structure_smiles = moldb_smiles,
          structure_molecular_formula = moldb_formula,
          structure_exact_mass = moldb_mono_mass,
          structure_xlogp = moldb_logp
        ) |>
        mutate(
          structure_taxonomy_npclassifier_01pathway = NA_character_,
          structure_taxonomy_npclassifier_02superclass = NA_character_,
          structure_taxonomy_npclassifier_03class = NA_character_,
          structure_taxonomy_classyfire_chemontid = NA_character_,
          structure_taxonomy_classyfire_01kingdom = NA_character_,
          structure_taxonomy_classyfire_02superclass = NA_character_,
          structure_taxonomy_classyfire_03class = NA_character_,
          structure_taxonomy_classyfire_04directparent = NA_character_
        ) |>
        mutate(
          organism_name = "Escherichia coli",
          organism_taxonomy_ottid = 474506,
          organism_taxonomy_01domain = "Bacteria",
          organism_taxonomy_02kingdom = NA_character_,
          organism_taxonomy_03phylum = "Proteobacteria",
          organism_taxonomy_04class = "Gammaproteobacteria",
          organism_taxonomy_05order = "Enterobacteriales",
          organism_taxonomy_06family = "Enterobacteriaceae",
          organism_taxonomy_07tribe = NA_character_,
          organism_taxonomy_08genus = NA_character_,
          organism_taxonomy_09species = "Escherichia coli",
          organism_taxonomy_10varietas = NA_character_
        ) |>
        mutate(reference_doi = NA) |>
        select_sop_columns() |>
        round_reals() |>
        distinct()
      rm(ecmdb)
    } else {
      log_debug("Sorry, ECMDB not found, returning an empty file instead")
      ecmdb_prepared <- fake_sop_columns()
    }

    log_debug(x = "Exporting ...")
    export_params(
      parameters = get_params(step = "prepare_libraries_sop_ecmdb"),
      step = "prepare_libraries_sop_closed"
    )
    export_output(x = ecmdb_prepared, file = output)
    rm(ecmdb_prepared)
    return(output)
  }
