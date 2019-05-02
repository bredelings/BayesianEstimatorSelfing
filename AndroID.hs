module AndroID where

import PopGen
import PopGen.Selfing
import PopGen.Selfing.Androdioecy
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

  theta_effective <- dp n_loci alpha (gamma 0.25 2.0) 

  (p_m, tau, s') <- andro_model ()

  let (s,r) = andro_mating_system s' tau p_m

  let factor = (1.0 - s*0.5)*r

  let theta = map (/factor) theta_effective

  (t, afs_dist) <- diploid_afs n_individuals n_loci s theta_effective

  observe observed_alleles afs_dist

--  Insert specific numbers of males and total individuals in below:
--  Observe <males> $ binomial <total> p_m

  return $ log_all [ p_m %% "p_m",
                     t   %% "t",
                     s'  %% "s~",
                     tau %% "tau",
                     s   %% "s*",
                     theta_effective %% "theta*",
                     theta %% "theta",
                     r %% "R" ]

andro_model _ = do

--  s' <- sample $ uniform 0.0 1.0

--  tau <- sample $ uniform 0.0 1.0
       
--  p_m <- sample $ uniform 0.0 1.0
  
  return (p_m, tau, s')



