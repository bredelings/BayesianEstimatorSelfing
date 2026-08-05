module PopGen.Selfing.Androdioecy where

-- By ignoring s' and tau, we are focusing on just the adult selfing rate s'
andro_mating_system' s p_m = 1.0 / ((1.0 + s) ^ 2 / (4.0 * p_h) + (1.0 - s) ^ 2 / (4.0 * p_m)) where p_h = 1.0 - p_m

-- By computing s from s', we are parameterizing the adult selfing rate in terms of the seed selfing rate and viability
andro_mating_system s' tau p_m = (s, r)  where
    s = (tau * s') / (tau * s' + 1.0 - s')
    r = andro_mating_system' s p_m

-- By ignoring s' and tau, we are focusing on just the adult selfing rate s'
andro_mating_system2' s p_m sigma = r  where
    p_h = 1.0 - p_m                -- fraction of hermaphrodites
    mp  = p_m * sigma                 -- male pollen
    hp  = p_h                       -- herm pollen
    g_m = 0.5 * (1.0 - s) * mp / (mp + hp)   -- probability a parent is male
    g_h = 1.0 - g_m                -- probability a parent is herm
    rr  = (g_h ^ 2) / p_h + (g_m ^ 2) / p_m -- N/N*, where N=N_m + N_h
    r   = 1.0 / rr                     -- N*/N

-- By computing s from s', we are parameterizing the adult selfing rate in terms of the seed selfing rate and viability
andro_mating_system2 s' tau p_m sigma = (s, r)  where
    s = (tau * s') / (tau * s' + 1.0 - s')
    r = andro_mating_system2' s p_m sigma
