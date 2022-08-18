module HermID where

import           PopGen
import           PopGen.Selfing
import           PopGen.Selfing.PureHermaphrodites
import           Probability
import           System.Environment

-- This file is a template.  It using Haskell syntax to describe a model.
-- Lines beginning with -- are comments.
-- To use commented priors, remove the -- and add data on the correspond variable.
-- Alternatively, remove the prior and set the variable to a constant using 'let'.

herm_model = do

--  tau <- uniform 0 1

--  ss <- uniform 0 1

    return (tau, ss)


model observed_alleles = do

    let n_loci = length observed_alleles

        n_individuals = length (observed_alleles !! 0) `div` 2

    let alpha = 0.10

    theta_effective <- dp n_loci alpha (gamma 0.25 2)

    (tau, ss)       <- herm_model

    let s = herm_mating_system ss tau
        r = 1

    let factor = (1 - s/2) * r

    let theta  = map (/ factor) theta_effective

    f_other <- beta 0.25 1

    let f_selfing = s / (2 - s)
        f_total   = 1 - (1 - f_selfing) * (1 - f_other)

    (t, afs_dist) <- robust_diploid_afs n_individuals n_loci s f_other theta_effective

    observed_alleles ~> afs_dist

    return
        [ "t" %=% t
        , "s~" %=% ss
        , "tau" %=% tau
        , "s*" %=% s
        , "F[selfing]" %=% f_selfing
        , "F[other]" %=% f
        , "F[total]" %=% f_total
        , "theta*" %=% theta_effective
        , "theta" %=% theta
        , "R" %=% r
        ]

main = do
  [filename] <- getArgs

  observed_alleles <- read_phase_file filename

  mcmc $ model observed_alleles
