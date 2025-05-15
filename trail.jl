using CSV
using DataFrames
using Statistics
using PrettyTables

# Load the dataset with explicit numeric types for cleaned columns
numeric_cols = [:Chol_HDL_ratio]
type_dict = Dict(col => Float64 for col in numeric_cols)
data = CSV.read("diabetic_retinopathy.csv", DataFrame, missingstring=["", "Nil", "NIL"], types=type_dict)

# Display basic information
println("Dataset Info:")
println(describe(data))
println("First few rows:")
println(first(data, 5))

# Check class distribution
println("Class Distribution:")
println(combine(groupby(data, :Clinical_Group), nrow => :count))

# Replace "NaN" strings and floating-point NaN
for col in names(data)
    data[!, col] = replace(data[!, col], "NaN" => missing)
    if eltype(data[!, col]) <: Union{Missing, Number}
        data[!, col] = map(x -> isequal(x, NaN) ? missing : x, data[!, col])
    end
end

# Function to parse values to Float64
function try_parse_float(x)
    if ismissing(x) || x === nothing || x in ["", "Nil", "NIL", "NaN", "nan"]
        return missing
    elseif x isa Number
        return Float64(x)
    else
        str_x = string(x)
        # Handle malformed numbers (e.g., "0..37")
        str_x = replace(str_x, r"\.\.+" => ".")
        try
            parsed = parse(Float64, str_x)
            return isnan(parsed) || isinf(parsed) ? missing : parsed
        catch e
            println("Warning: Could not parse '$x' in column as Float64, treating as missing. Error: $e")
            return missing
        end
    end
end

# Debug column types before processing
println("\nColumn types before processing:")
for col in names(data)
    println("Column: $col, Type: ", eltype(data[!, col]))
end

# Columns to clean

using Statistics  # Required for median calculation

# Loop through each clinical group for Hornerin
for group in unique(data[!, :Clinical_Group])
    # Filter rows for the current group
    group_mask = data[!, :Clinical_Group] .== group
    # Calculate median of non-missing Hornerin values for this group
    group_median = median(skipmissing(data[group_mask, :Hornerin]))
    # Replace missing Hornerin values in this group with the group median
    data[group_mask, :Hornerin] = coalesce.(data[group_mask, :Hornerin], group_median)
end

# println(data[!, :Hornerin])

# Loop through each clinical group for SFN
for group in unique(data[!, :Clinical_Group])
    # Filter rows for the current group
    group_mask = data[!, :Clinical_Group] .== group
    # Calculate median of non-missing SFN values for this group
    group_median = median(skipmissing(data[group_mask, :SFN]))
    # Replace missing SFN values in this group with the group median
    data[group_mask, :SFN] = coalesce.(data[group_mask, :SFN], group_median)
end

# println(data[!, :SFN])

# Loop through each clinical group for Age
for group in unique(data[!, :Clinical_Group])
    # Filter rows for the current group
    group_mask = data[!, :Clinical_Group] .== group
    # Calculate median of non-missing Age values for this group
    group_median = median(skipmissing(data[group_mask, :Age]))
    # Replace missing Age values in this group with the group median
    data[group_mask, :Age] = coalesce.(data[group_mask, :Age], group_median)
end

# println(data[!, :Age])

# Loop through each clinical group for Diabetic_Duration
for group in unique(data[!, :Clinical_Group])
    # Filter rows for the current group
    group_mask = data[!, :Clinical_Group] .== group
    # Calculate median of non-missing Diabetic_Duration values for this group
    group_median = median(skipmissing(data[group_mask, :Diabetic_Duration]))
    # Replace missing Diabetic_Duration values in this group with the group median
    data[group_mask, :Diabetic_Duration] = coalesce.(data[group_mask, :Diabetic_Duration], group_median)
end
# println(data[!, :Diabetic_Duration])

# Loop through each clinical group for TG
for group in unique(data[!, :Clinical_Group])
    # Filter rows for the current group
    group_mask = data[!, :Clinical_Group] .== group
    # Calculate median of non-missing TG values for this group
    group_median = median(skipmissing(data[group_mask, :TG]))
    # Replace missing TG values in this group with the group median
    data[group_mask, :TG] = coalesce.(data[group_mask, :TG], group_median)
end
# println(data[!, :TG])

# Loop through each clinical group for CHOL
for group in unique(data[!, :Clinical_Group])
    # Filter rows for the current group
    group_mask = data[!, :Clinical_Group] .== group
    # Calculate median of non-missing CHOL values for this group
    group_median = median(skipmissing(data[group_mask, :CHOL]))
    # Replace missing CHOL values in this group with the group median
    data[group_mask, :CHOL] = coalesce.(data[group_mask, :CHOL], group_median)
end
# println(data[!, :CHOL])

# Loop through each clinical group for LDL
for group in unique(data[!, :Clinical_Group])
    # Filter rows for the current group
    group_mask = data[!, :Clinical_Group] .== group
    # Calculate median of non-missing LDL values for this group
    group_median = median(skipmissing(data[group_mask, :LDL]))
    # Replace missing LDL values in this group with the group median
    data[group_mask, :LDL] = coalesce.(data[group_mask, :LDL], group_median)
end
# println(data[!, :LDL])

# Loop through each clinical group for HDL
for group in unique(data[!, :Clinical_Group])
    # Filter rows for the current group
    group_mask = data[!, :Clinical_Group] .== group
    # Calculate median of non-missing HDL values for this group
    group_median = median(skipmissing(data[group_mask, :HDL]))
    # Replace missing HDL values in this group with the group median
    data[group_mask, :HDL] = coalesce.(data[group_mask, :HDL], group_median)
end
# println(data[!, :HDL])


# Loop through each clinical group for Alkaline_Phosphatase
for group in unique(data[!, :Clinical_Group])
    # Filter rows for the current group
    group_mask = data[!, :Clinical_Group] .== group
    # Calculate median of non-missing Alkaline_Phosphatase values for this group
    group_median = median(skipmissing(data[group_mask, :Alkaline_Phosphatase ]))
    # Replace missing Alkaline_Phosphatase values in this group with the group median
    data[group_mask, :Alkaline_Phosphatase] = coalesce.(data[group_mask, :Alkaline_Phosphatase], group_median)
end
# println(data[!, Symbol("Alkaline_Phosphatase ")])



# Loop through each clinical group for D_Bil
for group in unique(data[!, :Clinical_Group])
    # Filter rows for the current group
    group_mask = data[!, :Clinical_Group] .== group
    # Calculate median of non-missing D_Bil values for this group
    group_median = median(skipmissing(data[group_mask, :D_Bil]))
    # Replace missing D_Bil values in this group with the group median
    data[group_mask, :D_Bil] = coalesce.(data[group_mask, :D_Bil], group_median)
end
# println(data[!, :D_Bil])

# Loop through each clinical group for T_Bil
for group in unique(data[!, :Clinical_Group])
    # Filter rows for the current group
    group_mask = data[!, :Clinical_Group] .== group
    # Calculate median of non-missing T_Bil values for this group
    group_median = median(skipmissing(data[group_mask, :T_Bil]))
    # Replace missing T_Bil values in this group with the group median
    data[group_mask, :T_Bil] = coalesce.(data[group_mask, :T_Bil], group_median)
end

# println(data[!, :T_Bil])

# Loop through each clinical group for FBS
for group in unique(data[!, :Clinical_Group])
    # Filter rows for the current group
    group_mask = data[!, :Clinical_Group] .== group
    # Calculate median of non-missing FBS values for this group
    group_median = median(skipmissing(data[group_mask, :FBS]))
    # Replace missing FBS values in this group with the group median
    data[group_mask, :FBS] = coalesce.(data[group_mask, :FBS], group_median)
end

# println(data[!, :FBS])


# # Loop through each clinical group for Chol_HDL_ratio
# for group in unique(data[!, :Clinical_Group])
#     # Filter rows for the current group
#     group_mask = data[!, :Clinical_Group] .== group
#     # Calculate median of non-missing Chol_HDL_ratio values for this group
#     group_median = median(skipmissing(data[group_mask, :Chol_HDL_ratio]))
#     # Replace missing Chol_HDL_ratio values in this group with the group median
#     data[group_mask, :Chol_HDL_ratio] = coalesce.(data[group_mask, :Chol_HDL_ratio], group_median)
# end
# # println(data[!, :Chol_HDL_ratio])





# Columns to clean for Chol_HDL_ratio
columns_to_clean = [:Chol_HDL_ratio]

# Process each column
for col in columns_to_clean
    println("\nProcessing column: $col")
    
    # Step 1: Inspect raw values
    println("Raw unique values: ", unique(data[!, col]))
    println("Raw type: ", eltype(data[!, col]))
    println("Raw missing count: ", sum(ismissing.(data[!, col])))
    
    # Step 2: Convert to numeric (redundant with CSV types, but ensures robustness)
    data[!, col] = try_parse_float.(data[!, col])
    
    # Step 3: Inspect converted values
    println("Converted unique values: ", unique(skipmissing(data[!, col])))
    println("Converted type: ", eltype(data[!, col]))
    println("NaN count: ", sum(x -> !ismissing(x) && x isa Number && isnan(x), data[!, col]))
    println("Non-missing count: ", sum(.!ismissing.(data[!, col])))
    
    # Step 4: Impute missing/NaN values with group median
    valid_values = filter(x -> !ismissing(x) && x isa Number && !isnan(x) && !isinf(x), data[!, col])
    overall_median = !isempty(valid_values) ? median(valid_values) : 0.0
    println("Overall median (for fallback): ", overall_median)
    
    for group in unique(data[!, :Clinical_Group])
        group_mask = data[!, :Clinical_Group] .== group
        group_values = data[group_mask, col]
        valid_group_values = filter(x -> !ismissing(x) && x isa Number && !isnan(x) && !isinf(x), group_values)
        
        # Debug
        println("  Group: $group")
        println("  Total rows: ", sum(group_mask))
        println("  Valid values count: ", length(valid_group_values))
        println("  Valid values: ", valid_group_values)
        
        # Calculate group median
        group_median = if !isempty(valid_group_values)
            median(valid_group_values)
        else
            println("Warning: No valid values in group $group for $col. Using overall median: $overall_median")
            overall_median
        end
        
        # Check for NaN
        if isnan(group_median)
            println("Error: Group median for $col in $group is NaN. Using overall median: $overall_median")
            group_median = overall_median
        end
        
        println("  Group median: ", group_median)
        
        # Replace missing or NaN with group median
        data[group_mask, col] = map(x -> ismissing(x) || (x isa Number && isnan(x)) ? group_median : x, group_values)
    end
    
    # Step 5: Verify
    println("Final $col column (first 20 rows): ", data[1:20, col])
    println("Final NaN count: ", sum(x -> !ismissing(x) && x isa Number && isnan(x), data[!, col]))
    println("Final missing count: ", sum(ismissing.(data[!, col])))
    println("Final data type: ", eltype(data[!, col]))
end

# Verify all columns
println("\nVerification of all columns:")
for col in names(data)
    nan_count = sum(x -> !ismissing(x) && x isa Number && isnan(x), data[!, col])
    missing_count = sum(ismissing.(data[!, col]))
    println("Column: $col, NaN count: $nan_count, Missing count: $missing_count")
end

# Save the cleaned dataset
CSV.write("diabetic_retinopathy_missing_removed_cleaned.csv", data)

# Display final dataset info
println("\nFinal dataset info:")
println(describe(data))
println("First few rows of cleaned data:")
pretty_table(first(data, 5))