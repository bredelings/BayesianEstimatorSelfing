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
-- Uncomment to estimate alpha:
--  alpha <- gamma 0.5 0.05;
--  Log "alpha" alpha;
  let {alpha = 0.10};

  theta_effective <- dp n_loci alpha (gamma 0.25 2.0); 
  -- Alternatively, one can use a dirichlet process mixture:
  --  theta_effective <- dpm n_loci (gamma 0.5 1.0) (gamma 1.05 0.1); 

  s <- uniform 0.0 1.0;

  afs_dist <- diploid_afs n_individuals n_loci s theta_effective;

  Observe observed_alleles afs_dist;

  Log "s" s;
  Log "theta*" theta_effective;
};
}
