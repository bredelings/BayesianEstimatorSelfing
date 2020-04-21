module Andro where

import           PopGen
import           PopGen.Selfing
import           PopGen.Selfing.Androdioecy
import           Probability
import           System.Environment

-- This file is a template.  It using Haskell syntax to describe a model.
-- Lines beginning with -- are comments.
-- To use commented priors, remove the -- and add data on the correspond variable.
-- Alternatively, remove the prior and set the variable to a constant using 'let'.

observed_alleles = read_phase_file (getArgs !! 0)

n_loci = length observed_alleles

n_individuals = length (observed_alleles !! 0) `div` 2

main = do

    let alpha = 0.10

    theta_effective <- random $ dp n_loci alpha (gamma 0.25 2.0)

    (male_fraction, s)        <- andro_model ()

    let r      = andro_mating_system' s male_fraction

    let factor = (1.0 - s * 0.5) * r

    let theta  = map (/ factor) theta_effective

    f               <- random $ beta 0.25 1.0

    (t, afs_dist) <- random $ robust_diploid_afs n_individuals n_loci s f theta_effective

    observe afs_dist observed_alleles

  --  Insert specific numbers of males and total individuals in below:
  --  observe (binomial <total_individual> male_fraction) <male_individuals>

    return ["male_fraction" %=% male_fraction, "t" %=% t, "s*" %=% s, "theta*" %=% theta_effective, "R" %=% r]

andro_model _ = do

  s <- beta 0.25 1.0

  male_fraction <- beta 2.0 2.0

  return (male_fraction, s)
