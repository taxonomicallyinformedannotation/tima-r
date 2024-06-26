#' @title Install latest version
#'
#' @description This function installs the latest version
#'
#' @param test Flag for test
#'
#' @return NULL
#'
#' @export
#'
#' @examples NULL
install_latest_version <- function(test = FALSE) {
  options(repos = c(CRAN = "https://cloud.r-project.org"))
  if (Sys.info()[["sysname"]] == "Windows") {
    if (!requireNamespace("installr", quietly = TRUE)) {
      install.packages("installr")
    }
    installr::install.rtools(check_r_update = FALSE, GUI = FALSE)
  }
  if (!requireNamespace("pak", quietly = TRUE)) {
    lib <- Sys.getenv("R_LIBS_SITE")
    if (lib == "") {
      lib <- file.path(dirname(.Library), "site-library")
      cat(sprintf("R_LIBS_SITE=%s\n", lib), append = TRUE)
      cat(sprintf("R_LIB_FOR_PAK=%s\n", lib), append = TRUE)

      message("Setting R_LIBS_SITE to ", lib)
    } else {
      message("R_LIBS_SITE is already set to ", lib)
      cat(sprintf(
        "R_LIB_FOR_PAK=%s\n",
        strsplit(lib, .Platform$path.sep)[[1]][[1]]
      ), append = TRUE)
    }
    install.packages(
      "pak",
      repos = sprintf(
        "https://r-lib.github.io/p/pak/stable/%s/%s/%s",
        .Platform$pkgType,
        R.Version()$os,
        R.Version()$arch
      )
    )
  }
  if (!requireNamespace(c("timaR"), quietly = TRUE)) {
    message("Installing for the first time...")
    local_version <- "myFirstInstallTrickToWork"
  } else {
    local_version <- pak::pkg_status("timaR")$version[1]
  }
  # TODO not ideal
  remote_version <- readLines(
    "https://raw.githubusercontent.com/taxonomicallyinformedannotation/tima-r/main/DESCRIPTION"
  )[[3]] |>
    gsub(
      pattern = "Version: ",
      replacement = "",
      fixed = TRUE
    )
  if ((local_version == remote_version) && (test == FALSE)) {
    message(
      "You already have the latest version (",
      local_version,
      ") skipping"
    )
  } else {
    pak::pak_update()
    pak::pak(ask = FALSE, upgrade = TRUE)
    # Try installing the local version first
    success <- tryCatch(
      {
        message("Installing local version")
        pak::pkg_install(
          pkg = ".",
          ask = FALSE,
          upgrade = FALSE
        )
        return(test == FALSE)
      },
      error = function(e) {
        return(FALSE)
      }
    )
    # If local version installation fails, try the URL from DESCRIPTION file
    if (!success) {
      success <- tryCatch(
        {
          message("Installing local version from URL")
          pak::pkg_install(
            pkg = desc::desc_get_urls()[[1]],
            ask = FALSE,
            upgrade = FALSE
          )
          return(test == FALSE)
        },
        error = function(e) {
          return(FALSE)
        }
      )
    }
    # If URL installation fails, try installing the remote version from GitHub
    if (!success) {
      success <- tryCatch(
        {
          message("Installing remote version")
          pak::pkg_install(
            pkg = "taxonomicallyinformedannotation/tima-r",
            ask = FALSE,
            upgrade = FALSE
          )
          return(test == FALSE)
        },
        error = function(e) {
          message("Install failed")
          return(FALSE)
        }
      )
    }
    # Final message if all attempts fail
    if (!success) {
      message("All installation attempts failed")
    }
  }
  cache <- fs::path_home(".tima")
  message("Creating cache at ", cache)
  fs::dir_create(path = cache)
  message("Copying default architecture ...")
  tryCatch(
    expr = {
      fs::dir_copy(
        path = "./inst",
        new_path = file.path(cache, "inst"),
        overwrite = TRUE
      )
    },
    error = function(e) {
      if (file.exists("./../../app.R")) {
        message("I'm in test dir")
        fs::dir_copy(
          path = "./../../",
          new_path = file.path(cache, "inst"),
          overwrite = TRUE
        )
      }
    }
  )
  tryCatch(
    expr = {
      message("Installing local targets")
      fs::file_copy(
        path = "./_targets.yaml",
        new_path = file.path(cache, "_targets.yaml"),
        overwrite = TRUE
      )
    },
    error = function(e) {
      message("Installing remote targets")
      timaR::get_file(
        url = "https://raw.githubusercontent.com/taxonomicallyinformedannotation/tima-r/main/_targets.yaml",
        export = file.path(cache, "_targets.yaml")
      )
    }
  )
  tryCatch(
    expr = {
      message("Getting local DESCRIPTION")
      fs::file_copy(
        path = "./DESCRIPTION",
        new_path = file.path(cache, "DESCRIPTION"),
        overwrite = TRUE
      )
    },
    error = function(e) {
      message("Getting remote DESCRIPTION")
      timaR::get_file(url = "https://raw.githubusercontent.com/taxonomicallyinformedannotation/tima-r/main/DESCRIPTION", export = file.path(cache, "DESCRIPTION"))
    }
  )
}
