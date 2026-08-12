# Ideas / pending work

Items deliberately set aside during other work, kept here so they are not
rediscovered from scratch. Nothing below is urgent; none of it blocks current
functionality.

## 1. Inconsistent default `seed`

Entry points disagree on what `seed` defaults to:

| function | default |
|---|---|
| `get_mutant_site()` (`R/penm.R`) | `241956` |
| `smrs()`, `sdmrs()` | `1024` |
| `smrs_ddg()`, `smrs_ddgact()`, `smrs_all()`, `mrs_all()`, `generate_mutants()` | none — required |

So the same nominal "default" produces different mutant ensembles depending on
which entry point is used. Options: unify on one value, or drop the defaults and
require `seed` everywhere (most explicit for a scientific package, and matches
what the majority of functions already do).

Not done because it is an API break: `tests/testthat/test_penm.R` and
`test_penm_sc.R` call `get_mutant_site()` with no `seed` and so pin `241956`,
and several files under `Rmd/` do the same.

## 2. `set.seed()` clobbers the user's global RNG state

Every `set.seed()` in the package permanently overwrites the caller's
`.Random.seed`. A user who seeds their own analysis, then calls `smrs()`, silently
loses their stream.

Fixable with `on.exit()` save/restore around the seeding sites, without taking on
a `withr` dependency. All seeding now goes through `R/seed.R`, so the change is
localised.

## 3. Documentation gaps reported by `R CMD check`

`devtools::check()` currently reports **0 errors, 3 warnings, 5 notes**. All
predate the 2026-08 seeding work. The documentation-related ones:

**Undocumented code objects** (WARNING) — these are `@export` + `@noRd`, so they
are exported without a help page:

```
amrs_all  calculate_enm_eij  calculate_enm_graph  calculate_enm_kmat
calculate_enm_nma  calculate_enm_nodes  delta_energy_dg_entropy
delta_energy_dvm  dmrs_analytical  dmrs_simulation  generate_mutants
get_mutant_site  mrs_all  old_name  smrs_all
```

Decide per object: document it properly, or unexport it if it is internal.
`old_name` looks like leftover scaffolding worth deleting.

**Undocumented arguments** (WARNING):
- `delta_energy`: `beta`, `ideal`, `pdb_site_active`
- `delta_structure_by_site`: `kmat_sqrt`
- `dgact_dv`: `prot`, `ideal`, `pdb_site_active`
- `dgact_tds`: `prot`, `ideal`, `pdb_site_active`, `beta`

**Rd line widths** (NOTE) — `\examples` lines over 100 characters in
`amrs_ddgact.Rd`, `sdmrs.Rd`, `smrs.Rd`, `smrs_ddg.Rd`, `smrs_ddgact.Rd`. These get
truncated in the PDF manual. Fix by wrapping the roxygen `@examples` source.

**Stale examples** — `R/mutscan_amrs_ddg.R:23` and `R/mutscan_amrs.R:89` pass
`seed = 1024` to functions that take no `seed` argument (the analytic functions are
deterministic). This propagates into `man/amrs_ddg.Rd`.

## 4. Other `R CMD check` notes

- **`no visible binding for global variable`** — several hundred, from tidyverse
  NSE (`i`, `j`, `dr2ij`, `mij`, …). Standard fix is a
  `utils::globalVariables()` call in one file.
- **Non-standard files at top level** — `CLAUDE.md`, `penm_0.2.0.9000.pdf`,
  `penm_0.2.0.pdf`. Add to `.Rbuildignore`.
- **Hidden directory `.claude`** — add to `.Rbuildignore`.
- **Unstated dependencies in tests** — `here`, `tictoc`, `tidyverse` are called
  via `library()` in test files but not declared in `Suggests`.

## 5. `sclfenm` is not verified

The self-consistent model (`mut_model = "sclfenm"`) is not confirmed correct, and
its tests are skipped on purpose ("Skip sclfenm test until sclefnm is fixed").
This is a science question, to be taken up deliberately in its own session — not
as a side effect of other work.

Open markers on that path:
- `R/penm.R:117` — `#TODO revise this: mut parameters are w.r.t. w0, not wt...`,
  on the `lij` update inside `get_mutant_site_sclfenm()`.
- `R/penm.R:226` — `WARNING: I'm not sure that "frustrated" case is handled well`
  on `mutate_graph()`, reached from sclfenm via `mutate_enm()`.

Consequences to respect while it stays unverified:
- `tests/testthat/fixtures/mut_qf.rda` still holds values from before the
  2026-08 seed-key change, and `mut_sc_qf.rda` does not exist. This is
  intentional: regenerating them would freeze the output of a model whose
  correctness is unestablished, making a future correct implementation look like
  a regression. Both fixtures are unused while the tests skip.
- **Not a defect:** sclfenm changes the *number of graph edges* (e.g. 956 → 962
  for 2acy site 80). That is the model working as designed — it recalculates the
  contact map from the mutant's coordinates, so new coordinates cross the
  distance cutoff differently.

## 6. Environment note (not a package issue)

`R CMD check` hangs indefinitely at `checking package dependencies` when
`options("repos")` is the unresolved `"@CRAN@"` placeholder, because dependency
resolution has no repository to consult. Fixed on this machine by setting a
mirror in `~/.Rprofile`:

```r
options(repos = c(CRAN = "https://cloud.r-project.org"))
```

Worth knowing on any new machine — the symptom looks like a slow check rather
than a configuration problem, and `_R_CHECK_CRAN_INCOMING_=FALSE` does *not*
work around it (`devtools::check()` already sets that itself).
