module Generic where

import           PopGen
import           PopGen.Selfing
import           Probability
import           System.Environment

model observed_alleles = do

    let n_loci = length observed_alleles

        n_individuals = length (observed_alleles !! 0) `div` 2

    -- Prior on the concentration parameter alpha for the Dirichlet Process
    alpha           <- gamma 2 0.5

    -- The vector of mutation rates theta[l] for each locus l
    theta_effective <- dp n_loci alpha (gamma 0.25 2)

    -- The beta 0.25 1 priors here allow f and s to get close to 0.
    -- This is not quite as good as a spike at zero, but not too bad.

    -- Decrease in heterozygosity that is NOT from selfing.
    f_other         <- beta 0.25 1

    -- The selfing rate s
    s               <- beta 0.25 1

    let f_selfing = s / (2 - s)
        f_total   = 1 - (1 - f_selfing) * (1 - f_other)

    -- The vector of selfing times t, and the distribution afs_dist of observed data,
    -- given t, f and (unobserved) i.
    (t, afs_dist) <- robust_diploid_afs n_individuals n_loci s f_other theta_effective

    -- Observed the data: compute the likelihood of the data, given t, f and (unobserved) i.
    observed_alleles ~> afs_dist

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

main = do
  [filename] <- getArgs

  observed_alleles <- read_phase2_file filename

  mcmc $ model observed_alleles

