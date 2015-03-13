# BayesianEstimatorSelfing
A Bayesian method for estimating self-fertilization rates and other mating system parameters

## Quick Start

```
% bali-phy -m Selfing.hs --iter=10000 --- Examples/outfile.001.70.001.phase &
% statreport --select=Selfing.s --mode --HPD Selfing-1/C1.p
% tracer Selfing-1/C1.p
```