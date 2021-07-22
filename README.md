# Bayesian Estimator of Selfing (BES)
BES is a software package for estimating self-fertilization (selfing)
rates and other mating system parameters from genotype data.  BES
estimates parameters in a Bayesian framework using Markov chain Monte
Carlo (MCMC).

BES contains a _generic_ model for estimating selfing rates and mutation
rates independent of a mating system. BES also contains models of
* pure hermaphroditism
* androdioecy (hermaphrodites + males)
* gynodioecy (hermaphrodites + females)

Additional *non-genetic* information, such as field observations of
the number of females or males, is required for to estimate mating
system parameters.

See the [paper](https://doi.org/10.1534/genetics.115.179093) and [figures](https://www.genetics.org/content/201/3/1171.figures-only).


## A more robust estimator

BES version 0.1.3 has been changed to be more robust by estimating the
loss-of-heterozygosity (F[other]) that is not due to selfing as well as the
selfing rate (s or s*).  Without allowing other sources of inbreeding,
the estimates of the selfing rate can be too high, since they assume
that selfing is the _only_ source of decreased heterozygosity.

With enough loci, it is easy to separate the loss of heterozygosity
that comes from selfing versus loss of heterozygosity that comes from
other sources.  This is because selfing affects different individuals
in different ways, having no effect on non-selfed individuals and a
large effect on individuals with many generations of selfing. Other
sources of inbreeding cause a loss of heterozygosity in all
individuals alike.  

The model of non-selfing inbreeding assumes that the two alleles in an outbred
individual have probability (1-F[other]) of being drawn independently from the
gene pool, and probability F[other] of being identical-by-descent (IBD).  No
mechanism is specified for the allele sharing in the IBD case, except that the
two IBD alleles are assumed to have coalesced quickly compared to a normal
coalesent event.

In addition to s* (the selfing rate), the example scripts now
report the inbreeding coefficients:

* F[other]
* F[is] = s*/(2-s*)
* F[total] = 1 - (1 - F[is]) * (1 - F[other])

# Install

1. Install the MCMC program [BAli-Phy](https://github.com/bredelings/BAli-Phy) version 3.6.0 or higher.

   See the [full documentation](http://bali-phy.org/README.xhtml) or
   the [quick install documentation](http://bali-phy.org/download.php).

2. Install the BES package for bali-phy:

   ```
   bali-phy --version
   bali-phy-pkg install BES
   bali-phy-pkg packages
   ```

3. Install the BES example scripts:

   ```
   git clone https://github.com/bredelings/BayesianEstimatorSelfing.git
   ```

For further instructions in installation and usage, see the [README.pdf](https://raw.githubusercontent.com/bredelings/BayesianEstimatorSelfing/master/doc/README.pdf)

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

# Usage

1. To try a test run, do

```
cd BayesianEstimatorSelfing
bali-phy -m Generic.hs -l tsv --test --- Examples/outfile.001.70.001.phase1
bali-phy -m Generic.hs -l tsv        --- Examples/outfile.001.70.001.phase1
```

The script `Generic.hs` is a template can be modified if you wish to adjust the priors.

2. If you want to use a FastPhase of Phase2-formatted input file, you can
use the `Generic2.hs` template:

```
bali-phy -m Generic2.hs -l tsv --test --- Examples/test.fastphase
bali-phy -m Generic2.hs -l tsv --test --- Examples/test.phase2
```

3. If you leave off the `-l tsv` then logging will be done in JSON format.


# Installing the development version of BES

*Note:* You should probably just run `bali-phy-pkg install BES` instead of doing this!

To install the unreleased development version of BES from github:
```
git clone https://github.com/bredelings/BayesianEstimatorSelfing.git
cd BayesianEstimatorSelfing
./make_package
bali-phy-pkg install-archive BES_<version>.tar.gz
```
This will probably require the latest (unreleased) version of bali-phy from github as well.

# Contact

You can send questions to the mailing list [https://groups.google.com/forum/#!forum/bayesian-estimator-selfing].
If you don't join the group first, your question will be held until I have a chance to check that it is not spam.