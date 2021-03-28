apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: spinnaker-ingress
  annotations:
    kubernetes.io/ingress.global-static-ip-name: ${ADP_CONFIG_GCP_GKE_CLUSTER}-lb-main
    networking.gke.io/managed-certificates: spinnaker-cert
    kubernetes.io/ingress.class: "gce"
spec:
  backend:
    serviceName: spin-deck
    servicePort: 9000
---
apiVersion: networking.gke.io/v1
kind: ManagedCertificate
metadata:
  name: spinnaker-cert
spec:
  domains:
    - spinnaker.${ADP_CONFIG_DNS_DOMAIN}