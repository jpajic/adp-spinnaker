# Joys and Pains

## Cloud Provider Selection
* Pain: AWS discontinued free credits and EKS nodes are not in "always free" tier.
* Pain: Azure region restrictions + old account matching makes it difficult to get 250$ free trial credits
* Joy: Google Cloud account creation and activation of free trial was smooth

## Google Cloud
* Joy: Interesting experience to work with GCP
* Joy: Very sophisticated managed Kubernetes distribution with comfortable integrations into other GCP services
* Joy: Simple to configure and highly performant networking, load balancing, SSL certificates, autoscaling
* Pain: Lots of services and integrations means a lot of documentation to read and complex concepts to understand beforehand
* Pain: Terraform integration is sometimes buggy, requests are batched and sent in the wrong order or cause race conditions when enabling GCP APIs

## Spinnaker Setup and Configuration
* Joy: (Unofficial) Helm chart available with many configuration options
* Pain: Helm chart buggy for some use cases (e.g. GCS using Workload Identity)
* Joy: Configuration-as-Code makes automated deployment straightforward
* Pain: Documentation on advanced configuration settings is spotty
* Pain: Delays from configuring resources (e.g. GitHub account) until they become available in the web interface

## Spinnaker Usage
* Joy: Triggers for automated deployment on manifest changes in repository
* Joy: Pretty visual representations of pipeline executions and current infrastructure, deployment, and application states
* Pain: Unintuitive namings of resources (cluster, load balancer, etc. all mean something else in other contexts. E.g. load balancer would be ingress in K8s, not service)
* Pain: Sometimes confusing error messages