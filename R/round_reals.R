#' @title Round reals
#'
#' @param df Dataframe to use
#' @param dig Number of digits
#'
#' @return NULL
#'
#' @export
#'
#' @examples NULL
round_reals <- function(df, dig = 5) {
  df |>
    ## Round to 5 digits to avoid small discrepancies
    tidytable::mutate(tidytable::across(
      .cols = c(
        tidytable::contains("structure_exact_mass"),
        tidytable::contains("structure_xlogp")
      ),
      .fns = \(x) round(as.numeric(x), digits = dig)
    ))
}
