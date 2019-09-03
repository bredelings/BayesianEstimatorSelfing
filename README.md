# Bayesian Estimator of Selfing (BES)
BES is a software package for estimating self-fertilization (selfing) rates and other mating system parameters
from genotype data.  BES estimates parameters in a Bayesian framework using Markov chain Monte Carlo (MCMC).
BES contains models of pure hermaphroditism, androdioecy (hermaphrodites + males), and gynodioecy (hermaphrodites +
females). Under each model, BES estimates selfing rates, mutation rates, and mating-system specific parameters.
BES also contains a generic model for estimating selfing rates and mutation rates independent of a mating system.
Additional non-genetic information, such as field observations of the number of females or males, is required for
estimating parameters under the gynodioecious model and the androdioecious model.

# Install

BES is implemented within the BAli-Phy MCMC framework, so you must first install [BAli-Phy](https://github.com/bredelings/BAli-Phy).

You can then install BES as follows:
```
bali-phy --version
bali-phy-pkg install BES
bali-phy-pkg packages
```

For further instructions in installation and usage, see the [README.pdf](https://raw.githubusercontent.com/bredelings/BayesianEstimatorSelfing/master/doc/README.pdf)

## Installing the development version of BES

This assumes you've installed the latest (unreleased) version of bali-phy from github.
```
git clone git@github.com:bredelings/BayesianEstimatorSelfing.git
cd BayesianEstimatorSelfing
./make_package
bali-phy-pkg install-archive BES_0.1.2.tar.gz
```

# Overview

BES is run as a Unix command line program.  It is not a GUI program; instead you must run it in a terminal.
Therefore, you might want to keep a [Unix Tutorial](http://www.ee.surrey.ac.uk/Teaching/Unix) or
[Unix cheat sheet](http://www.rain.org/~mkummel/unix.html) handy while you work.

BES runs on Linux, Mac OS X, and Windows.  BES is distributed as an extension package for the BAli-Phy inference framework.
You might therefore wish to refer to the [BAli-Phy Documentation](http://www.bali-phy.org/README.html) as well.

BES contains a number of modules that correspond to different mating system models.  Each model allows
estimating a different set of parameters.  The generic model and the pure hermaphrodite model without
inbreeding depression can be run without modification to estimate the selfing rate and locus-specific mutation rates.

However, the gynodioecious model and the androdiecious model require additional information besides the genetic data,
such as (for example) field observations on the fraction of hermaphrodites.  Therefore,
the user must [edit these modules](#specifying-additional-information) to add this information before attempting to run these models.  This manual
describes how to add information, but is not a substitute for understanding something about the structure of the
model.
