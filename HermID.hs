module HermID where

import           BAliPhy.Run
import           MCMC (runMCMC)
import           Options.Applicative
import           PopGen
import           PopGen.Selfing
import           PopGen.Selfing.PureHermaphrodites
import           Probability

inputs = strArgument (metavar "PHASE-FILE" <> help "PHASE genotype file")

-- This template requires parameter definitions before it can run.
-- Uncomment and choose the priors below, or define parameters with 'let'.
-- Supply observations or other identifying information appropriate for your data.

herm_model = do

--  tau <- sample $ uniform 0.0 1.0

--  ss <- sample $ uniform 0.0 1.0

    return (tau, ss)


model observed_alleles = do

    let n_loci = length observed_alleles
        n_individuals = length (observed_alleles !! 0) `div` 2

    let alpha = 0.10

    theta_effective <- dirichletProcess n_loci alpha (gamma 0.25 2.0)

    (tau, ss)       <- herm_model

    let s = herm_mating_system ss tau
        r = 1.0

    let factor = (1.0 - s * 0.5) * r

    let theta  = map (/ factor) theta_effective

    f_other <- sample $ beta 0.25 1.0

    let f_selfing = s / (2.0 - s)
        f_total   = 1.0 - (1.0 - f_selfing) * (1.0 - f_other)

    (t, afs_dist) <- robust_diploid_afs n_individuals n_loci s f_other theta_effective

    observe observed_alleles afs_dist

    return
        [ "t" %=% t
        , "s~" %=% ss
        , "tau" %=% tau
        , "s*" %=% s
        , "F[selfing]" %=% f_selfing
        , "F[other]" %=% f_other
        , "F[total]" %=% f_total
        , "theta*" %=% theta_effective
        , "theta" %=% theta
        , "R" %=% r
        ]

-- Parse the model inputs, construct its logged state, and either inspect it or run MCMC.
main = do
    (options, filename) <- execParser $
        withModelDescription "Estimate selfing in a hermaphroditic population" $
            modelRunParserWith "HermID" 200000 inputs

    runInfo <- initializeModelRun (runMode options)

    observed_alleles <- read_phase_file filename

    mcmcState <- makeLoggedMCMCState runInfo (logFormats options) $ model observed_alleles

    case runInfo of
        TestRun -> printInitialModel (logFormats options) mcmcState
        MCMCRun directory -> do
            reportModelRun (iterations options) (logFormats options) directory
            runMCMC (iterations options) mcmcState
