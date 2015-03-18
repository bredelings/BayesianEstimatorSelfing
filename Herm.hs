module Herm where
{
import PopGen;
import Distributions;
import System.Environment;

observed_alleles = read_phase_file (getArgs!!0);

n_loci = length observed_alleles;

n_individuals = length (observed_alleles!!0)/2;

main = Prefix "Selfing" $ do 
{
  let {alpha = 0.10};

  theta_effective <- dp n_loci alpha (gamma 0.25 2.0); 

  s <- uniform 0.0 1.0;

  let {c = 1.0};
  
  -- theta* = herm_factor * theta
  let {herm_factor = (1.0 - s*0.5)/c};

  let {theta = map (/herm_factor) theta_effective};

  afs_dist <- diploid_afs n_individuals n_loci s theta_effective;

  Observe observed_alleles afs_dist;

  Log "s*" s;
  Log "theta*" theta_effective;
  Log "theta" theta;
};
}
