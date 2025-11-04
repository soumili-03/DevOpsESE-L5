@echo off
echo ========================================
echo Cleaning up IoT Sensor API resources
echo ========================================
echo.

echo Deleting HPA...
kubectl delete -f hpa.yaml

echo Deleting Service...
kubectl delete -f service.yaml

echo Deleting Deployment...
kubectl delete -f deployment.yaml

echo.
echo Cleanup complete!
echo.
pause
