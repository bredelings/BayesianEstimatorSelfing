module Generic where

import           PopGen
import           PopGen.Selfing
import           Probability
import           System.Environment

observed_alleles = read_phase2_file (getArgs !! 0)

n_loci = length observed_alleles

n_individuals = length (observed_alleles !! 0) `div` 2

main = do

    -- Prior on the concentration parameter alpha for the Dirichlet Process
    alpha           <- gamma 2.0 0.5

    -- The vector of mutation rates theta[l] for each locus l
    theta_effective <- dp n_loci alpha (gamma 0.25 2.0)

    -- The beta 0.25 1.0 priors here allow f and s to get close to 0.
    -- This is not quite as good as a spike at zero, but not too bad.

    -- Decrease in heterozygosity that is NOT from selfing.
    f_other         <- beta 0.25 1.0

    -- The selfing rate s
    s               <- beta 0.25 1.0

    let f_selfing = s / (2.0 - s)
        f_total   = 1.0 - (1.0 - f_selfing) * (1.0 - f_other)

    -- The vector of selfing times t, and the distribution afs_dist of observed data,
    -- given t, f and (unobserved) i.
    (t, afs_dist) <- robust_diploid_afs n_individuals n_loci s f_other theta_effective

    -- Compute the likelihood of the observed data, given t, f and (unobserved) i.
    observe afs_dist observed_alleles

    -- Side-effect-free logging by constructing a JSON object that represents parameters.
    return
        [ "alpha" %=% alpha
        , "t" %=% t
        , "s*" %=% s
        , "F[selfing]" %=% f_selfing
        , "F[other]" %=% f_other
        , "F[total]" %=% f_total
        , "theta*" %=% theta_effective
        ]

