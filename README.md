# AI-Powered Network Threat Intelligence System (Julia-based)

This project is an AI-powered network threat intelligence system built with Julia.
Its goal is to provide an accessible and performant tool for monitoring network
traffic and logs, detecting anomalies, identifying known threats, and gaining
actionable insights into security posture.

## Prerequisites

*   Docker: [Installation Guide](https://docs.docker.com/engine/install/)
*   Docker Compose: [Installation Guide](https://docs.docker.com/compose/install/)
*   Sufficient hardware resources (CPU, RAM, Storage) for the application and any future services (e.g., ELK stack).

## Getting Started

1.  **Clone the repository:**
    ```bash
    git clone <repository-url>
    cd <repository-name>
    ```

2.  **Build and run the Julia application container:**
    ```bash
    docker-compose build
    docker-compose up
    ```

    You should see output from the Julia application, including a "Hello, Julia Threat Intelligence System!" message.

## Running the System (Basic)

The `docker-compose up` command will start the core Julia application.
Currently, this is a basic application that prints a startup message.
Future developments will expand its capabilities.

To stop the system, press `Ctrl+C` in the terminal where `docker-compose up` is running, or run:
```bash
docker-compose down
```

## Project Structure

*   `src/`: Contains the Julia application code.
    *   `Project.toml`: Julia project dependencies.
    *   `main.jl`: Main entry point for the Julia application.
*   `data/`: Intended for storing persistent data, sample data, etc. (currently empty).
*   `config/`: For configuration files (currently empty).
*   `scripts/`: For utility scripts (currently empty).
*   `tests/`: For test code (currently empty).
*   `Dockerfile`: Defines the Docker image for the Julia application.
*   `docker-compose.yml`: Configures services for Docker Compose.

## Future Enhancements

Refer to the Product Requirements Document for a full list of planned features, including:
*   Data ingestion from various sources (NetFlow, NIDS logs, syslog).
*   Advanced AI/ML analysis for anomaly detection and threat classification.
*   Integration with threat intelligence feeds.
*   Alerting and reporting mechanisms.
*   Integration with Elasticsearch and Kibana for data storage and visualization.