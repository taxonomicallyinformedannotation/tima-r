## Simple install helper
options(repos = c(CRAN = "https://cloud.r-project.org"))
if (Sys.info()[["sysname"]] == "Windows") {
  if (!requireNamespace("installr", quietly = TRUE)) {
    install.packages("installr")
  }
  installr::install.rtools(
    check_r_update = FALSE,
    GUI = FALSE
  )
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
    cat(
      sprintf(
        "R_LIB_FOR_PAK=%s\n",
        strsplit(lib, .Platform$path.sep)[[1]][[1]]
      ),
      append = TRUE
    )
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
pak::pak_update()
pak::lockfile_create()
pak::lockfile_install()
unlink(x = "pkg.lock")
pak::pak(
  ask = FALSE,
  upgrade = FALSE
)
tryCatch(
  expr = {
    pak::pkg_install(
      pkg = desc::desc_get_urls()[[1]],
      ask = FALSE,
      upgrade = FALSE
    )
  },
  error = function(e) {
    pak::pkg_install(
      pkg = ".",
      ask = FALSE,
      upgrade = FALSE
    )
  }
)
