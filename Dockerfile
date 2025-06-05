# Use an official Julia image as a parent image
FROM julia:1.6-buster

# Set the working directory in the container
WORKDIR /app

# Copy the Project.toml
COPY src/Project.toml /app/Project.toml
# If you generate a Manifest.toml locally and commit it, copy it too for reproducible builds:
# COPY src/Manifest.toml /app/Manifest.toml

# Install Julia packages
# Removing existing ~/.julia directory to ensure a clean state
# Update the package registry, then instantiate the project dependencies
RUN julia -e '     try rm(joinpath(homedir(), ".julia"), recursive=true, force=true) catch e println(stderr, "Error removing ~/.julia: ", e) end;     import Pkg;     Pkg.Registry.add("General");     Pkg.Registry.update();     Pkg.activate(".");     Pkg.instantiate();     Pkg.precompile()   '

# Copy the application source code
COPY src/ /app/src/

# Copy the data directory
COPY data/ /app/data/

# Specify the command to run on container startup
CMD ["julia", "src/main.jl"]
