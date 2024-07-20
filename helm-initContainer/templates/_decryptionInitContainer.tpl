{{- define "decryption.initContainer" -}}
- name: decrypt-secrets
  image: {{ .Values.initContainer.image }}
  command:
  - sh
  - -c
  {{- if hasKey .Values.encrypted_secret "pgp"  }}
  - decrypt-sops.sh "pgp" "{{ .Values.encrypted_secret.pgp }}" "{{ include "chart.name" . }}-secret" "{{ .Values.initContainer.k8s_args }}" "{{ include "chart.name" . }}"
  {{- else }}
  - decrypt-sops.sh "age" "" "{{ include "chart.name" . }}-secret" "{{ .Values.initContainer.k8s_args }}" "{{ include "chart.name" . }}"
  {{- end }}
  env:
  {{- if hasKey .Values.encrypted_secret "pgp"  }}
  - name: PGP_PRIVATE_KEY
    valueFrom:
      secretKeyRef:
        name: {{ printf "%s-%s" (include "chart.name" .) "pgp-keys" }}
        key: pgp-private-key.asc
  {{- else }}
  - name: SOPS_AGE_KEY_FILE
    valueFrom:
      secretKeyRef:
        name: {{ printf "%s-%s" (include "chart.name" .) "age-keys" }}
        key: age-key.txt
  {{- end }}
  volumeMounts:
  {{- include "chart.mounts" . | nindent 2 }}
{{- end }}