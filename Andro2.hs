module Andro2 where
{
import PopGen;
import PopGen.Selfing;
import PopGen.Selfing.Androdioecy;
import Distributions;
import System.Environment;

-- This file is a template.  It using Haskell syntax to describe a model.
-- Lines beginning with -- are comments.
-- To use commented priors, remove the -- and add data on the correspond variable.
-- Alternatively, remove the prior and set the variable to a constant using 'let'.

observed_alleles = read_phase_file (getArgs!!0);

n_loci = length observed_alleles;

n_individuals = length (observed_alleles!!0)/2;

main = Prefix "Selfing" $ do 
{
  let {alpha = 0.10};

  theta_effective <- dp n_loci alpha (gamma 0.25 2.0); 

  (p_m, s, sigma) <- andro2_model ();

  let {r = andro_mating_system2' s p_m sigma};

  let {factor = (1.0 - s*0.5)*r};

  let {theta = map (/factor) theta_effective};

  afs_dist <- diploid_afs n_individuals n_loci s theta_effective;

  Observe observed_alleles afs_dist;

--  Insert specific numbers of males and total individuals in below:
--  Observe <males> $ binomial <total> p_m;

  Log "p_m" p_m;
  Log "s*" s;

  Log "theta*" theta_effective;
  Log "theta" theta;
  Log "R" r;
};

andro2_model _ = Prefix "Andro" $ do
{
--  s <- uniform 0.0 1.0;

--  p_m <- uniform 0.0 1.0;

--  sigma_inverse <- uniform 0.0 1.0;
--  let {sigma = 1.0/sigma_inverse};

  return (p_m, s, sigma);
};

}
