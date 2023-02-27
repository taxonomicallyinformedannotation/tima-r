#' @title Replace ID in file paths
#'
#' @description This function replaces the default ID in the example by a user-specified one
#'
#' @param x a character string containing the default ID
#' @param default the default values for a GNPS job ID
#' @param repl a user-specified values for a GNPS job ID
#'
#' @return Character string with the GNPS job ID modified according to the rules specified in the function
#'
#' @export
#'
#' @examples replace_id(x = "example/123456_features.tsv", user_gnps = NULL, user_filename = "Foo")
replace_id <-
  function(x,
           user_filename = filename,
           user_gnps = gnps_job_id) {
    if (user_gnps == "96fa7c88200e4a03bee4644e581e3fb0") {
      user_gnps <- "example"
    }

    path <- x |>
      gsub(pattern = "/[^/]*$", replacement = "")

    file <- x |>
      gsub(pattern = ".*/", replacement = "")

    old <- file |>
      gsub(pattern = "_.*", replacement = "")

    new <- file |>
      gsub(
        pattern = old,
        replacement = ifelse(
          test = !is.null(user_gnps),
          yes = user_gnps,
          no = user_filename
        )
      )

    final <- file.path(path, new)

    return(final)
  }