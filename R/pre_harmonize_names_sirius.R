#' @title Pre harmonize names sirius
#'
#' @description This function pre harmonizes Sirius names to make them compatible
#'
#' @param x Character string containing a name
#'
#' @return Character string with the name modified according to the rules specified in the function
#'
#' @export
#'
#' @examples prepared_name <- pre_harmonize_names_sirius("My name/suffix")
pre_harmonize_names_sirius <- function(x) {
  # Remove any characters after and including the '/' character from the name
  y <- x |>
    stringr::str_remove(pattern = stringr::fixed(pattern = "/.*"))

  return(y)
}