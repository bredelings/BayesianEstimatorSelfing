module PopGen.Selfing.RobustGeneric where

import PopGen
import PopGen.Selfing
import Distributions
import System.Environment

observed_alleles = read_phase_file (getArgs!!0)

n_loci = length observed_alleles

n_individuals = length (observed_alleles!!0) `div` 2

main = do 

-- Uncomment to estimate alpha:
--  alpha <- gamma 0.5 0.05
--  Log "alpha" alpha
  let alpha = 0.10

  theta_effective <- dp n_loci alpha (gamma 0.25 2.0) 
  -- Alternatively, one can use a dirichlet process mixture:
  --  theta_effective <- dpm n_loci (gamma 0.5 1.0) (gamma 1.05 0.1) 

  f <- sample $ uniform 0.0 1.0
                     
  s <- sample $ uniform 0.0 1.0

  (t, afs_dist) <- robust_diploid_afs n_individuals n_loci s f theta_effective

  observe afs_dist observed_alleles

  return $ log_all [t %% "t",
                    s %% "s*",
                    f %% "f",
                    theta_effective %% "theta*"]

