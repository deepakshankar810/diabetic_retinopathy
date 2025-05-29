using DataFrames
using CSV

# Load the dataset, specifying missing value indicators
data = CSV.read("diabetic_retinopathy_cleaned_step_data.csv", DataFrame)

using DataFrames
using CSV

# # Step 1: Inspect current columns
# println("Current columns in the dataset:")
# println(names(data))

# # Step 2: Remove Patient_ID
# select!(data, Not(:Patient_ID))

# # Step 3: Inspect Clinical_Group
# println("\nSummary of Clinical_Group before encoding:")
# println("Unique values in Clinical_Group: ", unique(data[!, :Clinical_Group]))
# println("Value counts of Clinical_Group:")
# println(combine(groupby(data, :Clinical_Group, sort=true), nrow => :count))

# # Step 4: One-hot encode Clinical_Group
# # Create dummy variables (one-hot encoding)
# dummy_df = DataFrame([col => (data[!, :Clinical_Group] .== level) for (col, level) in zip([:Clinical_Group_DM, :Clinical_Group_DR, :Clinical_Group_DN], unique(data[!, :Clinical_Group]))])

# # Convert boolean to integers (0/1)
# for col in names(dummy_df)
#     dummy_df[!, col] = Int.(dummy_df[!, col])
# end

# # Combine original DataFrame with dummy variables
# data = hcat(data, dummy_df)

# # Step 5: Verify changes
# println("\nColumns after removing Patient_ID and encoding Clinical_Group:")
# println(names(data))
# println("\nSummary of one-hot encoded columns:")
# println(select(data, [:Clinical_Group, :Clinical_Group_DM, :Clinical_Group_DR, :Clinical_Group_DN])[1:5, :])

# # Display first 5 rows to verify changes
# println("\nFirst 5 rows of the dataset (selected columns):")
# select(data, [:Clinical_Group, :Clinical_Group_DM, :Clinical_Group_DR, :Clinical_Group_DN, :Hornerin, :SFN, :Age, :Gender, :Diabetic_Duration, :eGFR, :HB, :EAG, :FBS, :RBS, :HbA1C, :Systolic_BP, :Diastolic_BP, :BUN, :Total_Protein, :Serum_Albumin, :Serum_Creatinine, :CHOL, :TG, :HDL, :LDL, :Chol_HDL_ratio, :Serum_Globulin, :AG_Ratio, :Sodium, :Potassium, :Chloride, :Bicarbonate, :SGOT, :SGPT, :Alkaline_Phosphatase, :T_Bil, :D_Bil, :Calcium, :Phosphorus, :Albuminuria]) |> x -> show(first(x, 5), allcols=true)

# # Optional: Save the updated DataFrame
# CSV.write("diabetic_retinopathy_patientidremoved.csv", data)

using DataFrames
using CSV

# Step 1: Remove Patient_ID
select!(data, Not(:Patient_ID))

# Step 2: Inspect Clinical_Group
println("Unique values in Clinical_Group: ", unique(data[!, :Clinical_Group]))
println("Value counts of Clinical_Group:")
println(combine(groupby(data, :Clinical_Group, sort=true), nrow => :count))

# Step 3: One-hot encode Clinical_Group
dummy_df = DataFrame([col => (data[!, :Clinical_Group] .== level) for (col, level) in zip([:Clinical_Group_DM, :Clinical_Group_DR, :Clinical_Group_DN], unique(data[!, :Clinical_Group]))])
for col in names(dummy_df)
    dummy_df[!, col] = Int.(dummy_df[!, col])
end
data = hcat(data, dummy_df)

# Step 4: Verify changes
println("\nColumns after processing:")
println(names(data))
println("\nOne-hot encoded columns:")
println(select(data, [:Clinical_Group, :Clinical_Group_DM, :Clinical_Group_DR, :Clinical_Group_DN])[1:5, :])

# Display first 5 rows
println("\nFirst 5 rows:")
select(data, [:Clinical_Group, :Clinical_Group_DM, :Clinical_Group_DR, :Clinical_Group_DN, :Hornerin, :SFN, :Age, :Gender, :Diabetic_Duration, :eGFR, :Albuminuria, :HB]) |> x -> show(first(x, 5), allcols=true)

# # Save DataFrame
# CSV.write("diabetic_retinopathy_cleaned_step41.csv", data)

using DataFrames
using Statistics
using CSV
using Plots

# Step 1: Summary statistics for numerical features
numerical_cols = [:Hornerin, :SFN, :Age, :Diabetic_Duration, :eGFR, :HB, :EAG, :FBS, :RBS, :HbA1C, :Systolic_BP, :Diastolic_BP, :BUN, :Total_Protein, :Serum_Albumin, :Serum_Globulin, :AG_Ratio, :Serum_Creatinine, :Sodium, :Potassium, :Chloride, :Bicarbonate, :SGOT, :SGPT, :Alkaline_Phosphatase, :T_Bil, :D_Bil, :HDL, :LDL, :CHOL, :Chol_HDL_ratio, :TG]
println("Summary statistics for numerical features:")
numerical_summary = describe(data[!, numerical_cols], :mean, :median, :min, :max, :std)
show(numerical_summary, allcols=true)

# Step 2: Summarize categorical features
println("\nGender distribution:")
println(combine(groupby(data, :Gender, sort=true), nrow => :count))
println("\nAlbuminuria distribution:")
println(combine(groupby(data, :Albuminuria, sort=true), nrow => :count))
println("\nClinical_Group encoded distribution:")
println(combine(data, :Clinical_Group_DM => sum => :DM_count, :Clinical_Group_DR => sum => :DR_count, :Clinical_Group_DN => sum => :DN_count))

# Step 3: Correlation matrix
corr_matrix = cor(Matrix(data[!, numerical_cols]))
println("\nCorrelation matrix (first 5x5):")
show(corr_matrix[1:5, 1:5])

# Step 4: Plot correlation heatmap with string labels
string_cols = string.(numerical_cols)  # Convert symbols to strings
heatmap(string_cols, string_cols, corr_matrix, title="Correlation Heatmap", color=:viridis, clim=(-1, 1), xticks=(1:length(string_cols), string_cols), yticks=(1:length(string_cols), string_cols), xrot=45, size=(800, 800))


using DataFrames
using Statistics
using CSV
using Plots
gr()  # Set GR backend

# Correlation matrix (recompute for completeness)
numerical_cols = [:Hornerin, :SFN, :Age, :Diabetic_Duration, :eGFR, :HB, :EAG, :FBS, :RBS, :HbA1C, :Systolic_BP, :Diastolic_BP, :BUN, :Total_Protein, :Serum_Albumin, :Serum_Globulin, :AG_Ratio, :Serum_Creatinine, :Sodium, :Potassium, :Chloride, :Bicarbonate, :SGOT, :SGPT, :Alkaline_Phosphatase, :T_Bil, :D_Bil, :HDL, :LDL, :CHOL, :Chol_HDL_ratio, :TG]
corr_matrix = cor(Matrix(data[!, numerical_cols]))

# Plot correlation heatmap
string_cols = string.(numerical_cols)
heatmap(string_cols, string_cols, corr_matrix, title="Correlation Heatmap", color=:viridis, clim=(-1, 1), xticks=(1:length(string_cols), string_cols), yticks=(1:length(string_cols), string_cols), xrot=45, size=(800, 800))
savefig("correlation_heatmap.png")
println("Heatmap saved as correlation_heatmap.png")