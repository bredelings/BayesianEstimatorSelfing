module PopGen.Selfing.Herm where

import PopGen
import PopGen.Selfing
import Distributions
import System.Environment

observed_alleles = read_phase_file (getArgs!!0)

n_loci = length observed_alleles

n_individuals = length (observed_alleles!!0) `div` 2

main = do 

  let alpha = 1.0

  theta_effective <- dp n_loci alpha (gamma 0.25 2.0)

  s <- sample $ uniform 0.0 1.0

  let r = 1.0
  
  -- theta* = factor * theta
  let factor = (1.0 - s*0.5)/r

  let theta = map (/factor) theta_effective

  (t,afs_dist) <- diploid_afs n_individuals n_loci s theta_effective

  observe afs_dist observed_alleles

  return $ log_all [ t %% "t",
                     s %% "s*",
                     theta_effective %% "theta*",
                     theta %% "theta",
                     r %% "R" ]
