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

-- This file is a template.  It using Haskell syntax to describe a model.
-- Lines beginning with -- are comments.
-- To use commented priors, remove the -- and add data on the correspond variable.
-- Alternatively, remove the prior and set the variable to a constant using 'let'.

model males total observed_alleles = do

    let n_loci = length observed_alleles
        n_individuals = length (observed_alleles !! 0) `div` 2

    let alpha = 0.10

    theta_effective    <- dirichletProcess n_loci alpha (gamma 0.25 2.0)

    (male_fraction, s) <- andro_model

    let r      = andro_mating_system' s male_fraction

    let factor = (1.0 - s * 0.5) * r

    let theta  = map (/ factor) theta_effective

    f_other <- sample $ beta 0.25 1.0

    let f_selfing = s / (2.0 - s)
        f_total   = 1.0 - (1.0 - f_selfing) * (1.0 - f_other)

    (t, afs_dist) <- robust_diploid_afs n_individuals n_loci s f_other theta_effective

    observe observed_alleles afs_dist

    -- Treat the observed number of males among all surveyed individuals as
    -- binomial field data on the population male fraction.
    observe males $ binomial total $ toProb male_fraction

    return
        [ "male_fraction" %=% male_fraction
        , "t" %=% t
        , "s*" %=% s
        , "F[selfing]" %=% f_selfing
        , "F[other]" %=% f_other
        , "F[total]" %=% f_total
        , "theta*" %=% theta_effective
        , "R" %=% r
        ]

andro_model = do

    s             <- sample $ beta 0.25 1.0

    male_fraction <- sample $ beta 2.0 2.0

    return (male_fraction, s)

-- Parse the model inputs, construct its logged state, and either inspect it or run MCMC.
main = do
    (options, (filename, males, total)) <- execParser $
        withModelDescription "Estimate selfing in an androdioecious population" $
            modelRunParserWith "Andro" 200000 inputs

    validate_field_counts males total

    runInfo <- initializeModelRun (testMode options) (outputName options)

    observed_alleles <- read_phase_file filename

    mcmcState <- makeLoggedMCMCState runInfo (logFormats options) $ model males total observed_alleles

    case runInfo of
        TestRun -> printInitialModel (logFormats options) mcmcState
        MCMCRun directory -> do
            reportModelRun (iterations options) (logFormats options) directory
            runMCMC (iterations options) mcmcState
