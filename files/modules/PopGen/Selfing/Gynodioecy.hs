module PopGen.Selfing.Gynodioecy where
{
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
}
