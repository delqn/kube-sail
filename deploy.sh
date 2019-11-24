#!/bin/bash

set -auexo pipefail

cat <<EOF | KUBECONFIG=$HOME/.kube/config kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: meshed-service
  namespace: delqn
spec:
  selector:
    matchLabels:
      app: ws-app
  replicas: 2
  template:
    metadata:
      labels:
        app: ws-app
    spec:
      containers:
        - name: app
          imagePullPolicy: Always
          image: docker.io/kennethreitz/httpbin
          ports:
            - containerPort: 80
          livenessProbe:
            httpGet:
              path: /status/200
              port: 80
            initialDelaySeconds: 3
            periodSeconds: 3
      imagePullSecrets:
        - name: delqn-acr-creds
---

apiVersion: v1
kind: Service
metadata:
  name: service
  namespace: delqn
spec:
  selector:
    app: ws-app
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80

---

apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: ks-mis-li-ingress
  namespace: delqn
spec:
  rules:
  - host: ks.mis.li
    http:
      paths:
      - path: /*
        backend:
          serviceName: service
          servicePort: 80
EOF
