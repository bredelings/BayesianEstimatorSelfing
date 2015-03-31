module Andro where
{
import PopGen;
import PopGen.Selfing;
import Distributions;
import System.Environment;

observed_alleles = read_phase_file (getArgs!!0);

n_loci = length observed_alleles;

n_individuals = length (observed_alleles!!0)/2;

main = Prefix "Selfing" $ do 
{
  let {alpha = 0.10};

  --  theta_effective <- dpm n_loci (gamma 0.5 1.0) (gamma 1.05 0.1); 
  theta_effective <- dp n_loci alpha (gamma 0.25 2.0); 

  (p_m, s, r) <- andro_model ();

  let {factor = (1.0 - s*0.5)/r};

  let {theta = map (/factor) theta_effective};

  afs_dist <- diploid_afs n_individuals n_loci s theta_effective;

  Observe 20 $ binomial 2000 p_m;

  Observe observed_alleles afs_dist;

  Log "s*" s;
  Log "theta*" theta_effective;
  Log "theta" theta;
  Log "R" r;
};

andro_mating_system1 s p_m = (1.0+s)^2 /(4.0*p_h) + (1.0-s)^2/(4.0*p_m) where {p_h = 1.0-p_m};

andro_mating_system2 s' tau p_m = (s,r) where {s = (tau*s')/(tau*s'+1.0-s');
                                               r = andro_mating_system1 s p_m};
andro_model _ = Prefix "Andro" $ do
{
  s <- uniform 0.0 1.0;
  Log "s" s;

  p_m <- uniform 0.0 1.0;
  Log "p_m" p_m;
  
  let {(a,r) = andro_mating_system2 s 1.0 p_m};

  return (p_m, s, r);
};

}
