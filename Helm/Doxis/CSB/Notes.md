Look at [initial-setup-job.yaml](CSB/templates/initial-setup-job.yaml)

Rather than within the admin pod, use the k8s job to connect to the adminPod. Then in the job, for the createDomain script to be effective, the env var DX4_KUBERNETES_AUTO_DETECTION should be set to true
env:
  - name: DX4_KUBERNETES_AUTO_DETECTION
    value: "true"



Investigate where the PV is because for all pods, the DX4_SHARED_DIR environment variable has to be correctly set to point to a persistent volume in the Kubernetes cluster.
