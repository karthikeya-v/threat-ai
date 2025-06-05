module DataProcessing

using CSV
using DataFrames
using Dates
using Logging
using StatsBase

export load_and_preprocess_data

function load_and_preprocess_data(file_path::String)
    @info "Loading data from: " * file_path
    try
        df = CSV.read(file_path, DataFrame)
        @info "Successfully loaded $(nrow(df)) rows."

        # Basic Data Cleaning & Transformation
        # 1. Convert timestamp (if needed, though CSV.read might handle it well with default ISO format)
        #    If automatic parsing isn't perfect, you might need:
        #    df.timestamp = DateTime.(df.timestamp, dateformat"yyyy-mm-ddTHH:MM:SSZ")

        # 2. Feature Selection for anomaly detection
        #    For this example, let's focus on numerical features that might show anomalies.
        #    We'll also keep IPs for context if we want to inspect anomalies later.
        features_for_analysis = [:bytes_sent, :packets_sent, :dst_port]
        retained_cols = [:timestamp, :src_ip, :dst_ip, :protocol, :src_port, :dst_port, :bytes_sent, :packets_sent]

        processed_df = select(df, retained_cols)

        @info "Selected columns for processing and context: " * join(string.(retained_cols), ", ")
        @info "Features for direct numerical analysis: " * join(string.(features_for_analysis), ", ")

        # 3. Handle Missing Values (if any)
        #    For simplicity, we'll assume no missing values in key numerical features for now,
        #    or that they would be dropped/imputed in a real scenario.
        #    Example: dropmissing!(processed_df, features_for_analysis)

        # 4. Data Type Conversion (ensure numerical features are numbers)
        for col in features_for_analysis
            if !(eltype(processed_df[!, col]) <: Number)
                try
                    processed_df[!, col] = parse.(Float64, string.(processed_df[!, col]))
                catch e
                    @warn "Could not parse column $col to Float64. Error: $e"
                    # Handle error, e.g., by removing column or rows with unparseable data
                end
            end
        end

        # 5. Feature Scaling/Normalization (important for distance-based algorithms like KMeans)
        #    Using StatsBase for standardization (Z-score normalization)
        #    MLJ also provides scalers, which we'll use when we build the MLJ pipeline.
        #    For now, let's prepare the numerical data separately for potential direct use or inspection.

        numerical_data = Matrix(select(processed_df, features_for_analysis))

        # Standardize the numerical features
        # scaler = StatsBase.fit(ZScoreTransform, numerical_data, dims=1)
        # scaled_numerical_data = StatsBase.transform(scaler, numerical_data)
        # For MLJ, we typically pass the DataFrame and specify transformations in the pipeline.
        # So, we'll return the DataFrame and let MLJ handle scaling.

        @info "Data preprocessing steps (selection, type checks) complete."
        return processed_df, features_for_analysis

    catch e
        @error "Error during data loading or preprocessing: " * sprint(showerror, e)
        return DataFrame(), Symbol[] # Return empty on error
    end
end

end # module DataProcessing
