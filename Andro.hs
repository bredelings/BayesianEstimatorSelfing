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

model observed_alleles = do

    let n_loci = length observed_alleles
        n_individuals = length (observed_alleles !! 0) `div` 2

    let alpha = 0.10

    theta_effective    <- dirichletProcess n_loci alpha (gamma 0.25 2.0)

    (male_fraction, s) <- andro_model

    let r      = andro_mating_system' s male_fraction

    let factor = (1.0 - s * 0.5) * r

    let theta  = map (/ factor) theta_effective

    f_other <- sample $ beta 0.25 1.0

    let f_selfing = s / (2.0 - s)
        f_total   = 1.0 - (1.0 - f_selfing) * (1.0 - f_other)

    (t, afs_dist) <- robust_diploid_afs n_individuals n_loci s f_other theta_effective

    observe observed_alleles afs_dist

  --  Insert specific numbers of males and total individuals in below:
  --  observe <male_individuals> $ binomial <total_individual> male_fraction

    return
        [ "male_fraction" %=% male_fraction
        , "t" %=% t
        , "s*" %=% s
        , "F[selfing]" %=% f_selfing
        , "F[other]" %=% f_other
        , "F[total]" %=% f_total
        , "theta*" %=% theta_effective
        , "R" %=% r
        ]

andro_model = do

    s             <- sample $ beta 0.25 1.0

    male_fraction <- sample $ beta 2.0 2.0

    return (male_fraction, s)

main _ = do
    [filename] <- getArgs
    observed_alleles <- read_phase_file filename
    return $ model observed_alleles
