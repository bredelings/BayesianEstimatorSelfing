module Andro where

import           BAliPhy.Run
import           MCMC (runMCMC)
import           Options.Applicative
import           PopGen
import           PopGen.Selfing
import           PopGen.Selfing.Androdioecy
import           Probability
import           System.Exit
import           System.IO

-- Parse the genotype file and field-count observation before constructing the probabilistic model.
inputs = (,,) <$> strArgument (metavar "PHASE-FILE" <> help "PHASE genotype file")
              <*> option auto (long "males" <> metavar "M" <> help "Number of males observed")
              <*> option auto (long "total" <> metavar "N" <> help "Total number of individuals observed")

-- Reject impossible field counts with a controlled command-line failure before MCMC starts.
validate_field_counts males total =
    if 0 <= males && males <= total
    then return ()
    else do
        hPutStrLn stderr $ "Invalid field counts: expected 0 <= males <= total, but males = "
                         ++ show males ++ " and total = " ++ show total
        exitFailure

model males total observed_alleles = do

    let n_loci = length observed_alleles
        n_individuals = length (observed_alleles !! 0) `div` 2

    let alpha = 0.10

    theta_effective <- dirichletProcess n_loci alpha (gamma 0.25 2.0)

    (p_m, s)        <- andro_model

    let r      = andro_mating_system' s p_m

    -- Because R = N*/N, theta* = theta * (1 - s*/2) * R.
    let factor = (1.0 - s * 0.5) * r

    let theta  = map (/ factor) theta_effective

    (t, afs_dist) <- diploid_afs n_individuals n_loci s theta_effective

    observe observed_alleles afs_dist

    -- Treat the observed number of males among all surveyed individuals as
    -- binomial field data on the population male fraction.
    observe males $ binomial total $ toProb p_m

    return ["p_m" %=% p_m, "s*" %=% s, "theta*" %=% theta_effective, "theta" %=% theta, "R" %=% r]

andro_model = do

    s   <- sample $ uniform 0.0 1.0

    p_m <- sample $ uniform 0.0 1.0

    return (p_m, s)

-- Parse the model inputs, construct its logged state, and either inspect it or run MCMC.
main = do
    (options, (filename, males, total)) <- execParser $
        withModelDescription "Estimate selfing in an androdioecious population" $
            modelRunParserWith "Andro" 200000 inputs

    validate_field_counts males total

    runInfo <- initializeModelRun (runMode options)

    observed_alleles <- read_phase_file filename

    mcmcState <- makeLoggedMCMCState runInfo (logFormats options) $ model males total observed_alleles

    case runInfo of
        TestRun -> printInitialModel (logFormats options) mcmcState
        MCMCRun directory -> do
            reportModelRun (iterations options) (logFormats options) directory
            runMCMC (iterations options) mcmcState
