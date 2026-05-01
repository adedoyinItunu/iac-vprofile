# vprofile-action — Week 11 GitOps Application Repo

The application side of the Week 11 GitOps project. Forked from `MHIZokuchi/vprofile-action` and customised with our own Kubernetes manifests, Helm chart, and GitHub Actions workflow.

**Author:** globalitunu
**Class:** Week 11 — Class 2

---

## What this does

```
   git push to main
        │
        v
   ┌──────────────┐
   │  Testing     │  Maven test + checkstyle
   └──────┬───────┘
          v
   ┌────────────────────┐
   │ BUILD_AND_PUBLISH  │  docker build → docker push to ECR
   └────────┬───────────┘
            v
   ┌──────────────┐
   │ DeployToEKS  │  install Ingress controller, create ECR pull secret,
   │              │  helm upgrade --install
   └──────┬───────┘
          v
   ┌──────────────┐
   │  Live URL    │  http://<aws-load-balancer-hostname>
   └──────────────┘
```

---

## File layout

```
vprofile-action/
├── README.md
├── .gitignore
├── pom.xml                    ← Maven build config (from upstream)
├── src/                       ← Java source (from upstream)
├── Dockerfile                 ← packages WAR into Tomcat container (from upstream)
├── kubernetes/                ← raw K8s manifests (for reference / kubectl apply)
│   ├── vproapp-deployment.yml
│   ├── vproapp-service.yml
│   └── vproapp-ingress.yml
├── helm/vprofilecharts/       ← Helm chart wrapping the manifests
│   ├── Chart.yaml
│   ├── values.yaml            ← default values (overridden at deploy time)
│   └── templates/             ← copies of the K8s manifests
└── .github/workflows/
    └── main.yml               ← the application pipeline
```

---

## Required GitHub Secrets

In Settings → Secrets and variables → Actions, add three secrets:

| Name | Value |
|------|-------|
| `AWS_ROLE_ARN` | Same OIDC role ARN as the iac-vprofile repo |
| `AWS_REGION` | Same region as iac-vprofile |
| `REGISTRY` | ECR registry hostname ONLY — `123456789012.dkr.ecr.us-east-2.amazonaws.com`. **No protocol, no repo name, no trailing slash.** |

⚠️ **The `REGISTRY` secret format matters.** The workflow concatenates:
```
$REGISTRY / $ECR_REPOSITORY : $IMAGE_TAG
```
If `REGISTRY` already includes the repo name, you get `.../vprofileapp/vprofileapp:8` and image pulls fail. Just the hostname.

---

## Prerequisites

You need iac-vprofile to be deployed first — the EKS cluster, ECR repo, and IAM role all come from there.

---

## How the three K8s objects fit together

```
   Internet
       │
       │
       v
   AWS Load Balancer (provisioned by the Ingress Controller's LB Service)
       │
       v
   NGINX Ingress Controller (in ingress-nginx namespace)
       │
       │  reads spec from Ingress resources, routes accordingly
       v
   Ingress resource (vproapp-ingress)
       │
       │  rule: send everything to vproapp-service:8080
       v
   Service (vproapp-service)
       │
       │  selector: app=vproapp — finds pods with that label
       v
   Pod (vproapp Deployment, label app=vproapp)
       │
       v
   Tomcat → vprofile WAR file → 200 OK
```

The label `app: vproapp` is the thread connecting Deployment → Service → Ingress. Change it in one place without changing the others and the chain breaks.

---

## Cleanup

Don't forget — you're paying for the EKS cluster and ECR images while these are running.

```bash
# Tear down the K8s deployment
helm uninstall vproapp-stack
kubectl delete -n ingress-nginx svc ingress-nginx-controller   # frees the LB

# Then go to iac-vprofile and run terraform destroy via the workflow
```
