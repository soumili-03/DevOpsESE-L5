# IoT Sensor API - Kubernetes Auto-Scaling Demo

This project demonstrates Kubernetes Horizontal Pod Autoscaling (HPA) with an IoT sensor API application.

## Project Structure

```
k8s-autoscale-demo/
├── app.py                  # Flask application (IoT sensor API)
├── requirements.txt        # Python dependencies
├── Dockerfile             # Docker image definition
├── deployment.yaml        # Kubernetes deployment with resource limits
├── service.yaml           # Kubernetes service (NodePort)
├── hpa.yaml              # Horizontal Pod Autoscaler configuration
├── load_generator.py     # Load testing script
├── deploy.bat            # Automated deployment script
├── cleanup.bat           # Cleanup script
└── README.md             # This file
```

## Prerequisites

1. **Docker Desktop** with Kubernetes enabled
   - Open Docker Desktop
   - Go to Settings → Kubernetes
   - Check "Enable Kubernetes"
   - Click "Apply & Restart"

2. **Python 3.x** installed (for load generator)
   - Install requests library: `pip install requests`

3. **kubectl** (comes with Docker Desktop)

## Quick Start (1-Hour Setup)

### Step 1: Verify Prerequisites (2 minutes)

Open PowerShell or Command Prompt and verify:

```bash
# Check Docker
docker --version

# Check Kubernetes
kubectl version --client
kubectl cluster-info

# Check Python
python --version
```

### Step 2: Clone/Create Project Structure (2 minutes)

Create a directory for the project:

```bash
mkdir k8s-autoscale-demo
cd k8s-autoscale-demo
```

Copy all the provided files into this directory.

### Step 3: Deploy Everything (5 minutes)

Run the automated deployment script:

```bash
deploy.bat
```

This script will:
1. Build the Docker image
2. Install/configure metrics-server (required for HPA)
3. Deploy the application
4. Create the service
5. Set up the Horizontal Pod Autoscaler
6. Display the current status

**Expected Output:**
- Docker image built: `iot-sensor-api:latest`
- Deployment created with 1 pod
- Service exposed on NodePort 30081
- HPA configured (min=1, max=5, CPU=50%)

### Step 4: Verify Deployment (3 minutes)

Check the status:

```bash
# View pods
kubectl get pods -l app=iot-sensor-api

# View service
kubectl get svc iot-sensor-api

# View HPA
kubectl get hpa iot-sensor-api-hpa

# Check pod resource usage
kubectl top pods -l app=iot-sensor-api
```

### Step 5: Test the API (2 minutes)

Test the endpoints:

```bash
# Health check
curl http://localhost:30081/health

# Home endpoint
curl http://localhost:30081/

# Temperature sensor
curl http://localhost:30081/sensor/temperature

# Humidity sensor
curl http://localhost:30081/sensor/humidity
```

Or open in browser: http://localhost:30081

### Step 6: Generate Load and Observe Scaling (10-15 minutes)

#### Terminal 1: Monitor HPA

```bash
kubectl get hpa iot-sensor-api-hpa --watch
```

#### Terminal 2: Monitor Pods

```bash
kubectl get pods -l app=iot-sensor-api --watch
```

#### Terminal 3: Generate Load

```bash
# Generate load with 20 threads for 180 seconds (3 minutes)
python load_generator.py 20 180
```

**What to Observe:**

1. **Initial State**: 1 pod running, low CPU usage
2. **Under Load** (after 30-60 seconds):
   - CPU utilization increases above 50%
   - HPA triggers scaling
   - Additional pods are created (up to 5)
3. **After Load** (after stopping load):
   - CPU utilization decreases
   - HPA scales down (after stabilization window)
   - Pods return to minimum (1)

### Step 7: Advanced Monitoring (Optional)

View detailed HPA status:

```bash
kubectl describe hpa iot-sensor-api-hpa
```

View pod resource usage:

```bash
kubectl top pods -l app=iot-sensor-api
```

View deployment events:

```bash
kubectl describe deployment iot-sensor-api
```

## Manual Step-by-Step Instructions

If you prefer manual control instead of using the deploy.bat script:

### 1. Build Docker Image

```bash
docker build -t iot-sensor-api:latest .
```

### 2. Install Metrics Server

```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Patch for Docker Desktop (allows insecure TLS)
kubectl patch deployment metrics-server -n kube-system --type='json' -p='[{"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--kubelet-insecure-tls"}]'

# Wait for metrics-server to be ready
kubectl wait --for=condition=ready pod -l k8s-app=metrics-server -n kube-system --timeout=120s
```

### 3. Deploy Application

```bash
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml

# Wait for pods to be ready
kubectl wait --for=condition=ready pod -l app=iot-sensor-api --timeout=120s
```

### 4. Create HPA

```bash
kubectl apply -f hpa.yaml
```

### 5. Verify

```bash
kubectl get all -l app=iot-sensor-api
kubectl get hpa
```

## Configuration Details

### Resource Limits (deployment.yaml)

```yaml
resources:
  requests:
    cpu: 100m      # 0.1 CPU cores
    memory: 128Mi
  limits:
    cpu: 500m      # 0.5 CPU cores
    memory: 256Mi
```

### HPA Configuration (hpa.yaml)

- **Min Replicas**: 1
- **Max Replicas**: 5
- **Target CPU**: 50%
- **Scale Up**: Immediate (0s stabilization)
- **Scale Down**: 60s stabilization window

## Troubleshooting

### Metrics Not Available

If `kubectl top pods` shows "Metrics not available yet":

1. Wait 1-2 minutes after deployment
2. Check metrics-server: `kubectl get pods -n kube-system | findstr metrics`
3. Restart metrics-server: `kubectl rollout restart deployment metrics-server -n kube-system`

### HPA Not Scaling

1. Verify metrics are available: `kubectl top pods`
2. Check HPA status: `kubectl describe hpa iot-sensor-api-hpa`
3. Ensure CPU usage exceeds 50%: `kubectl top pods -l app=iot-sensor-api`
4. Check HPA events: `kubectl get events --sort-by=.metadata.creationTimestamp`

### Pods in ImagePullBackOff

This means Kubernetes can't find the Docker image. Ensure:

1. Image was built: `docker images | findstr iot-sensor-api`
2. Deployment uses `imagePullPolicy: Never`
3. Rebuild if needed: `docker build -t iot-sensor-api:latest .`

### Service Not Accessible

1. Check service: `kubectl get svc iot-sensor-api`
2. Check pod status: `kubectl get pods -l app=iot-sensor-api`
3. Check pod logs: `kubectl logs -l app=iot-sensor-api`
4. Verify port forwarding: `kubectl port-forward svc/iot-sensor-api 8080:8080`

## Cleanup

To remove all resources:

```bash
cleanup.bat
```

Or manually:

```bash
kubectl delete -f hpa.yaml
kubectl delete -f service.yaml
kubectl delete -f deployment.yaml
```

## Expected Results

✅ **Initial State:**
- 1 pod running
- CPU usage: 0-5%
- HPA shows: TARGETS: 0%/50%

✅ **Under Load:**
- CPU usage increases to 80-150%+
- HPA shows: TARGETS: 80%/50% (or higher)
- Pods scale from 1 → 2 → 3 → 4 → 5 (within 1-2 minutes)

✅ **After Load Stops:**
- CPU usage decreases
- After 60s stabilization, pods scale down
- Returns to 1 pod (within 2-3 minutes)

## API Endpoints

- `GET /` - Home/status endpoint
- `GET /health` - Health check endpoint
- `GET /sensor/temperature` - Get temperature reading
- `GET /sensor/humidity` - Get humidity reading

## Load Generator Usage

```bash
# Default: 10 threads for 300 seconds
python load_generator.py

# Custom: 20 threads for 180 seconds
python load_generator.py 20 180

# Heavy load: 50 threads for 120 seconds
python load_generator.py 50 120
```

## Timeline for 1-Hour Completion

- **0-5 min**: Setup prerequisites and verify environment
- **5-10 min**: Create project files and structure
- **10-15 min**: Run deploy.bat and verify deployment
- **15-20 min**: Test API endpoints
- **20-35 min**: Generate load and observe scaling up
- **35-50 min**: Observe scaling down after load stops
- **50-60 min**: Document results and cleanup

## Key Learning Points

1. **Resource Limits**: Critical for HPA to function properly
2. **Metrics Server**: Required for CPU/memory-based autoscaling
3. **Stabilization Windows**: Prevent thrashing (rapid scale up/down)
4. **CPU Targets**: 50% allows room for scaling before saturation
5. **NodePort**: Easy local access for testing

## Success Criteria

✅ Application deployed with resource limits
✅ HPA configured (min=1, max=5, CPU=50%)
✅ Under load, pods scale from 1 to 5
✅ After load stops, pods scale back to 1
✅ API remains accessible throughout scaling

## Repository: k8s-autoscale-demo

All files are ready for commit to your repository!
