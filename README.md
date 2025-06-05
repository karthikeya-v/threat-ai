# AI-Powered Network Threat Intelligence System (Julia-based)

This project is an AI-powered network threat intelligence system built with Julia.
Its goal is to provide an accessible and performant tool for monitoring network
traffic and logs, detecting anomalies, identifying known threats, and gaining
actionable insights into security posture.

**Current Capabilities:**
*   Loads sample network flow data from `data/sample_netflow.csv`.
*   Performs basic anomaly detection using K-Means clustering on the sample data.
*   Outputs potential anomalies to the console.

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

2.  **Review Sample Data:**
    Before running, you can inspect the sample data used for demonstration in `data/sample_netflow.csv`.

3.  **Build and run the Julia application container:**
    ```bash
    docker-compose build
    docker-compose up
    ```

## Running the System (Basic)

The `docker-compose up` command will start the core Julia application.
The application will:
1.  Load network flow data from `data/sample_netflow.csv`.
2.  Preprocess this data.
3.  Apply a K-Means clustering algorithm to identify potential anomalies based on features like bytes/packets sent and destination ports.
4.  Print any detected anomalies to the console log.

You should see output from the Julia application, including log messages about data loading, processing, and the results of the anomaly detection.

To stop the system, press `Ctrl+C` in the terminal where `docker-compose up` is running, or run:
```bash
docker-compose down
```

## Project Structure

*   `src/`: Contains the Julia application code.
    *   `Project.toml`: Julia project dependencies.
    *   `main.jl`: Main entry point for the Julia application.
    *   `data_processing.jl`: Module for loading and preprocessing data.
    *   `anomaly_detection.jl`: Module for AI-based anomaly detection.
*   `data/`: Contains sample data.
    *   `sample_netflow.csv`: Sample network flow data for demonstration.
*   `config/`: For configuration files (currently empty).
*   `scripts/`: For utility scripts (currently empty).
*   `tests/`: For test code (currently empty).
*   `Dockerfile`: Defines the Docker image for the Julia application.
*   `docker-compose.yml`: Configures services for Docker Compose.

## Future Enhancements

Refer to the Product Requirements Document for a full list of planned features, including:
*   Ingestion from various live data sources (NetFlow, NIDS logs, syslog).
*   More advanced AI/ML analysis and threat classification.
*   Integration with threat intelligence feeds.
*   Alerting and reporting mechanisms.
*   Integration with Elasticsearch and Kibana for data storage and visualization.