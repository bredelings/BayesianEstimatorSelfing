module AndroID where

import           PopGen
import           PopGen.Selfing
import           PopGen.Selfing.Androdioecy
import           Probability
import           System.Environment

model observed_alleles = do

    let n_loci = length observed_alleles
        n_individuals = length (observed_alleles !! 0) `div` 2

    let alpha = 0.10

    theta_effective <- dirichletProcess n_loci alpha (gamma 0.25 2.0)

    (p_m, tau, s')  <- andro_model

    let (s, r) = andro_mating_system s' tau p_m

    -- Because R = N*/N, theta* = theta * (1 - s*/2) * R.
    let factor = (1.0 - s * 0.5) * r

    let theta  = map (/ factor) theta_effective

    (t, afs_dist) <- diploid_afs n_individuals n_loci s theta_effective

    observe observed_alleles afs_dist

    observe 20 $ binomial 2000 p_m

    return ["p_m" %=% p_m, "s~" %=% s', "tau" %=% tau, "s*" %=% s, "theta*" %=% theta_effective, "theta" %=% theta, "R" %=% r]

andro_model = do

    s'  <- sample $ uniform 0.0 1.0

    tau <- sample $ uniform 0.0 1.0

    p_m <- sample $ uniform 0.0 1.0

    return (p_m, tau, s')

main _ = do
    [filename] <- getArgs
    observed_alleles <- read_phase_file filename
    return $ model observed_alleles
