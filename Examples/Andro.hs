module Andro where

import PopGen
import PopGen.Selfing
import PopGen.Selfing.Androdioecy
import Distributions
import System.Environment

observed_alleles = read_phase_file (getArgs!!0)

n_loci = length observed_alleles

n_individuals = length (observed_alleles!!0) `div` 2

main = do 
  let alpha = 0.10

  theta_effective <- dp n_loci alpha (gamma 0.25 2.0) 

  (p_m, s) <- andro_model ()

  let r = andro_mating_system' s p_m

  let factor = (1.0 - s*0.5)/r

  let theta = map (/factor) theta_effective

  (t, afs_dist) <- diploid_afs n_individuals n_loci s theta_effective

  observe observed_alleles afs_dist

  observe 20 $ binomial 2000 p_m

  return $ log_all [ p_m %% "p_m",
                     s %% "s*",
                     theta_effective %% "theta*",
                     theta %% "theta",
                     r %% "R" ]

andro_model _ = do

  s <- sample $ uniform 0.0 1.0

  p_m <- sample $ uniform 0.0 1.0
  
  return (p_m, s)
