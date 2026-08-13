module Gyno where

import           BAliPhy.Run
import           MCMC (runMCMC)
import           Options.Applicative
import           PopGen
import           PopGen.Selfing
import           PopGen.Selfing.Gynodioecy
import           Probability
import           System.Exit
import           System.IO

-- Parse the genotype file and field-count observation before constructing the probabilistic model.
inputs = (,,) <$> strArgument (metavar "PHASE-FILE" <> help "PHASE genotype file")
              <*> option auto (long "females" <> metavar "F" <> help "Number of females observed")
              <*> option auto (long "total" <> metavar "N" <> help "Total number of individuals observed")

-- Reject impossible field counts with a controlled command-line failure before MCMC starts.
validate_field_counts females total =
    if 0 <= females && females <= total
    then return ()
    else do
        hPutStrLn stderr $ "Invalid field counts: expected 0 <= females <= total, but females = "
                         ++ show females ++ " and total = " ++ show total
        exitFailure

model females total observed_alleles = do

    let n_loci = length observed_alleles
        n_individuals = length (observed_alleles !! 0) `div` 2

    let alpha = 0.10

    theta_effective       <- dirichletProcess n_loci alpha (gamma 0.5 0.5)

    (s', tau, p_f, sigma) <- gyno_model

    let (s, h, r) = gyno_mating_system tau s' p_f sigma

    -- Because R = N*/N, theta* = theta * (1 - s*/2) * R.
    let factor    = (1.0 - s * 0.5) * r

    let theta     = map (/ factor) theta_effective

    (t, afs_dist) <- diploid_afs n_individuals n_loci s theta_effective

    observe observed_alleles afs_dist

    -- Treat the observed number of females among all surveyed individuals as
    -- binomial field data on the population female fraction.
    observe females $ binomial total $ toProb p_f

    return
        [ "s~" %=% s'
        , "tau" %=% tau
        , "p_f" %=% p_f
        , "sigma" %=% sigma
        , "s*" %=% s
        , "theta*" %=% theta_effective
        , "theta" %=% theta
        , "H" %=% h
        , "R" %=% r
        ]

gyno_model = do

    s'  <- sample $ uniform 0.0 1.0

    tau <- sample $ beta 2.0 8.0

    p_f <- sample $ uniform 0.0 1.0

    let sigma = 1.0

    return (s', tau, p_f, sigma)

-- Parse the model inputs, construct its logged state, and either inspect it or run MCMC.
main = do
    (options, (filename, females, total)) <- execParser $
        withModelDescription "Estimate selfing in a gynodioecious population" $
            modelRunParserWith "Gyno" 200000 inputs

    validate_field_counts females total

    runInfo <- initializeModelRun (testMode options) (outputName options)

    observed_alleles <- read_phase_file filename

    mcmcState <- makeLoggedMCMCState runInfo (logFormats options) $ model females total observed_alleles

    case runInfo of
        TestRun -> printInitialModel (logFormats options) mcmcState
        MCMCRun directory -> do
            reportModelRun (iterations options) (logFormats options) directory
            runMCMC (iterations options) mcmcState
