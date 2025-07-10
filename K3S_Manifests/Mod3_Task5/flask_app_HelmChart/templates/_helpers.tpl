{{/* Generate chart name */}}
{{- define "rsschool-flask-app.name" -}}
{{- .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* Generate full name */}}
{{- define "rsschool-flask-app.fullname" -}}
{{- printf "%s-%s" .Release.Name (include "rsschool-flask-app.name" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}} 
