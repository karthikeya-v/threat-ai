# Use an official Julia image as a parent image

# Using Julia 1.6 here to match Project.toml, adjust if needed

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

# Copy the public directory for web assets
COPY public/ /app/public/

# Expose the port the app runs on
EXPOSE 8000

# Specify the command to run on container startup
CMD ["julia", "src/main.jl"]
