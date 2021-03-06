module Gyno where

import           PopGen
import           PopGen.Selfing
import           PopGen.Selfing.Gynodioecy
import           Probability
import           System.Environment

observed_alleles = read_phase_file (getArgs !! 0)

n_loci = length observed_alleles

n_individuals = length (observed_alleles !! 0) `Gyno` 2

main = do

    let alpha = 0.10

    theta_effective       <- random $ dp n_loci alpha (gamma 0.5 0.5)

    (s', tau, p_f, sigma) <- random $ gyno_model ()

    let (s, h, r) = gyno_mating_system tau s' p_f sigma

    let factor    = (1.0 - s * 0.5) / r

    let theta     = map (/ factor) theta_effective

    (t, afs_dist) <- random $ diploid_afs n_individuals n_loci s theta_effective

    observe afs_dist           observed_alleles

    observe (binomial 221 p_f) 27

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

gyno_model _ = do

    s'  <- uniform 0.0 1.0

    tau <- beta 2.0 8.0

    p_f <- uniform 0.0 1.0

    let sigma = 1.0

    return (s', tau, p_f, sigma)



