module PopGen.Selfing.Herm where

import           PopGen
import           PopGen.Selfing
import           Options.Applicative
import           Probability

options = info
    (strArgument (metavar "PHASE-FILE" <> help "PHASE genotype file") <**> helper)
    (fullDesc <> progDesc "Estimate selfing in a hermaphroditic population")

model observed_alleles = do

    let n_loci = length observed_alleles
        n_individuals = length (observed_alleles !! 0) `div` 2

    let alpha = 0.10

    theta_effective <- dirichletProcess n_loci alpha (gamma 0.25 2.0)

    s               <- sample $ uniform 0.0 1.0

    let r      = 1.0

    -- Because R = N*/N, theta* = theta * (1 - s*/2) * R.
    let factor = (1.0 - s * 0.5) * r

    let theta  = map (/ factor) theta_effective

    (t, afs_dist) <- diploid_afs n_individuals n_loci s theta_effective

    observe observed_alleles afs_dist

    return ["t" %=% t, "s*" %=% s, "theta*" %=% theta_effective, "theta" %=% theta, "R" %=% r]

main _ = do
    filename <- execParser options
    observed_alleles <- read_phase_file filename
    return $ model observed_alleles
