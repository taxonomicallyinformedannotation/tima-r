#' Title
#'
#' @param library TODO
#' @param input TODO
#' @param output TODO
#' @param quickmode TODO
#'
#' @return TODO
#' @export
#'
#' @importFrom dplyr anti_join distinct filter left_join select
#' @importFrom readr read_delim write_delim
#'
#' @examples
prepare_features_classification <-
  function(library = params$library,
           input = params$input,
           output = params$output,
           quickmode = params$quickmode) {
    stopifnot("Your input file does not exist" = file.exists(input))
    stopifnot("Your library file does not exist" = file.exists(library))
    stopifnot("Quickmode must be 'true' or 'false'" = quickmode %in% c(TRUE, FALSE))

    log_debug(x = "Loading files ...")
    log_debug(x = "... library")
    lotus <-
      readr::read_delim(
        file = library,
        col_select = c(
          inchikey_2D = structure_inchikey_2D,
          smiles_2D = structure_smiles_2D,
          structure_exact_mass,
          molecular_formula = structure_molecular_formula,
          structure_taxonomy_npclassifier_01pathway,
          structure_taxonomy_npclassifier_02superclass,
          structure_taxonomy_npclassifier_03class
        )
      ) |>
      dplyr::distinct()

    log_debug(x = "... features table")
    table <- readr::read_delim(file = input) |>
      dplyr::distinct(
        feature_id,
        component_id,
        mz,
        inchikey_2D,
        smiles_2D,
        score_input,
        library,
        mz_error,
        .keep_all = TRUE
      )

    log_debug(x = "Filtering structures ...")
    log_debug(x = "... missing classification")
    table_missing_classification <- table |>
      dplyr::filter(
        is.na(structure_taxonomy_npclassifier_01pathway) &
          is.na(structure_taxonomy_npclassifier_02superclass) &
          is.na(structure_taxonomy_npclassifier_03class)
      ) |>
      dplyr::distinct(inchikey_2D, smiles_2D)

    log_debug(x = "... missing masses")
    table_missing_mass <- table |>
      dplyr::filter(is.na(structure_exact_mass)) |>
      dplyr::distinct(inchikey_2D, smiles_2D)

    log_debug(x = "... missing formulas")
    table_missing_formula <- table |>
      dplyr::filter(is.na(molecular_formula)) |>
      dplyr::distinct(inchikey_2D, smiles_2D)

    log_debug(x = "... keeping the other ones safe")
    table_with_classification <-
      dplyr::anti_join(table, table_missing_classification)
    table_with_mass <- dplyr::anti_join(table, table_missing_mass)
    table_with_formula <-
      dplyr::anti_join(table, table_missing_formula)

    log_debug(x = "Completing the structures with the library")
    table_classified_lotus <-
      dplyr::left_join(
        table_missing_classification,
        lotus |>
          dplyr::distinct(
            inchikey_2D,
            smiles_2D,
            structure_taxonomy_npclassifier_01pathway,
            structure_taxonomy_npclassifier_02superclass,
            structure_taxonomy_npclassifier_03class
          )
      )

    table_massed_lotus <-
      dplyr::left_join(
        table_missing_mass,
        lotus |>
          dplyr::distinct(
            inchikey_2D, smiles_2D,
            structure_exact_mass
          )
      )

    table_formuled_lotus <-
      dplyr::left_join(
        table_missing_formula,
        lotus |>
          dplyr::distinct(
            inchikey_2D, smiles_2D,
            molecular_formula
          )
      )

    log_debug(x = "Filtering structures again (to calculate this time) ...")
    table_classified_lotus_missing <- table_classified_lotus |>
      dplyr::filter(
        is.na(structure_taxonomy_npclassifier_01pathway) &
          is.na(structure_taxonomy_npclassifier_02superclass) &
          is.na(structure_taxonomy_npclassifier_03class)
      ) |>
      dplyr::distinct(inchikey_2D, smiles_2D, .keep_all = TRUE) |>
      dplyr::filter(!is.na(smiles_2D))

    table_massed_lotus_missing <- table_massed_lotus |>
      dplyr::filter(is.na(structure_exact_mass)) |>
      dplyr::distinct(inchikey_2D, smiles_2D, .keep_all = TRUE) |>
      dplyr::filter(!is.na(smiles_2D))

    table_formuled_lotus_missing <- table_formuled_lotus |>
      dplyr::filter(is.na(molecular_formula)) |>
      dplyr::distinct(inchikey_2D, smiles_2D, .keep_all = TRUE) |>
      dplyr::filter(!is.na(smiles_2D))

    table_with_classification_lotus <-
      dplyr::anti_join(table_classified_lotus, table_classified_lotus_missing)

    table_with_mass_lotus <-
      dplyr::anti_join(table_massed_lotus, table_massed_lotus_missing)

    table_with_formula_lotus <-
      dplyr::anti_join(table_formuled_lotus, table_formuled_lotus_missing)

    ## TODO CALCULATION STEPS
    log_debug(x = "Calculation is not performed yet (TODO) ...")
    if (quickmode == FALSE) {
      ## add GNPS query steps for formula, exact mass, and classification
      ## I'll do it later on
    }

    log_debug(x = "Recombining everything back together")
    table_classified <-
      rbind(
        table_with_classification |>
          dplyr::distinct(
            inchikey_2D,
            smiles_2D,
            structure_taxonomy_npclassifier_01pathway,
            structure_taxonomy_npclassifier_02superclass,
            structure_taxonomy_npclassifier_03class
          ),
        table_classified_lotus,
        table_classified_lotus_missing,
        fill = TRUE
      ) |>
      dplyr::distinct(
        inchikey_2D,
        smiles_2D,
        structure_taxonomy_npclassifier_01pathway,
        structure_taxonomy_npclassifier_02superclass,
        structure_taxonomy_npclassifier_03class
      )

    table_massed <-
      rbind(
        table_with_mass |> dplyr::distinct(
          inchikey_2D,
          smiles_2D,
          structure_exact_mass
        ),
        table_massed_lotus,
        table_massed_lotus_missing,
        fill = TRUE
      ) |>
      dplyr::distinct(
        inchikey_2D,
        smiles_2D,
        structure_exact_mass
      )

    table_formuled <-
      rbind(
        table_with_formula |>
          dplyr::distinct(
            inchikey_2D,
            smiles_2D,
            molecular_formula
          ),
        table_formuled_lotus,
        table_formuled_lotus_missing,
        fill = TRUE
      ) |>
      dplyr::distinct(
        inchikey_2D,
        smiles_2D,
        molecular_formula
      )

    table_final <- dplyr::left_join(
      table,
      table_classified
    ) |>
      dplyr::left_join(table_formuled) |>
      dplyr::left_join(table_massed)

    table_final[] <-
      lapply(
        table_final,
        function(x) {
          y_as_na(x, y = "")
        }
      )

    log_debug(x = "Exporting ...")
    ifelse(
      test = !dir.exists(paths$data$interim$path),
      yes = dir.create(paths$data$interim$path),
      no = paste(paths$data$interim$path, "exists")
    )
    ifelse(
      test = !dir.exists(paths$data$interim$annotations$path),
      yes = dir.create(paths$data$interim$annotations$path),
      no = paste(paths$data$interim$annotations$path, "exists")
    )
    ifelse(
      test = !dir.exists(paths$data$interim$config$path),
      yes = dir.create(paths$data$interim$config$path),
      no = paste(paths$data$interim$config$path, "exists")
    )
    ifelse(
      test = !dir.exists(dirname(output)),
      yes = dir.create(dirname(output)),
      no = paste(dirname(output), "exists")
    )

    log_debug(
      x = "... path to export is",
      output
    )
    readr::write_delim(
      x = table_final,
      file = output,
      delim = "\t"
    )

    export_params(
      parameters = params,
      directory = paths$data$interim$config$path,
      step = "prepare_features_classification"
    )
  }
