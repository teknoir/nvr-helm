# Teknoir AI NVR Helm Chart

This chart deploys Teknoir AI NVRs to a Kubernetes cluster.

> The implementation of the Helm chart is right now the bare minimum to get it to work.

## Usage in Teknoir platform
Use the HelmChart to deploy the Triton Inference Server to a Device.

```yaml
---
apiVersion: helm.cattle.io/v1
kind: HelmChart
metadata:
  name: nvr
  namespace: default
spec:
  repo: https://teknoir.github.io/nvr-helm
  chart: nvr
  targetNamespace: default
  valuesContent: |-
    instances:
      TBD
```

## Example values.yaml

```yaml
# Values needed for Teknoir AI NVR
nvr:
  TBD
```

## Adding the repository

```bash
helm repo add teknoir-nvr https://teknoir.github.io/nvr-helm/
```

## Installing the chart

```bash
helm install nvr teknoir-nvr/nvr -f values.yaml
```