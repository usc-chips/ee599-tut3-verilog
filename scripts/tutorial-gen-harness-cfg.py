#=========================================================================
# Configuration file for generating the tutorial's harness
#=========================================================================

include_full_subpkgs = [
  "ex-basics",
  "ex-gcd",
  "vc",
]

include_partial_subpkgs = [
  "ex-sorter",
]

include_partial_subpkgs_full_files = [
  "ex-sorter/ex-sorter-SorterFlat.v",
  "ex-sorter/ex-sorter-SorterStruct.v",
  "ex-sorter/ex-sorter-gen-input.py",
  "ex-sorter/ex-sorter-test-harness.v",
  "ex-sorter/ex-sorter-sim-harness.v",
  "ex-sorter/ex-sorter-sim-flat.v",
  "ex-sorter/ex-sorter-sim-struct.v",
]

include_partial_subpkgs_strip_files = [
  "ex-sorter/ex-sorter.mk",
  "ex-sorter/ex-sorter-MinMaxUnit.v",
  "ex-sorter/ex-sorter-SorterFlat.t.v",
  "ex-sorter/ex-sorter-SorterStruct.t.v",
]

