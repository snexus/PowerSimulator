# Non-parameteric Power Simulator for A/B Tests


## General

The goal of simulator is to estimate power that would be achieved in an A/B test, provided historical sample of a metric and assumed effect size.

This simulator is useful in situations when parametric power estimation (for example using t-test) is not possible due to small sample size (when CLT is not applicable) or non-conventional metric, which can't be parametrized by a known probability distribution.

Inspired by https://patreonhq.com/a-framework-to-determine-how-much-data-you-need-for-an-experiment-a20fcd2719eb

Simulator can be used at experiment design or analysis stage to estimate sample size requirements or any other elements influencing statistical power of the test.

Simulator is non-parametric, i.e. doesn't have distribution assumptions. Instead, it uses resampling methods on snapshot of historical data to perform the analysis.  

---
**Inputs:**

* Historical sample of custom metric.
* Sample size.
* Control/target split ratio.
* Significance level of a test - alpha (probability of false positive).
* Minimum detectable uplift.

**Output**: statistical power.

---
### Typical workflows during experiment design stage

  * Obtain historical snapshot of metric.

  * Set required significance level (e.g. 0.05).

  * Set minimum effect size.
  
  * Set control/target split ratio

  * Iteratively _change_ sample size in simulator with fixed significance, effect size and ratio to achieve the desired power.
 
---

## Theory


The simulator is based on framework from Patreon, with additional improvements.



<img src ='https://cdn-images-1.medium.com/max/2400/0*oNPUhlcv43vVmRFq.png'>


---
## Changes to original framework

Additions contain specific implementations and improvements of `Treated treatment group` and `Perform statistical procedure` parts:


### Treated treatment group

Group treatment is applying `minimum detectable effect` to the response metric of untreated group.

Current implementation applies constant uplift (e.g. 10%) to the response metric. In reality, uplift is not constant, but rather random variable with specific mean and dispersion. 

In order to simulate this behavior, instead of using flat (constant) uplift - the response metric is bootstrapped at each round of simulation. This addition improves significantly accuracy of the simulator.


### Statistical procedure

Following statistical test is implemented in simulator:

* Two sample, one side permutation test - can be used with arbitrary shaped distributions of metrics, and as upper bound limit for Bayesian A/B tests. Most generic and slowest test.




---
## Example


```Julia
using PowerSimulator
using Distributions
using Statistics

# Generate dummy historical sample, drawn from Normal distribution. In practice, should be replaced by snapshot of historical data.
hsample = rand(Normal(50.0,20.0), 10000)

sample_size = 2000 # Total sample size, control+target
split_ratio = 0.5 # Split ratio control/target group. In this case 50%/50%.
effect_size = 0.03 # Assume 3% effect size.
alpha = 0.05 # Significance level.Controls type I error. Maximum probability of false positive.
n_iterations = 1000 # number of iterations for bootstrap procedure.
n_permutations = 1000 # number of draws for permutation procedure

# Call multi-threaded version of simulator.
@time outcomes, p_values = simulate_power_threads(hsample, sample_size ,alpha, effect_size, split_ratio, n_iterations, n_permutations)

# Calculate power by taking mean of individual outocmes.
print("Achieved power: ",mean(outcomes))
```