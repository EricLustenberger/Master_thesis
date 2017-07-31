  set obs 1
  gen year=1970
  gen mstat=2
  gen ltcg=100000
  taxsim9,replace
  list
