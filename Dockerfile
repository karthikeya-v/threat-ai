# Use an official Julia image as a parent image
# Using Julia 1.6 here to match Project.toml, adjust if needed
FROM julia:1.6-buster

# Set the working directory in the container
WORKDIR /app

# Copy the Project.toml and Manifest.toml (if it existed)
# Copying only Project.toml first to leverage Docker layer caching for dependencies
COPY src/Project.toml /app/Project.toml
# If Manifest.toml is generated locally and is important for exact reproducibility, copy it too:
# COPY src/Manifest.toml /app/Manifest.toml

# Install Julia packages
# Change to /app where Project.toml is
RUN julia -e 'using Pkg; Pkg.activate("."); Pkg.instantiate()'

# Copy the application source code
COPY src/ /app/src/

# Copy the data directory
COPY data/ /app/data/

# Specify the command to run on container startup
CMD ["julia", "src/main.jl"]
