# BayesianEstimatorSelfing (BES)
A Bayesian method for estimating self-fertilization rates and other mating system parameters

BES is distributed as a collection of modules for bali-phy.  Each
module corresponds to a different mating system, and therefore allows
estimating a different set of parameters.

BES is run from the unix command line.

## Installation

### Prerequisites

Before installing BES, you should first install
* BAli-Phy (http://www.bali-phy.org/README.html#installation)
* Tracer (http://tree.bio.ed.ac.uk/software/tracer/)

### Downloading BES

To download BES, simply download the modules that you want to use:
* Selfing.hs https://raw.githubusercontent.com/bredelings/BayesianEstimatorSelfing/master/Selfing.hs


## Quick Start

```
% bali-phy -m Selfing.hs --iter=10000 --- Examples/outfile.001.70.001.phase &
% statreport --select=Selfing.s --mode --HPD Selfing-1/C1.p
% tracer Selfing-1/C1.p
```