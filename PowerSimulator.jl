using Base.Threads
using Distributed


@everywhere include("StatisticalTests.jl")

const rnglist = [MersenneTwister() for i in 1:Threads.nthreads()]

# function simulate_power(historical_sample::Array, sample_size::Int, alpha::Float64, effect_size::Float64, 
#     split_ratio_target::Float64, n_iterations::Int = 10, n_permutations::Int = 1000)
 
#     perm_matrix = [randperm(sample_size) for x in 1:n_permutations]
 
#     test_outcomes, p_values = [], []
#     for i in 1:n_iterations
#        s = sample(historical_sample, sample_size, replace=true)
#        target, control = split_control_target(s, split_ratio_target)
#        uplift_target = apply_uplift_numerical(target, effect_size)
#        outcome, p_value = permutation_test(control, uplift_target, alpha, perm_matrix, n_permutations)
#        push!(test_outcomes, outcome)
#        push!(p_values, p_value)
#     end
    
#     return test_outcomes, p_values
 
#  end


"""
simulate_power_threads(historical_sample::Array{Float64,1}, sample_size::Int, alpha::Float64, effect_size::Float64, 
    split_ratio_target::Float64, n_iterations::Int = 10, n_permutations::Int = 1000)

Multi-threaded version of power simulator

"""
function simulate_power_threads(historical_sample::Array{Float64,1}, sample_size::Int, alpha::Float64, effect_size::Float64, 
    split_ratio_target::Float64, n_iterations::Int = 10, n_permutations::Int = 1000)
 
    # Calculating permutation matrix, to speed up sampling. This approach is not space efficient.
    perm_matrix = [randperm(sample_size) for x in 1:n_permutations]
 
    test_outcomes, p_values = [], []

    # Here we use threads macros to speed up the loop. We don't require stitching matrices togethers, loops can be completely parallel.
    @inbounds @threads for i in 1:n_iterations
       s = sample( rnglist[threadid()], historical_sample, sample_size, replace=true)
       target, control = split_control_target(s, split_ratio_target)
       uplift_target = apply_uplift_numerical(target, effect_size)

       uplift_target = sample(uplift_target, length(uplift_target), replace=true)
       outcome, p_value = permutation_test(control, uplift_target, alpha, perm_matrix, n_permutations)
       push!(test_outcomes, outcome)
       push!(p_values, p_value)
    end
    
    return test_outcomes, p_values
 
 end


#  rmprocs(workers())
#  addprocs(4)
#  nworkers()

#  function simulate_power_mp(historical_sample::Array{Float64,1}, sample_size::Int, alpha::Float64, effect_size::Float64, 
#     split_ratio_target::Float64, n_iterations::Int = 10, n_permutations::Int = 1000)
 
#     # Calculating permutation matrix, to speed up sampling. This approach is not space efficient.
#     perm_matrix = [randperm(sample_size) for x in 1:n_permutations]
 
#     #test_outcomes =SharedArray{Float64}(1, n_permutations)

#     # Here we use threads macros to speed up the loop. We don't require stitching matrices togethers, loops can be completely parallel.
#     @inbounds @sync @distributed (+) for i in 1:n_iterations
#        s = sample( historical_sample, sample_size, replace=true)
#        target, control = split_control_target(s, split_ratio_target)
#        uplift_target = apply_uplift_numerical(target, effect_size)
#        outcome, p_value = permutation_test(control, uplift_target, alpha, perm_matrix, n_permutations)
#        outcome/n_permutations

#     end
    
 
#  end


#  historical_sample = rand(Normal(50.0,20.0), 4000)
#  @time outcomes, p_values = simulate_power(historical_sample, 2000 ,0.05, 0.03, 0.5, 1000, 1000)
# @time outcomes, p_values = simulate_power_threads(historical_sample, 2000 ,0.05, 0.03, 0.5, 1000, 1000)
#  @time outcomes = simulate_power_mp(historical_sample, 2000 ,0.05, 0.03, 0.5, 1000, 1000)