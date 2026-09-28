module PopGen.Selfing.Herm where

import           BAliPhy.Run
import           MCMC (runMCMC)
import           Options.Applicative
import           PopGen
import           PopGen.Selfing
import           Probability

inputs = strArgument (metavar "PHASE-FILE" <> help "PHASE genotype file")

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

    -- Estimate additional loss of heterozygosity shared across individuals, beyond selfing.
    f_other <- sample $ beta 0.25 1.0

    let f_selfing = s / (2.0 - s)
        f_total   = 1.0 - (1.0 - f_selfing) * (1.0 - f_other)

    (t, afs_dist) <- robust_diploid_afs n_individuals n_loci s f_other theta_effective

    observe observed_alleles afs_dist

    return
        [ "t" %=% t
        , "s*" %=% s
        , "F[other]" %=% f_other
        , "F[selfing]" %=% f_selfing
        , "F[total]" %=% f_total
        , "theta*" %=% theta_effective
        , "theta" %=% theta
        , "R" %=% r
        ]

-- Parse the model inputs, construct its logged state, and either inspect it or run MCMC.
main = do
    (options, filename) <- execParser $
        withModelDescription "Estimate selfing in a hermaphroditic population" $
            modelRunParserWith "Herm" 200000 inputs

    runInfo <- initializeModelRun (runMode options)

    observed_alleles <- read_phase_file filename

    mcmcState <- makeLoggedMCMCState runInfo (logFormats options) $ model observed_alleles

    case runInfo of
        TestRun -> printInitialModel (logFormats options) mcmcState
        MCMCRun directory -> do
            reportModelRun (iterations options) (logFormats options) directory
            runMCMC (iterations options) mcmcState
