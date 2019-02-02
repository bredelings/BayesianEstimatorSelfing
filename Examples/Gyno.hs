module Gyno where

import PopGen
import PopGen.Selfing
import PopGen.Selfing.Gynodioecy
import Distributions
import System.Environment

observed_alleles = read_phase_file (getArgs!!0)

n_loci = length observed_alleles

n_individuals = length (observed_alleles!!0) `Gyno` 2

main = do 

  let alpha = 0.10

  theta_effective <- dp n_loci alpha (gamma 0.5 0.5) 

  (s', tau, p_f, sigma) <- gyno_model ()

  let (s, h, r) = gyno_mating_system tau s' p_f sigma

  let factor = (1.0 - s*0.5)/r
  
  let theta = map (/factor) theta_effective

  (t, afs_dist) <- diploid_afs n_individuals n_loci s theta_effective

  observe afs_dist observed_alleles

  observe (binomial 221 p_f) 27

  return $ log_all [ s' %% "s~",
                     tau %% "tau",
                     p_f %% "p_f",
                     sigma %% "sigma",
                     s %% "s*",
                     theta_effective %% "theta*",
                     theta %% "theta",
                     h %% "H",
                     r %% "R" ]

gyno_model _ = do

  s' <- sample $ uniform 0.0 1.0

  tau <- sample $ beta 2.0 8.0

  p_f <- sample $ uniform 0.0 1.0

  let sigma = 1.0

  return (s', tau, p_f, sigma)



