module AnomalyDetection

using MLJ
using DataFrames
using Logging
# Ensure Clustering.jl is listed in Project.toml and loaded if providing models directly
# using Clustering # MLJ will load it if KMeans is specified by string

export detect_anomalies

# Load the KMeans model from MLJ's model registry
KMeans = @load KMeans pkg=Clustering verbosity=0

function detect_anomalies(df::DataFrame, features::Vector{Symbol}; k_clusters::Int=3, anomaly_threshold_factor::Float64=2.0)
    @info "Starting anomaly detection process with k_clusters=$k_clusters..."

    if isempty(df) || isempty(features)
        @warn "Input DataFrame or feature list is empty. Skipping anomaly detection."
        return DataFrame() # Return an empty DataFrame for anomalies
    end

    # 1. Prepare data for MLJ
    # MLJ expects features (X) and optionally targets (y)
    # For unsupervised clustering, we only have X
    X = select(df, features)

    # 2. Define the K-Means model
    # We can tune hyperparameters like k (n_clusters)
    kmeans_model = KMeans(n_clusters=k_clusters)

    # 3. Create an MLJ machine with the model and data
    # A machine binds a model to data and stores learned parameters.
    mach = machine(kmeans_model, X)

    # 4. Train the machine (fit the model)
    try
        MLJ.fit!(mach, verbosity=0)
        @info "KMeans model fitted successfully."
    catch e
        @error "Error fitting KMeans model: " * sprint(showerror, e)
        return DataFrame() # Return empty on error
    end

    # 5. Get cluster assignments (predictions)
    cluster_assignments = MLJ.predict(mach, X) # This returns categorical values

    # Convert categorical assignments to integers for easier processing
    # The levels of the categorical array correspond to cluster names (e.g., "cluster_1")
    # We can map them to integers 1, 2, ..., k
    cluster_levels = levels(cluster_assignments)
    assignment_map = Dict(level => i for (i, level) in enumerate(cluster_levels))
    int_assignments = [assignment_map[val] for val in cluster_assignments]

    # Add cluster assignments to the original DataFrame for context
    df_with_clusters = copy(df)
    df_with_clusters.cluster = int_assignments
    @info "Cluster assignments added to DataFrame."

    # 6. Identify anomalies
    # A simple approach:
    #   a. Calculate cluster sizes.
    #   b. Calculate centroid of each cluster.
    #   c. Anomalies could be points in very small clusters or points far from their cluster centroid.

    anomalies_df = DataFrame() # Initialize an empty DataFrame for anomalies

    # Approach: Points in small clusters as anomalies
    cluster_counts = countmap(int_assignments)
    @info "Cluster counts: " * string(cluster_counts)

    # Determine a threshold for what constitutes a "small" cluster
    # For example, any cluster with fewer than 10% of the average cluster size, or a fixed small number.
    # Let's keep it simple: if a cluster has very few points, consider them anomalous.
    # This definition of "small_cluster_threshold" might need tuning.
    total_points = nrow(df_with_clusters)
    avg_cluster_size = total_points / k_clusters
    small_cluster_threshold = max(2, ceil(Int, avg_cluster_size * 0.1)) # At least 2, or 10% of avg

    for (cluster_id, count) in cluster_counts
        if count <= small_cluster_threshold
            @warn "Cluster $cluster_id is very small (count: $count). Marking its points as anomalies."
            append!(anomalies_df, filter(row -> row.cluster == cluster_id, df_with_clusters))
        end
    end

    # Another approach: points far from their cluster centroid
    # This requires access to the raw numerical data used for clustering and the centroids.
    # MLJ's `report(mach)` often contains such info (e.g., `mach.report.centroids`).
    # For simplicity, we are currently focusing on the small cluster approach.
    # If MLJ.report(mach).centroids is available and `X` is the numerical data:
    #   centroids = MLJ.report(mach).centroids # (n_features x k_clusters)
    #   For each point, calculate distance to its assigned centroid.
    #   If distance > mean_distance_for_cluster + N * std_dev_distance_for_cluster, it's an anomaly.

    if nrow(anomalies_df) > 0
        @info "Identified $(nrow(anomalies_df)) potential anomalies based on small cluster size."
    else
        @info "No anomalies identified based on small cluster size criteria."
    end

    # For now, we are only using the small cluster size method.
    # Deduplicate if a point ended up in anomalies_df multiple times (not expected with this logic but good practice)
    if nrow(anomalies_df) > 0
        anomalies_df = unique(anomalies_df)
    end

    return anomalies_df
end

end # module AnomalyDetection
