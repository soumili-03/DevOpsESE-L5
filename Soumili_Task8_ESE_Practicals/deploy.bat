@echo off
echo ========================================
echo IoT Sensor API - Auto-Scaling Demo
echo ========================================
echo.

REM Step 1: Build Docker image
echo Step 1: Building Docker image...
docker build -t iot-sensor-api:latest .
if %errorlevel% neq 0 (
    echo ERROR: Docker build failed!
    pause
    exit /b 1
)
echo Docker image built successfully!
echo.

REM Step 2: Enable metrics-server (required for HPA)
echo Step 2: Checking metrics-server...
kubectl get deployment metrics-server -n kube-system >nul 2>&1
if %errorlevel% neq 0 (
    echo Installing metrics-server...
    kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
    timeout /t 5 /nobreak >nul
    kubectl patch deployment metrics-server -n kube-system --type='json' -p='[{"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--kubelet-insecure-tls"}]'
    echo Waiting for metrics-server to be ready...
    timeout /t 30 /nobreak >nul
) else (
    echo metrics-server already installed
)
echo.

REM Step 3: Deploy application
echo Step 3: Deploying iot-sensor-api...
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
if %errorlevel% neq 0 (
    echo ERROR: Deployment failed!
    pause
    exit /b 1
)
echo Deployment created successfully!
echo.

REM Step 4: Wait for deployment to be ready
echo Step 4: Waiting for pods to be ready...
kubectl wait --for=condition=ready pod -l app=iot-sensor-api --timeout=120s
if %errorlevel% neq 0 (
    echo WARNING: Pods may not be ready yet. Continuing anyway...
)
echo.

REM Step 5: Create HPA
echo Step 5: Creating Horizontal Pod Autoscaler...
kubectl apply -f hpa.yaml
if %errorlevel% neq 0 (
    echo ERROR: HPA creation failed!
    pause
    exit /b 1
)
echo HPA created successfully!
echo.

REM Step 6: Display status
echo Step 6: Current Status
echo ========================================
echo.
echo Pods:
kubectl get pods -l app=iot-sensor-api
echo.
echo Service:
kubectl get svc iot-sensor-api
echo.
echo HPA:
kubectl get hpa iot-sensor-api-hpa
echo.
echo ========================================
echo.
echo Deployment Complete!
echo.
echo The API is accessible at: http://localhost:30081
echo.
echo To test the API:
echo   curl http://localhost:30081/
echo   curl http://localhost:30081/sensor/temperature
echo   curl http://localhost:30081/sensor/humidity
echo.
echo To generate load and test auto-scaling:
echo   python load_generator.py 20 180
echo.
echo To monitor scaling:
echo   kubectl get hpa iot-sensor-api-hpa --watch
echo   kubectl get pods -l app=iot-sensor-api --watch
echo.
pause
