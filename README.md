# Hermes

Hermes is a Codefresh **trigger manager** service.

## TL;DR

```sh
helm install codefresh/hermes
```

## Introduction

This chart bootstraps a [Hermes](https://github.com/codefresh-io/hermes) deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Prerequisites

- Kubernetes 1.8+ with Beta APIs enabled
- PV provisioner support in the underlying infrastructure
- Codefresh Helm Release

## Installing the Chart

To install the chart with the release name `my-release`:

```sh
helm install --name my-release --namespace codefresh codefresh/hermes
```

The command deploys Hermes on the Kubernetes cluster in the `codefresh` namespace with default configuration. The [configuration](#configuration) section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```sh
helm delete my-release
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

The following tables lists the configurable parameters of the Hermes chart and their default values.

| Parameter              | Description                                                      | Default                     |
| ---------------------- | ---------------------------------------------------------------- | --------------------------- |
| `image.repository`     | Hermes image                                                     | `codefresh/hermes`          |
| `image.tag`            | Hermes image tag                                                 | `0.8`                       |
| `image.PullPolicy`     | Image pull policy                                                | `IfNotPresent`              |
| `service.name`         | Kubernetes Service name                                          | `hermes`                    |
| `service.type`         | Kubernetes Service type                                          | `ClusterIP`                 |
| `service.externalPort` | Service external port                                            | `80`                        |
| `service.externalPort` | Service internal port                                            | `8080`                      |
| `logLevel`             | Log level: `debug`, `info`, `warning`, `error`, `fatal`, `panic` | `info`                      |
| `cfapi.protocol`       | Codefresh internal API protocol: `http` or `https`               | `http`                      |
| `cfapi.port`           | Codefresh internal API port                                      | `3000`                      |
| `cfapi.service`        | Codefresh Kubernetes service name                                | `{{ .Release.Name }}-cfapi` |

## Dependency

Hermes requires [Redis chart](https://hub.kubeapps.com/charts/stable/redis) (`~1.1.9` version).

## Backup and Restore

We are running pod named hermes-store-backup. This pod processes crond with such job:
```
0 * * * *   /opt/codefresh/backup
```
It means that `/opt/codefresh/backup` script runs every hour, creates RDB snapshot of hermes-store data and uploads it to AWS S3 `cf-backup-hermes` bucket as `hermes.backup` file.

If necessary we can attach to the pod and perform `/opt/codefresh/backup` script manually.

To restore the data we should use `/opt/codefresh/restore` script. If we run this script with no argument the script will take the latest version of `hermes.backup` file and loads it into hermes-store. 

If we want to recover any specific version of `hermes.backup` file we should pass file VersionId as command argument. Example:

```
/opt/codefresh/restore 9koX0K1dp83Lrcsd4AV2YiG9yVKFmRdF
```

Important note:

Do not forget to disable `appendonly` mode in values.yaml

```
redis:
  redisExtraFlags: "--appendonly no"
```
