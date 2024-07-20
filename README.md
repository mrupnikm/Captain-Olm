# Captain Olm: Helm Deployment with SOPS Secrets Encryption

## Table of Contents

1. [Introduction](#introduction)
2. [Prerequisites](#prerequisites)
3. [Installation](#installation)
4. [Usage](#usage)
5. [Secrets Directory and Encrypted File](#secrets-directory-and-encrypted-file)
6. [PGP or Age Decryption](#pgp-or-age-decryption)
7. [Init Container Dockerfile](#init-container-dockerfile)

## Introduction
This Helm chart provides a simple and secure way to deploy applications that utilize encrypted secrets managed by SOPS (Simple Objeccts
Protection System). This chart supports PGP and Age encryption algorithms. The secrets are encrypted locally in the `secrets` directory, which
contains an encrypted file called `secrets.enc.yaml`, and then decrypted on the cluster using a private key for decryption.
This way of encryption is also compatible with GitOps tools like ArgoCD.

## Prerequisites
1. Helm installed
2. Docker installed
4. Sops installed

## General Usage
The Helm chart installs your application using a Kubernetes deployment with an init container. This init container is responsible for decrypting
the encrypted secrets. After the init container finishes its job, the main container runs and starts serving your application.
> NOTE: the helm chart is derived from the default helm chart
1. Clone repo
2. Create your helm/secrets/secret.yaml and encrypt it with age or pgp to helm/secrets/secret.enc.yaml
3. Create docker image and push it to desired location
4. Configure custom-values.yaml
5. Create pgp-keys or age-keys secret in the same namespace as deployment on the cluster
6. Install chart

### Secrets Directory and Encrypted File
Keep your encrypted secrets file (`secrets.enc.yaml`) directory within this repository. Remember that
this chart does not handle encryption or decryption of new files; you must provide an already encrypted file with the correct format for the
provided encryption algorithm. For simple editing it is recomended to use something like the [idea sops editor](https://plugins.jetbrains.com/plugin/21317-simple-sops-edit)

### PGP or Age Ecryption
Update the `encrypted_secret.pgp` to the public key value or `encrypted_secret.age` to any value in your `values.yaml` file accordingly, based on whether you use PGP (Public Key Cryptography Standard)
or Age encryption. 

### Init Container Dockerfile
We provide a Dockerfile for the init container in the `docker` directory of this repository, which you can use as a base for customizing
the init container's behavior if needed. You may want to add additional steps or scripts depending on your specific use case. The provided
Dockerfile is tailored to decrypt secrets using either PGP or Age and copies the decrypted output into the Kubernetes secret.

We hope you find this Helm chart useful for securing and managing your encrypted secrets in your Kubernetes cluster!

