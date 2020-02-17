module PopGen.Selfing.Gynodioecy where

gyno_mating_system tau s' p_f sigma = (s, h, 1.0 / c)  where
    p_h = 1.0 - p_f
    x1  = p_h * s' * tau
    x2  = p_h * (1.0 - s')
    x3  = p_f * sigma
    s   = x1 / (x1 + x2 + x3)
    h   = x2 / (x2 + x3)
--  hh  = (1.0+h)/2.0  
--  c   = (s^2 + 2.0*s*(1.0-s)*hh + (1.0-s)^2*hh^2) /p_h + ((1.0-s)*(1.0-h))^2/(4.0*p_f)
--  c   = (2.0*s + (1.0-s)*(1.0+h))^2 /(4.0*p_h) + ((1.0-s)*(1.0-h))^2/(4.0*p_f)  
    c   = (2.0 - (1.0 - s) * (1.0 - h)) ^ 2 / (4.0 * p_h) + ((1.0 - s) * (1.0 - h)) ^ 2 / (4.0 * p_f)
