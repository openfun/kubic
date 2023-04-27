# How to test

It should work to test :

```yaml
kind: Deployment
apiVersion: apps/v1
metadata:
  name: whoami
  labels:
    app: myapp
    name: whoami

spec:
  replicas: 2
  selector:
    matchLabels:
      app: myapp
      task: whoami
  template:
    metadata:
      labels:
        app: myapp
        task: whoami
    spec:
      containers:
        - name: whoami
          image: traefik/whoami
          ports:
            - containerPort: 80
          resources:

---
apiVersion: v1
kind: Service
metadata:
  name: whoami

spec:
  ports:
    - name: http
      port: 80
  selector:
    app: myapp
    task: whoami

---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: whoami-ingress
  annotations:
    kubernetes.io/ingress.class: nginx
    cert-manager.io/issuer: "cert-manager-global"
spec:
  tls:
    - hosts:
        - whoami.scw-tf.fun-plus.fr
      secretName: whoami.scw-tf.fun-plus.fr
  rules:
    - host: whoami.scw-tf.fun-plus.fr
      http:
        paths:
          - pathType: Prefix
            path: "/"
            backend:
              service:
                name: whoami
                port:
                  number: 80

```
