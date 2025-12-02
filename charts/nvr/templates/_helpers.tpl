{{/* Helper: returns comma separated ids from a peripherals list.
Usage:
{{ include "nvr.peripheralIDs" (dict "peripherals" (default $.Values.defaults.camera.peripherals (default (dict "peripherals" $.Values.defaults.camera.peripherals) .camera).peripherals)) }}
*/}}
{{- define "nvr.peripheralIDs" -}}
{{- $peripherals := .peripherals | default list -}}
{{- $name := .name -}}
{{- if not $peripherals -}}{{- if not $name -}}{{- "" -}}{{- else -}}{{- $name -}}{{- end -}}{{- else -}}
{{- $ids := list -}}
{{- range $peripherals -}}
  {{- if .id -}}
    {{- $ids = append $ids (toString .id) -}}
  {{- end -}}
{{- end -}}
{{- join "," $ids -}}
{{- end -}}
{{- end -}}

{{/* Helper: returns comma separated names from a peripherals list.
Usage:
{{ include "nvr.peripheralNames" (dict "peripherals" (default $.Values.defaults.camera.peripherals (default (dict "peripherals" $.Values.defaults.camera.peripherals) .camera).peripherals)) }}
*/}}
{{- define "nvr.peripheralNames" -}}
{{- $peripherals := .peripherals | default list -}}
{{- if not $peripherals -}}{{- "" -}}{{- else -}}
{{- $names := list -}}
{{- range $peripherals -}}
  {{- if .name -}}
    {{- $names = append $names (toString .name) -}}
  {{- end -}}
{{- end -}}
{{- join "," $names -}}
{{- end -}}
{{- end -}}