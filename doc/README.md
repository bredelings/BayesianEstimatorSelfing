---
title: Bayesian Estimator of Selfing (BES)
geometry: margin=1in
---

# Introduction
BES is a software package for estimating self-fertilization (selfing) rates and other mating system parameters
from genotype data.  BES estimates parameters in a Bayesian framework using Markov chain Monte Carlo (MCMC).
BES contains models of pure hermaphroditism, androdioecy (hermaphrodites + males), and gynodioecy (hermaphrodites +
females). Under each model, BES estimates selfing rates, mutation rates, and mating-system specific parameters.
BES also contains a generic model for estimating selfing rates and mutation rates independent of a mating system.
Additional non-genetic information, such as field observations of the number of females or males, is required for
estimating parameters under the gynodioecious model and the androdioecious model.

BES runs through BAli-Phy in a terminal on Linux, macOS, and Windows.
It is an extension package for BAli-Phy and requires version 4.3 or later. See also the
[BAli-Phy user guide](https://www.bali-phy.org/README.html).

BES contains a number of modules that correspond to different mating system models.  Each model allows
estimating a different set of parameters.  The generic model and the pure hermaphrodite model without
inbreeding depression can be run without modification to estimate the selfing rate and locus-specific mutation rates.

However, the gynodioecious and androdioecious models require additional information besides the genetic data.
The corresponding scripts require observed male or female counts on the command line. Some models also require the
user to [edit the module](#specifying-additional-information) to choose priors, fix parameters, or add other identifying
information. This manual describes how to add information, but is not a substitute for understanding the structure
of the model.

# Installation

## Installing BAli-Phy

Since BES is an extension package for BAli-Phy, you must first install BAli-Phy before you can use BES.
To install BAli-Phy, follow the [installation instructions for BAli-Phy](https://www.bali-phy.org/README.html#installation).

## Installing additional software

For graphical inspection of TSV parameter logs, optionally install:

* [Tracer](http://tree.bio.ed.ac.uk/software/tracer/) helps to visualize the results of MCMC runs.

## Installing BES

First, check that the `bali-phy-pkg`  command works:
``` bash
% bali-phy-pkg help
```
Download and install the BES package:
``` bash
% bali-phy-pkg install BES
```
Check that the package is installed:
``` bash
% bali-phy-pkg packages
```
To see what modules were installed, run:
``` bash
% bali-phy-pkg files BES
```
You can uninstall the package by running:
``` bash
% bali-phy-pkg uninstall BES
```

The package supplies reusable modules. Clone the repository to obtain the editable model templates
and example data, then run the examples from that directory:

```sh
git clone https://github.com/bredelings/BayesianEstimatorSelfing.git
cd BayesianEstimatorSelfing
```

All supplied models estimate the additional non-selfing inbreeding component described below.
The ready-to-run models are `Generic.hs`, `Generic2.hs`, `Andro.hs`, `Examples/Andro.hs`,
`Examples/Gyno.hs`, and the installed `PopGen.Selfing.Herm` model. The androdioecious and gynodioecious
models require observed sex counts as command-line arguments.

`HermID.hs`, `AndroID.hs`, and top-level `Gyno.hs` deliberately leave parameter definitions commented
out. They must be edited before execution: supply priors, fixed values, or observations appropriate
to the analysis. `Examples/Gyno.hs` supplies an illustrative prior on relative selfed-seed viability
and fixes relative female seed production to 1. Review these assumptions before using it for your data.
The two runnable androdioecy scripts also contain different prior choices.

# Running the program

## Quick Start

First, inspect the initial model values without starting MCMC or creating an output directory:
``` bash
bali-phy run Generic.hs -l tsv --test Examples/outfile.001.70.001.phase1
```
Then run a short demonstration analysis using the generic model:
``` bash
bali-phy run Generic.hs -l tsv --iterations=1000 Examples/outfile.001.70.001.phase1
```
These 1,000 iterations demonstrate execution; they do not establish convergence. Assess mixing and
convergence before interpreting results. The run creates a directory called `Generic-1/` (or `Generic-2/`, etc.) that contains the output files.

After the run finishes, load the output file `Generic-1/C1.log` using the GUI program Tracer.  On Unix, you can run this from
the command line as follows:
``` bash
% tracer Generic-1/C1.log &
```
It is also possible to use a non-graphical program statreport to view the estimates of the selfing rate
``` bash
% statreport --select="s*" Generic-1/C1.log
```
This can be useful when analyzing data in a terminal.

# Input

`Generic.hs` and the mating-system models read the PHASE layout described below. Specify both
alleles for each locus, using `NA` for missing data.

`Generic2.hs` instead reads FastPhase or Phase2 files. The supplied examples can be inspected with:

```sh
bali-phy run Generic2.hs -l tsv --test Examples/test.fastphase
bali-phy run Generic2.hs -l tsv --test Examples/test.phase2
```

Use `--iterations` instead of `--test` to sample from these models. The files in `Examples/` illustrate
the accepted layouts.

A PHASE file contains a 3-line header, followed by a single line for each observed individual.  The header consists of

1. The number of individuals, on a line by itself.
2. The number of loci, on a line by itself.
3. A sequence of 'M's (for microsatellite) on a line by itself.  The number of M's should equal the number of loci.

The line describing each individual should contain an individual name, followed by a list of integer allele names.
The name and the numbers should be tab-delimited, and there should be twice the number of alleles as loci, since
there are 2 alleles per locus.  Integer allele names must be positive.  The purpose of this is to avoid confusion,
since 0 and negative numbers are often used to indicate missing data.

Here is a very small PHASE file as an illustration:
```
2
3
MMM
sample.1	23	23	2	1	NA	NA
sample.2	23	20	1	1	4	5
```

# Output

## Output directory

For an MCMC run, BAli-Phy creates a new directory to store its output files.  By default, its base name is
the name of the model, with a number added to make the directory unique.  For example, the `Generic` model
uses `Generic-1/`, then `Generic-2/`, and so on.

The `--name` option selects a different base name while retaining automatic unique-directory creation.
Alternatively, `--output-dir` writes into the exact directory specified; that directory must already exist.
If both options are supplied, `--output-dir` takes precedence.  A run with `--test` does not create an output
directory.

## Output files

The selected logging format determines the parameter files:

| File name | Description |
| --------- | ----------- |
| `C1.log.json` | JSON parameter samples, written by default. |
| `C1.log` | Tab-separated parameter samples, written with `-l tsv`. |

Use `-l json,tsv` to write both formats. The scripts print progress and diagnostics to the terminal;
they do not automatically create `C1.out` or `C1.err`. A `--test` invocation prints initial values
rather than creating parameter logs.

The logs contain samples of model parameters and derived quantities. For example, `s*` is the
fraction of uniparental individuals at the time of breeding. Use TSV output for Tracer and the
`statreport` commands below.

Since each mating system has a unique set of parameters, the variables
for each model will be described in the section for that model.

# Analyzing output files

## Using `statreport`

In order to determine estimates of parameters, you can use the program
`statreport`:

``` bash
% statreport C1.log
```

To select particular parameters for numerical summaries, use:
``` bash
% statreport --select "s*" C1.log
```
Here quotes are necessary to make sure that the `*` is not interpreted
by the command line shell, but is passed in to the `statreport`
program unchanged.

You can also use the arguments `--mean`, `--mode`, and `--median` (the
default) to examine different properties of the posterior distribution.


## Using `tracer`

Tracer is a graphical program for exploring posterior distributions.

Run the model with `-l tsv`, then load the resulting `C1.log` file using `tracer`.  On Unix, if `tracer` is in your
`PATH`, you can do this by typing

``` bash
% tracer C1.log &
```

# Mating system models

The stochastic process that generates the genetic data is described in
terms of mating system parameters $\Psi$ and the effective scaled mutation
rates $\Theta^*_l$ for each locus $l$.  The set of variables $\Psi$ is
specific for each mating system.

Some quantities are of interest for each mating system

* $s^*$ is the fraction of uniparental adults (selfing rate).
* $R$ is the decrease in effective population size caused by the mating system.
* ${T_k}$ is the number of generations of selfing in the immediate ancestry of individual $k$.
* ${\Theta_l}$ is the scaled mutation rate $4Nu$ for locus $l$.
* ${\Theta^*_l}$ is the *effective* scaled mutation rate for locus $l$.

Here, $R$ is given by

* $R = \lim_{N\to\infty} \frac{N^*}{N}$

where $N$ is the population size, and $N^*$ is the effective
population size defined by the rate of parent-sharing.  The effective scaled mutation rate is

* $\Theta^*_l = \Theta_l \cdot (1-s^*/2) \cdot R$.

In general, $s^*$ and $R$ are composite parameters: they are
determined from the basic mating system parameters $\Psi$.

It is important to note that the genetic data contain information
about $s^*$, ${\Theta^*_l}$, and the additional inbreeding component described below.  Therefore, the basic
mating system parameters $\Psi$ may be unidentifiable on the basis of
genetic data alone.  This can be solved by introducing additional data
in the form of field observations on, for example, the fraction of
males or the fraction of females in the population.  When such
information is unavailable, the generic model should be used.

## Non-selfing inbreeding

All supplied model scripts use the robust estimator, which estimates `F[other]` alongside selfing.
This allows decreased heterozygosity to have sources other than selfing. The model uses a shared
`F[other]` across individuals, while individual selfing histories vary. Information across loci
helps distinguish these components, subject to the data and model assumptions.

For an individual without recent selfing, its two alleles are independent draws from the gene pool
with probability $1-F_{\mathrm{other}}$, or identical by descent with probability
$F_{\mathrm{other}}$. The latter case assumes rapid coalescence compared with an ordinary coalescent
event, without specifying its mechanism. The supplied prior on `F[other]` is `beta 0.25 1.0`.

The following fields supplement each model's parameter table below:

| Field | Meaning |
| ----- | ------- |
| `F[other]` | Additional loss of heterozygosity, estimated from the model. |
| `F[selfing]` | Selfing component: $s^*/(2-s^*)$. |
| `F[total]` | Combined component: $1-(1-F_{\mathrm{selfing}})(1-F_{\mathrm{other}})$. |

The mating-system parameter sets $\Psi$ below describe reproduction. `F[other]` is an additional
parameter of the genetic observation model; the two other inbreeding coefficients are derived.

## Generic model

The generic model is agnostic about the particular mating system, and
reports $s^*$, ${T_k}$, ${\Theta^*_l}$, and the common inbreeding fields as estimated from the
genetic data.  Since the mating system is not known, $R$ cannot be
calculated.  This means that it is not possible to calculate
${\Theta_l}$ from ${\Theta^*_l}$.

The generic model characterizes reproduction in terms of
the selfing rate $s^*$.  Thus, $\Psi=\{s^*\}$, and so $s^*$ is a basic
parameter, instead of being calculated from other parameters.

The following variables are estimated, with the field names given:

| Variable | Name | Description |
| -------- | ---------------- | ------------------------------------------------------------ |
| $s^*$ | s* | Fraction of uniparental adults (selfing rate). |
| ${T_k}$ | t[$k$] | Number of generations of selfing for individual $k$. |
| ${\Theta^*_l}$ | theta\*[$l$]       | *Effective* scaled mutation rate for locus $l$. |

This variant is implemented by `Generic.hs` and `Generic2.hs`, which differ in their input format.

## Pure Hermaphrodite

In the pure hermaphrodite model, each individual contributes both
male and female gametes to the gene pool.  There are two variants of
this model.

### Variant I

The first variant has $\Psi=\{s^*\}$.  This variant treats $s^*$ as a
basic parameter, and does not model inbreeding depression.  This
variant is similar to the generic model, except that $R$ can be
calculated because the mating system is known to be a pure
hermaphrodite mating system.  This allows ${\Theta_l}$ to be
calculated also.  However, note that $R$ is always $1$ for the pure
hermaphrodite model.

The following variables are estimated, with the field names given:

| Variable | Name | Description |
| -------- | ---------------- | ------------------------------------------------------------ |
| $s^*$ | s* | Fraction of uniparental adults (selfing rate). |
| ${T_k}$ | t[$k$] | Number of generations of selfing for individual $k$. |
| $R$ | R | Decrease in parent-sharing effective population size |
| ${\Theta^*_l}$ | theta\*[$l$]       | *Effective* scaled mutation rate for locus $l$. |
| ${\Theta_l}$ | theta\[$l$]       | Scaled mutation rate $4Nu$ for locus $l$. |

This variant is implemented by the installed `PopGen.Selfing.Herm` model.

### Variant II
The second variant has $\Psi=\{\tilde{s},\tau\}$.  This variant treats
$s^*$ as a composite parameter.

The following variables are estimated, with the field names given:

| Variable | Name | Description |
| -------- | ---------------- | ------------------------------------------------------------ |
| $\tilde{s}$ | s~ | Fraction of uniparental seeds. |
| $\tau$ | tau | Relative viability of selfed seeds. |
| $s^*$ | s* | Fraction of uniparental adults (selfing rate). |
| ${T_k}$ | t[$k$] | Number of generations of selfing for individual $k$. |
| $R$ | R | Decrease in parent-sharing effective population size |
| ${\Theta^*_l}$ | theta\*[$l$]       | *Effective* scaled mutation rate for locus $l$. |
| ${\Theta_l}$ | theta\[$l$]       | Scaled mutation rate $4Nu$ for locus $l$. |

Here the user must modify `HermID.hs` to add additional information
about $\tilde{s}$ or $\tau$.

This variant is implemented by `HermID.hs`.

## Androdioecy

In the androdioecious model, the population consists of some fraction
$p_m$ of males, with the rest of the individuals being
hermaphrodites.  Hermaphrodites produce male gametes, but only
fertilize their own eggs. There are two variants of
this model.

### Variant I

The first variant has $\Psi=\{s^*,p_m\}$.  This variant treats $s^*$ as a
basic parameter, and does not model inbreeding depression.  

The following variables are estimated, with the field names given:

| Variable | Name | Description |
| -------- | ---------------- | ------------------------------------------------------------ |
| $s^*$ | s* | Fraction of uniparental adults (selfing rate). |
| $p_m$ | p_m | The fraction of males |
| ${T_k}$ | t[$k$] | Number of generations of selfing for individual $k$. |
| $R$ | R | Decrease in parent-sharing effective population size |
| ${\Theta^*_l}$ | theta\*[$l$]       | *Effective* scaled mutation rate for locus $l$. |
| ${\Theta_l}$ | theta\[$l$]       | Scaled mutation rate $4Nu$ for locus $l$. |

The observed number of males supplies additional information about $p_m$ through a binomial likelihood. Supply the
number of males and the total number of surveyed individuals as required model arguments:

``` bash
% bali-phy run Andro.hs --males 20 --total 2000 data.phase
```

These commands assume that the named input file exists. The priors remain specified in `Andro.hs` and must be edited there if different priors are desired.

### Variant II
The second variant has $\Psi=\{\tilde{s},\tau,p_m\}$.  This variant treats
$s^*$ as a composite parameter.

The following variables are estimated, with the field names given:

| Variable | Name | Description |
| -------- | ---------------- | ------------------------------------------------------------ |
| $\tilde{s}$ | s~ | Fraction of uniparental zygotes. |
| $\tau$ | tau | Relative viability of selfed zygotes. |
| $p_m$ | p_m | The fraction of males |
| $s^*$ | s* | Fraction of uniparental adults (selfing rate). |
| ${T_k}$ | t[$k$] | Number of generations of selfing for individual $k$. |
| $R$ | R | Decrease in parent-sharing effective population size |
| ${\Theta^*_l}$ | theta\*[$l$]       | *Effective* scaled mutation rate for locus $l$. |
| ${\Theta_l}$ | theta\[$l$]       | Scaled mutation rate $4Nu$ for locus $l$. |

The required `--males` and `--total` arguments supply additional information about $p_m$. The user must still modify
`AndroID.hs` to provide a prior or fixed value for $\tilde{s}$ or $\tau$.

``` bash
% bali-phy run AndroID.hs --males 20 --total 2000 data.phase
```

## Gynodioecy

In the gynodioecious model, the population consists of some fraction
$p_f$ of females, with the rest of the individuals being
hermaphrodites.  Hermaphrodites produce pollen, and so can contribute
male gametes to females, other hermaphrodites, and themselves.

In this model $\Psi=\{\tilde{s},\tau,p_f,\sigma\}$.  Here $s^*$ is a
composite parameter.

The following variables are estimated, with the field names given:

| Variable | Name | Description |
| -------- | ---------------- | ------------------------------------------------------------ |
| $\tilde{s}$ | s~ | Fraction of hermaphrodite seeds set by self-pollen. |
| $\tau$ | tau | Relative viability of selfed seeds. |
| $p_f$ | p_f | The fraction of females |
| $\sigma$ | sigma | Seed production rate of females relative to hermaphrodites. |
| $s^*$ | s* | Fraction of uniparental adults (selfing rate). |
| ${T_k}$ | t[$k$] | Number of generations of selfing for individual $k$. |
| $R$ | R | Decrease in parent-sharing effective population size |
| $H$ | H | Fraction of non-selfed individuals with a hermaphrodite seed-parent. |
| ${\Theta^*_l}$ | theta\*[$l$]       | *Effective* scaled mutation rate for locus $l$. |
| ${\Theta_l}$ | theta\[$l$]       | Scaled mutation rate $4Nu$ for locus $l$. |

For a ready-to-run illustration, use `Examples/Gyno.hs`; it specifies the additional choices in its source.
Top-level `Gyno.hs` is an incomplete template. The required `--females` and `--total` arguments supply additional information about $p_f$. The user must still
modify `Gyno.hs` to provide priors or fixed values for two of the remaining three components of $\Psi$.

``` bash
% bali-phy run Gyno.hs --females 27 --total 221 data.phase
```


# Specifying additional information

When the mating system parameters $\Psi$ contain more than one degree
of freedom, the mating system parameters are not identifiable from
genetic data alone. The androdioecious and gynodioecious scripts incorporate observed sex counts supplied on the
command line. Other observations, fixed values, and prior choices are specified by modifying the model-description
module (`HermID.hs`, `Andro.hs`, `AndroID.hs`, or `Gyno.hs`). In general, if $\Psi$ contains $n$ variables, then
additional information about $n-1$ of them must be incorporated.

## Modifying model-description modules

BES model-description modules (such as `Andro.hs`) use a Haskell-like syntax.
In this syntax,

1. Function application `f(x,y)` is written `f x y`.
2. Comments are introduced by `--`.
3. In a `do` block, an `observe` command introduces data.  Commenting out the
`observe` statements removes the data from the model file.

In the model-description template files (e.g. `HermID.hs`), the comments illustrate possible ways to introduce
variables.

## Methods for adding additional information

Additional information about a variable can be added in 3 ways.

1. Add observations that depend on that variable.
2. Fix the variable to a known constant value.
3. Place a subjective prior on the variable.

The supplied androdioecious and gynodioecious scripts already implement the common case of a binomial observation
on the number of males or females. These counts are required command-line arguments and should not also be added to
the source. The following source modifications apply to other observations and parameters.

### Introduce a variable with a prior and place observations on it.
``` haskell
  tau <- sample $ uniform 0.0 1.0
  observe 10 $ binomial 20 $ toProb tau
```

### Fix a variable to a known constant value.
If you know the value of a variable, you can fix it to a constant:
``` haskell
  let tau = 1.0
```
If you have observations about a variable (e.g. $p_m$) then do not fix that
variable to a constant.  If you fix a variable to a constant, then that variable
cannot be estimated since its value is already known.


### Place a subjective prior on a variable
This approach doesn't actually make the parameter *identifiable*,
since this approach affects only the prior, and not the likelihood.
``` haskell
  tau <- sample $ beta 2.0 8.0
```
As a result, it is not possible to compare the posterior (with data)
and the prior (without data) to assess the impact of the data.  This
approach is therefore not recommended.

# Bayesian priors and posteriors

In Bayesian parlance, *prior* means "before the data", and *posterior*
means "after the data".  The Bayesian approach places prior
distributions on parameters.  As a result, parameters become random
variables, and can have distributions.  This differs from the maximum
likelihood setting, where parameters are not random.  However, the
researcher must interpret prior and posterior distributions carefully
in order to avoid drawing erroneous conclusions.

## Uninformative priors

We take the "objective Bayesian" approach, and seek priors that have
minimal influence on the analysis.  In general, such priors have a
broad range.  This range should not be characterized simply in terms
of the mean or median, but in terms of the Bayesian Credible Interval
(BCI), and in terms of the shapes of the tails of the distribution.

Note that, although the goal is to obtain priors with minimal
influence, such priors are not actually "uninformative".
Specifically, a uniform prior is not "uninformative".  The choice of
an appropriate prior should be undertaken with care in order to avoid
ruling out any plausible outcome *a priori*.

## Comparing the posterior and the prior

The posterior distribution combines information from the prior distribution
and the likelihood.  In order to determine if the shape of the
posterior is being largely driven by the prior, or largely driven by
the likelihood, one should compare the posterior and the prior distributions.

## Priors on composite parameters

For models, such as the gynodioecious model, where $s^*$ is a
composite parameter, no prior distribution is placed on $s^*$
directly.  However, $s^*$ still has a prior distribution that is the
combined result of the priors on all the basic parameters that it is
computed from.

In order to determine what the shape of the prior on $s^*$ is, one
can run the model without data.  This can be done by commenting out
the `observe` statements.
