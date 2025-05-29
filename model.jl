using DataFrames
using Statistics
using CSV
using Random


# Load the dataset, specifying missing value indicators
data = CSV.read("diabetic_retinopathy_cleaned_step41.csv", DataFrame)


using DataFrames
using Statistics
using CSV
using Random

# Step 1: Identify highly correlated pairs
numerical_cols = [:Hornerin, :SFN, :Age, :Diabetic_Duration, :eGFR, :HB, :EAG, :FBS, :RBS, :HbA1C, :Systolic_BP, :Diastolic_BP, :BUN, :Total_Protein, :Serum_Albumin, :Serum_Globulin, :AG_Ratio, :Serum_Creatinine, :Sodium, :Potassium, :Chloride, :Bicarbonate, :SGOT, :SGPT, :Alkaline_Phosphatase, :T_Bil, :D_Bil, :HDL, :LDL, :CHOL, :Chol_HDL_ratio, :TG, :Clinical_Group_DM, :Clinical_Group_DR, :Clinical_Group_DN]
corr_matrix = cor(Matrix(data[!, numerical_cols]))
threshold = 0.7
cor_pairs = []
for i in 1:length(numerical_cols)
    for j in (i+1):length(numerical_cols)
        if abs(corr_matrix[i, j]) > threshold
            push!(cor_pairs, (numerical_cols[i], numerical_cols[j], corr_matrix[i, j]))
        end
    end
end
println("Highly correlated pairs (|corr| > $threshold):")
for (col1, col2, corr) in cor_pairs
    println("$col1 vs $col2: $corr")
end

# Step 3: Prepare features and target (default: Clinical_Group)
target_col = :Clinical_Group  # Change to :Albuminuria, :Hornerin, etc., if needed
feature_cols = setdiff(names(data), [target_col])  # Keep all other columns as features
X = data[!, feature_cols]
y = data[!, target_col]
println("\nFeatures: ", names(X))
println("Target: ", target_col)
println("Target distribution:")
println(combine(groupby(data, target_col, sort=true), nrow => :count))

# Step 4: Train-test split
Random.seed!(42)  # For reproducibility
n = nrow(data)
train_idx = shuffle(1:n)[1:round(Int, 0.8 * n)]
test_idx = setdiff(1:n, train_idx)
X_train = X[train_idx, :]
X_test = X[test_idx, :]
y_train = y[train_idx]
y_test = y[test_idx]
println("\nTrain set size: ", size(X_train))
println("Test set size: ", size(X_test))

# # Save split datasets
# CSV.write("X_train_step43.csv", X_train)
# CSV.write("X_test_step43.csv", X_test)
# CSV.write("y_train_step43.csv", DataFrame(Clinical_Group=y_train))
# CSV.write("y_test_step43.csv", DataFrame(Clinical_Group=y_test))


using DataFrames
using CSV
using MLJ
using Random
using PrettyPrinting
using StatisticalMeasures.ConfusionMatrices
using JLSO

# Step 1: Load datasets
X_train = CSV.read("X_train_step43.csv", DataFrame)
X_test = CSV.read("X_test_step43.csv", DataFrame)
y_train = CSV.read("y_train_step43.csv", DataFrame)[!, :Clinical_Group]
y_test = CSV.read("y_test_step43.csv", DataFrame)[!, :Clinical_Group]

# Step 2: Exclude Clinical_Group and encoded columns
feature_cols = setdiff(names(X_train), [:Clinical_Group, :Clinical_Group_DM, :Clinical_Group_DR, :Clinical_Group_DN])
X_train = X_train[!, feature_cols]
X_test = X_test[!, feature_cols]
println("Features: ", names(X_train))

# Step 3: Train model
Random.seed!(42)
RFC = @load RandomForestClassifier pkg=DecisionTree
model = RFC(n_trees=100, max_depth=5)
mach = machine(model, X_train, categorical(y_train))
fit!(mach)
println("Model trained")

# Step 4: Evaluate on test set
y_pred = predict_mode(mach, X_test)
accuracy = mean(y_pred .== y_test)
println("\nTest accuracy: ", round(accuracy, digits=3))

# Detailed metrics
conf_mat = confusion_matrix(y_pred, categorical(y_test))
println("\nConfusion matrix:")
pprint(conf_mat)

# Extract matrix
cm_matrix = ConfusionMatrices.matrix(conf_mat)
classes = levels(categorical(y_test))
metrics = Dict()
for (i, class) in enumerate(classes)
    tp = cm_matrix[i, i]
    fp = sum(cm_matrix[i, :]) - tp
    fn = sum(cm_matrix[:, i]) - tp
    precision = iszero(tp + fp) ? 0.0 : tp / (tp + fp)
    recall = iszero(tp + fn) ? 0.0 : tp / (tp + fn)
    f1 = iszero(precision + recall) ? 0.0 : 2 * (precision * recall) / (precision + recall)
    metrics[class] = (precision=precision, recall=recall, f1=f1)
end
println("\nClass-wise metrics:")
for class in classes
    println("$class: Precision=$(round(metrics[class].precision, digits=3)), Recall=$(round(metrics[class].recall, digits=3)), F1=$(round(metrics[class].f1, digits=3))")
end

# Step 5: Save model and metrics
JLSO.save("random_forest_step44.jls", :machine => mach)
CSV.write("metrics_step44.csv", DataFrame(
    class = collect(keys(metrics)),
    precision = [m.precision for m in values(metrics)],
    recall = [m.recall for m in values(metrics)],
    f1 = [m.f1 for m in values(metrics)]
))
println("Model and metrics saved")


using DataFrames
using CSV
using MLJ
using Random
using PrettyPrinting
using StatisticalMeasures.ConfusionMatrices
using JLSO

# Step 1: Load datasets
X_train = CSV.read("X_train_step43.csv", DataFrame)
X_test = CSV.read("X_test_step43.csv", DataFrame)
y_train = CSV.read("y_train_step43.csv", DataFrame)[!, :Clinical_Group]
y_test = CSV.read("y_test_step43.csv", DataFrame)[!, :Clinical_Group]

# Step 2: Exclude Clinical_Group and encoded columns
feature_cols = setdiff(names(X_train), [:Clinical_Group, :Clinical_Group_DM, :Clinical_Group_DR, :Clinical_Group_DN])
X_train = X_train[!, feature_cols]
X_test = X_test[!, feature_cols]
println("Features: ", names(X_train))

# Step 3: Define model and hyperparameter grid
Random.seed!(42)
RFC = @load RandomForestClassifier pkg=DecisionTree
model = RFC()

# Define parameter ranges
r1 = range(model, :n_trees, values=[50, 100, 200])
r2 = range(model, :max_depth, values=[3, 5, 7])

# Step 4: Tune model with cross-validation
self_tuning_model = TunedModel(
    model=model,
    ranges=[r1, r2],
    tuning=Grid(resolution=3),
    resampling=CV(nfolds=5),
    measure=MLJ.accuracy
)
mach = machine(self_tuning_model, X_train, categorical(y_train))
fit!(mach)
println("Tuning complete. Best parameters: ", fitted_params(mach).best_model)

# Step 5: Evaluate on test set
y_pred = predict_mode(mach, X_test)
accuracy = mean(y_pred .== y_test)
println("\nTest accuracy: ", round(accuracy, digits=3))

# Detailed metrics
conf_mat = confusion_matrix(y_pred, categorical(y_test))
println("\nConfusion matrix:")
pprint(conf_mat)

# Extract matrix
cm_matrix = ConfusionMatrices.matrix(conf_mat)
classes = levels(categorical(y_test))
metrics = Dict()
for (i, class) in enumerate(classes)
    tp = cm_matrix[i, i]
    fp = sum(cm_matrix[i, :]) - tp
    fn = sum(cm_matrix[:, i]) - tp
    precision = iszero(tp + fp) ? 0.0 : tp / (tp + fp)
    recall = iszero(tp + fn) ? 0.0 : tp / (tp + fn)
    f1 = iszero(precision + recall) ? 0.0 : 2 * (precision * recall) / (precision + recall)
    metrics[class] = (precision=precision, recall=recall, f1=f1)
end
println("\nClass-wise metrics:")
for class in classes
    println("$class: Precision=$(round(metrics[class].precision, digits=3)), Recall=$(round(metrics[class].recall, digits=3)), F1=$(round(metrics[class].f1, digits=3))")
end

# Step 6: Save model and metrics
JLSO.save("random_forest_tuned_step45.jls", :machine => mach)
CSV.write("metrics_step45.csv", DataFrame(
    class = collect(keys(metrics)),
    precision = [m.precision for m in values(metrics)],
    recall = [m.recall for m in values(metrics)],
    f1 = [m.f1 for m in values(metrics)]
))
println("Tuned model and metrics saved")