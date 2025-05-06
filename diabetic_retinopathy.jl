# 1) Loading and Exploring the Dataset
using CSV
using DataFrames

# Load the dataset
data = CSV.read("diabetic_retinopathy.csv", DataFrame)

# Display basic information
println("Dataset Info:")
println(describe(data))
println("First few rows:")
println(first(data, 5))

# Check class distribution
println("Class Distribution:")
println(combine(groupby(data, :Clinical_Group), nrow => :count))

# 2) Data Preprocessing
# i) handling missing values
using CSV, DataFrames, Impute, StatsBase, Random

# Load data
data = CSV.read("diabetic_retinopathy.csv", DataFrame)

# Clean column names
rename!(data, [strip(string(col)) for col in names(data)])

# Replace "NIL" with missing
for col in names(data)
    data[!, col] = replace(data[!, col], "NIL" => missing, "Nil" => missing)
end

# Custom random sampling imputation
function random_sample_impute(col; rng=Random.default_rng())
    non_missing = collect(skipmissing(col))
    if isempty(non_missing)
        return col
    end
    return [ismissing(x) ? sample(rng, non_missing) : x for x in col]
end

# Impute numerical columns
numerical_cols = [:Hornerin, :SFN, :Age, :Diabetic_Duration, :eGFR, :HB, :EAG, :FBS, :RBS, :HbA1C, 
                  :Systolic_BP, :Diastolic_BP, :BUN, :Total_Protein, :Serum_Albumin, :Serum_Globulin, 
                  :AG_Ratio, :Serum_Creatinine, :Sodium, :Potassium, :Chloride, :Bicarbonate, :SGOT, 
                  :SGPT, :Alkaline_Phosphatase, :T_Bil, :D_Bil, :HDL, :LDL, :CHOL, :Chol_HDL_ratio, :TG]
for col in numerical_cols
    if eltype(data[!, col]) <: Union{Missing, Number}
        data[!, col] = random_sample_impute(data[!, col]; rng=MersenneTwister(42))
    end
end

# Impute categorical columns with mode
categorical_cols = [:Gender, :Albuminuria]
for col in categorical_cols
    if eltype(data[!, col]) <: Union{Missing, String}
        mode_val = mode(skipmissing(data[!, col]))
        data[!, col] = coalesce.(data[!, col], mode_val)
    end
end

# Verify data
println("Column names: ", names(data))
println("First few rows: ", first(data, 5))

# ii) Encoding categorical variables
using CSV, DataFrames, MLJ, MLJBase, Impute, StatsBase, Random

# Load data
data = CSV.read("diabetic_retinopathy.csv", DataFrame)

# Clean column names
rename!(data, [strip(string(col)) for col in names(data)])

# Replace "NIL" with missing
for col in names(data)
    data[!, col] = replace(data[!, col], "NIL" => missing, "Nil" => missing)
end

# Custom random sampling imputation
function random_sample_impute(col; rng=Random.default_rng())
    non_missing = collect(skipmissing(col))
    if isempty(non_missing)
        return col
    end
    return [ismissing(x) ? sample(rng, non_missing) : x for x in col]
end

# Impute numerical columns
numerical_cols = [:Hornerin, :SFN, :Age, :Diabetic_Duration, :eGFR, :HB, :EAG, :FBS, :RBS, :HbA1C, 
                  :Systolic_BP, :Diastolic_BP, :BUN, :Total_Protein, :Serum_Albumin, :Serum_Globulin, 
                  :AG_Ratio, :Serum_Creatinine, :Sodium, :Potassium, :Chloride, :Bicarbonate, :SGOT, 
                  :SGPT, :Alkaline_Phosphatase, :T_Bil, :D_Bil, :HDL, :LDL, :CHOL, :Chol_HDL_ratio, :TG]
for col in numerical_cols
    if eltype(data[!, col]) <: Union{Missing, Number}
        data[!, col] = random_sample_impute(data[!, col]; rng=MersenneTwister(42))
    end
end

# Impute categorical columns with mode
categorical_cols = [:Gender, :Albuminuria]
for col in categorical_cols
    if eltype(data[!, col]) <: Union{Missing, String}
        mode_val = mode(skipmissing(data[!, col]))
        data[!, col] = coalesce.(data[!, col], mode_val)
    end
end

# Encode categorical variables
using CSV, DataFrames, MLJ, MLJBase, Impute, StatsBase, Random
using DataFrames: select  # Explicitly import select

# Load data
data = CSV.read("diabetic_retinopathy.csv", DataFrame)

# Clean column names
rename!(data, [strip(string(col)) for col in names(data)])

# Replace "NIL" with missing
for col in names(data)
    data[!, col] = replace(data[!, col], "NIL" => missing, "Nil" => missing)
end

# Custom random sampling imputation
function random_sample_impute(col; rng=Random.default_rng())
    non_missing = collect(skipmissing(col))
    if isempty(non_missing)
        return col
    end
    return [ismissing(x) ? sample(rng, non_missing) : x for x in col]
end

# Impute numerical columns
numerical_cols = [:Hornerin, :SFN, :Age, :Diabetic_Duration, :eGFR, :HB, :EAG, :FBS, :RBS, :HbA1C, 
                  :Systolic_BP, :Diastolic_BP, :BUN, :Total_Protein, :Serum_Albumin, :Serum_Globulin, 
                  :AG_Ratio, :Serum_Creatinine, :Sodium, :Potassium, :Chloride, :Bicarbonate, :SGOT, 
                  :SGPT, :Alkaline_Phosphatase, :T_Bil, :D_Bil, :HDL, :LDL, :CHOL, :Chol_HDL_ratio, :TG]
for col in numerical_cols
    if eltype(data[!, col]) <: Union{Missing, Number}
        data[!, col] = random_sample_impute(data[!, col]; rng=MersenneTwister(42))
    end
end

# Impute categorical columns with mode
categorical_cols = [:Gender, :Albuminuria]
for col in categorical_cols
    if eltype(data[!, col]) <: Union{Missing, String}
        mode_val = mode(skipmissing(data[!, col]))
        data[!, col] = coalesce.(data[!, col], mode_val)
    end
end

# Encode categorical variables
data[!, :Clinical_Group] = categorical(data[!, :Clinical_Group])
hot_encoder = OneHotEncoder(; features=[:Gender, :Albuminuria], drop_last=false)
mach = machine(hot_encoder, data)
fit!(mach)
data_encoded = MLJBase.transform(mach, data)
data_encoded = select(data_encoded, Not([:Gender, :Albuminuria]))  # Use DataFrames.select

# Verify encoded data
println("Encoded column names: ", names(data_encoded))
println("First few rows of encoded data: ", first(data_encoded, 5))