module HermID where

import           BAliPhy.Run
import           MCMC (runMCMC)
import           Options.Applicative
import           PopGen
import           PopGen.Selfing
import           PopGen.Selfing.PureHermaphrodites
import           Probability

inputs = strArgument (metavar "PHASE-FILE" <> help "PHASE genotype file")

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

    -- Because R = N*/N, theta* = theta * (1 - s*/2) * R.
    let factor = (1.0 - s * 0.5) * r

    let theta  = map (/ factor) theta_effective

    (t, afs_dist) <- diploid_afs n_individuals n_loci s theta_effective

    observe observed_alleles afs_dist

    return ["s~" %=% ss, "t" %=% t, "tau" %=% tau, "s*" %=% s, "theta*" %=% theta_effective, "theta" %=% theta, "R" %=% r]

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
