using Distributions
using Statistics
using Random

include("Utils.jl")

function permutation_test(control::Array{Float64,1}, target::Array{Float64,1},alpha::Float64, perm_matrix, n_permutations::Int = 1000,
     fun::Function = mean)

     len_control, len_target = length(control), length(target)
     
     # Observed difference
     d = abs(fun(target)-fun(control))
     all = reshape([control; target],  :)
     d_array = []


     # Do permutation loops
     for j in 1:n_permutations
        s = all[perm_matrix[j]] 
        pcontrol = s[begin:len_control]
        ptarget = s[len_control+1:end]
        push!(d_array, fun(ptarget)-fun(pcontrol))
         
     end

     p_value =  mean(d .< d_array)
     return p_value < alpha, p_value
    
end






# sample_size = 10
# n_permutations = 10
# split_ratio_target = 0.5
# effect_size = 0.1
# alpha=0.05
# historical_sample = [1,2,3,5,4,3,1,2,3,4,5,6]
# historical_sample = rand(Normal(50.0,20.0), 4000)

# @time outcomes, p_values = simulate_power(historical_sample, 2000 ,0.05, 0.03, 0.5, 1000, 1000)

# mean(outcomes)

# perm_matrix = [randperm(sample_size) for x in 1:n_permutations]

# s = sample(historical_sample, sample_size, replace=true)
# target, control = split_control_target(s, split_ratio_target)

# uplift_target = apply_uplift_numerical(target, effect_size)
# outcome, p_value = permutation_test(control, uplift_target, alpha, perm_matrix, n_permutations)


# control = rand(Normal(1,5),10000)
# target = rand(Normal(1.3,5), 10000)

# perm_matrix = [randperm(length(control) + length(target)) for x in 1:1000]

# all = reshape([control; target],  :)
# d_array = []

# @time perm_matrix = [randperm(length(all)) for x in 1:1000]

# target = control


# @time permutation_test(control, target, 0.05, perm_matrix, 1000 )

# len_control, len_target = length(control), length(target)
# # d = mean(target)-mean(control)


# all = reshape([control; target],  :)

# d_array = []
# s = sample(all, length(all), replace=false)
# pcontrol = s[begin:len_control]
# ptarget = s[len_control+1:end]
# push!(d_array, mean(ptarget)-mean(pcontrol))

# mean(d .< d_array)