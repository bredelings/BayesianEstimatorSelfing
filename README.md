# Bayesian Estimator of Selfing (BES)
A Bayesian method for estimating self-fertilization rates and other mating system parameters

## Introduction
BES is a Unix command line program that is developed primarily on Linux.  BES also runs on Windows and Mac OS X,
but it is not a GUI program.  Instead, you must run it in a terminal.  Therefore, you might want to keep a
[Unix Tutorial](http://www.ee.surrey.ac.uk/Teaching/Unix) or
[Unix cheat sheet](http://www.rain.org/~mkummel/unix.html) handy while you work.

BES is distributed as a collection of plugins for BAli-Phy.  BAli-Phy provides a framework for developing graphical
models and corresponding Markov chain Monte Carlo (MCMC) algorithms similar to BUGS.  BES therefore runs on
every platform that BALi-Phy runs on, which currently includes Linux, Mac OS X, and Windows.  You might wish to refer
to the [BAli-Phy Documentation](http://www.bali-phy.org/README.html) as well.

Each module of BES corresponds to a different mating system, and therefore allows estimating a different set of
parameters.  The generic module (Selfing.hs) and one version of the pure hermaphrodite model with no inbreeding
depression (Herm.hs) can be run without modification to estimate the selfing rate and locus-specific mutation rates.

However, the gynodioecious model module (Gyno.hs) and the androdiecious model module (Andro.hs) require
additional information, such as (for example) field observations on the fraction of hermaphrodites.  Therefore,
the user most modify these modules to add this information before attempting to run these models.  This manual
describes how to add information, but is not a substitute for understanding something about the structure of the
model.

## Installation

### Installing BAli-Phy

Since BES runs as plugins inside BALi-Phy, you must first install BAli-Phy.  To install BAli-Phy, follow
the [installation instructions for BAli-Phy](http://www.bali-phy.org/README.html#installation).

### Installing additional software

In addition to BAli-Phy, we recommend additional software.
* [Tracer](http://tree.bio.ed.ac.uk/software/tracer/) help to visualize the results of MCMC runs.

### Installing BES

To download BES, simply download the modules that you want to use:
* [Selfing.hs](https://raw.githubusercontent.com/bredelings/BayesianEstimatorSelfing/master/Selfing.hs)


## Running the program

### Quick Start

```
% bali-phy -m Selfing.hs --iter=10000 --- Examples/outfile.001.70.001.phase &
% statreport --select=Selfing.s --mode --HPD Selfing-1/C1.p
% tracer Selfing-1/C1.p
```

## Input

Input files must be in PHASE format.  Both alleles for each locus should be specified, with NA given to indicate missing data.

A PHASE file contains a 3-line header, followed by a single line for each observed individual.  The header consists of

1. The number of individuals, on a line by itself.
2. The number of loci, on a line by itself.
3. A sequence of 'M's (for microsatellite) on a line by itself.  The number of M's should equal the number of loci.

The line describing each individual should contain an individual name, followed by a list of integer allele names.
The name and the numbers should be tab-delimited, and there should be twice the number of alleles as loci, since
there are 2 alleles per locus.

Here is a very small PHASE file as an illustration:
```
2
3
MMM
sample.1	23	23	2	1	NA	NA
sample.2	23	20	1	1	4	5
```

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

* Selfing.s - This is the selfing rate.
* Selfing.Theta*!!<i> - This is the effective scaled mutation rate for locus i.
