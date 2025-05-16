using CSV
using DataFrames
using Statistics
using PrettyTables

# Load the dataset with explicit numeric types for cleaned columns, except T_Bil
numeric_cols = [:Hornerin, :SFN, :Age, :Diabetic_Duration, :TG, :CHOL, :LDL, :HDL, :Chol_HDL_ratio, :D_Bil, :Alkaline_Phosphatase, :eGFR, :HB, :EAG, :FBS, :RBS, :HbA1C, :Systolic_BP, :Diastolic_BP, :BUN, :Total_Protein, :Serum_Albumin, :Serum_Globulin, :AG_Ratio, :Serum_Creatinine, :Sodium, :Potassium, :Chloride, :Bicarbonate, :SGOT, :SGPT]
type_dict = Dict(col => Float64 for col in numeric_cols)
data = CSV.read("diabetic_retinopathy.csv", DataFrame, missingstring=["", "Nil", "NIL"], types=merge(type_dict, Dict(:T_Bil => String)))

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
function try_parse_float(x, col::Symbol, row::Int)
    if ismissing(x) || x === nothing || x in ["", "Nil", "NIL", "NaN", "nan"]
        return missing
    elseif x isa Number
        return Float64(x)
    else
        str_x = string(x)
        str_x = replace(str_x, r"\.\.+" => ".")
        try
            parsed = parse(Float64, str_x)
            if col == :T_Bil && str_x == "0.37" && row == 36
                println("Info: Successfully parsed '0..37' as $parsed in T_Bil at row 36")
            end
            return isnan(parsed) || isinf(parsed) ? missing : parsed
        catch e
            println("Warning: Could not parse '$x' in column $col at row $row as Float64, treating as missing. Error: $e")
            return missing
        end
    end
end

# Debug column types before processing
println("\nColumn types before processing:")
for col in names(data)
    println("Column: $col, Type: ", eltype(data[!, col]))
end

# Columns to clean (all numeric except Gender, Albuminuria, Patient_ID, Clinical_Group)
columns_to_clean = [:Hornerin, :SFN, :Age, :Diabetic_Duration, :TG, :CHOL, :LDL, :HDL, :Chol_HDL_ratio, :D_Bil, :T_Bil, :Alkaline_Phosphatase, :eGFR, :HB, :EAG, :FBS, :RBS, :HbA1C, :Systolic_BP, :Diastolic_BP, :BUN, :Total_Protein, :Serum_Albumin, :Serum_Globulin, :AG_Ratio, :Serum_Creatinine, :Sodium, :Potassium, :Chloride, :Bicarbonate, :SGOT, :SGPT]

# Process each column
for col in columns_to_clean
    println("\nProcessing column: $col")
    
    # Step 1: Inspect raw values
    println("Raw unique values: ", unique(data[!, col]))
    println("Raw type: ", eltype(data[!, col]))
    println("Raw missing count: ", sum(ismissing.(data[!, col])))
    
    # Step 2: Convert to numeric with row tracking
    data[!, col] = [try_parse_float(data[i, col], col, i) for i in 1:nrow(data)]
    
    # Step 3: Inspect converted values
    println("Converted unique values: ", unique(skipmissing(data[!, col])))
    println("Converted type: ", eltype(data[!, col]))
    println("NaN count: ", sum(x -> !ismissing(x) && x isa Number && isnan(x), data[!, col]))
    println("Non-missing count: ", sum(.!ismissing.(data[!, col])))
    
    # Special checks
    if col == :HDL
        println("HDL value at row 41: ", data[41, :HDL])
        decimal_rows = findall(x -> !ismissing(x) && x != floor(x), data[!, col])
        println("HDL rows with decimal values: ", decimal_rows)
    elseif col == :LDL
        println("LDL value at row 41: ", data[41, :LDL])
        decimal_rows = findall(x -> !ismissing(x) && x != floor(x), data[!, col])
        println("LDL rows with decimal values: ", decimal_rows)
    elseif col == :Chol_HDL_ratio
        println("Chol_HDL_ratio at row 21 (integer case): ", data[21, :Chol_HDL_ratio])
        integer_rows = findall(x -> !ismissing(x) && x == floor(x), data[!, col])
        println("Chol_HDL_ratio rows with integer values: ", integer_rows)
    elseif col == :Alkaline_Phosphatase
        high_rows = findall(x -> !ismissing(x) && x > 200, data[!, col])
        println("Alkaline_Phosphatase rows with values > 200: ", high_rows)
    elseif col == :SGOT
        high_rows = findall(x -> !ismissing(x) && x > 100, data[!, col])
        println("SGOT rows with values > 100: ", high_rows)
    elseif col == :SGPT
        high_rows = findall(x -> !ismissing(x) && x > 100, data[!, col])
        println("SGPT rows with values > 100: ", high_rows)
    elseif col == :Serum_Creatinine
        high_rows = findall(x -> !ismissing(x) && x > 2.0, data[!, col])
        println("Serum_Creatinine rows with values > 2.0: ", high_rows)
    end
    
    # Step 4: Impute missing/NaN values with group median
    valid_values = filter(x -> !ismissing(x) && x isa Number && !isnan(x) && !isinf(x), data[!, col])
    overall_median = !isempty(valid_values) ? median(valid_values) : 0.0
    println("Overall median (for fallback): ", overall_median)
    
    for group in unique(skipmissing(data[!, :Clinical_Group]))
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
CSV.write("diabetic_retinopathy_fully_cleaned.csv", data)

# Display final dataset info
println("\nFinal dataset info:")
println(describe(data))
println("First few rows of cleaned data:")
pretty_table(first(data, 5))