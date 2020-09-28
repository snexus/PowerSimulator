"""
   split_control_target(historicalSample::AbstractArray, targetSplitRatio::Float64)
   
Splits historicalSample into `control` and `target`

"""
function split_control_target(historicalSample::AbstractArray, targetSplitRatio::Float64)

    splitSample = trunc(Int, length(historicalSample)*targetSplitRatio + 0.5)
    target, control = historicalSample[begin:splitSample], historicalSample[splitSample:end]

    return target, control
end

"""
   apply_uplift_numerical(target::AbstractArray, upliftMean::Float64)
   
Increases target by upliftMean. For example if upliftMean=0.1, 10% uplift is assumed.

"""
function apply_uplift_numerical(target::AbstractArray, upliftMean::Float64)
    return target*(1.0+upliftMean)
end

# a = [1,2,3,4,5,7]
# control, target = split_control_target(a, 0.5)
# target = apply_uplift_numerical(target, 0.1)
