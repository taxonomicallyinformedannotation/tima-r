utils::globalVariables(
  c(
    "type"
  )
)

#' @title Prepare libraries of retention times
#'
#' @description This function prepares retention times libraries
#'    to be used for later
#'
#' @param mgf_exp MGF containing experimental retention times
#' @param mgf_is MGF containing in silico predicted retention times
#' @param temp_exp File containing experimental retention times
#' @param temp_is File containing in silico predicted retention times
#' @param output_rt Output retention time file
#' @param output_sop Output pseudo sop file
#' @param col_ik Name of the InChIKey in mgf
#' @param col_rt Name of the retention time in mgf
#' @param col_sm Name of the SMILES in mgf
#' @param name_inchikey Name of the InChIKey in file
#' @param name_rt Name of the retention time in file
#' @param name_smiles Name of the SMILES in file
#' @param unit_rt Unit of the retention time. Must be "seconds" or "minutes"
#' @param parameters Params
#'
#' @return NULL
#'
#' @export
#'
#' @examples NULL
prepare_libraries_rt <-
  function(mgf_exp = params$files$libraries$spectral$exp,
           mgf_is = params$files$libraries$spectral$is,
           temp_exp = params$files$libraries$temporal$exp,
           temp_is = params$files$libraries$temporal$is,
           output_rt = params$files$libraries$temporal$prepared,
           output_sop = params$files$libraries$sop$prepared,
           col_ik = params$names$mgf$inchikey,
           col_rt = params$names$mgf$retention_time,
           col_sm = params$names$mgf$smiles,
           name_inchikey = params$names$inchikey,
           name_rt = params$names$rt,
           name_smiles = params$names$smiles,
           unit_rt = params$units$rt,
           parameters = params) {
    params <<- parameters

    ## default transforms from `Spectra`
    if (col_rt == "RTINSECONDS") {
      col_rt <- "rtime"
    }
    if (col_sm == "SMILES") {
      col_sm <- "smiles"
    }

    ## TODO improve
    if (length(mgf_exp$neg) == 0) {
      mgf_exp$neg <- NULL
    }
    if (length(mgf_exp$pos) == 0) {
      mgf_exp$pos <- NULL
    }
    if (length(mgf_exp) == 0) {
      mgf_exp <- NULL
    }
    if (length(mgf_is$neg) == 0) {
      mgf_is$neg <- NULL
    }
    if (length(mgf_is$pos) == 0) {
      mgf_is$pos <- NULL
    }
    if (length(mgf_is) == 0) {
      mgf_is <- NULL
    }
    if (length(temp_exp) == 0) {
      temp_exp <- NULL
    }
    if (length(temp_is) == 0) {
      temp_is <- NULL
    }

    rts_from_mgf <-
      function(mgf) {
        log_debug("Importing spectra ...")
        spectra <- mgf |>
          lapply(FUN = import_spectra)
        log_debug("Extracting retention times...")
        ## TODO refactor to avoid pos neg
        rts <-
          tidytable::bind_rows(
            spectra$neg@backend@spectraData |>
              data.frame() |>
              tidytable::as_tidytable(),
            spectra$pos@backend@spectraData |>
              data.frame() |>
              tidytable::as_tidytable()
          ) |>
          tidytable::select(tidytable::any_of(c(
            rt = col_rt,
            inchikey = col_ik,
            smiles = col_sm
          )))
        return(rts)
      }
    rts_from_tab <-
      function(tab) {
        log_debug("Importing file ...")
        rts <- tab |>
          lapply(FUN = tidytable::fread) |>
          tidytable::bind_rows() |>
          tidytable::select(tidytable::any_of(
            c(
              rt = name_rt,
              inchikey = name_inchikey,
              smiles = name_smiles
            )
          ))
        return(rts)
      }
    polish_df <-
      function(df,
               type = "experimental",
               unit = unit_rt) {
        df_polished <- df |>
          data.frame() |>
          tidytable::mutate(type = type) |>
          tidytable::rowwise() |>
          tidytable::mutate(rt = ifelse(unit == "seconds",
            yes = rt / 60,
            no = rt
          )) |>
          tidytable::bind_rows(data.frame(
            inchikey = NA_character_,
            smiles = NA_character_
          )) |>
          tidytable::filter(!is.na(as.numeric(rt))) |>
          tidytable::filter(!is.na(smiles)) |>
          tidytable::distinct()
        return(df_polished)
      }
    complete_df <- function(df) {
      df_full <- df |>
        tidytable::filter(!is.na(inchikey))
      df_missing <- df |>
        tidytable::filter(is.na(inchikey))
      log_debug(
        "There are",
        nrow(df_missing),
        "entries without InChIKey.",
        "We would recommend you adding them but will try completing.",
        "We will query them on the fly, this might take some time."
      )
      ## TODO change with a small dependency
      smiles <- unique(df_missing$smiles)
      get_inchikey <- function(smiles, toolkit = "rdkit") {
        url <- paste0(
          "https://api.naturalproducts.net/latest/convert/inchikey?smiles=",
          utils::URLencode(smiles),
          "&toolkit=",
          toolkit
        )
        tryCatch(
          expr = jsonlite::fromJSON(txt = url),
          error = function(e) {
            return(NA_character_)
          }
        )
      }
      inchikey <- pbapply::pblapply(
        X = smiles,
        FUN = get_inchikey
      ) |>
        as.character()
      df_missing <- df_missing |>
        tidytable::select(-inchikey) |>
        tidytable::left_join(tidytable::tidytable(
          smiles,
          inchikey
        ))

      df_completed <- df_full |>
        tidytable::bind_rows(df_missing) |>
        tidytable::mutate(
          tidytable::across(
            .cols = tidytable::where(is.character),
            .fns = function(x) {
              tidytable::na_if(x, "NA")
            }
          )
        )
      df_completed <- df_completed |>
        tidytable::select(
          rt,
          structure_smiles = smiles,
          structure_inchikey = inchikey,
          type
        ) |>
        tidytable::distinct()
      log_debug(
        "There were still",
        nrow(df_completed |>
          tidytable::filter(is.na(
            structure_inchikey
          ))),
        "entries for which no InChIKey could not be found in the end."
      )
      return(df_completed)
    }

    empty_df <- tidytable::tidytable(
      rt = NA_real_,
      structure_smiles = NA_character_,
      structure_inchikey = NA_character_,
      type = NA_character_
    )

    ## from mgf
    if (!is.null(mgf_exp)) {
      rts_exp_1 <- mgf_exp |>
        rts_from_mgf() |>
        polish_df() |>
        complete_df()
    } else {
      rts_exp_1 <- empty_df
    }
    if (!is.null(mgf_is)) {
      rts_is_1 <- mgf_is |>
        rts_from_mgf() |>
        polish_df(type = "predicted") |>
        complete_df()
    } else {
      rts_is_1 <- empty_df
    }

    ## from csv
    if (!is.null(temp_exp)) {
      rts_exp_2 <- temp_exp |>
        rts_from_tab() |>
        polish_df() |>
        complete_df()
    } else {
      rts_exp_2 <- empty_df
    }
    if (!is.null(temp_is)) {
      rts_is_2 <- temp_is |>
        rts_from_tab() |>
        polish_df(type = "predicted") |>
        complete_df()
    } else {
      rts_is_2 <- empty_df
    }

    df_rts <- tidytable::bind_rows(
      rts_exp_1,
      rts_exp_2,
      rts_is_1,
      rts_is_2
    ) |>
      tidytable::filter(!is.na(as.numeric(rt))) |>
      tidytable::filter(!is.na((structure_inchikey)))

    sop <- df_rts |>
      tidytable::select(
        structure_smiles,
        structure_inchikey,
        organism_name = type
      ) |>
      tidytable::distinct()

    rts <- df_rts |>
      tidytable::select(-structure_smiles) |>
      tidytable::distinct() |>
      tidytable::mutate(structure_inchikey_2D = gsub(
        pattern = "-.*",
        replacement = "",
        x = structure_inchikey
      )) |>
      ## TODO REMINDER FOR NOW
      tidytable::select(-structure_inchikey)

    if (nrow(rts) == 0) {
      log_debug("No retention time library found, returning empty table.")
      sop <- tidytable::tidytable(
        structure_smiles = NA_character_,
        structure_inchikey_2D = NA_character_,
        organism_name = NA_character_
      )
    }

    if (nrow(rts) == 0) {
      log_debug("No retention time library found, returning empty tables")
      rts <- tidytable::tidytable(
        rt = NA_real_,
        structure_inchikey_2D = NA_character_,
        type = NA_character_
      )
    }
    export_params(step = "prepare_libraries_rt")
    export_output(x = rts, file = output_rt)
    export_output(x = sop, file = output_sop)
    return(
      c(
        "rt" = output_rt,
        "sop" = output_sop
      )
    )
  }