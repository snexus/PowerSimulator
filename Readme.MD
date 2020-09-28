## Statistical Power Simulator for A/B Tests

### Usage example

```Julia
using SimulatePower

# Generate dummy historical sample, drawn from Normal distribution.
hsample = rand(Normal(50.0,20.0), 4000)

# Call multi-threaded version of simulator.
@time outcomes, p_values = simulate_power_threads(historical_sample, 2000 ,0.05, 0.03, 0.5, 1000, 1000)

# Calculate power by taking mean of individual outocmes.
mean(outomes)

```