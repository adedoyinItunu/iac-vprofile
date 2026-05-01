# MongoDB + Mongo Express on Kubernetes — Week 10 Hands-on

A two-tier deployment on a local Minikube cluster: MongoDB (database) + Mongo Express (web UI), wired together with a Secret for credentials and a ConfigMap for the hostname.

**Author:** globalitunu
**Bootcamp:** She Codes Africa DevOps — Week 10 (Kubernetes Class 1)

---

## What this builds

```
       Browser (you)
            |
            |  http://<minikube-ip>:30001
            v
   ┌──────────────────────────┐
   │  mongo-express-service   │   (type: LoadBalancer, exposed via nodePort)
   └────────────┬─────────────┘
                |
                v
   ┌──────────────────────────┐
   │   mongo-express pod      │   reads ME_CONFIG_MONGODB_*
   │   (web UI)               │   env vars from Secret + ConfigMap
   └────────────┬─────────────┘
                |
                |  resolves "mongodb-service" via cluster DNS
                v
   ┌──────────────────────────┐
   │   mongodb-service        │   (type: ClusterIP, internal-only)
   └────────────┬─────────────┘
                |
                v
   ┌──────────────────────────┐
   │   mongodb pod            │   reads MONGO_INITDB_ROOT_USERNAME
   │   (database)             │   and password from Secret
   └──────────────────────────┘
```

Six K8s objects in total:
- 1 Secret (MongoDB admin credentials)
- 1 ConfigMap (Mongo server hostname)
- 2 Deployments (MongoDB + Mongo Express)
- 2 Services (one internal, one external)

---

## File layout

```
k8s-manifests/
├── mongo-secret.yaml       ← apply FIRST (others reference it)
├── mongo.yaml              ← MongoDB Deployment + internal Service
├── mongo-configmap.yaml    ← Hostname for Mongo Express to find Mongo
└── mongo-express.yaml      ← Web UI Deployment + external Service
```

Apply order matters — Secret first, then everything else.

---

## How to run

Prereqs: Minikube + kubectl installed (see `SUBMISSION-GUIDE.md` for install instructions).

```bash
minikube start

# Apply in this order
kubectl apply -f k8s-manifests/mongo-secret.yaml
kubectl apply -f k8s-manifests/mongo.yaml
kubectl apply -f k8s-manifests/mongo-configmap.yaml
kubectl apply -f k8s-manifests/mongo-express.yaml

# Wait until both pods are Running
kubectl get pods --watch

# Open the Mongo Express UI in your browser
minikube service mongo-express-service
```

Login with: `username` / `password` (the values base64-encoded in the Secret).

---

## Key concepts demonstrated

| Concept | Where you see it |
|---------|-----------------|
| **Pod** | Each Deployment runs one pod with a single container |
| **Deployment** | Both `mongodb-deployment` and `mongo-express` |
| **Service (ClusterIP)** | `mongodb-service` — only reachable inside the cluster |
| **Service (LoadBalancer)** | `mongo-express-service` — exposed externally via nodePort |
| **Labels / selectors** | `app: mongodb` and `app: mongo-express` are how Services find their pods |
| **Secret** | `mongodb-secret` holds the admin credentials (base64-encoded) |
| **ConfigMap** | `mongodb-configmap` holds the Mongo hostname |
| **secretKeyRef / configMapKeyRef** | How env vars are populated from Secret/ConfigMap values |
| **Cluster DNS** | The ConfigMap's value `mongodb-service` is a DNS name that resolves inside the cluster |

---

## Cleanup

```bash
# Delete the K8s resources
kubectl delete -f k8s-manifests/

# Stop the cluster (preserves it for later)
minikube stop

# Or delete it entirely
minikube delete
```
