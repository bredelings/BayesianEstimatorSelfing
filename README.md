# Bayesian Estimator of Selfing (BES)
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
* [Selfing.hs](https://raw.githubusercontent.com/bredelings/BayesianEstimatorSelfing/master/Selfing.hs)


## Quick Start

```
% bali-phy -m Selfing.hs --iter=10000 --- Examples/outfile.001.70.001.phase &
% statreport --select=Selfing.s --mode --HPD Selfing-1/C1.p
% tracer Selfing-1/C1.p
```

## Input

## Output

### Output directory

BAli-Phy creates a new directory to store its output files each time it is run.  By default, the directory
name is the name of the model file, with a number added to the end to make it unique.  BAli-Phy first checks
if there is already a directory called <file>-1/, and then moves on to <file>-2/, etc. until it find an unused
directory name.

You can specify a different name to use instead of the model file name by using the **--name--** option.

### Output files

BAli-Phy write the following output files inside the directory that it creates:

| File name | Description |
| --------- | ----------- |
| C1.out    | General information: command line, start time, etc. |
| C1.err    | May contain error messages. |
| C1.p      | MCMC samples for different variables. |

#### Variables

