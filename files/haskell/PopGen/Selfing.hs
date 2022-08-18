module PopGen.Selfing where

import           Probability
import           Range
import           Foreign.Pair
import           MCMC

foreign import bpcall "PopGen:ewens_diploid_probability" builtin_ewens_diploid_probability :: Double -> EVector Int -> EVector Int -> LogDouble
foreign import bpcall "MCMC:sum_out_coals" builtin_sum_out_coals :: Int -> [Int] -> ContextIndex -> RealWorld -> EPair RealWorld ()

sum_out_coals x y c = IOAction (pair_from_c . builtin_sum_out_coals x y c)

ewens_diploid_probability theta i x = builtin_ewens_diploid_probability theta (list_to_vector i) (list_to_vector x)

afs2 thetas ps = Distribution "afs2" (make_densities $ ewens_diploid_probability thetas ps) (error "afs2 has no quantile") (error "afs2 cannot be sampled from") (error "afs2 has no range")

robust_diploid_afs n_individuals n_loci s f theta_effective = lazy $ do
    t <- iid n_individuals (rgeometric s)

    i <- (independent [ iid n_loci $ rbernoulli $ 0.5 ** (intToDouble (t !! k)) * (1 - f) | k <- [0 .. n_individuals - 1] ])
           `with_tk_effect` (\i -> add_move (\c -> mapM_ (\k -> sum_out_coals (t !! k) (i !! k) c) [0 .. n_individuals - 1]))

    return $ (t, plate n_loci (\l -> afs2 (theta_effective !! l) (map (!! l) i)))

diploid_afs n_individuals n_loci s theta_effective = robust_diploid_afs n_individuals n_loci s 0.0 theta_effective
