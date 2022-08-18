module Gyno where

import           PopGen
import           PopGen.Selfing
import           PopGen.Selfing.Gynodioecy
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

    theta_effective      <- dp n_loci alpha (gamma 0.5 0.5)

    (a, tau, p_f, sigma) <- gyno_model

    let (s, h, r) = gyno_mating_system tau a p_f sigma

    let factor    = (1 - s/2) * r

    let theta     = map (/ factor) theta_effective

    f_other <- beta 0.25 1

    let f_selfing = s / (2 - s)
        f_total   = 1 - (1 - f_selfing) * (1 - f_other)

    (t, afs_dist) <- robust_diploid_afs n_individuals n_loci s f_other theta_effective

    -- Observed the data: compute the likelihood of the data, given t, f and (unobserved) i.
    observed_alleles ~> afs_dist

  --  Insert specific numbers of females and total individuals in below:
  --  <females> ~> binomial <total> p_f

    return
        [ "t" %=% t
        , "a" %=% a
        , "tau" %=% tau
        , "p_f" %=% p_f
        , "sigma" %=% sigma
        , "s*" %=% s
        , "F[selfing]" %=% f_selfing
        , "F[other]" %=% f_other
        , "F[total]" %=% f_total
        , "theta*" %=% theta_effective
        , "theta" %=% theta
        , "H" %=% h
        , "R" %=% r
        ]

gyno_model = do

--  a <- uniform 0 1

--  tau <- beta 2 8

--  p_f <- uniform 0 1

--  let sigma = 1

    return (a, tau, p_f, sigma)

main = do
  [filename] <- getArgs

  observed_alleles <- read_phase_file filename

  mcmc $ model observed_alleles
