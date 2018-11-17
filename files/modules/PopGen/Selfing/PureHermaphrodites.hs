module PopGen.Selfing.PureHermaphrodites where

herm_mating_system s' tau = s where s = (tau*s')/(tau*s'+1.0-s')

