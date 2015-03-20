module Gyno where
{
import PopGen;
import Distributions;
import System.Environment;

observed_alleles = read_phase_file (getArgs!!0);

n_loci = length observed_alleles;

n_individuals = length (observed_alleles!!0)/2;

gyno tau a p_f sigma = (s, c, h) where {
                                   p_h = 1.0 - p_f;
                                   x1 = tau * p_h * a;
                                   x2 = p_h * (1.0-a);
                                   x3 = p_f * sigma;
                                   s  =  x1/(x1+x2+x3);
                                   h = x2/(x2+x3);
                                   c = (2.0 - (1.0-s)*(1.0-h))^2 /(4.0*p_h) + ((1.0-s)*(1.0-h))^2/(4.0*p_f)
                                  };
                                                                                        
gyno_model _ = Prefix "Gyno" $ do
{
-- tau ~ beta( 16.0, 64.0 ); tau = 0.205;
  tau <- beta 2.0 8.0;
  Log "tau" tau;

  a <- uniform 0.0 1.0; 
  Log "a" a;

  p_f <- uniform 0.0 1.0;
  Log "p_f" p_f;

  let {sigma = 1.0};

  Log "h" h;

  let (s, c, h) = gyno tau a p_f sigma;

  Log "C" c;

  Log "a_times_tau" (a*tau);

  return (tau, a, p_f, s, c, gyno_factor);
};

main = Prefix "Selfing" $ do 
{
          let {alpha = 0.10};

          theta_effective <- dp n_loci alpha (gamma 0.5 0.5); 

          (tau, a, p_f, s, c, gyno_factor) <- gyno_model ();

          let {herm_factor = (1.0 - s*0.5)};
  
          let {theta_herm = map (/herm_factor) theta_effective};
          let {theta_gyno = map (/gyno_factor) theta_effective};

          Observe 27 $ binomial 221 p_f;

          afs_dist <- diploid_afs n_individuals n_loci s theta_effective;

          Observe observed_alleles afs_dist;

	  Log "s" s;
	  Log "theta_herm" theta_herm;
	  Log "theta_gyno" theta_gyno;
	  Log "herm_factor" herm_factor;
	  Log "herm_factor_div_gyno_factor" (herm_factor/gyno_factor);
};


}
