## ----------------------------------------------------------------------------------------------------------------------
# Test analytic Double Mutational Response Scanning function `amrs`

# load libraries
library(tidyverse)
library(bio3d)
library(penmscan)
library(jefuns)
library(here)
library(tictoc)
library(Matrix)

load(test_path("fixtures", "wt.rda"))

# The stored fixtures predate two representation changes that leave every value
# untouched:
#   1. jefuns::matrix_to_tibble() now ends with arrange(j, i) (column-major);
#      the fixtures were saved row-major. This reorders rows only.
#   2. mut_param$nmut_per_site was renamed to nmut.
# Canonicalise both sides so the comparison tests values, not representation.
canonicalise <- function(x) {
  sort_tbl <- function(tbl) {
    keys <- intersect(c("i", "j", "n"), names(tbl))
    if (length(keys) == 0) return(tbl)
    dplyr::arrange(tbl, dplyr::across(dplyr::all_of(keys)))
  }
  if (!is.null(x$mut_param)) {
    names(x$mut_param)[names(x$mut_param) == "nmut_per_site"] <- "nmut"
  }
  lapply(x, function(el) if (is.data.frame(el)) sort_tbl(el) else el)
}

load(test_path("fixtures", "mrs_all_output.rda"))
mrs_all_output_test <- mrs_all(wt, nmut = 5, mut_model = "lfenm", mut_dl_sigma = 0.3, mut_sd_min = 1, seed = 1234)
test_that("mrs with option mean_max is ok", {
  expect_equal(canonicalise(mrs_all_output_test), canonicalise(mrs_all_output))
  })

load(test_path("fixtures", "smrs_all_output.rda"))
smrs_all_output_test <- smrs_all(wt, nmut = 5, mut_model = "lfenm", mut_dl_sigma = 0.3, mut_sd_min = 1, seed = 1234)
test_that("smrs with option mean_max is ok", {
  expect_equal(canonicalise(smrs_all_output_test), canonicalise(smrs_all_output))
})

load(test_path("fixtures", "amrs_all_output.rda"))
amrs_all_output_test <- amrs_all(wt, mut_dl_sigma = 0.3, mut_sd_min = 1)
test_that("amrs with option mean_max is ok", {
  expect_equal(canonicalise(amrs_all_output_test), canonicalise(amrs_all_output))
  })



