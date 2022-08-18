module AndroID where

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

    theta_effective <- dp n_loci alpha (gamma 0.25 2)

    (p_m, tau, s')  <- andro_model ()

    let (s, r) = andro_mating_system s' tau p_m

    let factor = (1 - s/2) * r

    let theta  = map (/ factor) theta_effective

    f_other <- beta 0.25 1

    let f_selfing = s / (2 - s)
        f_total   = 1 - (1 - f_selfing) * (1 - f_other)

    (t, afs_dist) <- robust_diploid_afs n_individuals n_loci s f_other theta_effective

    -- Observed the data: compute the likelihood of the data, given t, f and (unobserved) i.
    observed_alleles ~> afs_dist

  --  Insert specific numbers of males and total individuals in below:
  --  <males> ~> binomial <total> p_m

    return
        [ "p_m" %=% p_m
        , "t" %=% t
        , "s~" %=% s'
        , "tau" %=% tau
        , "s*" %=% s
        , "F[selfing]" %=% f_selfing
        , "F[other]" %=% f_other
        , "F[total]" %=% f_total
        , "theta*" %=% theta_effective
        , "theta" %=% theta
        , "R" %=% r
        ]

andro_model _ = do

--  s' <- uniform 0 1

--  tau <- uniform 0 1

--  p_m <- uniform 0 1

    return (p_m, tau, s')

main = do
  [filename] <- getArgs

  observed_alleles <- read_phase_file filename

  mcmc $ model observed_alleles
