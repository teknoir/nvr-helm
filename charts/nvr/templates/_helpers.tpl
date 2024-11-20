{{/*
Expand the name of the chart.
*/}}
{{- define "nvr.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "nvr.fullname" -}}
{{- if .Values.nvr.fullnameOverride }}
{{- .Values.nvr.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Generate the Environment Variable ConfigMap name.
*/}}
{{- define "nvr.configmapName" -}}
{{- printf "%s-env-config" (include "nvr.fullname" .) }}
{{- end }}

{{/*
Generate the NvDsAnalytics ConfigMap name.
*/}}
{{- define "nvr.analyticsConfigmapName" -}}
{{- printf "%s-analytics-config" (include "nvr.fullname" .) }}
{{- end }}
