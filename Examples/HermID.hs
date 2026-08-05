module HermID where

import           PopGen
import           PopGen.Selfing
import           PopGen.Selfing.PureHermaphrodites
import           Probability
import           System.Environment

herm_model = do

    tau <- sample $ uniform 0.0 1.0

    ss  <- sample $ uniform 0.0 1.0

    return (tau, ss)


model observed_alleles = do

    let n_loci = length observed_alleles
        n_individuals = length (observed_alleles !! 0) `div` 2

    let alpha = 0.10

    theta_effective <- dirichletProcess n_loci alpha (gamma 0.25 2.0)

    (tau, ss)       <- herm_model

    let s = herm_mating_system ss tau
        r = 1.0

    let factor = (1.0 - s * 0.5) / r

    let theta  = map (/ factor) theta_effective

    (t, afs_dist) <- diploid_afs n_individuals n_loci s theta_effective

    observe observed_alleles afs_dist

    return ["s~" %=% ss, "t" %=% t, "tau" %=% tau, "s*" %=% s, "theta*" %=% theta_effective, "theta" %=% theta, "R" %=% r]

main _ = do
    [filename] <- getArgs
    observed_alleles <- read_phase_file filename
    return $ model observed_alleles
