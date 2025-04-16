# README:
# - If using a fixed tag for images, changing the image pull policy to anything other than "Always"
#   will use a cached/stale image.
# - We recommend using unique tags for user code images, as this will guarantee that the docker
#   image will be consistent for the pipeline's entire execution.
---
global:
  postgresqlSecretName: 'dagster-postgresql-secret'
  # The DAGSTER_HOME env var is set by default on all nodes from this value
  dagsterHome: '/opt/dagster/dagster_home'

  # A service account name to use for this chart and all subcharts. If this is set, then
  # dagster subcharts will not create their own service accounts.
  serviceAccountName: ''

  # The name for the secret used to pass Celery broker and backend connection urls. This can
  # generally be left as the default, but can be useful if setting generateCeleryConfigSecret
  # to false below.
  celeryConfigSecretName: 'dagster-celery-config-secret'

nameOverride: ''
fullnameOverride: ''
rbacEnabled: true
# Specify secrets to run containers based on images in private registries. See:
# https://kubernetes.io/docs/concepts/containers/images/#referring-to-an-imagepullsecrets-on-a-pod
imagePullSecrets: []

####################################################################################################
# Dagster Webserver: Configuration for the Dagster webserver
####################################################################################################
dagsterWebserver:
  replicaCount: 1
  image:
    # When a tag is not supplied for a Dagster provided image,
    # it will default as the Helm chart version.
    repository: 'docker.io/dagster/dagster-celery-k8s'
    tag: ~
    pullPolicy: Always

  # Support overriding the name prefix of the webserver pods
  nameOverride: 'dagster-webserver'

  # Support path prefix (i.e. /dagster)
  pathPrefix: ~

  service:
    type: ClusterIP
    # Defines the port where the webserver will serve requests; if changed, don't forget to update the
    # livenessProbe and startupProbe entries below as well.
    port: 80
    annotations: {}

  # Defines a workspace for the webserver. This should only be set if user deployments are enabled, but
  # the subchart is disabled to manage user deployments in a separate Helm release.
  # In this case, the webserver will need the addresses of the code servers in order to load the user code,
  # or the name of an existing configmap to mount as the workspace file.
  workspace:
    enabled: false

    # List of servers to include in the workflow file. When set,
    # `externalConfigmap` must be empty.
    servers:
      - host: 'k8s-example-user-code-1'
        port: 3030
        name: 'user-code-example'

    # Defines the name of a configmap provisioned outside of the
    # Helm release to use as workspace file. When set, `servers`
    # must be empty.
    externalConfigmap: ~

  # Deploy a separate instance of the webserver in --read-only mode (can't launch runs, disable schedules, etc.)
  enableReadOnly: false

  # The timeout in milliseconds to set on database statements sent to the Dagster instance.
  dbStatementTimeout: ~

  # The maximum age in seconds of a connection to use in the sqlalchemy connection pool.
  # Defaults to 1 hour if not set.
  # Set to -1 to disable.
  dbPoolRecycle: ~

  # The maximum overflow size of the sqlalchemy pool. Set to -1 to disable.
  dbPoolMaxOverflow: ~

  # The log level of the uvicorn web server, defaults to warning if not set
  logLevel: ~

  # Additional environment variables to set.
  # These will be directly applied to the daemon container. See
  # https://kubernetes.io/docs/tasks/inject-data-application/define-environment-variable-container/
  #
  # Example:
  #
  # env:
  # - name: ENV_ONE
  #   value: "one"
  # - name: ENV_TWO
  #   value: "two"
  env: []

  # Additional environment variables can be retrieved and set from ConfigMaps. See:
  # https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/#configure-all-key-value-pairs-in-a-configmap-as-container-environment-variables
  #
  # Example:
  #
  # envConfigMaps:
  #   - name: config-map
  envConfigMaps: []

  # Additional environment variables can be retrieved and set from Secrets. See:
  # https://kubernetes.io/docs/concepts/configuration/secret/#use-case-as-container-environment-variables
  #
  # Example:
  #
  # envSecrets:
  #   - name: secret
  envSecrets: []

  # Additional labels that should be included on the deployment. See:
  # https://kubernetes.io/docs/concepts/overview/working-with-objects/labels
  #
  # Example:
  # labels:
  #   my-label-key: my_label-value
  deploymentLabels: {}

  # Additional labels that should be included on the pod. See:
  # https://kubernetes.io/docs/concepts/overview/working-with-objects/labels
  #
  # Example:
  # labels:
  #   my-label-key: my_label-value
  labels: {}

  # Additional volumes that should be included. See:
  # https://v1-18.docs.kubernetes.io/docs/reference/generated/kubernetes-api/v1.18/#volume-v1-core
  #
  # Example:
  #
  # volumes:
  #   - name: my-volume
  #     configMap: my-config-map
  volumes: []

  # Additional volume mounts that should be included. See:
  # See: https://v1-18.docs.kubernetes.io/docs/reference/generated/kubernetes-api/v1.18/#volumemount-v1-core
  #
  # Example:
  #
  # volumeMounts:
  #   - name: test-volume
  #     mountPath: /opt/dagster/test_folder
  #     subPath: test_file.yaml
  volumeMounts: []

  # Additional containers that should run as sidecars to the webserver. See:
  # https://kubernetes.io/docs/concepts/workloads/pods/#how-pods-manage-multiple-containers
  # For K8s versions after 1.29, prefer using extraPrependedInitContainers instead. See:
  # https://kubernetes.io/docs/concepts/workloads/pods/sidecar-containers/
  #
  # Example:
  # extraContainers:
  #   - name: my-sidecar
  #     image: busybox
  extraContainers: []

  # Additional init containers that should run before the webserver's init container, such as sidecars.
  # For K8s versions after 1.29, see:
  # https://kubernetes.io/docs/concepts/workloads/pods/sidecar-containers/
  #
  # Extra init containers are started **before** the connection to the database is tested. #
  # Example:
  # extraPrependedInitContainers:
  #   - name: my-sidecar
  #     image: busybox
  extraPrependedInitContainers: []

  # Support Node, affinity and tolerations for webserver pod assignment. See:
  # https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#nodeselector
  # https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity
  # https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/
  annotations: {}
  nodeSelector: {}
  affinity: {}
  tolerations: []
  podSecurityContext: {}
  securityContext: {}
  resources: {}

  # Configure initContainer resources separately from main container
  initContainerResources: {}

  # Enable the check-db-ready initContainer
  checkDbReadyInitContainer: true

  # Override the default K8s scheduler
  # schedulerName: ~

  # If you want to specify resources, uncomment the following lines, adjust them as necessary,
  # and remove the curly braces after 'resources:'.
  # limits:
  #   cpu: 100m
  #   memory: 128Mi
  # requests:
  #   cpu: 100m
  #   memory: 128Mi
  # Readiness probe detects when the pod is ready to serve requests.
  # https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes
  readinessProbe:
    httpGet:
      path: '/server_info'
      port: 80
    periodSeconds: 20
    timeoutSeconds: 10
    successThreshold: 1
    failureThreshold: 3

  # As of 0.14.0, liveness probes are disabled by default. If you want to enable them, it's recommended to also
  # enable startup probes.
  livenessProbe: {}
  startupProbe:
    enabled: false

####################################################################################################
# Compute Log Manager: Configuration for the compute log manager.
#
# By default, NoOpComputeLogManager is set as a compute log manager. As a result, stdout and stderr
# logs will be unavailable in the Dagster UI. To change this behavior, choose a compute log
# manager with a storage backend to capture and persist stdout and stderr logs.
#
# See https://docs.dagster.io/deployment/dagster-instance#compute-log-storage for more information.
####################################################################################################
computeLogManager:
  # Type can be one of [
  #   NoOpComputeLogManager,
  #   AzureBlobComputeLogManager,
  #   GCSComputeLogManager,
  #   S3ComputeLogManager,
  #   LocalComputeLogManager,
  #   CustomComputeLogManager,
  # ]
  type: NoOpComputeLogManager
  config: {}
  ##  Uncomment this configuration if the AzureBlobComputeLogManager is selected
  #   azureBlobComputeLogManager:
  #     storageAccount: ~
  #     container: ~
  #     secretCredential: ~
  #     defaultAzureCredential: ~
  #     accessKeyOrSasToken: ~
  #     localDir: ~
  #     prefix: ~
  #     uploadInterval: ~
  #     showUrlOnly: ~
  ##  Uncomment this configuration if the GCSComputeLogManager is selected
  #   gcsComputeLogManager:
  #     bucket: ~
  #     localDir: ~
  #     prefix: ~
  #     jsonCredentialsEnvvar: ~
  #     uploadInterval: ~
  ##  Uncomment this configuration if the S3ComputeLogManager is selected
  #   s3ComputeLogManager:
  #     bucket: ~
  #     localDir: ~
  #     prefix: ~
  #     useSsl: ~
  #     verify: ~
  #     verifyCertPath: ~
  #     endpointUrl: ~
  #     skipEmptyFiles: ~
  #     uploadInterval: ~
  #     uploadExtraArgs: {}
  ##  Uncomment this configuration if the LocalComputeLogManager is selected
  #   localComputeLogManager:
  #     baseDir: ~
  #     pollingTimeout: ~
  ##  Uncomment this configuration if the CustomComputeLogManager is selected.
  ##  Using this setting requires a custom webserver image that defines the user specified
  ##  compute log manager in an installed python module.
  #   customComputeLogManager:
  #     module: ~
  #     class: ~
  #     config: {}

pythonLogs: {}
## The names of python loggers that will be captured as Dagster logs
#  managedPythonLoggers:
#    - foo_logger
## The log level for the instance. Logs emitted below this severity will be ignored.
## One of [NOTSET, DEBUG, INFO, WARNING, WARN, ERROR, FATAL, CRITICAL]
#  pythonLogLevel: INFO
## Python log handlers that will be applied to all Dagster logs
#  dagsterHandlerConfig:
#    handlers:
#      myHandler:
#        class: logging.FileHandler
#        filename: "/logs/my_dagster_logs.log"
#        mode: "a"

####################################################################################################
# User Code Deployments: Configuration for user code containers to be loaded via GRPC server. For
# each item in the "deployments" list, a K8s Deployment and K8s Service will be created to run the
# GRPC server that the Dagster webserver communicates with to get definitions information and the current
# image information. These deployments can be updated independently of the Dagster webserver, and the webserver
# will pull the current image for all execution. When using a distributed executor (such as
# Celery-K8s) for job execution, the current image will be queried once and used for all
# op executions for that run. In order to guarantee that all op executions within a job
# execution use the same image, we recommend using a unique tag (ie not "latest").
#
# All user code will be invoked within the images.
####################################################################################################
dagster-user-deployments:
  # Creates a workspace file with the gRPC servers hosting your user code.
  enabled: true

  # If you plan on deploying user code in a separate Helm release, set this to false.
  enableSubchart: true

  # Specify secrets to run user code server containers based on images in private registries. See:
  # https://kubernetes.io/docs/concepts/containers/images/#referring-to-an-imagepullsecrets-on-a-pod
  imagePullSecrets:
    []
    # - name: ecr-creds

  # List of unique deployments
  deployments:
    - name: 'hydrosat'
      image:
        # When a tag is not supplied, it will default as the Helm chart version.
        # repository: 'najeebrgn/hydrosat_najeeb'
        # tag: 7
        # repository: '962311380064.dkr.ecr.eu-west-1.amazonaws.com/test/repo'
        repository: 'najeebrgn/hydrosat'
        tag: latest

        # Change with caution! If you're using a fixed tag for pipeline run images, changing the
        # image pull policy to anything other than "Always" will use a cached/stale image, which is
        # almost certainly not what you want.
        pullPolicy: Always

      # Arguments to `dagster api grpc`.
      # Ex: "dagster api grpc -m dagster_test.test_project.test_jobs.repo -a define_demo_execution_repo"
      # would translate to:
      # dagsterApiGrpcArgs:
      #   - "-m"
      #   - "dagster_test.test_project.test_jobs.repo"
      #   - "-a"
      #   - "define_demo_execution_repo"
      #
      # The `dagsterApiGrpcArgs` key can also be replaced with `codeServerArgs` to use a new
      # experimental `dagster code-server start` command instead of `dagster api grpc`, which can
      # reload its definitions from within the Dagster UI without needing to restart the user code
      # deployment pod.
      dagsterApiGrpcArgs:
        - '--python-file'
        - '/hydrosat/definitions.py'
      port: 3030

      # Whether or not to include configuration specified for this user code deployment in the pods
      # launched for runs from that deployment
      includeConfigInLaunchedRuns:
        enabled: true

      # Additional environment variables to set.
      # These will be directly applied to the daemon container. See
      # https://kubernetes.io/docs/tasks/inject-data-application/define-environment-variable-container/
      #
      # Example:
      #
      # env:
      # - name: ENV_ONE
      #   value: "one"
      # - name: ENV_TWO
      #   value: "two"
      env:
        - name: S3_BUCKET
          value: '${S3_BUCKET}'
        - name: AWS_REGION
          value: '${AWS_REGION}'

      # Additional environment variables can be retrieved and set from ConfigMaps. See:
      # https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/#configure-all-key-value-pairs-in-a-configmap-as-container-environment-variables
      #
      # Example:
      #
      # envConfigMaps:
      #   - name: config-map
      envConfigMaps: []

      # Additional environment variables can be retrieved and set from Secrets. See:
      # https://kubernetes.io/docs/concepts/configuration/secret/#use-case-as-container-environment-variables
      #
      # Example:
      #
      # envSecrets:
      #   - name: secret
      envSecrets:
        - name: aws-credentials

      # Additional labels that should be included. See:
      # https://kubernetes.io/docs/concepts/overview/working-with-objects/labels
      #
      # Example:
      # labels:
      #   my-label-key: my_label-value
      labels: {}

      # Additional volumes that should be included. See:
      # https://v1-18.docs.kubernetes.io/docs/reference/generated/kubernetes-api/v1.18/#volume-v1-core
      #
      # Example:
      #
      # volumes:
      #   - name: my-volume
      #     configMap: my-config-map
      volumes: []

      # Additional volume mounts that should be included. See:
      # See: https://v1-18.docs.kubernetes.io/docs/reference/generated/kubernetes-api/v1.18/#volumemount-v1-core
      #
      # Example:
      #
      # volumeMounts:
      #   - name: test-volume
      #     mountPath: /opt/dagster/test_folder
      #     subPath: test_file.yaml
      volumeMounts: []

      # Init containers to run before the main container. See:
      # https://kubernetes.io/docs/concepts/workloads/pods/init-containers/
      initContainers: []

      # Additional containers (i.e. sidecars) to run alongside the main container. See:
      # https://kubernetes.io/docs/concepts/workloads/pods/sidecar-containers/
      #
      # Example:
      #
      # sidecarContainers:
      #   - name: my-sidecar
      #     image: ...
      #     volumeMounts: []
      #     env: []
      sidecarContainers: []

      annotations: {}
      nodeSelector: {}
      affinity: {}
      tolerations: []
      podSecurityContext: {}
      securityContext: {}
      resources: {}

      # Override the default K8s scheduler
      # schedulerName: ~

      # Readiness probe detects when the pod is ready to serve requests.
      # https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes
      readinessProbe:
        # Readiness probes are enabled by default.
        enabled: true
        # If `readinessProbe` has no `exec` field, then the following default will be used:
        # exec:
        #   command: ["dagster", "api", "grpc-health-check", "-p", "{{ $deployment.port }}"]
        periodSeconds: 20
        timeoutSeconds: 10
        successThreshold: 1
        # Allow roughly 300 seconds to start up by default
        failureThreshold: 1

      # As of 0.14.0, liveness probes are disabled by default. If you want to enable them, it's recommended to also
      # enable startup probes.
      livenessProbe: {}
      startupProbe:
        enabled: false

      # Strategy to follow when replacing old pods with new pods. See:
      # https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#strategy
      deploymentStrategy: {}

      service:
        annotations: {}

####################################################################################################
# Scheduler: Configuration for the scheduler
####################################################################################################
scheduler:
  # Type can be one of [
  #   DagsterDaemonScheduler,
  #   CustomScheduler,
  #  ]
  type: DagsterDaemonScheduler
  config:
    {}
    ## This configuration will only be used if the DagsterDaemonScheduler is selected.
    # daemonScheduler:
    #   maxCatchupRuns: 5
    #   maxTickRetries: 0

    ## This configuration will only be used if the CustomScheduler is selected.
    ## Using this setting requires a custom webserver image that defines the user specified
    ## scheduler in an installed python module.
    #   customScheduler:
    #     module: ~
    #     class: ~
    #     config: {}

####################################################################################################
# Run Launcher: Configuration for run launcher
####################################################################################################
runLauncher:
  # Type can be one of [K8sRunLauncher, CeleryK8sRunLauncher, CustomRunLauncher]
  type: K8sRunLauncher

  config:
    # This configuration will only be used if the K8sRunLauncher is selected
    k8sRunLauncher:
      # Change with caution! If you're using a fixed tag for pipeline run images, changing the
      # image pull policy to anything other than "Always" will use a cached/stale image, which is
      # almost certainly not what you want.
      imagePullPolicy: 'Always'

      ## The image to use for the launched Job's Dagster container.
      ## The `pullPolicy` field is ignored. Use`imagePullPolicy` instead.
      # image:
      #   repository: ""
      #   tag: ""
      #   pullPolicy: Always

      # The Kubernetes namespace where new jobs will be launched.
      # By default, the release namespace is used.
      jobNamespace: ~

      # Set to true to load kubeconfig from within cluster.
      loadInclusterConfig: true

      # File to load kubeconfig from. Only set this if loadInclusterConfig is false.
      kubeconfigFile: ~

      # Additional environment variables can be retrieved and set from ConfigMaps for the Job. See:
      # https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/#configure-all-key-value-pairs-in-a-configmap-as-container-environment-variables
      #
      # Example:
      #
      # envConfigMaps:
      #   - name: config-map
      envConfigMaps: []

      # Additional environment variables can be retrieved and set from Secrets for the Job. See:
      # https://kubernetes.io/docs/concepts/configuration/secret/#use-case-as-container-environment-variables
      #
      # Example:
      #
      # envSecrets:
      #   - name: secret
      envSecrets: []

      # Additional variables from the existing environment can be passed into the Job.
      #
      # Example:
      #
      # envVars:
      #   - "FOO_ENV_VAR" (Will pull the value of FOO_ENV_VAR from the calling process)
      #   - "BAR_ENV_VAR=baz_value" (Will set the value of BAR_ENV_VAR to baz_value)
      envVars: []

      # Additional volumes that should be included in the Job's Pod. See:
      # https://v1-18.docs.kubernetes.io/docs/reference/generated/kubernetes-api/v1.18/#volume-v1-core
      #
      # Example:
      #
      # volumes:
      #   - name: my-volume
      #     configMap: my-config-map
      volumes: []

      # Additional volume mounts that should be included in the container in the Job's Pod. See:
      # See: https://v1-18.docs.kubernetes.io/docs/reference/generated/kubernetes-api/v1.18/#volumemount-v1-core
      #
      # Example:
      #
      # volumeMounts:
      #   - name: test-volume
      #     mountPath: /opt/dagster/test_folder
      #     subPath: test_file.yaml
      volumeMounts: []

      # Additional labels that should be included in the Job's Pod. See:
      # https://kubernetes.io/docs/concepts/overview/working-with-objects/labels
      #
      # Example:
      # labels:
      #   my_label_key: my_label_value
      labels: {}

      # Default compute resource requirements for the container in the Job's Pod. See:
      # https://kubernetes.io/docs/concepts/configuration/manage-resources-containers
      #
      # Example:
      # resources:
      #   limits:
      #     cpu: 100m
      #     memory: 128Mi
      #   requests:
      #     cpu: 100m
      #     memory: 128Mi
      resources: {}

      # Override the default K8s scheduler for launched Pods
      # schedulerName: ~

      # Whether the launched Kubernetes Jobs and Pods should fail if the Dagster run fails.
      failPodOnRunFailure: false

      # Security settings for the container. See
      # https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-capabilities-for-a-container
      securityContext: ~

      # Raw k8s configuration for the Kubernetes Job and Pod created for the run.
      # See: https://docs.dagster.io/deployment/guides/kubernetes/customizing-your-deployment
      #
      # Example:
      # runK8sConfig:
      #   containerConfig: # raw config for the pod's main container
      #     resources:
      #       limits:
      #         cpu: 100m
      #         memory: 128Mi
      #   podTemplateSpecMetadata: # raw config for the pod's metadata
      #     annotations:
      #       mykey: myvalue
      #   podSpecConfig: # raw config for the spec of the launched's pod
      #     nodeSelector:
      #       disktype: ssd
      #   jobSpecConfig: # raw config for the kubernetes job's spec
      #     ttlSecondsAfterFinished: 7200
      #   jobMetadata: # raw config for the kubernetes job's metadata
      #     annotations:
      #       mykey: myvalue
      runK8sConfig: {}

    # This configuration will only be used if the CeleryK8sRunLauncher is selected
    celeryK8sRunLauncher:
      # Change with caution! If you're using a fixed tag for pipeline run images, changing the
      # image pull policy to anything other than "Always" will use a cached/stale image, which is
      # almost certainly not what you want.
      imagePullPolicy: 'Always'

      # The Celery workers can be deployed with a fixed image (no user code included)
      image:
        # When a tag is not supplied for a Dagster provided image,
        # it will default as the Helm chart version.
        repository: 'docker.io/dagster/dagster-celery-k8s'
        tag: ~
        pullPolicy: Always

      # The Kubernetes namespace where new jobs will be launched.
      # By default, the release namespace is used.
      jobNamespace: ~

      # Support overriding the name prefix of Celery worker pods
      nameOverride: 'celery-workers'

      # Additional config options for Celery, applied to all queues.
      # These can be overridden per-queue below.
      # For available options, see:
      # https://docs.celeryq.dev/en/stable/userguide/configuration.html
      configSource: {}

      # Additional Celery worker queues can be configured here. When overriding, be sure to
      # provision a "dagster" worker queue, as this is the default queue used by Dagster.
      #
      # Optionally, labels and node selectors can be set on the Celery queue's workers.
      # Specifying a queue's node selector will override any existing node selector defaults.
      # configSource will be merged with the shared configSource above.
      workerQueues:
        - name: 'dagster'
          replicaCount: 2
          labels: {}
          nodeSelector: {}
          configSource: {}
          additionalCeleryArgs: []

      # Additional environment variables to set on the celery/job containers
      # A Kubernetes ConfigMap will be created with these environment variables. See:
      # https://kubernetes.io/docs/concepts/configuration/configmap/
      #
      # Example:
      #
      # env:
      #   ENV_ONE: one
      #   ENV_TWO: two
      env: {}

      # Additional environment variables can be retrieved and set from ConfigMaps. See:
      # https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/#configure-all-key-value-pairs-in-a-configmap-as-container-environment-variables
      #
      # Example:
      #
      # envConfigMaps:
      #   - name: config-map
      envConfigMaps: []

      # Additional environment variables can be retrieved and set from Secrets. See:
      # https://kubernetes.io/docs/concepts/configuration/secret/#use-case-as-container-environment-variables
      #
      # Example:
      #
      # envSecrets:
      #   - name: secret
      envSecrets: []

      annotations: {}

      # Sets a node selector as a default for all Celery queues.
      #
      # See:
      # https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#nodeselector
      nodeSelector: {}

      # Support affinity and tolerations for Celery pod assignment. See:
      # https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity
      # https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/
      affinity: {}
      tolerations: []
      podSecurityContext: {}
      securityContext: {}

      # Specify resources.
      # Example:
      #
      # resources:
      #   limits:
      #     cpu: 100m
      #     memory: 128Mi
      #   requests:
      #     cpu: 100m
      #     memory: 128Mi
      resources: {}

      # Enable the check-db-ready initContainer
      checkDbReadyInitContainer: true
      # Override the default K8s scheduler
      # schedulerName: ~

      # If `livenessProbe` does not contain `exec` field, then we will default to using:
      # exec:
      #   command:
      #     - /bin/sh
      #     - -c
      #     - dagster-celery status -A dagster_celery_k8s.app -y {{ $.Values.global.dagsterHome }}/celery-config.yaml | grep "${HOSTNAME}:.*OK"
      livenessProbe:
        initialDelaySeconds: 15
        periodSeconds: 10
        timeoutSeconds: 10
        successThreshold: 1
        failureThreshold: 3

      # Additional volumes that should be included in the Job's Pod. See:
      # https://v1-18.docs.kubernetes.io/docs/reference/generated/kubernetes-api/v1.18/#volume-v1-core
      #
      # Example:
      #
      # volumes:
      #   - name: my-volume
      #     configMap: my-config-map
      volumes: []

      # Additional volume mounts that should be included in the container in the Job's Pod. See:
      # See: https://v1-18.docs.kubernetes.io/docs/reference/generated/kubernetes-api/v1.18/#volumemount-v1-core
      #
      # Example:
      #
      # volumeMounts:
      #   - name: test-volume
      #     mountPath: /opt/dagster/test_folder
      #     subPath: test_file.yaml
      volumeMounts: []

      # Additional labels that should be included in the Job's Pod. See:
      # https://kubernetes.io/docs/concepts/overview/working-with-objects/labels
      #
      # Example:
      # labels:
      #   my_label_key: my_label_value
      labels: {}

      # Whether the launched Kubernetes Jobs and Pods should fail if the Dagster run fails.
      failPodOnRunFailure: false

    ## Uncomment this configuration will only be used if the CustomRunLauncher is selected.
    ## Using this setting requires a custom webserver image that defines the user specified
    ## run launcher in an installed python module.
    # customRunLauncher:
    #   module: ~
    #   class: ~
    #   config: {}

####################################################################################################
# PostgreSQL: Configuration values for postgresql
#
# https://github.com/kubernetes/charts/blob/master/stable/postgresql/README.md
#
# A PostgreSQL database is required to run Dagster on Kubernetes. If postgresql.enabled is marked as
# false, the PG credentials specified here will still be used, and should point to an external PG
# database that is accessible from this chart.
####################################################################################################
postgresql:
  # set postgresql.enabled to be false to disable deploy of a PostgreSQL database and use an
  # existing external PostgreSQL database
  enabled: true

  # Used by init container to check that db is running. (Even if enabled:false)
  image:
    registry: 'docker.io'
    repository: 'library/postgres'
    tag: '14.6'
    pullPolicy: IfNotPresent

  # set this PostgreSQL hostname when using an external PostgreSQL database
  postgresqlHost: ''

  postgresqlUsername: test

  # Note when changing this password (e.g. in test) that credentials will
  # persist as long as the PVCs do -- see:
  # https://github.com/helm/charts/issues/12836#issuecomment-524552358
  postgresqlPassword: test

  postgresqlDatabase: test

  # set postgresql parameter keywords for the connection string.
  # see: https://www.postgresql.org/docs/current/libpq-connect.html#LIBPQ-PARAMKEYWORDS
  postgresqlParams: {}

  # When set, overrides the default `postgresql` scheme for the connection string.
  # (e.g., set to `postgresql+pg8000` to use the `pg8000` library).
  # See: https://docs.sqlalchemy.org/en/13/dialects/postgresql.html#dialect-postgresql
  postgresqlScheme: ''

  service:
    port: 5432

# Whether to generate a secret resource for the PostgreSQL password. Useful if
# global.postgresqlSecretName is managed outside of this helm chart.
generatePostgresqlPasswordSecret: true

# If true, the helm chart will create a secret for you with the Celery broker and backend
# connection urls, including an optional Redis or RabbitMQ password. Set this to false if you want
# to manage a secret with the Celery broker/backend connection strings yourself. If you manage
# the secret yourself, the secret should have the name specified in global.celeryConfigSecretName,
# and should have the broker URL in a DAGSTER_CELERY_BROKER_URL key and the backend URL in a
# DAGSTER_CELERY_BACKEND_URL key.
generateCeleryConfigSecret: true

####################################################################################################
# RabbitMQ: Configuration values for rabbitmq. Only one of RabbitMQ / Redis should be enabled.
####################################################################################################
rabbitmq:
  enabled: false

  image:
    repository: 'bitnami/rabbitmq'
    tag: '3.8.12'
    pullPolicy: IfNotPresent

  rabbitmq:
    username: test
    password: test

  service:
    port: 5672

  # https://github.com/helm/charts/issues/17250#issuecomment-533444837
  volumePermissions:
    enabled: true
    image:
      repository: bitnami/minideb
      tag: stretch
      pullPolicy: IfNotPresent

####################################################################################################
# Redis: Configuration values for Redis. Can be used instead of RabbitMQ.
####################################################################################################
redis:
  # To use redis instead of rabbitmq, set `enabled` to true.
  enabled: false

  # To manage redis via helm, set `internal` to `true`. To use an external redis, set `internal` to `false`.
  # Note: If `internal` is true, then redis pod will be created regardless of `enabled` flag.
  internal: false

  usePassword: false
  password: 'test'

  # Redis host URL
  host: ''

  # Redis port
  port: 6379

  # Set DB number for Redis broker DB (default 0)
  brokerDbNumber: 0

  # Set DB number for Redis backend DB (default 0)
  backendDbNumber: 0

  # If your Redis connection needs configuration options, you can use this field to specific the
  # exact connection URL needed, rather than letting it be constructed from the Helm values.
  brokerUrl: ''
  backendUrl: ''

####################################################################################################
# Flower: (Optional) The flower web interface for diagnostics and debugging Celery queues & workers
####################################################################################################
flower:
  enabled: false

  image:
    repository: 'docker.io/mher/flower'
    tag: '0.9.5'
    pullPolicy: Always

  service:
    type: ClusterIP
    annotations: {}
    port: 5555

  # Support Node, affinity and tolerations for Flower pod assignment. See:
  # https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#nodeselector
  # https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity
  # https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/
  annotations: {}
  nodeSelector: {}
  affinity: {}
  tolerations: []
  podSecurityContext: {}
  securityContext: {}

  # Enable the check-db-ready initContainer
  checkDbReadyInitContainer: true
  # Override the default K8s scheduler
  # schedulerName: ~

  resources: {}
  # If you want to specify resources, uncomment the following lines, adjust them as necessary,
  # and remove the curly braces after 'resources:'.
  # limits:
  #   cpu: 100m
  #   memory: 128Mi
  # requests:
  #   cpu: 100m
  #   memory: 128Mi

  # Liveness probe detects when to restart flower.
  # https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes
  livenessProbe:
    tcpSocket:
      port: 'flower'
    # initialDelaySeconds: 60
    periodSeconds: 20
    failureThreshold: 3

  # Startup probe (available in kubernetes v1.16+) is used at pod startup. Once it has succeeded,
  # then liveness probe takes over.
  # If on kubernetes < v1.16, then comment out `startupProbe` lines and comment in
  # `initialDelaySeconds: 60` under `livenessProbe`
  startupProbe:
    tcpSocket:
      port: 'flower'
    periodSeconds: 10
    failureThreshold: 6

####################################################################################################
# Ingress: (Optional) Create ingresses for the Dagster webserver and Flower
####################################################################################################
ingress:
  enabled: false

  annotations: {}
  labels: {}

  # Specify the IngressClass used to implement this ingress.
  #
  # See https://kubernetes.io/blog/2020/04/02/improvements-to-the-ingress-api-in-kubernetes-1.18/#specifying-the-class-of-an-ingress
  ingressClassName: ~

  dagsterWebserver:
    # Ingress hostname for the webserver e.g. dagster.mycompany.com
    # This variable allows customizing the route pattern in the ingress. Some
    # ingress controllers may only support "/", whereas some may need "/*".
    path: '/*'
    pathType: ImplementationSpecific
    # NOTE: do NOT keep trailing slash. For root configuration, set as empty string
    # See: https://github.com/dagster-io/dagster/issues/2073
    host: ''

    tls:
      enabled: false
      secretName: ''

    # Different http paths to add to the ingress before the default webserver path
    # Example:
    #
    # precedingPaths:
    #   - path: "/*"
    #     pathType: ImplementationSpecific
    #     serviceName: "ssl-redirect"
    #     servicePort: "use-annotation"
    precedingPaths: []

    # Different http paths to add to the ingress after the default webserver path
    # Example:
    #
    # succeedingPaths:
    #   - path: "/*"
    #     pathType: ImplementationSpecific
    #     serviceName: "ssl-redirect"
    #     servicePort: "use-annotation"
    succeedingPaths: []

  readOnlyDagsterWebserver:
    # Ingress hostname for read only webserver e.g. viewer.dagster.mycompany.com
    # This variable allows customizing the route pattern in the ingress. Some
    # ingress controllers may only support "/", whereas some may need "/*".
    path: '/*'
    pathType: ImplementationSpecific
    # NOTE: do NOT keep trailing slash. For root configuration, set as empty string
    # See: https://github.com/dagster-io/dagster/issues/2073
    host: ''

    tls:
      enabled: false
      secretName: ''

    # Different http paths to add to the ingress before the default webserver path
    # Example:
    #
    # precedingPaths:
    #   - path: "/*"
    #     pathType: ImplementationSpecific
    #     serviceName: "ssl-redirect"
    #     servicePort: "use-annotation"
    precedingPaths: []

    # Different http paths to add to the ingress after the default webserver path
    # Example:
    #
    # succeedingPaths:
    #   - path: "/*"
    #     pathType: ImplementationSpecific
    #     serviceName: "ssl-redirect"
    #     servicePort: "use-annotation"
    succeedingPaths: []

  flower:
    # Ingress hostname for Flower e.g. flower.mycompany.com
    host: ''
    # if path is '/flower', Flower will be accessible at 'mycompany.com/flower'
    # NOTE: do NOT keep trailing slash. For root configuration, set as empty string
    path: ''
    pathType: ImplementationSpecific

    tls:
      enabled: false
      secretName: ''

    # Different http paths to add to the ingress before the default flower path
    # Example:
    #
    # precedingPaths:
    #   - path: "/*"
    #     pathType: ImplementationSpecific
    #     serviceName: "ssl-redirect"
    #     servicePort: "use-annotation"
    precedingPaths: []

    # Different http paths to add to the ingress after the default flower path
    # Example:
    #
    # succeedingPaths:
    #   - path: "/*"
    #     pathType: ImplementationSpecific
    #     serviceName: "ssl-redirect"
    #     servicePort: "use-annotation"
    succeedingPaths: []

####################################################################################################
# Dagster Daemon (Optional) Deploy a daemon for launching queued runs and running schedules and
# sensors.
#
# By default, this daemon is included in your deployment and used to run schedules and sensors.
# Setting `enabled` to false will stop the daemon from being included in your deployment.
#
# Each thread in the daemon periodically sends heartbeats to indicate that it is still running.
# Setting `heartbeatTolerance` lets you configure how long each thread can run without sending
# a heartbeat before the daemon determines that one must be hanging and restarts the process.
#
# Setting `config.queuedRunCoordinator.maxConcurrentRuns` in `runCoordinator` allows you to set
# limits on the total number of runs that can execute at once.
####################################################################################################
dagsterDaemon:
  enabled: true

  image:
    # When a tag is not supplied for a Dagster provided image,
    # it will default as the Helm chart version.
    repository: 'docker.io/dagster/dagster-celery-k8s'
    tag: ~
    pullPolicy: Always

  heartbeatTolerance: 1800

  runCoordinator:
    # Whether or not to enable the run queue (or some other custom run coordinator). See
    # https://docs.dagster.io/deployment/run-coordinator for more information.
    enabled: true

    # Type can be one of [
    #   QueuedRunCoordinator,
    #   CustomRunCoordinator,
    #  ]
    type: QueuedRunCoordinator
    config:
      queuedRunCoordinator:
        # The maximum number of runs to allow to be running at once. Defaults to no limit.
        maxConcurrentRuns: ~
        # Tag based concurrency limits. See https://docs.dagster.io/deployment/run-coordinator#usage
        # for examples.
        tagConcurrencyLimits: []
        # How frequently in seconds to check for new runs to pull from the queue and launch.
        # Defaults to 5.
        dequeueIntervalSeconds: ~
        # Whether to dequeue runs using an asynchronous thread pool, allowing multiple runs
        # to be dequeued in parallel.
        dequeueUseThreads: true
        # The max number of worker threads to use when dequeing runs. Can be tuned
        # to allow more runs to be dequeued in parallel, but may require allocating more
        # resources to the daemon.
        dequeueNumWorkers: 4

    ##  Uncomment this configuration if the CustomRunCoordinator is selected.
    ##  Using this setting requires a custom Daemon image that defines the user specified
    ##  run coordinator in an installed python module.
    #   customRunCoordinator:
    #     module: ~
    #     class: ~
    #     config: {}

  # Enables monitoring of run worker pods. If a run doesn't start within the timeout, it will be
  # marked as failed. If a run had started but then the run worker crashed, the monitoring daemon
  # will either fail the run or attempt to resume the run with a new run worker.
  runMonitoring:
    enabled: true
    # Timeout for runs to start (avoids runs hanging in STARTING)
    startTimeoutSeconds: 300
    # Timeout for runs to cancel (avoids runs hanging in CANCELING)
    # cancelTimeoutSeconds: 300
    # Timeout for runs to finish (avoids runs hanging in RUNNING)
    # maxRuntimeSeconds: 7200
    # How often to check on in progress runs
    pollIntervalSeconds: 120
    # [Experimental] Max number of times to attempt to resume a run with a new run worker instead
    # of failing the run if the run worker has crashed. Only works for runs using the
    # `k8s_job_executor` to run each op in its own Kubernetes job. To enable, set this value
    # to a value greater than 0.
    maxResumeRunAttempts: 0
    # [Experimental] Number of seconds to wait after a run has ended with a success/failed/canceled
    # status before freeing any concurrency slots that may have been retained.
    freeSlotsAfterRunEndSeconds: 0

  runRetries:
    enabled: true
    maxRetries: 0

  sensors:
    # Whether to evaluate sensors using an asynchronous thread pool, allowing sensprs
    # to execute in parallel,
    useThreads: true
    # The max number of worker threads to use when evaluating sensors. Can be tuned
    # to allow more sensors to run in parallel, but may require allocating more resources to the
    # daemon.
    numWorkers: 4
    # Uncomment to use a threadpool to submit runs from a single sensor tick in parallel. Can be
    # used to decrease latency when a sensor emits multiple run requests within a single tick.
    # numSubmitWorkers: 4

  schedules:
    # Whether to evaluate schedules using an asynchronous thread pool, allowing schedules
    # to execute in parallel
    useThreads: true
    # The max number of worker threads to use when evaluating sensors. Can be tuned
    # to allow more schedules to run in parallel, but may require allocating more resources to the
    # daemon.
    numWorkers: 4
    # Uncomment to use a threadpool to submit runs from a single schedule tick in parallel. Can be
    # used to decrease latency when a schedule emits multiple run requests within a single tick.
    # numSubmitWorkers: 4

  # Additional environment variables to set.
  # These will be directly applied to the daemon container. See
  # https://kubernetes.io/docs/tasks/inject-data-application/define-environment-variable-container/
  #
  # Example:
  #
  # env:
  # - name: ENV_ONE
  #   value: "one"
  # - name: ENV_TWO
  #   value: "two"
  env: []

  # Additional environment variables can be retrieved and set from ConfigMaps. See:
  # https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/#configure-all-key-value-pairs-in-a-configmap-as-container-environment-variables
  #
  # Example:
  #
  # envConfigMaps:
  #   - name: config-map
  envConfigMaps: []

  # Additional environment variables can be retrieved and set from Secrets. See:
  # https://kubernetes.io/docs/concepts/configuration/secret/#use-case-as-container-environment-variables
  #
  # Example:
  #
  # envSecrets:
  #   - name: secret
  envSecrets: []
  # Additional labels that should be included on the deployment. See:
  # https://kubernetes.io/docs/concepts/overview/working-with-objects/labels
  #
  # Example:
  # deploymentLabels:
  #   my-label-key: my_label-value
  deploymentLabels: {}

  # Additional labels that should be included on the pod. See:
  # https://kubernetes.io/docs/concepts/overview/working-with-objects/labels
  #
  # Example:
  # labels:
  #   my-label-key: my_label-value
  labels: {}

  # Additional volumes that should be included. See:
  # https://v1-18.docs.kubernetes.io/docs/reference/generated/kubernetes-api/v1.18/#volume-v1-core
  #
  # Example:
  #
  # volumes:
  #   - name: my-volume
  #     configMap: my-config-map
  volumes: []

  # Additional volume mounts that should be included. See:
  # See: https://v1-18.docs.kubernetes.io/docs/reference/generated/kubernetes-api/v1.18/#volumemount-v1-core
  #
  # Example:
  #
  # volumeMounts:
  #   - name: test-volume
  #     mountPath: /opt/dagster/test_folder
  #     subPath: test_file.yaml
  volumeMounts: []

  # Additional containers that should run as sidecars to the daemon. See:
  # https://kubernetes.io/docs/concepts/workloads/pods/#how-pods-manage-multiple-containers
  # For K8s versions after 1.29, prefer using extraPrependedInitContainers instead. See:
  # https://kubernetes.io/docs/concepts/workloads/pods/sidecar-containers/
  #
  # Example:
  # extraContainers:
  #   - name: my-sidecar
  #     image: busybox
  extraContainers: []

  # Additional init containers that should run before to the daemon's init container, such as sidecars.
  # For K8s versions after 1.29, see:
  # https://kubernetes.io/docs/concepts/workloads/pods/sidecar-containers/
  #
  # Extra init containers are started **before** the connection to the database is tested.
  #
  # Example:
  # extraPrependedInitContainers:
  #   - name: my-sidecar
  #     image: busybox
  extraPrependedInitContainers: []

  annotations: {}
  nodeSelector: {}
  affinity: {}
  tolerations: []
  podSecurityContext: {}
  securityContext: {}
  resources: {}

  # Configure initContainer resources separately from main container
  initContainerResources: {}
  # Enable the check-db-ready initContainer
  checkDbReadyInitContainer: true
  # Override the default K8s scheduler
  # schedulerName: ~

  # As of 0.14.0, liveness probes are disabled by default. If you want to enable them, it's recommended to also
  # enable startup probes.
  livenessProbe: {}
  readinessProbe: {}
  startupProbe: {}

####################################################################################################
# busybox: Configuration for the busybox image used to check connections
####################################################################################################
busybox:
  image:
    repository: 'docker.io/busybox'
    tag: '1.28'
    pullPolicy: 'IfNotPresent'

####################################################################################################
# Extra Manifests: (Optional) Create additional k8s resources within this chart
####################################################################################################
extraManifests:
#  # Set default container resource requests/limits for the namespace
#  #   * To override these for dagster system containers; edit the resources sections of
#  #     this values yaml -  eg: webserver.resources & celery.resources
#  #   * To override these in solid execution containers; add a @solid(tag=) similar to:
#  #      { "dagster-k8s/config": { "container_config": { "resources": {...
#  - apiVersion: v1
#    kind: LimitRange
#    metadata:
#      name: default-container-resources
#    spec:
#      limits:
#        - default:
#            cpu: 250m
#            memory: 512Mi
#          defaultRequest:
#            cpu: 100m
#            memory: 256Mi
#          type: Container
#  # Example 2:
#  - apiVersion: cloud.google.com/v1beta1
#    kind: BackendConfig
#    metadata:
#      name: "{{ .Release.Name }}-backend-config"
#      labels:
#      {{- include "dagster.labels" . | nindent 6 }}
#      spec:
#        securityPolicy:
#          name: "gcp-cloud-armor-policy-test"

####################################################################################################
# Dagster Instance Migrate: Creates a job to migrate your instance. This field should only be
# enabled in a one-off setting.
#
# For more details, see:
# https://docs.dagster.io/deployment/guides/kubernetes/how-to-migrate-your-instance
####################################################################################################
migrate:
  enabled: false

  # Additional containers that should be run as sidecars to the migration job. See:
  # https://kubernetes.io/docs/concepts/workloads/pods/#how-pods-manage-multiple-containers
  # For K8s versions after 1.29, prefer using initContainers to use native sidecars instead. See:
  # https://kubernetes.io/docs/concepts/workloads/pods/sidecar-containers/
  #
  # Example:
  # extraContainers:
  #   - name: my-sidecar
  #     image: busybox
  extraContainers: []

  # Init containers that should run before the main job container, such as native sidecars. See:
  # https://kubernetes.io/docs/concepts/workloads/pods/sidecar-containers/
  #
  # Example:
  # initContainers:
  #   - name: my-sidecar
  #     image: busybox
  initContainers: []

####################################################################################################
# As an open source project, we collect usage statistics to better understand how users engage
# with Dagster and to inform development priorities.
#
# Telemetry data will motivate projects such as adding functionality in frequently-used parts of
# the product and will help us understand adoption of new features.
#
# For more details, see:
# https://docs.dagster.io/getting-started/telemetry
####################################################################################################
telemetry:
  enabled: true

serviceAccount:
  create: true

  # Specifies the name for the service account to reference in the chart. Note that setting
  # the global service account name will override this field.
  name: ''

  annotations: {}

####################################################################################################
# Sets a data retention policy for data types such as schedule / sensor ticks.
#
# For more details, see:
# https://docs.dagster.io/deployment/dagster-instance#data-retention
####################################################################################################
retention:
  enabled: false
  schedule:
    # For schedule ticks, specifies after how many days ticks can be removed.  This field can either
    # be a dict of tick types to integers, or an integer (applies to all tick types).  A value of -1
    # indicates that ticks should be retained indefinitely.
    purgeAfterDays: -1
  sensor:
    # For sensor ticks, specifies after how many days ticks can be removed.  This field can either
    # be a dict of tick types to integers, or an integer (applies to all tick types).  A value of -1
    # indicates that ticks should be retained indefinitely.
    purgeAfterDays:
      failure: -1
      skipped: 7
      started: -1
      success: -1
  autoMaterialize:
    # For auto-materialization ticks, specifies after how many days ticks can be removed.  This
    # field can either be a dict of tick types to integers, or an integer (applies to all tick
    # types).  A value of -1 indicates that ticks should be retained indefinitely.
    purgeAfterDays:
      failure: -1
      skipped: 7
      started: -1
      success: -1
####################################################################################################
# Additional fields on the instance to configure that aren't already determined by a key above.
# See https://docs.dagster.io/deployment/dagster-instance for the full set of available fields.
####################################################################################################
# Example:
#
# additionalInstanceConfig:
#   auto_materialize: # See: https://docs.dagster.io/deployment/dagster-instance#auto-materialize
#     run_tags:
#       key: value
additionalInstanceConfig: {}

####################################################################################################
# [DEPRECATED] Pipeline Run
#
# This config can now be set with dagster-user-deployments.
####################################################################################################
pipelineRun:
  image:
    # When a tag is not supplied for a Dagster provided image,
    # it will default as the Helm chart version.
    repository: 'docker.io/dagster/user-code-example'
    tag: ~
    pullPolicy: Always

  # Additional environment variables to set.
  # A Kubernetes ConfigMap will be created with these environment variables. See:
  # https://kubernetes.io/docs/concepts/configuration/configmap/
  #
  # Example:
  #
  # env:
  #   ENV_ONE: one
  #   ENV_TWO: two
  env: {}
