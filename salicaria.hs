module Test where
{
import PopGen;
import PopGen.Selfing;
import Distributions;
import System.Environment;

observed_alleles = read_phase_file (getArgs!!0);

n_loci = length observed_alleles;

n_individuals = length (observed_alleles!!0)/2;

gyno_mating_system tau a p_f sigma = (s, h, r) where
    {p_h = 1.0 - p_f;
     x1  = p_h * a * tau;
     x2  = p_h * (1.0-a);
     x3  = p_f * sigma;
     s   = x1/(x1+x2+x3);
     h   = x2/(x2+x3);
     hh  = (1.0+h)/2.0;
     r   = (2.0*s + (1.0-s)*(1.0+h))^2 /(4.0*p_h) + ((1.0-s)*(1.0-h))^2/(4.0*p_f)
    };


gyno_model _ = Prefix "Gyno" $ do
{
  tau <- beta 2.0 8.0;

  a <- uniform 0.0 1.0;

  p_f <- uniform 0.0 1.0;

  let {sigma = 1.0};

  let {(s, h, r) = gyno_mating_system tau a p_f sigma};

  return (tau, a, p_f, sigma, s, h, r);
};

main = Prefix "Selfing" $ do 
{
          let {alpha = 0.10};

          theta_effective <- dp n_loci alpha (gamma 0.5 0.5); 

          (tau, a, p_f, sigma, s, h, r) <- gyno_model ();

          let {factor = (1.0 - s*0.5)/r};
  
          let {theta = map (/factor) theta_effective};

          Observe 27 $ binomial 221 p_f;

          afs_dist <- diploid_afs n_individuals n_loci s theta_effective;

          Observe observed_alleles afs_dist;

          Log "a" a;
          Log "p_f" p_f;
          Log "tau" tau;
          Log "sigma" sigma;
              
	  Log "s*" s;
	  Log "theta*" theta_effective;
	  Log "theta" theta;
          Log "H" h;
          Log "R" r;
};


}
