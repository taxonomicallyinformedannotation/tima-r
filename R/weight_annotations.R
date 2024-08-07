import::from(tidytable, any_of, .into = environment())
import::from(tidytable, arrange, .into = environment())
import::from(tidytable, bind_rows, .into = environment())
import::from(tidytable, count, .into = environment())
import::from(tidytable, desc, .into = environment())
import::from(tidytable, distinct, .into = environment())
import::from(tidytable, filter, .into = environment())
import::from(tidytable, fread, .into = environment())
import::from(tidytable, full_join, .into = environment())
import::from(tidytable, group_by, .into = environment())
import::from(tidytable, left_join, .into = environment())
import::from(tidytable, select, .into = environment())
import::from(tidytable, where, .into = environment())

#' @title Weight annotations
#'
#' @description This function weights annotations.
#'
#' @importFrom tidytable any_of
#' @importFrom tidytable arrange
#' @importFrom tidytable bind_rows
#' @importFrom tidytable count
#' @importFrom tidytable desc
#' @importFrom tidytable distinct
#' @importFrom tidytable filter
#' @importFrom tidytable fread
#' @importFrom tidytable full_join
#' @importFrom tidytable group_by
#' @importFrom tidytable left_join
#' @importFrom tidytable select
#' @importFrom tidytable where
#'
#' @include clean_bio.R
#' @include clean_chemo.R
#' @include columns_model.R
#' @include decorate_bio.R
#' @include decorate_chemo.R
#' @include get_params.R
#' @include parse_yaml_paths.R
#' @include weight_bio.R
#' @include weight_chemo.R
#'
#' @param library Library containing the keys
#' @param org_tax_ott File containing organisms taxonomy (OTT)
#' @param str_stereo File containing structures stereo
#' @param annotations Prepared annotations file
#' @param canopus Prepared canopus file
#' @param formula Prepared formula file
#' @param components Prepared components file
#' @param edges Prepared edges file
#' @param taxa Prepared taxed features file
#' @param output Output file
#' @param candidates_final Number of final candidates to keep
#' @param weight_spectral Weight for the spectral score
#' @param weight_chemical Weight for the biological score
#' @param weight_biological Weight for the chemical consistency score
#' @param score_biological_domain Score for a `domain` match
#' (should be lower than `kingdom`)
#' @param score_biological_kingdom Score for a `kingdom` match
#' (should be lower than `phylum`)
#' @param score_biological_phylum Score for a `phylum` match
#' (should be lower than `class`)
#' @param score_biological_class Score for a `class` match
#' (should be lower than `order`)
#' @param score_biological_order Score for a `order` match
#' (should be lower than `infraorder`)
#' @param score_biological_infraorder Score for a `infraorder` match
#' (should be lower than `order`)
#' @param score_biological_family Score for a `family` match
#' (should be lower than `subfamily`)
#' @param score_biological_subfamily Score for a `subfamily` match
#' (should be lower than `family`)
#' @param score_biological_tribe Score for a `tribe` match
#' (should be lower than `subtribe`)
#' @param score_biological_subtribe Score for a `subtribe` match
#' (should be lower than `genus`)
#' @param score_biological_genus Score for a `genus` match
#' (should be lower than `subgenus`)
#' @param score_biological_subgenus Score for a `subgenus` match
#' (should be lower than `species`)
#' @param score_biological_species Score for a `species` match
#' (should be lower than `subspecies`)
#' @param score_biological_subspecies Score for a `subspecies` match
#' (should be lower than `variety`)
#' @param score_biological_variety Score for a `variety` match
#' (should be the highest)
#' @param score_chemical_cla_kingdom Score for a `Classyfire kingdom` match
#' (should be lower than ` Classyfire superclass`)
#' @param score_chemical_cla_superclass
#' Score for a `Classyfire superclass` match
#' (should be lower than `Classyfire class`)
#' @param score_chemical_cla_class Score for a `Classyfire class` match
#' (should be lower than `Classyfire parent`)
#' @param score_chemical_cla_parent Score for a `Classyfire parent` match
#' (should be the highest)
#' @param score_chemical_npc_pathway Score for a `NPC pathway` match
#' (should be lower than ` NPC superclass`)
#' @param score_chemical_npc_superclass Score for a `NPC superclass`
#' match (should be lower than `NPC class`)
#' @param score_chemical_npc_class Score for a `NPC class` match
#' (should be the highest)
#' @param force Force parameters. Use it at your own risk
#' @param minimal_consistency Minimal consistency score for a class. FLOAT
#' @param minimal_ms1_bio Minimal biological score to keep MS1 based annotation
#' @param minimal_ms1_chemo Minimal chemical score to keep MS1 based annotation
#' @param minimal_ms1_condition Condition to be used. Must be "OR" or "AND".
#' @param ms1_only Keep only MS1 annotations. BOOLEAN
#' @param compounds_names Report compounds names. Can be very large. BOOLEAN
#' @param high_confidence Report high confidence candidates only. BOOLEAN
#' @param remove_ties Remove ties. BOOLEAN
#' @param summarise Summarize results (1 row per feature). BOOLEAN
#' @param pattern Pattern to identify your job. STRING
#'
#' @return NULL
#'
#' @export
#'
#' @seealso annotate_masses weight_bio weight_chemo
#'
#' @examples NULL
weight_annotations <- function(library = get_params(step = "weight_annotations")$files$libraries$sop$merged$keys,
                               org_tax_ott = get_params(step = "weight_annotations")$files$libraries$sop$merged$organisms$taxonomies$ott,
                               str_stereo = get_params(step = "weight_annotations")$files$libraries$sop$merged$structures$stereo,
                               annotations = get_params(step = "weight_annotations")$files$annotations$filtered,
                               canopus = get_params(step = "weight_annotations")$files$annotations$prepared$canopus,
                               formula = get_params(step = "weight_annotations")$files$annotations$prepared$formula,
                               components = get_params(step = "weight_annotations")$files$networks$spectral$components$prepared,
                               edges = get_params(step = "weight_annotations")$files$networks$spectral$edges$prepared,
                               taxa = get_params(step = "weight_annotations")$files$metadata$prepared,
                               output = get_params(step = "weight_annotations")$files$annotations$processed,
                               candidates_final = get_params(step = "weight_annotations")$annotations$candidates$final,
                               weight_spectral = get_params(step = "weight_annotations")$weights$global$spectral,
                               weight_chemical = get_params(step = "weight_annotations")$weights$global$chemical,
                               weight_biological = get_params(step = "weight_annotations")$weights$global$biological,
                               score_biological_domain = get_params(step = "weight_annotations")$weights$biological$domain,
                               score_biological_kingdom = get_params(step = "weight_annotations")$weights$biological$kingdom,
                               score_biological_phylum = get_params(step = "weight_annotations")$weights$biological$phylum,
                               score_biological_class = get_params(step = "weight_annotations")$weights$biological$class,
                               score_biological_order = get_params(step = "weight_annotations")$weights$biological$order,
                               score_biological_infraorder = get_params(step = "weight_annotations")$weights$biological$infraorder,
                               score_biological_family = get_params(step = "weight_annotations")$weights$biological$family,
                               score_biological_subfamily = get_params(step = "weight_annotations")$weights$biological$subfamily,
                               score_biological_tribe = get_params(step = "weight_annotations")$weights$biological$tribe,
                               score_biological_subtribe = get_params(step = "weight_annotations")$weights$biological$subtribe,
                               score_biological_genus = get_params(step = "weight_annotations")$weights$biological$genus,
                               score_biological_subgenus = get_params(step = "weight_annotations")$weights$biological$subgenus,
                               score_biological_species = get_params(step = "weight_annotations")$weights$biological$species,
                               score_biological_subspecies = get_params(step = "weight_annotations")$weights$biological$subspecies,
                               score_biological_variety = get_params(step = "weight_annotations")$weights$biological$variety,
                               score_chemical_cla_kingdom = get_params(step = "weight_annotations")$weights$chemical$cla$kingdom,
                               score_chemical_cla_superclass = get_params(step = "weight_annotations")$weights$chemical$cla$superclass,
                               score_chemical_cla_class = get_params(step = "weight_annotations")$weights$chemical$cla$class,
                               score_chemical_cla_parent = get_params(step = "weight_annotations")$weights$chemical$cla$parent,
                               score_chemical_npc_pathway = get_params(step = "weight_annotations")$weights$chemical$npc$pathway,
                               score_chemical_npc_superclass = get_params(step = "weight_annotations")$weights$chemical$npc$superclass,
                               score_chemical_npc_class = get_params(step = "weight_annotations")$weights$chemical$npc$class,
                               minimal_consistency = get_params(step = "weight_annotations")$annotations$thresholds$consistency,
                               minimal_ms1_bio = get_params(step = "weight_annotations")$annotations$thresholds$ms1$biological,
                               minimal_ms1_chemo = get_params(step = "weight_annotations")$annotations$thresholds$ms1$chemical,
                               minimal_ms1_condition = get_params(step = "weight_annotations")$annotations$thresholds$ms1$condition,
                               ms1_only = get_params(step = "weight_annotations")$annotations$ms1only,
                               compounds_names = get_params(step = "weight_annotations")$options$compounds_names,
                               high_confidence = get_params(step = "weight_annotations")$options$high_confidence,
                               remove_ties = get_params(step = "weight_annotations")$options$remove_ties,
                               summarise = get_params(step = "weight_annotations")$options$summarise,
                               pattern = get_params(step = "weight_annotations")$files$pattern,
                               force = get_params(step = "weight_annotations")$options$force) {
  stopifnot("Annotations file(s) do(es) not exist" = all(lapply(X = annotations, FUN = file.exists) |> unlist()))
  stopifnot("Your library file does not exist." = file.exists(library))
  stopifnot("Your components file does not exist." = file.exists(components))
  stopifnot("Your edges file does not exist." = file.exists(edges))
  stopifnot("Your taxa file does not exist." = file.exists(taxa))
  stopifnot(
    "Condition must be 'OR' or 'AND'." =
      minimal_ms1_condition %in% c("OR", "AND")
  )
  log_debug(x = "Loading files ...")

  log_debug(x = "... components")
  components_table <- fread(
    file = components,
    na.strings = c("", "NA"),
    colClasses = "character"
  )

  log_debug(x = "... edges")
  edges_table <- fread(
    file = edges,
    na.strings = c("", "NA"),
    colClasses = "character"
  )

  log_debug(x = "... structure-organism pairs")
  structure_organism_pairs_table <-
    fread(
      file = library,
      na.strings = c("", "NA"),
      colClasses = "character"
    ) |>
    left_join(fread(
      file = str_stereo,
      na.strings = c("", "NA"),
      colClasses = "character"
    )) |>
    left_join(fread(
      file = org_tax_ott,
      na.strings = c("", "NA"),
      colClasses = "character"
    ))

  log_debug(x = "... canopus")
  canopus_table <-
    fread(
      file = canopus,
      na.strings = c("", "NA"),
      colClasses = "character"
    )

  log_debug(x = "... formula")
  formula_table <-
    fread(
      file = formula,
      na.strings = c("", "NA"),
      colClasses = "character"
    )

  log_debug(x = "... annotations")
  annotation_table <- lapply(
    X = annotations,
    FUN = fread,
    na.strings = c("", "NA"),
    colClasses = "character"
  ) |>
    bind_rows()

  log_debug(
    x = "Got",
    annotation_table |>
      filter(!is.na(
        candidate_structure_inchikey_no_stereo
      )) |>
      distinct(
        feature_id,
        candidate_library,
        candidate_structure_inchikey_no_stereo
      ) |>
      group_by(candidate_library) |>
      count(),
    "initial annotations"
  )

  features_table <- annotation_table |>
    distinct(feature_id, rt, mz)

  log_debug(x = "Re-arranging annotations")
  model <- columns_model()

  annotation_table_1 <- annotation_table |>
    select(any_of(
      c(
        model$features_columns,
        model$candidates_calculated_columns,
        model$candidates_spectra_columns,
        model$candidates_structures_columns
      )
    )) |>
    ## keep best score per structure (example if annotated by MS1 and MS2)
    arrange(desc(candidate_score_similarity)) |>
    distinct(
      feature_id,
      candidate_structure_inchikey_no_stereo,
      candidate_structure_smiles_no_stereo,
      .keep_all = TRUE
    )
  annotation_table_2 <- annotation_table |>
    select(
      any_of(
        c(
          model$features_columns,
          model$candidates_sirius_str_columns,
          model$candidates_structures_columns
        )
      ),
      -candidate_structure_error_mz,
      -candidate_structure_error_rt
    ) |>
    filter(!is.na(candidate_score_sirius_csi)) |>
    distinct()

  annotation_table <- annotation_table_1 |>
    full_join(annotation_table_2) |>
    full_join(formula_table) |>
    full_join(canopus_table) |>
    left_join(
      edges_table |>
        distinct(
          feature_id = feature_source,
          feature_spectrum_entropy,
          feature_spectrum_peaks
        )
    )

  if (ms1_only == TRUE) {
    annotation_table <- annotation_table |>
      filter(is.na(candidate_score_similarity) &
        is.na(candidate_score_sirius_csi))
  }
  if (compounds_names == FALSE) {
    annotation_table <- annotation_table |>
      select(-candidate_structure_name)
  }

  log_debug(x = "adding biological organism metadata")
  annotation_table_taxed <- annotation_table |>
    left_join(fread(
      file = taxa,
      na.strings = c("", "NA"),
      colClasses = "character"
    ))

  rm(annotation_table, annotation_table_1, annotation_table_2)

  log_debug(x = "performing taxonomically informed scoring")
  results <- weight_bio() |>
    decorate_bio() |>
    clean_bio() |>
    weight_chemo() |>
    decorate_chemo() |>
    clean_chemo() |>
    select(where(~ any(!is.na(.))))

  log_debug(x = "Exporting ...")
  time <- format(Sys.time(), "%y%m%d_%H%M%OS")
  dir_time <- file.path(
    parse_yaml_paths()$data$processed$path,
    paste0(time, "_", pattern)
  )
  final_output <- file.path(dir_time, output)
  export_params(
    parameters = get_params(step = "prepare_params"),
    directory = dir_time,
    step = "prepare_params"
  )
  export_params(
    parameters = get_params(step = "prepare_params_advanced"),
    directory = dir_time,
    step = "prepare_params_advanced"
  )
  export_output(x = results, file = final_output)
  rm(results)

  return(final_output)
}
