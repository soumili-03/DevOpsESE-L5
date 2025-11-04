# QUICK START GUIDE - IoT Sensor API Auto-Scaling
# Complete this in 1 hour on Windows!

## ⚡ FASTEST PATH TO SUCCESS (5 Steps)

### STEP 1: Verify Prerequisites (2 minutes)
Open PowerShell or CMD and run:
```
docker --version
kubectl cluster-info
python --version
```
✅ All commands should work. If not, enable Kubernetes in Docker Desktop settings.

### STEP 2: Create Project (2 minutes)
```
mkdir k8s-autoscale-demo
cd k8s-autoscale-demo
```
Download all files from the outputs folder into this directory.

### STEP 3: Install Python Dependencies (1 minute)
```
pip install requests flask
```

### STEP 4: Deploy Everything (5 minutes)
```
deploy.bat
```
Wait for the script to complete. You should see:
- ✅ Docker image built
- ✅ Deployment created
- ✅ Service running on port 30081
- ✅ HPA created

### STEP 5: Test Auto-Scaling (15 minutes)

#### Open 3 Terminal Windows:

**Terminal 1 - Start Monitoring:**
```
monitor.bat
```
This opens 3 windows showing HPA, Pods, and CPU usage.

**Terminal 2 - Test API:**
```
curl http://localhost:30081/health
curl http://localhost:30081/sensor/temperature
```

**Terminal 3 - Generate Load:**
```
python load_generator.py 20 180
```

#### What You'll See:
1. **Minute 0-1**: 1 pod, low CPU (0-10%)
2. **Minute 1-2**: CPU rises to 50%+, HPA triggers
3. **Minute 2-3**: Pods scale to 2, 3, 4, 5
4. **Minute 3-6**: Heavy load, all 5 pods running
5. **Minute 6-7**: Load stops, CPU drops
6. **Minute 7-9**: Pods scale down to 1

## 📊 Expected Output

### Before Load:
```
NAME                             READY   STATUS    RESTARTS   AGE
iot-sensor-api-xxxxxxxxxx-xxxxx   1/1     Running   0          2m

NAME                     REFERENCE                   TARGETS   MINPODS   MAXPODS   REPLICAS
iot-sensor-api-hpa       Deployment/iot-sensor-api   5%/50%    1         5         1
```

### During Load (Peak):
```
NAME                             READY   STATUS    RESTARTS   AGE
iot-sensor-api-xxxxxxxxxx-xxxxx   1/1     Running   0          5m
iot-sensor-api-xxxxxxxxxx-yyyyy   1/1     Running   0          2m
iot-sensor-api-xxxxxxxxxx-zzzzz   1/1     Running   0          2m
iot-sensor-api-xxxxxxxxxx-aaaaa   1/1     Running   0          1m
iot-sensor-api-xxxxxxxxxx-bbbbb   1/1     Running   0          1m

NAME                     REFERENCE                   TARGETS    MINPODS   MAXPODS   REPLICAS
iot-sensor-api-hpa       Deployment/iot-sensor-api   85%/50%    1         5         5
```

### After Load:
```
NAME                             READY   STATUS    RESTARTS   AGE
iot-sensor-api-xxxxxxxxxx-xxxxx   1/1     Running   0          10m

NAME                     REFERENCE                   TARGETS   MINPODS   MAXPODS   REPLICAS
iot-sensor-api-hpa       Deployment/iot-sensor-api   3%/50%    1         5         1
```

## 🔧 Troubleshooting

### Issue: "Metrics not available"
**Solution:**
```
kubectl rollout restart deployment metrics-server -n kube-system
timeout /t 60
```

### Issue: HPA not scaling
**Solution:**
Check if CPU is actually high:
```
kubectl top pods -l app=iot-sensor-api
```
If not, increase load:
```
python load_generator.py 50 180
```

### Issue: Can't access http://localhost:30081
**Solution:**
```
kubectl get pods -l app=iot-sensor-api
kubectl logs -l app=iot-sensor-api
kubectl describe svc iot-sensor-api
```

### Issue: Pods stuck in "Pending"
**Solution:**
Check Docker Desktop has enough resources:
- Settings → Resources → Advanced
- Increase CPUs to 4 and Memory to 4GB

## 📸 Screenshot Checklist

Capture these for your submission:
1. ✅ `kubectl get pods -l app=iot-sensor-api` (showing 5 pods)
2. ✅ `kubectl get hpa` (showing >50% CPU and 5 replicas)
3. ✅ `kubectl top pods` (showing high CPU usage)
4. ✅ Browser showing http://localhost:30081 working
5. ✅ Load generator output showing requests sent

## 🧹 Cleanup
When done:
```
cleanup.bat
```

## ⏱️ 1-Hour Timeline

- **0-10 min**: Setup and deploy
- **10-15 min**: Verify deployment and test API
- **15-30 min**: Generate load and observe scale UP
- **30-45 min**: Observe scale DOWN
- **45-55 min**: Take screenshots and document
- **55-60 min**: Cleanup and final verification

## 🎯 Success Criteria Checklist

- ✅ App deployed with resource limits (CPU: 100m-500m, Memory: 128Mi-256Mi)
- ✅ HPA configured (min=1, max=5, target=50%)
- ✅ Metrics-server running and providing metrics
- ✅ API accessible on http://localhost:30081
- ✅ Under load: CPU >50%, pods scale from 1 to 5
- ✅ After load: CPU <50%, pods scale back to 1
- ✅ No errors or crashes during scaling

## 📝 Files You Need

All files are in the outputs folder:
- app.py
- requirements.txt
- Dockerfile
- deployment.yaml
- service.yaml
- hpa.yaml
- load_generator.py
- deploy.bat
- monitor.bat
- cleanup.bat
- README.md

## 🚀 READY TO START!

Run this command to begin:
```
deploy.bat
```

Good luck! 🎉
