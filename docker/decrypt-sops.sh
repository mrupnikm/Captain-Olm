#!/bin/bash

if [ -z "$1" ]; then
  echo "No parameter provided. Please specify 'pgp' or 'age'."
  exit 1
fi

# of type age or pgp
MODE=$1
# if pgp than ID
PGP_KEY=$2
# naming of the created secret
NEW_SECRET_NAME=$3
# for things like namespace to deploy
K8S_ARGS=$4
TMP_SECRET_FILE=decrypted-secret.yaml
HELM_NAME=$5

cat <<EOF > ${TMP_SECRET_FILE}
apiVersion: v1
kind: Secret
metadata:
  name: ${NEW_SECRET_NAME}
type: Opaque
data:
EOF

handle_secret_creation(){
  # Loop through each key in the secrets.yaml file using yq
  for KEY in $(yq e 'keys | .[]' /tmp/secrets.yaml); do
    VALUE=$(yq e ".${KEY}" /tmp/secrets.yaml)

    ENCODED_VALUE=$(echo -n "$VALUE" | base64 -w 0)

    echo "Key: $KEY"
    echo "Value: $VALUE"
    echo "Encoded Value: $ENCODED_VALUE"
    echo "  $KEY: $ENCODED_VALUE" >> ${TMP_SECRET_FILE}
  done

  echo "Contents of ${TMP_SECRET_FILE}:"
  cat ${TMP_SECRET_FILE}

  echo /tmp/secrets.yaml
  cat ${TMP_SECRET_FILE}
  kubectl apply -f ${TMP_SECRET_FILE} ${K8S_ARGS}
  kubectl get secret ${NEW_SECRET_NAME}
}


if [ "$MODE" == "pgp" ]; then
  echo "The parameter is 'pgp'. Executing PGP related tasks..."

  export GNUPGHOME=/tmp/gnupg
  echo "$PGP_PRIVATE_KEY" > /tmp/gnupg/private-key.asc
  echo "use-agent" >> /tmp/gnupg/gpg.conf
  gpg --batch --import /tmp/gnupg/private-key.asc

  sops --decrypt --pgp ${PGP_KEY} /tmp/secrets/secrets.enc.yaml  > /tmp/secrets.yaml
  handle_secret_creation

elif [ "$MODE" == "age" ]; then
  echo "The parameter is 'age'. Executing Age related tasks..."

  echo $SOPS_AGE_KEY_FILE > /tmp/age-key.txt
  SOPS_AGE_KEY_FILE=/tmp/age-key.txt sops -d /tmp/secrets/secrets.enc.yaml > /tmp/secrets.yaml

  handle_secret_creation

else
  echo "Invalid parameter. Please specify 'pgp' or 'age'."
  exit 1
fi
