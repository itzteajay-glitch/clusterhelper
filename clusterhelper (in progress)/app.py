import os
from flask import Flask, render_template, request, redirect, url_for
import subprocess
import requests

app = Flask(__name__)

# Root Route - Display the chart search form
@app.route('/', methods=['GET', 'POST'])
def index():
    if request.method == 'POST':
        chart_name = request.form['chart_name']
        namespace = request.form['namespace']
        loadbalancer_ip = request.form.get('loadbalancer_ip', None)
        
        # Search for the chart
        chart_found, latest_version = search_chart(chart_name)
        if chart_found:
            return redirect(url_for('configure', chart=chart_name, version=latest_version, namespace=namespace, ip=loadbalancer_ip))
        else:
            return render_template('index.html', error="Chart not found!")
    
    return render_template('index.html')

# Route to configure YAML files after chart search
@app.route('/configure', methods=['GET', 'POST'])
def configure():
    chart = request.args.get('chart')
    version = request.args.get('version')
    namespace = request.args.get('namespace')
    ip = request.args.get('ip')

    if request.method == 'POST':
        # Modify YAML files based on the form data
        modify_yaml_files(chart, version, namespace, ip)
        
        # Optionally, push to Git
        if request.form.get('push_to_git'):
            git_commit_push()
        
        return "Configuration Updated and Committed!"

    # Render the configure page on GET request
    return render_template('configure.html', chart=chart, version=version, namespace=namespace, ip=ip)

def search_chart(chart_name):
    """Search for the chart in TrueCharts repository."""
    trains = ["incubator", "library", "premium", "stable", "system"]
    for train in trains:
        url = f"https://truecharts.org/charts/{train}/{chart_name}/"
        response = requests.head(url)
        if response.status_code == 404:
            continue
        else:
            # Get the latest version of the chart (simplified for this example)
            chart_url = f"https://raw.githubusercontent.com/truecharts/public/refs/heads/master/charts/{train}/{chart_name}/Chart.yaml"
            chart_data = requests.get(chart_url).text
            version = chart_data.split("version:")[1].strip().split("\n")[0]
            return True, version
    return False, None

def modify_yaml_files(chart, version, namespace, ip):
    """Modify the helm-release.yaml and namespace.yaml based on form input."""
    # For simplicity, let's just output a modification to the console (you can modify files here)
    print(f"Modifying YAML files for {chart} (version {version}) in namespace {namespace} with IP {ip}")

def git_commit_push():
    """Commit and push changes to Git."""
    print("Committing and pushing changes to Git...")
    subprocess.run(["git", "add", "-A"])
    subprocess.run(["git", "commit", "-m", "Updated helm chart configuration"])
    subprocess.run(["git", "push"])

if __name__ == '__main__':
    app.run(debug=True)