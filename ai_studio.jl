# using Pkg
# Pkg.add(["CSV", "DataFrames", "Impute", "Statistics", "StatsBase"])

using CSV
using DataFrames
using Impute
using Statistics
using StatsBase

# Load the dataset, specifying missing value indicators
data = CSV.read("diabetic_retinopathy_old.csv", DataFrame, 
                missingstring=["NaN", "Nil", "NIL", "-", ""])

# Display the first 5 rows to verify loading
println("First 5 rows of the dataset:")
show(first(data, 5), allcols=true)

# Display column names to check for any whitespace issues
println("\nColumn names:")
println(names(data))

# Summarize missing values per column
println("\nMissing values per column:")
for col in names(data)
    println("$col: $(sum(ismissing.(data[!, col])))")
end


using DataFrames
using Statistics
using StatsBase

# Step 1: Inspect unique values in Albuminuria
println("Unique values in Albuminuria before recoding:")
println(unique(data[!, :Albuminuria]))

# Step 2: Recode Albuminuria
function recode_albuminuria(value)
    if ismissing(value)
        return missing
    end
    # Convert to lowercase to handle case variations
    val_lower = lowercase(string(value))
    if val_lower == "neg"
        return 0
    elseif val_lower == "1+"
        return 1
    elseif val_lower == "2+"
        return 2
    elseif val_lower == "3+"
        return 3
    elseif val_lower == "4+"
        return 4
    else
        println("Unexpected value in Albuminuria: ", value)
        return missing  # Return missing for unexpected values
    end
end

# Apply recoding to Albuminuria column
data[!, :Albuminuria] = recode_albuminuria.(data[!, :Albuminuria])

# Convert Albuminuria to Int64, allowing missing values
data[!, :Albuminuria] = convert(Vector{Union{Missing, Int64}}, data[!, :Albuminuria])

# Step 3: Impute missing values with group median
# Compute median Albuminuria for each Clinical_Group
group_medians = combine(groupby(data, :Clinical_Group), :Albuminuria => (x -> median(skipmissing(x))) => :Albuminuria_median)

# Create a dictionary for group medians
median_dict = Dict(row.Clinical_Group => row.Albuminuria_median for row in eachrow(group_medians))

# Print medians for verification
println("\nMedian Albuminuria by Clinical_Group:")
println(median_dict)

# Function to impute missing Albuminuria based on group median
function impute_albuminuria(row)
    if ismissing(row.Albuminuria)
        return Int(round(median_dict[row.Clinical_Group]))  # Round to nearest integer
    else
        return row.Albuminuria
    end
end

# Apply imputation
data[!, :Albuminuria] = impute_albuminuria.(eachrow(data))

# Step 4: Verify changes
# Check unique values in Albuminuria
println("\nUnique values in Albuminuria after recoding and imputation:")
println(unique(data[!, :Albuminuria]))

# Check for missing values in Albuminuria
println("\nMissing values in Albuminuria: ", sum(ismissing.(data[!, :Albuminuria])))

# Display first 5 rows to verify Albuminuria
println("\nFirst 5 rows of the dataset (selected columns):")
select(data, [:Patient_ID, :Clinical_Group, :Albuminuria]) |> x -> show(first(x, 5), allcols=true)

# Optional: Save the updated DataFrame
CSV.write("diabetic_retinopathy_cleaned_step2.csv", data)

using DataFrames
using Statistics
using StatsBase

# Step 1: Inspect Hornerin column
println("Summary of Hornerin before imputation:")
println("Missing values in Hornerin: ", sum(ismissing.(data[!, :Hornerin])))
println("Non-missing Hornerin values (min, max, mean):")
if sum(.!ismissing.(data[!, :Hornerin])) > 0
    println("Min: ", minimum(skipmissing(data[!, :Hornerin])))
    println("Max: ", maximum(skipmissing(data[!, :Hornerin])))
    println("Mean: ", mean(skipmissing(data[!, :Hornerin])))
else
    println("No non-missing values in Hornerin")
end

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
println("Min: ", minimum(data[!, :Hornerin]))
println("Max: ", maximum(data[!, :Hornerin]))
println("Mean: ", mean(data[!, :Hornerin]))

# Display first 5 rows to verify Hornerin
println("\nFirst 5 rows of the dataset (selected columns):")
select(data, [:Patient_ID, :Clinical_Group, :Hornerin, :Albuminuria]) |> x -> show(first(x, 5), allcols=true)

# Optional: Save the updated DataFrame
# CSV.write("diabetic_retinopathy_cleaned_step3.csv", data)

using DataFrames
using Statistics
using StatsBase

# Step 1: Inspect SFN column
println("Summary of SFN before imputation:")
println("Missing values in SFN: ", sum(ismissing.(data[!, :SFN])))
println("Non-missing SFN values (min, max, mean):")
if sum(.!ismissing.(data[!, :SFN])) > 0
    println("Min: ", minimum(skipmissing(data[!, :SFN])))
    println("Max: ", maximum(skipmissing(data[!, :SFN])))
    println("Mean: ", mean(skipmissing(data[!, :SFN])))
else
    println("No non-missing values in SFN")
end

# Step 2: Impute missing values with group median
# Compute median SFN for each Clinical_Group
group_medians = combine(groupby(data, :Clinical_Group), :SFN => (x -> median(skipmissing(x))) => :SFN_median)

# Create a dictionary for group medians
median_dict = Dict(row.Clinical_Group => row.SFN_median for row in eachrow(group_medians))

# Print medians for verification
println("\nMedian SFN by Clinical_Group:")
println(median_dict)

# Function to impute missing SFN based on group median
function impute_sfn(row)
    if ismissing(row.SFN)
        return median_dict[row.Clinical_Group]
    else
        return row.SFN
    end
end

# Apply imputation
data[!, :SFN] = impute_sfn.(eachrow(data))

# Step 3: Verify changes
println("\nSummary of SFN after imputation:")
println("Missing values in SFN: ", sum(ismissing.(data[!, :SFN])))
println("Non-missing SFN values (min, max, mean):")
println("Min: ", minimum(data[!, :SFN]))
println("Max: ", maximum(data[!, :SFN]))
println("Mean: ", mean(data[!, :SFN]))

# Display first 5 rows to verify SFN
println("\nFirst 5 rows of the dataset (selected columns):")
select(data, [:Patient_ID, :Clinical_Group, :Hornerin, :SFN, :Albuminuria]) |> x -> show(first(x, 5), allcols=true)

# Optional: Save the updated DataFrame
# CSV.write("diabetic_retinopathy_cleaned_step3.csv", data)

# using DataFrames
# using Statistics
# using StatsBase

# Step 1: Inspect Age column
println("Summary of Age before imputation:")
println("Missing values in Age: ", sum(ismissing.(data[!, :Age])))
println("Non-missing Age values (min, max, mean):")
if sum(.!ismissing.(data[!, :Age])) > 0
    println("Min: ", minimum(skipmissing(data[!, :Age])))
    println("Max: ", maximum(skipmissing(data[!, :Age])))
    println("Mean: ", mean(skipmissing(data[!, :Age])))
else
    println("No non-missing values in Age")
end

# Step 2: Impute missing values with group median
# Compute median Age for each Clinical_Group
group_medians = combine(groupby(data, :Clinical_Group), :Age => (x -> median(skipmissing(x))) => :Age_median)

# Create a dictionary for group medians
median_dict = Dict(row.Clinical_Group => row.Age_median for row in eachrow(group_medians))

# Print medians for verification
println("\nMedian Age by Clinical_Group:")
println(median_dict)

# Function to impute missing Age based on group median
function impute_age(row)
    if ismissing(row.Age)
        return Int(round(median_dict[row.Clinical_Group]))  # Round to nearest integer
    else
        return row.Age
    end
end

# Apply imputation
data[!, :Age] = impute_age.(eachrow(data))

# Step 3: Verify changes
println("\nSummary of Age after imputation:")
println("Missing values in Age: ", sum(ismissing.(data[!, :Age])))
println("Non-missing Age values (min, max, mean):")
println("Min: ", minimum(data[!, :Age]))
println("Max: ", maximum(data[!, :Age]))
println("Mean: ", mean(data[!, :Age]))

# Display first 5 rows to verify Age
println

using DataFrames
using Statistics
using StatsBase

# Step 1: Inspect Diabetic_Duration column
println("Summary of Diabetic_Duration before imputation:")
println("Missing values in Diabetic_Duration: ", sum(ismissing.(data[!, :Diabetic_Duration])))
println("Non-missing Diabetic_Duration values (min, max, mean):")
if sum(.!ismissing.(data[!, :Diabetic_Duration])) > 0
    println("Min: ", minimum(skipmissing(data[!, :Diabetic_Duration])))
    println("Max: ", maximum(skipmissing(data[!, :Diabetic_Duration])))
    println("Mean: ", mean(skipmissing(data[!, :Diabetic_Duration])))
else
    println("No non-missing values in Diabetic_Duration")
end

# Step 2: Impute missing values with group median
# Compute median Diabetic_Duration for each Clinical_Group
group_medians = combine(groupby(data, :Clinical_Group), :Diabetic_Duration => (x -> median(skipmissing(x))) => :Diabetic_Duration_median)

# Create a dictionary for group medians
median_dict = Dict(row.Clinical_Group => row.Diabetic_Duration_median for row in eachrow(group_medians))

# Print medians for verification
println("\nMedian Diabetic_Duration by Clinical_Group:")
println(median_dict)

# Function to impute missing Diabetic_Duration based on group median
function impute_diabetic_duration(row)
    if ismissing(row.Diabetic_Duration)
        return round(median_dict[row.Clinical_Group], digits=1)  # Round to 1 decimal place
    else
        return row.Diabetic_Duration
    end
end

# Apply imputation
data[!, :Diabetic_Duration] = impute_diabetic_duration.(eachrow(data))

# Step 3: Verify changes
println("\nSummary of Diabetic_Duration after imputation:")
println("Missing values in Diabetic_Duration: ", sum(ismissing.(data[!, :Diabetic_Duration])))
println("Non-missing Diabetic_Duration values (min, max, mean):")
println("Min: ", minimum(data[!, :Diabetic_Duration]))
println("Max: ", maximum(data[!, :Diabetic_Duration]))
println("Mean: ", mean(data[!, :Diabetic_Duration]))

# Display first 5 rows to verify Diabetic_Duration
println("\nFirst 5 rows of the dataset (selected columns):")
select(data, [:Patient_ID, :Clinical_Group, :Hornerin, :SFN, :Age, :Diabetic_Duration, :Albuminuria]) |> x -> show(first(x, 5), allcols=true)

# Optional: Save the updated DataFrame
# CSV.write("diabetic_retinopathy_cleaned_step3.csv", data)

using DataFrames
using Statistics
using StatsBase

# Step 1: Inspect eGFR column
println("Summary of eGFR before imputation:")
println("Missing values in eGFR: ", sum(ismissing.(data[!, :eGFR])))
println("Non-missing eGFR values (min, max, mean):")
if sum(.!ismissing.(data[!, :eGFR])) > 0
    println("Min: ", minimum(skipmissing(data[!, :eGFR])))
    println("Max: ", maximum(skipmissing(data[!, :eGFR])))
    println("Mean: ", mean(skipmissing(data[!, :eGFR])))
else
    println("No non-missing values in eGFR")
end

# Step 2: Impute missing values with group median
# Compute median eGFR for each Clinical_Group
group_medians = combine(groupby(data, :Clinical_Group), :eGFR => (x -> median(skipmissing(x))) => :eGFR_median)

# Create a dictionary for group medians
median_dict = Dict(row.Clinical_Group => row.eGFR_median for row in eachrow(group_medians))

# Print medians for verification
println("\nMedian eGFR by Clinical_Group:")
println(median_dict)

# Function to impute missing eGFR based on group median
function impute_egfr(row)
    if ismissing(row.eGFR)
        return Int(round(median_dict[row.Clinical_Group]))  # Round to nearest integer
    else
        return row.eGFR
    end
end

# Apply imputation
data[!, :eGFR] = impute_egfr.(eachrow(data))

# Step 3: Verify changes
println("\nSummary of eGFR after imputation:")
println("Missing values in eGFR: ", sum(ismissing.(data[!, :eGFR])))
println("Non-missing eGFR values (min, max, mean):")
println("Min: ", minimum(data[!, :eGFR]))
println("Max: ", maximum(data[!, :eGFR]))
println("Mean: ", mean(data[!, :eGFR]))

# Display first 5 rows to verify eGFR
println("\nFirst 5 rows of the dataset (selected columns):")
select(data, [:Patient_ID, :Clinical_Group, :Hornerin, :SFN, :Age, :Diabetic_Duration, :eGFR, :Albuminuria]) |> x -> show(first(x, 5), allcols=true)

# Optional: Save the updated DataFrame
# CSV.write("diabetic_retinopathy_cleaned_step3.csv", data)

using DataFrames
using Statistics
using StatsBase

# Step 1: Inspect EAG column
println("Summary of EAG before imputation:")
println("Missing values in EAG: ", sum(ismissing.(data[!, :EAG])))
println("Non-missing EAG values (min, max, mean):")
if sum(.!ismissing.(data[!, :EAG])) > 0
    println("Min: ", minimum(skipmissing(data[!, :EAG])))
    println("Max: ", maximum(skipmissing(data[!, :EAG])))
    println("Mean: ", mean(skipmissing(data[!, :EAG])))
else
    println("No non-missing values in EAG")
end

# Step 2: Impute missing values with group median
# Compute median EAG for each Clinical_Group
group_medians = combine(groupby(data, :Clinical_Group), :EAG => (x -> median(skipmissing(x))) => :EAG_median)

# Create a dictionary for group medians
median_dict = Dict(row.Clinical_Group => row.EAG_median for row in eachrow(group_medians))

# Print medians for verification
println("\nMedian EAG by Clinical_Group:")
println(median_dict)

# Function to impute missing EAG based on group median
function impute_eag(row)
    if ismissing(row.EAG)
        return Int(round(median_dict[row.Clinical_Group]))  # Round to nearest integer
    else
        return row.EAG
    end
end

# Apply imputation
data[!, :EAG] = impute_eag.(eachrow(data))

# Step 3: Verify changes
println("\nSummary of EAG after imputation:")
println("Missing values in EAG: ", sum(ismissing.(data[!, :EAG])))
println("Non-missing EAG values (min, max, mean):")
println("Min: ", minimum(data[!, :EAG]))
println("Max: ", maximum(data[!, :EAG]))
println("Mean: ", mean(data[!, :EAG]))

# Display first 5 rows to verify EAG
println("\nFirst 5 rows of the dataset (selected columns):")
select(data, [:Patient_ID, :Clinical_Group, :Hornerin, :SFN, :Age, :Diabetic_Duration, :eGFR, :HB, :EAG, :Albuminuria]) |> x -> show(first(x, 5), allcols=true)

# Optional: Save the updated DataFrame
# CSV.write("diabetic_retinopathy_cleaned_step3.csv", data)

using DataFrames
using Statistics
using StatsBase

# Step 1: Inspect FBS column
println("Summary of FBS before imputation:")
println("Missing values in FBS: ", sum(ismissing.(data[!, :FBS])))
println("Non-missing FBS values (min, max, mean):")
if sum(.!ismissing.(data[!, :FBS])) > 0
    println("Min: ", minimum(skipmissing(data[!, :FBS])))
    println("Max: ", maximum(skipmissing(data[!, :FBS])))
    println("Mean: ", mean(skipmissing(data[!, :FBS])))
else
    println("No non-missing values in FBS")
end

# Step 2: Impute missing values with group median
# Compute median FBS for each Clinical_Group
group_medians = combine(groupby(data, :Clinical_Group), :FBS => (x -> median(skipmissing(x))) => :FBS_median)

# Create a dictionary for group medians
median_dict = Dict(row.Clinical_Group => row.FBS_median for row in eachrow(group_medians))

# Print medians for verification
println("\nMedian FBS by Clinical_Group:")
println(median_dict)

# Function to impute missing FBS based on group median
function impute_fbs(row)
    if ismissing(row.FBS)
        return Int(round(median_dict[row.Clinical_Group]))  # Round to nearest integer
    else
        return row.FBS
    end
end

# Apply imputation
data[!, :FBS] = impute_fbs.(eachrow(data))

# Step 3: Verify changes
println("\nSummary of FBS after imputation:")
println("Missing values in FBS: ", sum(ismissing.(data[!, :FBS])))
println("Non-missing FBS values (min, max, mean):")
println("Min: ", minimum(data[!, :FBS]))
println("Max: ", maximum(data[!, :FBS]))
println("Mean: ", mean(data[!, :FBS]))

# Display first 5 rows to verify FBS
println("\nFirst 5 rows of the dataset (selected columns):")
select(data, [:Patient_ID, :Clinical_Group, :Hornerin, :SFN, :Age, :Diabetic_Duration, :eGFR, :HB, :EAG, :FBS, :Albuminuria]) |> x -> show(first(x, 5), allcols=true)

# Optional: Save the updated DataFrame
# CSV.write("diabetic_retinopathy_cleaned_step3.csv", data)

using DataFrames
using Statistics
using StatsBase

# Step 1: Inspect RBS column
println("Summary of RBS before imputation:")
println("Missing values in RBS: ", sum(ismissing.(data[!, :RBS])))
println("Non-missing RBS values (min, max, mean):")
if sum(.!ismissing.(data[!, :RBS])) > 0
    println("Min: ", minimum(skipmissing(data[!, :RBS])))
    println("Max: ", maximum(skipmissing(data[!, :RBS])))
    println("Mean: ", mean(skipmissing(data[!, :RBS])))
else
    println("No non-missing values in RBS")
end

# Step 2: Impute missing values with group median
# Compute median RBS for each Clinical_Group
group_medians = combine(groupby(data, :Clinical_Group), :RBS => (x -> median(skipmissing(x))) => :RBS_median)

# Create a dictionary for group medians
median_dict = Dict(row.Clinical_Group => row.RBS_median for row in eachrow(group_medians))

# Print medians for verification
println("\nMedian RBS by Clinical_Group:")
println(median_dict)

# Function to impute missing RBS based on group median
function impute_rbs(row)
    if ismissing(row.RBS)
        return Int(round(median_dict[row.Clinical_Group]))  # Round to nearest integer
    else
        return row.RBS
    end
end

# Apply imputation
data[!, :RBS] = impute_rbs.(eachrow(data))

# Step 3: Verify changes
println("\nSummary of RBS after imputation:")
println("Missing values in RBS: ", sum(ismissing.(data[!, :RBS])))
println("RBS values (min, max, mean after imputation):")
println("Min: ", minimum(data[!, :RBS]))
println("Max: ", maximum(data[!, :RBS]))
println("Mean: ", mean(data[!, :RBS]))

# Display first 5 rows to verify RBS
println("\nFirst 5 rows of the dataset (selected columns):")
select(data, [:Patient_ID, :Clinical_Group, :Hornerin, :SFN, :Age, :Diabetic_Duration, :eGFR, :HB, :EAG, :FBS, :RBS, :Albuminuria]) |> x -> show(first(x, 5), allcols=true)

# Optional: Save the updated DataFrame
# CSV.write("diabetic_retinopathy_cleaned_step3.csv", data)

using DataFrames
using Statistics
using StatsBase

# Step 1: Inspect HbA1C column
println("Summary of HbA1C before imputation:")
println("Missing values in HbA1C: ", sum(ismissing.(data[!, :HbA1C])))
println("Non-missing HbA1C values (min, max, mean):")
if sum(.!ismissing.(data[!, :HbA1C])) > 0
    println("Min: ", minimum(skipmissing(data[!, :HbA1C])))
    println("Max: ", maximum(skipmissing(data[!, :HbA1C])))
    println("Mean: ", mean(skipmissing(data[!, :HbA1C])))
else
    println("No non-missing values in HbA1C")
end

# Step 2: Impute missing values with group median
# Compute median HbA1C for each Clinical_Group
group_medians = combine(groupby(data, :Clinical_Group), :HbA1C => (x -> median(skipmissing(x))) => :HbA1C_median)

# Create a dictionary for group medians
median_dict = Dict(row.Clinical_Group => row.HbA1C_median for row in eachrow(group_medians))

# Print medians for verification
println("\nMedian HbA1C by Clinical_Group:")
println(median_dict)

# Function to impute missing HbA1C based on group median
function impute_hba1c(row)
    if ismissing(row.HbA1C)
        return round(median_dict[row.Clinical_Group], digits=1)  # Round to 1 decimal place
    else
        return row.HbA1C
    end
end

# Apply imputation
data[!, :HbA1C] = impute_hba1c.(eachrow(data))

# Step 3: Verify changes
println("\nSummary of HbA1C after imputation:")
println("Missing values in HbA1C: ", sum(ismissing.(data[!, :HbA1C])))
println("HbA1C values (min, max, mean after imputation):")
println("Min: ", minimum(data[!, :HbA1C]))
println("Max: ", maximum(data[!, :HbA1C]))
println("Mean: ", mean(data[!, :HbA1C]))

# Display first 5 rows to verify HbA1C
println("\nFirst 5 rows of the dataset (selected columns):")
select(data, [:Patient_ID, :Clinical_Group, :Hornerin, :SFN, :Age, :Diabetic_Duration, :eGFR, :HB, :EAG, :FBS, :RBS, :HbA1C, :Albuminuria]) |> x -> show(first(x, 5), allcols=true)

# Optional: Save the updated DataFrame
# CSV.write("diabetic_retinopathy_cleaned_step3.csv", data)

using DataFrames
using Statistics
using StatsBase

# Step 1: Inspect Systolic_BP column
println("Summary of Systolic_BP before imputation:")
println("Missing values in Systolic_BP: ", sum(ismissing.(data[!, :Systolic_BP])))
println("Non-missing Systolic_BP values (min, max, mean):")
if sum(.!ismissing.(data[!, :Systolic_BP])) > 0
    println("Min: ", minimum(skipmissing(data[!, :Systolic_BP])))
    println("Max: ", maximum(skipmissing(data[!, :Systolic_BP])))
    println("Mean: ", mean(skipmissing(data[!, :Systolic_BP])))
else
    println("No non-missing values in Systolic_BP")
end

# Step 2: Impute missing values with group median
# Compute median Systolic_BP for each Clinical_Group
group_medians = combine(groupby(data, :Clinical_Group), :Systolic_BP => (x -> median(skipmissing(x))) => :Systolic_BP_median)

# Create a dictionary for group medians
median_dict = Dict(row.Clinical_Group => row.Systolic_BP_median for row in eachrow(group_medians))

# Print medians for verification
println("\nMedian Systolic_BP by Clinical_Group:")
println(median_dict)

# Function to impute missing Systolic_BP based on group median
function impute_systolic_bp(row)
    if ismissing(row.Systolic_BP)
        return Int(round(median_dict[row.Clinical_Group]))  # Round to nearest integer
    else
        return row.Systolic_BP
    end
end

# Apply imputation
data[!, :Systolic_BP] = impute_systolic_bp.(eachrow(data))

# Step 3: Verify changes
println("\nSummary of Systolic_BP after imputation:")
println("Missing values in Systolic_BP: ", sum(ismissing.(data[!, :Systolic_BP])))
println("Systolic_BP values (min, max, mean after imputation):")
println("Min: ", minimum(data[!, :Systolic_BP]))
println("Max: ", maximum(data[!, :Systolic_BP]))
println("Mean: ", mean(data[!, :Systolic_BP]))

# Display first 5 rows to verify Systolic_BP
println("\nFirst 5 rows of the dataset (selected columns):")
select(data, [:Patient_ID, :Clinical_Group, :Hornerin, :SFN, :Age, :Diabetic_Duration, :eGFR, :HB, :EAG, :FBS, :RBS, :HbA1C, :Systolic_BP, :Albuminuria]) |> x -> show(first(x, 5), allcols=true)

# Optional: Save the updated DataFrame
# CSV.write("diabetic_retinopathy_cleaned_step2.csv", data)

using DataFrames
using Statistics
using StatsBase

# Step 1: Inspect Diastolic_BP column
println("Summary of Diastolic_BP before imputation:")
println("Missing values in Diastolic_BP: ", sum(ismissing.(data[!, :Diastolic_BP])))
println("Non-missing Diastolic_BP values (min, max, mean):")
if sum(.!ismissing.(data[!, :Diastolic_BP])) > 0
    println("Min: ", minimum(skipmissing(data[!, :Diastolic_BP])))
    println("Max: ", maximum(skipmissing(data[!, :Diastolic_BP])))
    println("Mean: ", mean(skipmissing(data[!, :Diastolic_BP])))
else
    println("No non-missing values in Diastolic_BP")
end

# Step 2: Impute missing values with group median
# Compute median Diastolic_BP for each Clinical_Group
group_medians = combine(groupby(data, :Clinical_Group), :Diastolic_BP => (x -> median(skipmissing(x))) => :Diastolic_BP_median)

# Create a dictionary for group medians
median_dict = Dict(row.Clinical_Group => row.Diastolic_BP_median for row in eachrow(group_medians))

# Print medians for verification
println("\nMedian Diastolic_BP by Clinical_Group:")
println(median_dict)

# Function to impute missing Diastolic_BP based on group median
function impute_diastolic_bp(row)
    if ismissing(row.Diastolic_BP)
        return Int(round(median_dict[row.Clinical_Group]))  # Round to nearest integer
    else
        return row.Diastolic_BP
    end
end

# Apply imputation
data[!, :Diastolic_BP] = impute_diastolic_bp.(eachrow(data))

# Step 3: Verify changes
println("\nSummary of Diastolic_BP after imputation:")
println("Missing values in Diastolic_BP: ", sum(ismissing.(data[!, :Diastolic_BP])))
println("Diastolic_BP values (min, max, mean after imputation):")
println("Min: ", minimum(data[!, :Diastolic_BP]))
println("Max: ", maximum(data[!, :Diastolic_BP]))
println("Mean: ", mean(data[!, :Diastolic_BP]))

# Display first 5 rows to verify Diastolic_BP
println("\nFirst 5 rows of the dataset (selected columns):")
select(data, [:Patient_ID, :Clinical_Group, :Hornerin, :SFN, :Age, :Diabetic_Duration, :eGFR, :HB, :EAG, :FBS, :RBS, :HbA1C, :Systolic_BP, :Diastolic_BP, :Albuminuria]) |> x -> show(first(x, 5), allcols=true)

# Optional: Save the updated DataFrame
# CSV.write("diabetic_retinopathy_cleaned_step3.csv", data)

using DataFrames
using Statistics
using StatsBase

# Step 1: Inspect BUN column
println("Summary of BUN before imputation:")
println("Missing values in BUN: ", sum(ismissing.(data[!, :BUN])))
println("Non-missing BUN values (min, max, mean):")
if sum(.!ismissing.(data[!, :BUN])) > 0
    println("Min: ", minimum(skipmissing(data[!, :BUN])))
    println("Max: ", maximum(skipmissing(data[!, :BUN])))
    println("Mean: ", mean(skipmissing(data[!, :BUN])))
else
    println("No non-missing values in BUN")
end

# Step 2: Impute missing values with group median
# Compute median BUN for each Clinical_Group
group_medians = combine(groupby(data, :Clinical_Group), :BUN => (x -> median(skipmissing(x))) => :BUN_median)

# Create a dictionary for group medians
median_dict = Dict(row.Clinical_Group => row.BUN_median for row in eachrow(group_medians))

# Print medians for verification
println("\nMedian BUN by Clinical_Group:")
println(median_dict)

# Function to impute missing BUN based on group median
function impute_bun(row)
    if ismissing(row.BUN)
        return round(median_dict[row.Clinical_Group], digits=1)  # Round to 1 decimal place
    else
        return row.BUN
    end
end

# Apply imputation
data[!, :BUN] = impute_bun.(eachrow(data))

# Step 3: Verify changes
println("\nSummary of BUN after imputation:")
println("Missing values in BUN: ", sum(ismissing.(data[!, :BUN])))
println("BUN values (min, max, mean after imputation):")
println("Min: ", minimum(data[!, :BUN]))
println("Max: ", maximum(data[!, :BUN]))
println("Mean: ", mean(data[!, :BUN]))

# Display first 5 rows to verify BUN
println("\nFirst 5 rows of the dataset (selected columns):")
select(data, [:Patient_ID, :Clinical_Group, :Hornerin, :SFN, :Age, :Diabetic_Duration, :eGFR, :HB, :EAG, :FBS, :RBS, :HbA1C, :Systolic_BP, :Diastolic_BP, :BUN, :Albuminuria]) |> x -> show(first(x, 5), allcols=true)

# Optional: Save the updated DataFrame
# CSV.write("diabetic_retinopathy_cleaned_step3.csv", data)

using DataFrames
using Statistics
using StatsBase

# Step 1: Inspect Total_Protein column
println("Summary of Total_Protein before imputation:")
println("Missing values in Total_Protein: ", sum(ismissing.(data[!, :Total_Protein])))
println("Non-missing Total_Protein values (min, max, mean):")
if sum(.!ismissing.(data[!, :Total_Protein])) > 0
    println("Min: ", minimum(skipmissing(data[!, :Total_Protein])))
    println("Max: ", maximum(skipmissing(data[!, :Total_Protein])))
    println("Mean: ", mean(skipmissing(data[!, :Total_Protein])))
else
    println("No non-missing values in Total_Protein")
end

# Step 2: Impute missing values with group median
# Compute median Total_Protein for each Clinical_Group
group_medians = combine(groupby(data, :Clinical_Group), :Total_Protein => (x -> median(skipmissing(x))) => :Total_Protein_median)

# Create a dictionary for group medians
median_dict = Dict(row.Clinical_Group => row.Total_Protein_median for row in eachrow(group_medians))

# Print medians for verification
println("\nMedian Total_Protein by Clinical_Group:")
println(median_dict)

# Function to impute missing Total_Protein based on group median
function impute_total_protein(row)
    if ismissing(row.Total_Protein)
        return round(median_dict[row.Clinical_Group], digits=1)  # Corrected bracket
    else
        return row.Total_Protein
    end
end

# Apply imputation
data[!, :Total_Protein] = impute_total_protein.(eachrow(data))

# Step 3: Verify changes
println("\nSummary of Total_Protein after imputation:")
println("Missing values in Total_Protein: ", sum(ismissing.(data[!, :Total_Protein])))
println("Total_Protein values (min, max, mean after imputation):")
println("Min: ", minimum(data[!, :Total_Protein]))
println("Max: ", maximum(data[!, :Total_Protein]))
println("Mean: ", mean(data[!, :Total_Protein]))

# Display first 5 rows to verify Total_Protein
println("\nFirst 5 rows of the dataset (selected columns):")
select(data, [:Patient_ID, :Clinical_Group, :Hornerin, :SFN, :Age, :Diabetic_Duration, :eGFR, :HB, :EAG, :FBS, :RBS, :HbA1C, :Systolic_BP, :Diastolic_BP, :BUN, :Total_Protein, :Albuminuria]) |> x -> show(first(x, 5), allcols=true)

# Optional: Save the updated DataFrame
# CSV.write("diabetic_retinopathy_cleaned_step3.csv", data)

using DataFrames
using Statistics
using StatsBase

# Step 1: Inspect Serum_Albumin column
println("Summary of Serum_Albumin before imputation:")
println("Missing values in Serum_Albumin: ", sum(ismissing.(data[!, :Serum_Albumin])))
println("Non-missing Serum_Albumin values (min, max, mean):")
if sum(.!ismissing.(data[!, :Serum_Albumin])) > 0
    println("Min: ", minimum(skipmissing(data[!, :Serum_Albumin])))
    println("Max: ", maximum(skipmissing(data[!, :Serum_Albumin])))
    println("Mean: ", mean(skipmissing(data[!, :Serum_Albumin])))
else
    println("No non-missing values in Serum_Albumin")
end

# Step 2: Impute missing values with group median
# Compute median Serum_Albumin for each Clinical_Group
group_medians = combine(groupby(data, :Clinical_Group), :Serum_Albumin => (x -> median(skipmissing(x))) => :Serum_Albumin_median)

# Create a dictionary for group medians
median_dict = Dict(row.Clinical_Group => row.Serum_Albumin_median for row in eachrow(group_medians))

# Print medians for verification
println("\nMedian Serum_Albumin by Clinical_Group:")
println(median_dict)

# Function to impute missing Serum_Albumin based on group median
function impute_serum_albumin(row)
    if ismissing(row.Serum_Albumin)
        return round(median_dict[row.Clinical_Group], digits=1)  # Round to 1 decimal place
    else
        return row.Serum_Albumin
    end
end

# Apply imputation
data[!, :Serum_Albumin] = impute_serum_albumin.(eachrow(data))

# Step 3: Verify changes
println("\nSummary of Serum_Albumin after imputation:")
println("Missing values in Serum_Albumin: ", sum(ismissing.(data[!, :Serum_Albumin])))
println("Serum_Albumin values (min, max, mean after imputation):")
println("Min: ", minimum(data[!, :Serum_Albumin]))
println("Max: ", maximum(data[!, :Serum_Albumin]))
println("Mean: ", mean(data[!, :Serum_Albumin]))

# Display first 5 rows to verify Serum_Albumin
println("\nFirst 5 rows of the dataset (selected columns):")
select(data, [:Patient_ID, :Clinical_Group, :Hornerin, :SFN, :Age, :Diabetic_Duration, :eGFR, :HB, :EAG, :FBS, :RBS, :HbA1C, :Systolic_BP, :Diastolic_BP, :BUN, :Total_Protein, :Serum_Albumin, :Albuminuria]) |> x -> show(first(x, 5), allcols=true)

# Optional: Save the updated DataFrame
# CSV.write("diabetic_retinopathy_cleaned_step3.csv", data)

using DataFrames
using Statistics
using StatsBase

# Step 1: Inspect Serum_Creatinine column
println("Summary of Serum_Creatinine before imputation:")
println("Missing values in Serum_Creatinine: ", sum(ismissing.(data[!, :Serum_Creatinine])))
println("Non-missing Serum_Creatinine values (min, max, mean):")
if sum(.!ismissing.(data[!, :Serum_Creatinine])) > 0
    println("Min: ", minimum(skipmissing(data[!, :Serum_Creatinine])))
    println("Max: ", maximum(skipmissing(data[!, :Serum_Creatinine])))
    println("Mean: ", mean(skipmissing(data[!, :Serum_Creatinine])))
else
    println("No non-missing values in Serum_Creatinine")
end

# Step 2: Impute missing values with group median
# Compute median Serum_Creatinine for each Clinical_Group
group_medians = combine(groupby(data, :Clinical_Group), :Serum_Creatinine => (x -> median(skipmissing(x))) => :Serum_Creatinine_median)

# Create a dictionary for group medians
median_dict = Dict(row.Clinical_Group => row.Serum_Creatinine_median for row in eachrow(group_medians))

# Print medians for verification
println("\nMedian Serum_Creatinine by Clinical_Group:")
println(median_dict)

# Function to impute missing Serum_Creatinine based on group median
function impute_serum_creatinine(row)
    if ismissing(row.Serum_Creatinine)
        return round(median_dict[row.Clinical_Group], digits=1)  # Round to 1 decimal place
    else
        return row.Serum_Creatinine
    end
end

# Apply imputation
data[!, :Serum_Creatinine] = impute_serum_creatinine.(eachrow(data))

# Step 3: Verify changes
println("\nSummary of Serum_Creatinine after imputation:")
println("Missing values in Serum_Creatinine: ", sum(ismissing.(data[!, :Serum_Creatinine])))
println("Serum_Creatinine values (min, max, mean after imputation):")
println("Min: ", minimum(data[!, :Serum_Creatinine]))
println("Max: ", maximum(data[!, :Serum_Creatinine]))
println("Mean: ", mean(data[!, :Serum_Creatinine]))

# Display first 5 rows to verify Serum_Creatinine
println("\nFirst 5 rows of the dataset (selected columns):")
select(data, [:Patient_ID, :Clinical_Group, :Hornerin, :SFN, :Age, :Diabetic_Duration, :eGFR, :HB, :EAG, :FBS, :RBS, :HbA1C, :Systolic_BP, :Diastolic_BP, :BUN, :Total_Protein, :Serum_Albumin, :Serum_Creatinine, :Albuminuria]) |> x -> show(first(x, 5), allcols=true)

# Optional: Save the updated DataFrame
# CSV.write("diabetic_retinopathy_cleaned_step3.csv", data)

using DataFrames
using Statistics
using StatsBase

# Step 1: Inspect CHOL column
println("Summary of CHOL before imputation:")
println("Missing values in CHOL: ", sum(ismissing.(data[!, :CHOL])))
println("Non-missing CHOL values (min, max, mean):")
if sum(.!ismissing.(data[!, :CHOL])) > 0
    println("Min: ", minimum(skipmissing(data[!, :CHOL])))
    println("Max: ", maximum(skipmissing(data[!, :CHOL])))
    println("Mean: ", mean(skipmissing(data[!, :CHOL])))
else
    println("No non-missing values in CHOL")
end

# Step 2: Impute missing values with group median
# Compute median CHOL for each Clinical_Group
group_medians = combine(groupby(data, :Clinical_Group), :CHOL => (x -> median(skipmissing(x))) => :CHOL_median)

# Create a dictionary for group medians
median_dict = Dict(row.Clinical_Group => row.CHOL_median for row in eachrow(group_medians))

# Print medians for verification
println("\nMedian CHOL by Clinical_Group:")
println(median_dict)

# Function to impute missing CHOL based on group median
function impute_chol(row)
    if ismissing(row.CHOL)
        return Int(round(median_dict[row.Clinical_Group]))  # Round to nearest integer
    else
        return row.CHOL
    end
end

# Apply imputation
data[!, :CHOL] = impute_chol.(eachrow(data))

# Step 3: Verify changes
println("\nSummary of CHOL after imputation:")
println("Missing values in CHOL: ", sum(ismissing.(data[!, :CHOL])))
println("CHOL values (min, max, mean after imputation):")
println("Min: ", minimum(data[!, :CHOL]))
println("Max: ", maximum(data[!, :CHOL]))
println("Mean: ", mean(data[!, :CHOL]))

# Display first 5 rows to verify CHOL
println("\nFirst 5 rows of the dataset (selected columns):")
select(data, [:Patient_ID, :Clinical_Group, :Hornerin, :SFN, :Age, :Diabetic_Duration, :eGFR, :HB, :EAG, :FBS, :RBS, :HbA1C, :Systolic_BP, :Diastolic_BP, :BUN, :Total_Protein, :Serum_Albumin, :Serum_Creatinine, :CHOL, :Albuminuria]) |> x -> show(first(x, 5), allcols=true)

# Optional: Save the updated DataFrame
# CSV.write("diabetic_retinopathy_cleaned_step3.csv", data)

using DataFrames
using Statistics
using StatsBase

# Step 1: Inspect TG column
println("Summary of TG before imputation:")
println("Missing values in TG: ", sum(ismissing.(data[!, :TG])))
println("Non-missing TG values (min, max, mean):")
if sum(.!ismissing.(data[!, :TG])) > 0
    println("Min: ", minimum(skipmissing(data[!, :TG])))
    println("Max: ", maximum(skipmissing(data[!, :TG])))
    println("Mean: ", mean(skipmissing(data[!, :TG])))
else
    println("No non-missing values in TG")
end

# Step 2: Impute missing values with group median
# Compute median TG for each Clinical_Group
group_medians = combine(groupby(data, :Clinical_Group), :TG => (x -> median(skipmissing(x))) => :TG_median)

# Create a dictionary for group medians
median_dict = Dict(row.Clinical_Group => row.TG_median for row in eachrow(group_medians))

# Print medians for verification
println("\nMedian TG by Clinical_Group:")
println(median_dict)

# Function to impute missing TG based on group median
function impute_tg(row)
    if ismissing(row.TG)
        return Int(round(median_dict[row.Clinical_Group]))  # Round to nearest integer
    else
        return row.TG
    end
end

# Apply imputation
data[!, :TG] = impute_tg.(eachrow(data))

# Step 3: Verify changes
println("\nSummary of TG after imputation:")
println("Missing values in TG: ", sum(ismissing.(data[!, :TG])))
println("TG values (min, max, mean after imputation):")
println("Min: ", minimum(data[!, :TG]))
println("Max: ", maximum(data[!, :TG]))
println("Mean: ", mean(data[!, :TG]))

# Display first 5 rows to verify TG
println("\nFirst 5 rows of the dataset (selected columns):")
select(data, [:Patient_ID, :Clinical_Group, :Hornerin, :SFN, :Age, :Diabetic_Duration, :eGFR, :HB, :EAG, :FBS, :RBS, :HbA1C, :Systolic_BP, :Diastolic_BP, :BUN, :Total_Protein, :Serum_Albumin, :Serum_Creatinine, :CHOL, :TG, :Albuminuria]) |> x -> show(first(x, 5), allcols=true)

# Optional: Save the updated DataFrame
# CSV.write("diabetic_retinopathy_cleaned_step3.csv", data)

using DataFrames
using Statistics
using StatsBase

# Step 1: Inspect HDL column
println("Summary of HDL before imputation:")
println("Missing values in HDL: ", sum(ismissing.(data[!, :HDL])))
println("Non-missing HDL values (min, max, mean):")
if sum(.!ismissing.(data[!, :HDL])) > 0
    println("Min: ", minimum(skipmissing(data[!, :HDL])))
    println("Max: ", maximum(skipmissing(data[!, :HDL])))
    println("Mean: ", mean(skipmissing(data[!, :HDL])))
else
    println("No non-missing values in HDL")
end

# Step 2: Impute missing values with group median
# Compute median HDL for each Clinical_Group
group_medians = combine(groupby(data, :Clinical_Group), :HDL => (x -> median(skipmissing(x))) => :HDL_median)

# Create a dictionary for group medians
median_dict = Dict(row.Clinical_Group => row.HDL_median for row in eachrow(group_medians))

# Print medians for verification
println("\nMedian HDL by Clinical_Group:")
println(median_dict)

# Function to impute missing HDL based on group median
function impute_hdl(row)
    if ismissing(row.HDL)
        return Int(round(median_dict[row.Clinical_Group]))  # Round to nearest integer
    else
        return row.HDL
    end
end

# Apply imputation
data[!, :HDL] = impute_hdl.(eachrow(data))

# Step 3: Verify changes
println("\nSummary of HDL after imputation:")
println("Missing values in HDL: ", sum(ismissing.(data[!, :HDL])))
println("HDL values (min, max, mean after imputation):")
println("Min: ", minimum(data[!, :HDL]))
println("Max: ", maximum(data[!, :HDL]))
println("Mean: ", mean(data[!, :HDL]))

# Display first 5 rows to verify HDL
println("\nFirst 5 rows of the dataset (selected columns):")
select(data, [:Patient_ID, :Clinical_Group, :Hornerin, :SFN, :Age, :Diabetic_Duration, :eGFR, :HB, :EAG, :FBS, :RBS, :HbA1C, :Systolic_BP, :Diastolic_BP, :BUN, :Total_Protein, :Serum_Albumin, :Serum_Creatinine, :CHOL, :TG, :HDL, :Albuminuria]) |> x -> show(first(x, 5), allcols=true)

# Optional: Save the updated DataFrame
# CSV.write("diabetic_retinopathy_cleaned_step3.csv", data)

using DataFrames
using Statistics
using StatsBase

# Step 1: Inspect LDL column
println("Summary of LDL before imputation:")
println("Missing values in LDL: ", sum(ismissing.(data[!, :LDL])))
println("Non-missing LDL values (min, max, mean):")
if sum(.!ismissing.(data[!, :LDL])) > 0
    println("Min: ", minimum(skipmissing(data[!, :LDL])))
    println("Max: ", maximum(skipmissing(data[!, :LDL])))
    println("Mean: ", mean(skipmissing(data[!, :LDL])))
else
    println("No non-missing values in LDL")
end

# Step 2: Impute missing values with group median
# Compute median LDL for each Clinical_Group
group_medians = combine(groupby(data, :Clinical_Group), :LDL => (x -> median(skipmissing(x))) => :LDL_median)

# Create a dictionary for group medians
median_dict = Dict(row.Clinical_Group => row.LDL_median for row in eachrow(group_medians))

# Print medians for verification
println("\nMedian LDL by Clinical_Group:")
println(median_dict)

# Function to impute missing LDL based on group median
function impute_ldl(row)
    if ismissing(row.LDL)
        return Int(round(median_dict[row.Clinical_Group]))  # Round to nearest integer
    else
        return row.LDL
    end
end

# Apply imputation
data[!, :LDL] = impute_ldl.(eachrow(data))

# Step 3: Verify changes
println("\nSummary of LDL after imputation:")
println("Missing values in LDL: ", sum(ismissing.(data[!, :LDL])))
println("LDL values (min, max, mean after imputation):")
println("Min: ", minimum(data[!, :LDL]))
println("Max: ", maximum(data[!, :LDL]))
println("Mean: ", mean(data[!, :LDL]))

# Display first 5 rows to verify LDL
println("\nFirst 5 rows of the dataset (selected columns):")
select(data, [:Patient_ID, :Clinical_Group, :Hornerin, :SFN, :Age, :Diabetic_Duration, :eGFR, :HB, :EAG, :FBS, :RBS, :HbA1C, :Systolic_BP, :Diastolic_BP, :BUN, :Total_Protein, :Serum_Albumin, :Serum_Creatinine, :CHOL, :TG, :HDL, :LDL, :Albuminuria]) |> x -> show(first(x, 5), allcols=true)

# Optional: Save the updated DataFrame
# CSV.write("diabetic_retinopathy_cleaned_step3.csv", data)

using DataFrames
using Statistics
using StatsBase

# Step 1: Inspect Chol_HDL_ratio column
println("Summary of Chol_HDL_ratio before imputation:")
println("Missing values in Chol_HDL_ratio: ", sum(ismissing.(data[!, :Chol_HDL_ratio])))
println("Non-missing Chol_HDL_ratio values (min, max, mean):")
if sum(.!ismissing.(data[!, :Chol_HDL_ratio])) > 0
    println("Min: ", minimum(skipmissing(data[!, :Chol_HDL_ratio])))
    println("Max: ", maximum(skipmissing(data[!, :Chol_HDL_ratio])))
    println("Mean: ", mean(skipmissing(data[!, :Chol_HDL_ratio])))
else
    println("No non-missing values in Chol_HDL_ratio")
end

# Step 2: Impute missing values with group median
# Compute median Chol_HDL_ratio for each Clinical_Group
group_medians = combine(groupby(data, :Clinical_Group), :Chol_HDL_ratio => (x -> median(skipmissing(x))) => :Chol_HDL_ratio_median)

# Create a dictionary for group medians
median_dict = Dict(row.Clinical_Group => row.Chol_HDL_ratio_median for row in eachrow(group_medians))

# Print medians for verification
println("\nMedian Chol_HDL_ratio by Clinical_Group:")
println(median_dict)

# Function to impute missing Chol_HDL_ratio based on group median
function impute_chol_hdl_ratio(row)
    if ismissing(row.Chol_HDL_ratio)
        return round(median_dict[row.Clinical_Group], digits=1)  # Round to 1 decimal place
    else
        return row.Chol_HDL_ratio
    end
end

# Apply imputation
data[!, :Chol_HDL_ratio] = impute_chol_hdl_ratio.(eachrow(data))

# Step 3: Verify changes
println("\nSummary of Chol_HDL_ratio after imputation:")
println("Missing values in Chol_HDL_ratio: ", sum(ismissing.(data[!, :Chol_HDL_ratio])))
println("Chol_HDL_ratio values (min, max, mean after imputation):")
println("Min: ", minimum(data[!, :Chol_HDL_ratio]))
println("Max: ", maximum(data[!, :Chol_HDL_ratio]))
println("Mean: ", mean(data[!, :Chol_HDL_ratio]))

# Display first 5 rows to verify Chol_HDL_ratio
println("\nFirst 5 rows of the dataset (selected columns):")
select(data, [:Patient_ID, :Clinical_Group, :Hornerin, :SFN, :Age, :Diabetic_Duration, :eGFR, :HB, :EAG, :FBS, :RBS, :HbA1C, :Systolic_BP, :Diastolic_BP, :BUN, :Total_Protein, :Serum_Albumin, :Serum_Creatinine, :CHOL, :TG, :HDL, :LDL, :Chol_HDL_ratio, :Albuminuria]) |> x -> show(first(x, 5), allcols=true)




# Step 1: Inspect HB column
println("Summary of HB before imputation:")
println("Missing values in HB: ", sum(ismissing.(data[!, :HB])))
println("Non-missing HB values (min, max, mean):")
if sum(.!ismissing.(data[!, :HB])) > 0
   println("Min: ", minimum(skipmissing(data[!, :HB])))
   println("Max: ", maximum(skipmissing(data[!, :HB])))
   println("Mean: ", mean(skipmissing(data[!, :HB])))
else
   println("No non-missing values in HB")
end


# Step 2: Impute missing values with group median
# Compute median HB for each Clinical_Group
group_medians = combine(groupby(data, :Clinical_Group), :HB => (x -> median(skipmissing(x))) => :HB_median)


# Create a dictionary for group medians
median_dict = Dict(row.Clinical_Group => row.HB_median for row in eachrow(group_medians))


# Print medians for verification
println("\nMedian HB by Clinical_Group:")
println(median_dict)


# Function to impute missing HB based on group median
function impute_HB(row)
   if ismissing(row.HB)
       return round(median_dict[row.Clinical_Group], digits=1)  # Round to 1 decimal place
   else
       return row.HB
   end
end


# Apply imputation
data[!, :HB] = impute_HB.(eachrow(data))


# Step 3: Verify changes
println("\nSummary of HB after imputation:")
println("Missing values in HB: ", sum(ismissing.(data[!, :HB])))
println("HB values (min, max, mean after imputation):")
println("Min: ", minimum(data[!, :HB]))
println("Max: ", maximum(data[!, :HB]))
println("Mean: ", mean(data[!, :HB]))


# Display first 5 rows to verify HB
println("\nFirst 5 rows of the dataset (selected columns):")
select(data, [:Patient_ID, :Clinical_Group, :Hornerin, :SFN, :Age, :Diabetic_Duration, :eGFR, :HB, :EAG, :FBS, :RBS, :HbA1C, :Systolic_BP, :Diastolic_BP, :BUN, :Total_Protein, :Serum_Albumin, :Serum_Creatinine, :CHOL, :TG, :HDL, :LDL, :Chol_HDL_ratio, :Albuminuria]) |> x -> show(first(x, 5), allcols=true)




# Optional: Save the updated DataFrame
CSV.write("diabetic_retinopathy_cleaned_step3.csv", data)