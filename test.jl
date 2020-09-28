using Statistics
using Random
using Distributions
using Plots

controlSize = 12758
targetSize = 12901

totalSize = targetSize + controlSize

b = Binomial(totalSize, 0.5)
elapsedTime = @elapsed x = rand(b, 10000)

println("\nP-value SRM: ", mean(x .> targetSize))
println("Elapsed time: ", elapsedTime)

q = quantile(x, [0.025,0.975])
println("95% CI: ", q)


gr()
g = histogram(x, bins=100, title="Distribution of sample size")
vline!(q)



