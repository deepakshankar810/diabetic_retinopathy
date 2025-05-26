using CSV
using DataFrames

df = CSV.read("diabetic_retinopathy_old.csv", DataFrame)
df = DataFrame(df)  # ensure it's a DataFrame

first(df, 5)  # view first 5 rows
describe(df)  # summary statistics
names(df)     # column names

# Display first few rows
println(first(df, 5))

# Show summary
println(describe(df))

# Show column names
println(names(df))

# Count missing values per column
println([sum(ismissing, col) for col in eachcol(df)])
