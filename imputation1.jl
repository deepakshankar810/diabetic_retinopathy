
using CSV
using DataFrames
using Impute
using Statistics
using StatsBase

# Load the dataset, specifying missing value indicators
data = CSV.read("diabetic_retinopathy_cleaned_step2.csv", DataFrame,)

using DataFrames
using Statistics
using StatsBase

# Step 1: Inspect Hornerin column
println("Summary of Hornerin before imputation:")
println("Missing values in Hornerin: ", sum(ismissing.(data[!, :Hornerin])))
println("Non-missing Hornerin values (min, max, mean):")
describe(data[!, :Hornerin], :min, :max, :mean) |> show

# Step 2: Impute missing values with group median
# Compute median Hornerin for each Clinical_Group
group_medians = combine(groupby(data, :Clinical_Group), :Hornerin => (x -> median(skipmissing(x))) => :Hornerin_median)

# Create a dictionary for group medians
median_dict = Dict(row.Clinical_Group => row.Hornerin_median for row in eachrow(group_medians))

# Print medians for verification
println("\nMedian Hornerin by Clinical_Group:")
println(median_dict)

# Function to impute missing Hornerin based on group median
function impute_hornerin(row)
    if ismissing(row.Hornerin)
        return median_dict[row.Clinical_Group]
    else
        return row.Hornerin
    end
end

# Apply imputation
data[!, :Hornerin] = impute_hornerin.(eachrow(data))

# Step 3: Verify changes
println("\nSummary of Hornerin after imputation:")
println("Missing values in Hornerin: ", sum(ismissing.(data[!, :Hornerin])))
println("Non-missing Hornerin values (min, max, mean):")
describe(data[!, :Hornerin], :min, :max, :mean) |> show

# Display first 5 rows to verify Hornerin
println("\nFirst 5 rows of the dataset (selected columns):")
select(data, [:Patient_ID, :Clinical_Group, :Hornerin, :Albuminuria]) |> x -> show(first(x, 5), allcols=true)

# Optional: Save the updated DataFrame
CSV.write("diabetic_retinopathy_cleaned_step3.csv", data)