using CSV
using DataFrames
using Statistics
using Impute
using StatsBase
using Random
using PrettyTables

# Load the dataset
data = CSV.read("diabetic_retinopathy.csv", DataFrame)

# Replace string "NaN", "NIL", and floating-point NaN with missing
for col in names(data)
    data[!, col] = replace(data[!, col], "NaN" => missing, "NIL" => missing, "Nil" => missing)
    if eltype(data[!, col]) <: Union{Missing, Number}
        data[!, col] = map(x -> isequal(x, NaN) ? missing : x, data[!, col])
    end
end

# Handle missing Hornerin values by replacing with group median
for group in unique(data[!, :Clinical_Group])
    group_mask = data[!, :Clinical_Group] .== group
    valid_values = filter(x -> !ismissing(x) && !isnan(x), data[group_mask, :Hornerin])
    group_median = length(valid_values) > 0 ? median(valid_values) : 0.0
    data[group_mask, :Hornerin] = coalesce.(data[group_mask, :Hornerin], group_median)
end

# Handle missing SFN values by replacing with group median
for group in unique(data[!, :Clinical_Group])
    group_mask = data[!, :Clinical_Group] .== group
    valid_values = filter(x -> !ismissing(x) && !isnan(x), data[group_mask, :SFN])
    group_median = length(valid_values) > 0 ? median(valid_values) : 0.0
    data[group_mask, :SFN] = coalesce.(data[group_mask, :SFN], group_median)
end

# Save the cleaned dataset
CSV.write("diabetic_retinopathy_missing_removed_cleaned.csv", data)