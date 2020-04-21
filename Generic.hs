module Generic where

import           PopGen
import           PopGen.Selfing
import           Probability
import           System.Environment

observed_alleles = read_phase_file (getArgs !! 0)

n_loci = length observed_alleles

n_individuals = length (observed_alleles !! 0) `div` 2

main = do

    -- Prior on the concentration parameter alpha for the Dirichlet Process
    alpha           <- random $ gamma 2.0 0.5

    -- The vector of mutation rates theta[l] for each locus l
    theta_effective <- random $ dp n_loci alpha (gamma 0.25 2.0)

    -- The beta 0.25 1.0 priors here allow f and s to get close to 0.
    -- This is not quite as good as a spike at zero, but not too bad.

    -- Decrease in heterozygosity that is NOT from selfing.
    f               <- random $ beta 0.25 1.0

    -- The selfing rate s
    s               <- random $ beta 0.25 1.0

    -- The vector of selfing times t, and the distribution afs_dist of observed data,
    -- given t, f and (unobserved) i.
    (t, afs_dist)   <- random $ robust_diploid_afs n_individuals n_loci s f theta_effective

    -- Compute the likelihood of the observed data, given t, f and (unobserved) i.
    observe afs_dist observed_alleles

    -- Side-effect-free logging by constructing a JSON object that represents parameters.
    return ["alpha" %=% alpha, "t" %=% t, "s*" %=% s, "f" %=% f, "theta*" %=% theta_effective]

