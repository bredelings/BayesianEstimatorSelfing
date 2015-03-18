module Gyno where
{
import PopGen;
import Distributions;
import System.Environment;

observed_alleles = read_phase_file (getArgs!!0);

n_loci = length observed_alleles;

n_individuals = length (observed_alleles!!0)/2;

gyno_model _ = Prefix "Gyno" $ do
{
-- tau ~ beta( 16.0, 64.0 ); tau = 0.205;
  tau <- beta 2.0 8.0;
  Log "tau" tau;

-- a = 1.0; a = 0.99; a = 0.95; a = 0.9; a = 0.8; a = 0.6; a = 0.5; a = 0.4;
  a <- uniform 0.0 1.0;
  Log "a" a;

  p_f <- uniform 0.0 1.0;
  Log "p_f" p_f;

  let {sigma = 1.0};

  let {p_h = 1.0 - p_f};
  
  let {s = let {x1=tau*p_h*a; x2=p_h*(1.0-a); x3=p_f*sigma} in x1/(x1+x2+x3)};

  let {h = let {n2 = p_h * (1.0-a);n3 = p_f * sigma} in n2/(n2 + n3)};
  Log "h" h;

  let {hh = (1.0+h)/2.0;
       c1 = (s^2 + 2.0*s*(1.0-s)*hh + (1.0-s)^2*hh^2) /p_h + ((1.0-s)*(1.0-h))^2/(4.0*p_f);
       c2 = (2.0 - (1.0-s)*(1.0+h))^2 /(4.0*p_h) + ((1.0-s)*(1.0-h))^2/(4.0*p_f);
       c3 = (2.0 - (1.0-s)*(1.0-h))^2 /(4.0*p_h) + ((1.0-s)*(1.0-h))^2/(4.0*p_f);
        c = (2.0*s + (1.0-s)*(1.0+h))^2 /(4.0*p_h) + ((1.0-s)*(1.0-h))^2/(4.0*p_f);
           gyno_factor = (1.0 - s*0.5)/c};
  Log "C1" c1;
  Log "C2" c2;
  Log "C3" c3;
  Log "C" c;
  Log "gyno_factor" gyno_factor;

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
