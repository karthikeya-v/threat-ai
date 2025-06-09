using Genie, Genie.Router, Genie.Renderer, Genie.Renderer.Html, Genie.Renderer.Json # Added Json
using Logging # For @error
using DataFrames # For DataFrame operations if anomalies is a DataFrame

# --- Modules ---
include("data_processing.jl")
include("anomaly_detection.jl")
using .DataProcessing
using .AnomalyDetection

# --- Web Routes --- #

route("/") do
  serve_static_file("index.html", root="public")
end

route("/api/anomalies") do
  try
    sample_data_path = "data/sample_netflow.csv"
    processed_df, features_for_analysis = load_and_preprocess_data(sample_data_path)

    if isempty(processed_df) || isempty(features_for_analysis)
      @error "API: Failed to load or preprocess data."
      return json(:error => "Failed to load or preprocess data", status = 500)
    end

    anomalies = detect_anomalies(processed_df, features_for_analysis, k_clusters=4, anomaly_threshold_factor=1.5)

    if !isempty(anomalies)
      # Convert DataFrame to a more JSON-friendly format (e.g., array of dicts)
      # Genie's json() can often handle DataFrames directly, but let's be explicit for broader compatibility
      output_anomalies = []
      for row in eachrow(anomalies)
          push!(output_anomalies, Dict(names(row) .=> values(row)))
      end
      return json(:anomalies => output_anomalies)
    else
      return json(:message => "No anomalies detected based on current criteria.")
    end
  catch ex
    @error "API Error: " * sprint(showerror, ex)
    return json(:error => "Internal server error while detecting anomalies", :details => sprint(showerror, ex), status = 500)
  end
end

# --- Main Server Start --- #

# Ensure Genie configurations are set if needed (e.g., port, host)
# For default, Genie.startup() is enough.
# We will run it synchronously for now in the Docker container.
Genie.startup(async=false, host="0.0.0.0", port=8000)
