{{/*
Expand the name of the chart.
*/}}
{{- define "chart.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "chart.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
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
Create chart name and version as used by the chart label.
*/}}
{{- define "chart.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "chart.labels" -}}
helm.sh/chart: {{ include "chart.name" . }}
{{ include "chart.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "chart.selectorLabels" -}}
app.kubernetes.io/name: {{ include "chart.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "chart.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "chart.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "chart.concatConfigMapName" -}}
{{ printf "%s-%s" (include "chart.name" .) "config" }}
{{- end }}

{{- define "chart.concatSecretName" -}}
{{ printf "%s-encrypted-%s" (include "chart.name" .) "secret" }}
{{- end }}

{{- define "chart.concatDecryptedSecretName" -}}
{{ printf "%s-%s" (include "chart.name" .) "secret" }}
{{- end }}

{{- define "chart.concaFinalSecretName" -}}
{{ printf "%s-%s" (include "chart.name" .) "secret" }}
{{- end }}

{{- define "chart.mounts" -}}
{{- with .Values.volumeMounts }}
{{- toYaml . | nindent 2 }}
{{- end }}
{{- end }}

{{- define "chart.volumes" -}}
- name: config
  configMap:
    name: {{ include "chart.concatConfigMapName" $ }}
- name: encrypted-secrets
  secret:
    secretName: {{ include "chart.concatSecretName" $ }}
- name: decrypted-secrets
  secret:
    secretName: {{ include "chart.concatDecryptedSecretName" $ }}
{{- range .Values.extraVolumes }}
- name: {{ .name }}
  {{- if .configMap }}
  configMap:
    name: {{ .configMap.name }}
  {{- end }}
  {{- if .secret }}
  secret:
    secretName: {{ .secret.secretName }}
  {{- end }}
{{- end }}
{{- end }}




