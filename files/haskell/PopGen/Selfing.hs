module PopGen.Selfing where

import           Foreign.Vector (EVector, toVector)
import           MCMC
import           Probability

foreign import bpcall "PopGen:ewens_diploid_probability"
    ewensDiploidProbabilityNative :: Double -> EVector Int -> EVector Int -> ProbDensity

foreign import bpcall "MCMC:sum_out_coals"
    sumOutCoalsNative :: Int -> [Int] -> ContextIndex -> IO ()

ewens_diploid_probability theta indicators alleles =
    ewensDiploidProbabilityNative theta (toVector indicators) (toVector alleles)

data AFS2 = AFS2 Double [Int]

instance Dist AFS2 where
    type Result AFS2 = [Int]
    distName _ = "afs2"

instance HasAnnotatedPdf AFS2 where
    annotatedDensities (AFS2 theta indicators) =
        make_prob_densities $ ewens_diploid_probability theta indicators

afs2 theta indicators = AFS2 theta indicators

-- Sample selfing times and per-locus coalescence indicators, then register their joint update.
robust_diploid_afs n_individuals n_loci s f theta_effective = lazy $ do
    -- A run of t selfing generations has probability (1-s)*s^t. Convert s
    -- before subtraction so the stopping probability retains a small tail.
    t <- sample $ iid n_individuals (geometric $ 1 - toProb s)

    -- Update every individual's time and indicators in one transition kernel, as required by the move.
    i <- (sample $ independent
            [ iid n_loci $ bernoulli $ 1 - pow 0.5 (fromIntegral (t !! k)) * (1 - toProb f)
            | k <- [0 .. n_individuals - 1]
            ])
        `withTKEffect` (\indicators ->
            addMove 1 $ TransitionKernel (\context ->
                mapM_ (\k -> sumOutCoalsNative (t !! k) (indicators !! k) context)
                      [0 .. n_individuals - 1]))

    return (t, plate n_loci (\l -> afs2 (theta_effective !! l) (map (!! l) i)))

diploid_afs n_individuals n_loci s theta_effective =
    robust_diploid_afs n_individuals n_loci s (0 :: Double) theta_effective
