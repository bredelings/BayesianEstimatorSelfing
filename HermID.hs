module HermID where
{
import PopGen;
import PopGen.Selfing;
import Distributions;
import System.Environment;

observed_alleles = read_phase_file (getArgs!!0);

n_loci = length observed_alleles;

n_individuals = length (observed_alleles!!0)/2;

herm_model _ = Prefix "Herm" $ do
{
-- You must define tau here somehow in order to use this model.
--  tau <- uniform 0.0 1.0;
--  Observe tau ???          -- (some kind of observation?)
--  Log "tau" tau;

  ss <- uniform 0.0 1.0;
  Log "s~" ss;

  let {s = (tau * ss)/(tau*ss + 1.0 - ss)};

  let {c = 1.0};
  
  return (tau, ss, s, c);
};

main = Prefix "Selfing" $ do 
{
  let {alpha = 0.10};

  theta_effective <- dp n_loci alpha (gamma 0.25 2.0); 

  (tau, ss, s, c) <- herm_model ();

  let {herm_factor = (1.0 - s*0.5)/c};

  let {theta = map (/herm_factor) theta_effective};

  afs_dist <- diploid_afs n_individuals n_loci s theta_effective;

  Observe observed_alleles afs_dist;

  Log "s*" s;
  Log "theta*" theta_effective;
  Log "theta" theta;
};
}
