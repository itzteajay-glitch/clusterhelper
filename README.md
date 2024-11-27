# Cluster Tool Web App

A web-based application to streamline Kubernetes cluster management tasks. This tool provides an interactive UI for setting up Helm charts, managing namespaces, and configuring LoadBalancer IPs, built with Flask.

## Features

- **Search TrueCharts Helm Charts**: Verify the existence of charts across multiple trains.
- **Set Up Helm Charts**: Configure charts with custom namespaces and versions.
- **LoadBalancer IP Configuration**: Optionally add or comment out LoadBalancer IP settings.
- **Git Integration**: Push configurations to Git and reconcile with Flux.

## Getting Started

Follow the instructions below to install and run the application.

### Prerequisites

- **Python 3.7+**
- **Pip** (Python package manager)
- **Git** (for version control and Flux integration)

### Installation

1. **Clone the repository**:
    ```bash
    git clone https://github.com/yourusername/cluster-tool-web.git
    cd cluster-tool-web
    ```

2. **Set up a virtual environment** (optional but recommended):
    ```bash
    python -m venv venv
    source venv/bin/activate  # On Windows: venv\Scripts\activate
    ```

3. **Install dependencies**:
    ```bash
    pip install -r requirements.txt
    ```

### Running the Application

1. **Start the Flask development server**:
    ```bash
    python run.py
    ```

2. **Access the application**:
    Open a web browser and navigate to `http://127.0.0.1:5000`.

### Usage

1. **Search for Helm Charts**:
   - Enter the chart name and submit.
   - The app will search for the chart across TrueCharts trains and display the results.

2. **Set Up a Helm Chart**:
   - Provide the chart name, namespace, and (optional) LoadBalancer IP.
   - Review and confirm the generated configuration.

3. **Git Integration** (optional):
   - Push the configuration to Git and reconcile with Flux via the CLI.

### File Structure

```
cluster_tool_web/
├── app/
│   ├── __init__.py         # Flask app factory
│   ├── routes.py           # Routes for handling API endpoints
│   ├── utils.py            # Helper functions for chart management
│   ├── templates/          # HTML templates
│   │   ├── base.html       # Base template
│   │   ├── index.html      # Main page
│   ├── static/             # Static files (CSS, JS, images)
│       ├── styles.css      # Styling for the app
├── run.py                  # Entry point for the Flask app
├── requirements.txt        # Dependencies
└── README.md               # Project documentation
```

### API Endpoints

#### `GET /`
- **Description**: Renders the main UI.
- **Response**: HTML page.

#### `POST /search-chart`
- **Description**: Search for a chart across TrueCharts trains.
- **Request Body**:
    ```json
    {
        "chart_name": "string"
    }
    ```
- **Response**:
    ```json
    [
        {
            "train": "string",
            "exists": true,
            "version": "string"
        }
    ]
    ```

#### `POST /setup-chart`
- **Description**: Set up a Helm chart with a namespace and optional LoadBalancer IP.
- **Request Body**:
    ```json
    {
        "chart_name": "string",
        "namespace": "string",
        "loadbalancer_ip": "string"
    }
    ```
- **Response**:
    ```json
    {
        "success": true
    }
    ```

### Future Enhancements

- Add authentication for secure access.
- Integrate with Kubernetes APIs for dynamic cluster management.
- Improve error handling and validation.

### Contributing

Contributions are welcome! To contribute:
1. Fork the repository.
2. Create a new branch (`git checkout -b feature-branch`).
3. Commit your changes (`git commit -m 'Add new feature'`).
4. Push to the branch (`git push origin feature-branch`).
5. Open a pull request.

### License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

Feel free to customize the `README.md` to better suit your project!