using Logging
using Dates

# Include the new modules
include("data_processing.jl")
include("anomaly_detection.jl")

# Make their functions available
using .DataProcessing
using .AnomalyDetection

function main()
    # Setup basic console logging
    global_logger(ConsoleLogger(stdout, Logging.Info))

    @info "Starting AI Threat Intelligence System..."
    @info "Timestamp: " * string(now())

    println("-"^50)
    println("Hello, Julia Threat Intelligence System!")
    println("This is the main entry point of the application.")
    println("-"^50)

    # Define the path to the sample data
    sample_data_path = "data/sample_netflow.csv" # Assuming Docker WORKDIR is /app

    # 1. Load and Preprocess Data
    @info "Attempting to load and preprocess data..."
    processed_df, features_for_analysis = load_and_preprocess_data(sample_data_path)

    if !isempty(processed_df) && !isempty(features_for_analysis)
        @info "Data loaded and preprocessed successfully."
        @info "Features selected for anomaly detection: " * join(string.(features_for_analysis), ", ")
        # println("First 5 rows of processed data:")
        # println(first(processed_df, 5)) # Comment out for cleaner logs in production
    else
        @error "Failed to load or preprocess data. Exiting."
        return # Exit if data loading fails
    end

    println("-"^50)

    # 2. Detect Anomalies
    @info "Attempting to detect anomalies..."
    # We can adjust k_clusters and anomaly_threshold_factor as needed
    anomalies = detect_anomalies(processed_df, features_for_analysis, k_clusters=4, anomaly_threshold_factor=1.5)

    if !isempty(anomalies)
        @warn "Potential anomalies detected:"
        # In a real system, you'd format this output better or send it to an alert system
        show(stdout, anomalies; allrows=true, allcols=true, show_row_number=false, summary=false)
        println() # for a newline after show
    else
        @info "No anomalies detected based on current criteria."
    end

    println("-"^50)
    @info "AI Threat Intelligence System processing complete."
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
