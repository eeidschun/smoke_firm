## ============================================================================
## Central path constants for the smoke_firm pipeline.
##
## Source this at the top of every script:
##     source("smoke_firm_dir/code/fxns/1_paths.R")
##
## Scripts are run from the REPOSITORY ROOT (the folder that contains
## smoke_firm_dir/). Running from inside smoke_firm_dir/ also works.
##
## Exposes (all absolute after normalizePath):
##   FIRM_DIR     smoke_firm_dir/                     the working copy
##   CODE_DIR     smoke_firm_dir/code/
##   FXN_DIR      smoke_firm_dir/code/fxns/           shared function files
##   SUPPORT_DIR  smoke_firm_dir/input/               support files + built panels
##   OUT_DIR      smoke_firm_dir/output/
##   PRELIM_DIR   smoke_firm_dir/output/prelim_analysis/
##   RAW_DIR      smoke_firm_dir/raw/cleaned_RMS/     full_*_7467_*.RData (gitignored)
##   fxn("2_upc_overrides.R")                         source a sibling function file
## ============================================================================

local({
  root <- if (dir.exists("smoke_firm_dir"))                 "smoke_firm_dir"
          else if (dir.exists(file.path("code", "fxns")))   "."
          else stop("1_paths.R: run from the repository root (the folder containing ",
                    "smoke_firm_dir/), or from inside smoke_firm_dir/.", call. = FALSE)
  assign("FIRM_DIR", normalizePath(root, mustWork = TRUE), envir = .GlobalEnv)
})

CODE_DIR    <- file.path(FIRM_DIR, "code")
FXN_DIR     <- file.path(CODE_DIR, "fxns")
SUPPORT_DIR <- file.path(FIRM_DIR, "input")
OUT_DIR     <- file.path(FIRM_DIR, "output")
PRELIM_DIR  <- file.path(OUT_DIR, "prelim_analysis")
RAW_DIR     <- file.path(FIRM_DIR, "raw", "cleaned_RMS")

fxn <- function(name) source(file.path(FXN_DIR, name))
