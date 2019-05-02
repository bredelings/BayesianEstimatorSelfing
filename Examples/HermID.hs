module HermID where

import PopGen
import PopGen.Selfing
import PopGen.Selfing.PureHermaphrodites
import Probability
import System.Environment

observed_alleles = read_phase_file (getArgs!!0)

n_loci = length observed_alleles

n_individuals = length (observed_alleles!!0) `div` 2

herm_model = do

  tau <- sample $ uniform 0.0 1.0

  ss <- sample $ uniform 0.0 1.0

  return (tau, ss)


main = block $ do 

  let alpha = 0.10

  theta_effective <- random $ dp n_loci alpha (gamma 0.25 2.0)

  (tau, ss) <- random $ herm_model

  let s = herm_mating_system ss tau
      r = 1.0

  let factor = (1.0 - s*0.5)/r

  let theta = map (/factor) theta_effective

  (t, afs_dist) <- random $ diploid_afs n_individuals n_loci s theta_effective

  observe afs_dist observed_alleles

  return $ log_all [ss %% "s~",
                    t %% "t",
                    tau %% "tau",
                    s %% "s*",
                    theta_effective %% "theta*",
                    theta %% "theta",
                    r %% "R" ]
