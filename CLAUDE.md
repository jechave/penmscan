# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Package Overview

The `penm` package (Perturbing Elastic Network Models) is an R package for building and analyzing Elastic Network Models (ENMs) of proteins. It performs mutation scanning and calculates mutation-response matrices for protein structure analysis.

## Development Commands

### Building and Installing
```bash
# Install the package and its dependencies
R CMD INSTALL .

# Build and check the package
R CMD build .
R CMD check penm_*.tar.gz

# Install using devtools (recommended for development)
Rscript -e "devtools::install()"
Rscript -e "devtools::build()"
Rscript -e "devtools::check()"
```

### Testing
```bash
# Run all tests
Rscript -e "devtools::test()"

# Run specific test file
Rscript -e "testthat::test_file('tests/testthat/test_enm.R')"
```

### Documentation
```bash
# Generate documentation from roxygen2 comments
Rscript -e "devtools::document()"

# Build package documentation
Rscript -e "pkgdown::build_site()"
```

## Architecture

### Core Components

1. **ENM Creation (`R/enm.R`)**
   - `set_enm()`: Main function that creates a `prot` object containing ENM structure
   - Creates a protein object with components: param, nodes, graph, eij, kmat, nma
   - Supports different models: "anm", "ming_wall", "hnm", "hnm0", "pfanm", "reach"
   - Node types: "ca" (alpha carbons) or "sc" (side chains)

2. **Mutation Perturbation (`R/penm.R`)**
   - `get_mutant_site()`: Core mutation function supporting two models:
     - `lfenm`: Linear Force ENM model (fast, approximate)
     - `sclfenm`: Self-Consistent LFENM (recalculates full ENM)
   - Mutations perturb edge lengths based on sequence distance

3. **Mutation Scanning Analysis**
   - **Analytical methods** (`R/mutscan_amrs.R`, `R/mutscan_admrs.R`):
     - `amrs()`: Single-site mutation response scanning
     - `admrs()`: Double-site mutation response (compensation matrices)
   - **Simulation methods** (`R/mutscan_smrs.R`, `R/mutscan_sdmrs.R`):
     - `smrs()`: Monte Carlo simulation of mutation responses
     - `sdmrs()`: Simulation-based double mutation scanning

4. **Response Calculations**
   - Three response types calculated:
     - `dr2`: Structural deformations (displacement)
     - `de2`: Deformation energy
     - `df2`: Mechanical force
   - Responses can be calculated by site or by normal mode

### Data Flow

1. PDB file → `bio3d::read.pdb()` → pdb object
2. pdb object → `set_enm()` → prot object (contains ENM)
3. prot object → mutation scanning functions → response matrices
4. Response matrices → analysis/visualization

### Key Dependencies

- **bio3d**: PDB file reading and structural analysis
- **jefuns**: Utility functions (sister package)
- **Matrix**: Sparse matrix operations
- **pracma**: Numerical analysis
- Standard tidyverse packages for data manipulation

### Testing Structure

Tests are in `tests/testthat/` with pre-computed reference data in `tests/data/`:
- `test_enm.R`: Core ENM creation tests
- `test_penm.R`: Mutation perturbation tests
- `test_penm_sc.R`: Side-chain specific tests
- `test_mrs_all.R`: Mutation response scanning tests
- `test_dmrs.R`: Double mutation response tests

Test data can be refreshed using scripts in `tests/R/`:
- `refresh_test_enm_data.R`
- `refresh_test_penm_data.R`
- `refresh_test_penm_sc_data.R`

### Important Parameters

- `d_max`: Distance cutoff for defining network contacts (typically 10.5 Å for Cα, 12.5 Å for side chains)
- `mut_dl_sigma`: Standard deviation for edge length perturbations (typically 0.3)
- `mut_sd_min`: Minimum sequence distance for mutation (typically 1-2)
- `frustrated`: Whether to include frustrations in the model (typically FALSE)