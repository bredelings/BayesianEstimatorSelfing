module PopGen.Selfing.Androdioecy where
{
andro_mating_system' s p_m = (1.0+s)^2 /(4.0*p_h) + (1.0-s)^2/(4.0*p_m) where {p_h = 1.0-p_m};

andro_mating_system s' tau p_m = (s,r) where {s = (tau*s')/(tau*s'+1.0-s');
                                              r = andro_mating_system' s p_m};
}
