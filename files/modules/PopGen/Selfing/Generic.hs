module PopGen.Selfing.Generic where

import PopGen
import PopGen.Selfing
import Probability
import System.Environment

observed_alleles = read_phase_file (getArgs!!0)

n_loci = length observed_alleles

n_individuals = length (observed_alleles!!0) `div` 2

main = do 

-- Uncomment to estimate alpha:
--  alpha <- gamma 0.5 0.05;
  let alpha = 0.10

  theta_effective <- dp n_loci alpha (gamma 0.25 2.0)

  -- Alternatively, one can use a dirichlet process mixture:
  --  theta_effective <- dpm n_loci (gamma 0.5 1.0) (gamma 1.05 0.1); 

  s <- sample $ uniform 0.0 1.0

  (t, afs_dist) <- diploid_afs n_individuals n_loci s theta_effective

  observe observed_alleles afs_dist

  return $ log_all [s %% "s*",
                    t %% "t",
                    theta_effective %% "theta*" ]
