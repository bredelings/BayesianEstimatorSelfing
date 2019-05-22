module Gyno where

import PopGen
import PopGen.Selfing
import PopGen.Selfing.Gynodioecy
import Probability
import System.Environment

-- This file is a template.  It using Haskell syntax to describe a model.
-- Lines beginning with -- are comments.
-- To use commented priors, remove the -- and add data on the correspond variable.
-- Alternatively, remove the prior and set the variable to a constant using 'let'.

observed_alleles = read_phase_file (getArgs!!0)

n_loci = length observed_alleles

n_individuals = length (observed_alleles!!0) `div` 2

main = do

  let alpha = 0.10

  theta_effective <- random $ dp n_loci alpha (gamma 0.5 0.5)

  (a, tau, p_f, sigma) <- random $ gyno_model

  let (s, h, r) = gyno_mating_system tau a p_f sigma

  let factor = (1.0 - s*0.5)*r
  
  let theta = map (/factor) theta_effective

  (t, afs_dist) <- random $ diploid_afs n_individuals n_loci s theta_effective

  observe observed_alleles afs_dist

--  Insert specific numbers of females and total individuals in below:
--  observe (binomial <total> p_f) <females>

  return $ log_all [ t   %% "t",
                     a   %% "a",
                     tau %% "tau",
                     p_f %% "p_f",
                     sigma %% "sigma",
                     s   %% "s*",
                     theta_effective %% "theta*",
                     theta %% "theta",
                     h %% "H",
                     r %% "R"]

gyno_model = do

--  a <- uniform 0.0 1.0

--  tau <- beta 2.0 8.0

--  p_f <- uniform 0.0 1.0

--  let sigma = 1.0

  return (a, tau, p_f, sigma)



