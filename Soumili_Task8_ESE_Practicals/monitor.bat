@echo off
echo ========================================
echo Auto-Scaling Monitor
echo ========================================
echo.
echo This will monitor HPA and Pods in real-time
echo Press Ctrl+C to stop monitoring
echo.
echo Starting in 3 seconds...
timeout /t 3 /nobreak >nul

start "HPA Monitor" cmd /k "kubectl get hpa iot-sensor-api-hpa --watch"
timeout /t 1 /nobreak >nul
start "Pods Monitor" cmd /k "kubectl get pods -l app=iot-sensor-api --watch"
timeout /t 1 /nobreak >nul
start "Top Pods" cmd /k "for /L %%i in (1,0,2) do @(kubectl top pods -l app=iot-sensor-api & timeout /t 5 /nobreak >nul & cls)"

echo.
echo Monitoring windows opened!
echo - HPA Monitor: Shows autoscaler status
echo - Pods Monitor: Shows pod scaling
echo - Top Pods: Shows CPU/Memory usage
echo.
echo Now run the load generator in another window:
echo   python load_generator.py 20 180
echo.
pause
