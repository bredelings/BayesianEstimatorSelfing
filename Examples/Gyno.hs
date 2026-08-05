module Gyno where

import           PopGen
import           PopGen.Selfing
import           PopGen.Selfing.Gynodioecy
import           Probability
import           System.Environment

model observed_alleles = do

    let n_loci = length observed_alleles
        n_individuals = length (observed_alleles !! 0) `div` 2

    let alpha = 0.10

    theta_effective       <- dirichletProcess n_loci alpha (gamma 0.5 0.5)

    (s', tau, p_f, sigma) <- gyno_model

    let (s, h, r) = gyno_mating_system tau s' p_f sigma

    -- Because R = N*/N, theta* = theta * (1 - s*/2) * R.
    let factor    = (1.0 - s * 0.5) * r

    let theta     = map (/ factor) theta_effective

    (t, afs_dist) <- diploid_afs n_individuals n_loci s theta_effective

    observe observed_alleles afs_dist

    observe 27 $ binomial 221 $ toProb p_f

    return
        [ "s~" %=% s'
        , "tau" %=% tau
        , "p_f" %=% p_f
        , "sigma" %=% sigma
        , "s*" %=% s
        , "theta*" %=% theta_effective
        , "theta" %=% theta
        , "H" %=% h
        , "R" %=% r
        ]

gyno_model = do

    s'  <- sample $ uniform 0.0 1.0

    tau <- sample $ beta 2.0 8.0

    p_f <- sample $ uniform 0.0 1.0

    let sigma = 1.0

    return (s', tau, p_f, sigma)

main _ = do
    [filename] <- getArgs
    observed_alleles <- read_phase_file filename
    return $ model observed_alleles
