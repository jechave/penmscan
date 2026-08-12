# Refresh data to use in test_amrs.R

## ----------------------------------------------------------------------------------------------------------------------
# load libraries
library(tidyverse)
library(bio3d)
library(penm)
library(jefuns)
library(here)
library(tictoc)
library(Matrix)


## ----------------------------------------------------------------------------------------------------------------------
load(here("tests/testthat/fixtures/wt.rda"))

mrs_all_output <- mrs_all(wt, nmut = 5, mut_model = "lfenm", mut_dl_sigma = 0.3, mut_sd_min = 1, seed = 1234)
save(mrs_all_output, file = here("tests/testthat/fixtures/mrs_all_output.rda"))

smrs_all_output <- smrs_all(wt, nmut = 5, mut_model = "lfenm", mut_dl_sigma = 0.3, mut_sd_min = 1, seed = 1234)
save(smrs_all_output, file = here("tests/testthat/fixtures/smrs_all_output.rda"))

amrs_all_output <- amrs_all(wt, mut_dl_sigma = 0.3, mut_sd_min = 1)
save(amrs_all_output, file = here("tests/testthat/fixtures/amrs_all_output.rda"))




