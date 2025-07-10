# Deploying Flask Application to K3s with Helm

## 1. Containerize Your Flask App

- Make sure your Flask app has a `Dockerfile` that builds and runs your app.
- Example `Dockerfile`:
  ```dockerfile
  FROM python:3.10-slim
  WORKDIR /app
  COPY requirements.txt .
  RUN pip install --no-cache-dir -r requirements.txt
  COPY . .
  CMD ["python", "app.py"]
  ```
- Build and push your image to a registry (Docker Hub, GitHub Container Registry, etc.):
  ```bash
  docker build -t <your-username>/rsschool-flask:latest .
  docker push <your-username>/rsschool-flask:latest
  ```

---

## 2. Create a Helm Chart

- In your repo, run:
  ```bash
  helm create flask-app
  ```
- This creates a `flask-app/` directory with a sample chart.

---

## 3. Edit the Helm Chart

- In `flask-app/values.yaml`, set:
  ```yaml
  image:
    repository: <your-username>/rsschool-flask
    pullPolicy: IfNotPresent
    tag: "latest"
  ```
- In `flask-app/templates/deployment.yaml`, ensure the container port matches your Flask app (usually 5000).
- In `flask-app/templates/service.yaml`, set the service type to `ClusterIP` (default) or `NodePort` if you want direct access.

---

## 4. (Optional) Add Ingress

- In `flask-app/templates/ingress.yaml`, configure an Ingress resource if you want to expose your app via a domain and TLS.
- Example:
  ```yaml
  apiVersion: networking.k8s.io/v1
  kind: Ingress
  metadata:
    name: flask-app
    annotations:
      kubernetes.io/ingress.class: nginx
  spec:
    rules:
      - host: flask.example.com
        http:
          paths:
            - path: /
              pathType: Prefix
              backend:
                service:
                  name: flask-app
                  port:
                    number: 5000
  ```

---

## 5. Deploy to K3s

- Package and install the chart:
  ```bash
  helm install flask-app ./flask-app -n <namespace> --create-namespace
  ```
  Or, if you want to upgrade:
  ```bash
  helm upgrade --install flask-app ./flask-app -n <namespace> --create-namespace
  ```

---

## 6. Verify Deployment

- Check pods:
  ```bash
  kubectl get pods -n <namespace>
  ```
- Check service:
  ```bash
  kubectl get svc -n <namespace>
  ```
- If using Ingress, check:
  ```bash
  kubectl get ingress -n <namespace>
  ```

---

## 7. (Optional) Automate with GitHub Actions

- Add a step in your workflow to build, push, and deploy your Helm chart.

---

## **Summary of Steps**

1. Containerize your Flask app and push the image to a registry.
2. Create a Helm chart (`helm create flask-app`).
3. Edit the chart to use your image and set ports.
4. (Optional) Add an Ingress resource.
5. Install/upgrade the chart in your K3s cluster.
6. Verify everything is running.

---

**If you want, I can generate a minimal Helm chart for your Flask app and show you the exact files to edit! Just let me know your image name and desired namespace.**
