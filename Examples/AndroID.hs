module Andro where

import           PopGen
import           PopGen.Selfing
import           PopGen.Selfing.Androdioecy
import           Probability
import           System.Environment

observed_alleles = read_phase_file (getArgs !! 0)

n_loci = length observed_alleles

n_individuals = length (observed_alleles !! 0) `div` 2

main = do

    let alpha = 0.10

    theta_effective <- random $ dp n_loci alpha (gamma 0.25 2.0)

    (p_m, tau, s')  <- random $ andro_model ()

    let (s, r) = andro_mating_system s' tau p_m

    let factor = (1.0 - s * 0.5) / r

    let theta  = map (/ factor) theta_effective

    (t, afs_dist) <- random $ diploid_afs n_individuals n_loci s theta_effective

    observe afs_dist            observed_alleles

    observe (binomial 2000 p_m) 20

    return ["p_m" %=% p_m, "s~" %=% s', "tau" %=% tau, "s*" %=% s, "theta*" %=% theta_effective, "theta" %=% theta, "R" %=% r]

andro_model _ = do

    s'  <- uniform 0.0 1.0

    tau <- uniform 0.0 1.0

    p_m <- uniform 0.0 1.0

    return (p_m, tau, s')

