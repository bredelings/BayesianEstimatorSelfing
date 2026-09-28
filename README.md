# Bayesian Estimator of Selfing (BES)

BES estimates self-fertilization (selfing) rates and other mating-system parameters from genotype
data, using Bayesian inference and Markov chain Monte Carlo (MCMC). It provides a generic model
that estimates selfing and effective mutation rates without specifying a mating system, as well as
models of:

* pure hermaphroditism
* androdioecy (hermaphrodites + males)
* gynodioecy (hermaphrodites + females)

Estimating the underlying mating-system parameters can require additional information, such as
observed male or female counts, fixed parameter values, or informative priors.
See the [paper](https://doi.org/10.1534/genetics.115.179093) for the mating-system models.

## Robust estimation

All supplied model scripts estimate loss of heterozygosity from sources other than selfing
(`F[other]`) alongside the selfing rate (`s*`). Allowing this additional component avoids attributing
all decreased heterozygosity to selfing, which can otherwise inflate estimates of the selfing rate.

The model uses a shared `F[other]` across individuals, while the number of consecutive generations of
selfing varies among individuals. Information across loci helps distinguish these components; how
well they can be separated depends on the data and model assumptions.

For an individual without recent selfing, the model treats the two alleles as independent draws
from the gene pool with probability `1 - F[other]`, or as identical by descent (IBD) with probability
`F[other]`. It does not specify a mechanism for the latter case, but assumes that the IBD alleles
coalesced quickly compared with an ordinary coalescent event.

The scripts report:

* `F[other]`: loss of heterozygosity from sources other than selfing.
* `F[selfing] = s*/(2-s*)`: the selfing component.
* `F[total] = 1 - (1 - F[selfing]) * (1 - F[other])`: the combined component.

## Installation

1. Install [BAli-Phy](https://github.com/bredelings/BAli-Phy) version 4.3 or later, following its
   [installation instructions](https://www.bali-phy.org/README.html#installation).

2. Install the BES package, which supplies the reusable model modules:

   ```sh
   bali-phy --version
   bali-phy-pkg install BES
   bali-phy-pkg packages
   ```

3. Clone this repository to obtain the editable model templates and example data:

   ```sh
   git clone https://github.com/bredelings/BayesianEstimatorSelfing.git
   cd BayesianEstimatorSelfing
   ```

BES runs through BAli-Phy in a terminal on Linux, macOS, or Windows. For more detail, see the
[BAli-Phy user guide](https://www.bali-phy.org/README.html) and the BES
[full manual](doc/README.md) ([PDF](doc/README.pdf)).

## Choosing a model

All models below include `F[other]`. Ready-to-run examples contain particular prior choices;
review those choices before using them for your own data.

| Model | Use |
| ----- | --- |
| `Generic.hs` | Ready-to-run generic model for PHASE data. |
| `Generic2.hs` | Ready-to-run generic model for FastPhase or Phase2 data. |
| `Andro.hs` | Ready-to-run androdioecy model; requires `--males` and `--total`. |
| `Examples/Andro.hs` | Runnable androdioecy example with its own prior choices; requires sex counts. |
| `Examples/Gyno.hs` | Runnable gynodioecy example with specified priors and relative female seed production fixed at 1; requires `--females` and `--total`. |
| `PopGen.Selfing.Herm` | Installed, ready-to-run pure-hermaphrodite model without inbreeding depression. |
| `HermID.hs`, `AndroID.hs`, `Gyno.hs` | Templates requiring parameter/prior definitions before execution. |

The last three templates intentionally leave some definitions commented out. Supply appropriate
priors, fixed values, or observations before running them. Sex counts are command-line arguments;
other identifying information requires editing the template. See
[specifying additional information](doc/README.md#specifying-additional-information).

## Usage

Run these commands from the cloned repository. First inspect the generic model's initial values
without starting MCMC or creating an output directory:

```sh
bali-phy run Generic.hs -l tsv --test Examples/outfile.001.70.001.phase1
```

Then run a short demonstration analysis:

```sh
bali-phy run Generic.hs -l tsv --iterations=1000 Examples/outfile.001.70.001.phase1
```

This creates `Generic-1/` (or the next available numbered directory). The 1,000 iterations are a
demonstration, not a convergence criterion; assess mixing and convergence before interpreting an
analysis. With `-l tsv`, parameter samples are written to `C1.log`, which can be examined with
Tracer or summarized with:

```sh
statreport --select="s*" Generic-1/C1.log
```

Without `-l tsv`, the default is JSON logging to `C1.log.json`. To write both formats, use
`-l json,tsv`. The `Generic.hs` template can be edited to change its priors.

For FastPhase or Phase2 input, use `Generic2.hs`:

```sh
bali-phy run Generic2.hs -l tsv --test Examples/test.fastphase
bali-phy run Generic2.hs -l tsv --test Examples/test.phase2
```

For androdioecy, supply the observed number of males and the total surveyed population sample:

```sh
bali-phy run Andro.hs -l tsv --iterations=1000 --males 20 --total 2000 Examples/outfile.001.70.001.phase1
```

The runnable gynodioecy example similarly requires the observed number of females:

```sh
bali-phy run Examples/Gyno.hs -l tsv --iterations=1000 --females 27 --total 221 Examples/outfile.001.70.001.phase1
```

These counts are illustrative; replace them with your observations. The top-level `Gyno.hs` is an
editable template rather than a ready-to-run example.

## Building the manual

Edit `doc/README.md` for manual content and `doc/pandoc.css` for its HTML styling. Mathematical
notation stays in LaTeX-style `$...$` expressions in the Markdown source. The generated files are
`doc/README.html` and `doc/README.pdf`; regenerate them rather than editing them directly.

The build uses Pandoc (validated with version 3.11). PDF generation also requires `pdflatex` and
the LaTeX packages used by Pandoc's default template, such as those supplied by a TeX Live installation.

```sh
./make_doc       # build HTML and PDF
./make_doc html  # build HTML only; no TeX installation needed
./make_doc pdf   # build PDF only
./make_doc --help
```

The script locates its inputs relative to itself, so it can also be invoked by path from another
directory. The HTML embeds its stylesheet and uses native MathML for equations; it can be opened
offline in a modern browser without fetching rendering resources. PDF equations are typeset by LaTeX.

## Contact

Questions can be sent to the
[BES mailing list](https://groups.google.com/g/bayesian-estimator-selfing).
Join the group before posting to avoid having your question held for moderation.
