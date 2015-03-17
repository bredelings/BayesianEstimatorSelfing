module Andro where
{
import PopGen;
import Distributions;
import System.Environment;

observed_alleles = read_phase_file (getArgs!!0);

n_loci = length observed_alleles;

n_individuals = length (observed_alleles!!0)/2;

andro_model _ = Prefix "Andro" $ do
{
  s <- uniform 0.0 1.0;
  Log "s" s;

  p_m <- uniform 0.0 1.0;
  Log "p_m" p_m;
  
  let {p_h = 1.0 - p_m};

  let {andro_factor = (1.0 - s*0.5)/( (1.0+s)^2 /(4.0*p_h) + (1.0-s)^2/(4.0*p_m))};
  Log "andro_factor" andro_factor;

  return (p_m, s, andro_factor);
};

main = Prefix "Selfing" $ do 
{
--  alpha <- gamma 0.5 0.05;
--  Log "alpha" alpha;
  let {alpha = 0.10};

  --  theta_effective <- dpm n_loci (gamma 0.5 1.0) (gamma 1.05 0.1); 
  theta_effective <- dp n_loci alpha (gamma 0.25 2.0); 

  (p_m, s, andro_factor) <- andro_model ();

  let {herm_factor = (1.0 - s*0.5)};
  
  let {theta_herm = map (/herm_factor) theta_effective};
  let {theta_andro = map (/andro_factor) theta_effective};

--  Observe <how many males?> $ binomial <how many individuals sexed?> p_m;

  afs_dist <- diploid_afs n_individuals n_loci s theta_effective;

  Observe observed_alleles afs_dist;

  Log "s" s;
  Log "theta_herm" theta_herm;
  Log "theta_andro" theta_andro;
  Log "herm_factor" herm_factor;
  Log "herm_factor_div_andro_factor" (herm_factor/andro_factor);
};
}
