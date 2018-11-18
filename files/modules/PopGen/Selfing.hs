module PopGen.Selfing where

import Distributions
import Range

builtin builtin_ewens_diploid_probability 3 "ewens_diploid_probability" "PopGen"
builtin builtin_sum_out_coals 3 "sum_out_coals" "MCMC"

sum_out_coals x y c = IOAction3 builtin_sum_out_coals x y c

ewens_diploid_probability theta i x = builtin_ewens_diploid_probability theta (list_to_vector i) (list_to_vector x)

afs2 thetas ps = ProbDensity (ewens_diploid_probability thetas ps) (error "afs2 has no quantile") () ()

robust_diploid_afs n_individuals n_loci s f theta_effective = do 
  t <- sample $ iid n_individuals (rgeometric s)

  i <- sample $ plate n_individuals (\k->iid n_loci (rbernoulli (0.5**t!!k*(1.0-f))) )

  AddMove (\c -> mapM_ (\k-> sum_out_coals (t!!k) (i!!k) c) [0..n_individuals-1])

  return $ (t, plate n_loci (\l -> afs2 (theta_effective!!l) (map (!!l) i)))

diploid_afs n_individuals n_loci s theta_effective = robust_diploid_afs n_individuals n_loci s 0.0 theta_effective
