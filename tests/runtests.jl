# tests/runtests.jl
using Test
using HTTP
using JSON3
using Genie # Required for Genie.config

# It's good practice to allow overriding the base URL via an environment variable
# For now, we hardcode assuming the server runs on default Genie port 8000
const BASE_URL = "http://localhost:8000"

# It's important to configure Genie for the test environment
# This might involve setting Genie.Configuration.app_env
# However, for basic HTTP tests against a running server, this might not be strictly needed
# but good to be aware of.
# We set the context to the main app's directory to find `main.jl` if needed
# and to ensure Genie related pathing for configs etc. are correct.
# This is tricky as runtests.jl is in /tests but main.jl is in /src
# For now, we assume the server is started externally and correctly.

@testset "Web UI and API Tests" begin

    # Give the server a moment to start if it were started by this script
    # sleep(5) # Not ideal, but sometimes necessary for CI. Remove if server is started externally.

    @testset "Main Page" begin
        try
            response = HTTP.get(BASE_URL * "/")
            @test response.status == 200
            body = String(response.body)
            @test occursin("<title>Funky Fish UI - Anomalies</title>", body)
            @test occursin("<h1>Funky Fish Network Anomalies</h1>", body)
        catch ex
            @error "Main Page test failed to connect or other HTTP error" exception=(ex, catch_backtrace())
            @test false # Fail test explicitly if HTTP request fails
        end
    end

    @testset "Anomalies API Endpoint" begin
        try
            response = HTTP.get(BASE_URL * "/api/anomalies")
            @test response.status == 200

            content_type = HTTP.header(response, "Content-Type", "")
            @test occursin("application/json", content_type)

            json_response = JSON3.read(response.body)

            # Check if the response contains 'anomalies' array or 'message' string
            @test haskey(json_response, :anomalies) || haskey(json_response, :message)

            if haskey(json_response, :anomalies)
                @test json_response.anomalies isa Vector
                # If there are anomalies, check structure of the first one (if any)
                if !isempty(json_response.anomalies)
                    @test json_response.anomalies[1] isa JSON3.Object
                    # Example check for expected keys, assuming CSV headers are the keys
                    # This depends on the actual data in sample_netflow.csv
                    # For instance, if 'src_ip' is a column:
                    # @test haskey(json_response.anomalies[1], :src_ip)
                end
            elseif haskey(json_response, :message)
                 @test json_response.message isa String
            else # Should not happen if previous test passed
                @test false # Fail if neither key is present
            end

        catch ex
            @error "Anomalies API test failed to connect or other HTTP error" exception=(ex, catch_backtrace())
            @test false # Fail test explicitly
        end
    end
end

# Placeholder for a function that could start the server if needed
# function start_server()
#   try
#     # Navigate to src directory to run main.jl in its context
#     cd_path = joinpath("..", "src") # Relative to tests/
#     @info "Attempting to start server from $cd_path by running main.jl"
#     # This is a blocking call, so it needs to be run async
#     # And we need a way to stop it. This is complex.
#     # run(`julia $cd_path/main.jl`, wait=false) # Simplified, likely needs more robust handling
#   catch e
#     @error "Failed to start server for testing: $e"
#   end
# end
# start_server() # Call this if you implement server starting logic

# Placeholder for stopping server
# function stop_server() ... end
# atexit(stop_server)
