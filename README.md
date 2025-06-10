# Prerequisites

- K8s environment (K8s, k3d, kind)
- Docker
- Tested with K3d and kind. 
  - k3d is a lightweight wrapper to run k3s (Rancher Lab’s minimal Kubernetes distribution) in docker.
  - kind is a tool for running local Kubernetes clusters using Docker container “nodes”.
- jq (optional if you want to format JSON logs outputs)

# Demo

**Create a k8s cluster**

```
k3d cluster create mycluster --servers=1 --agents=2
```

**Example of a Kubernetes Custom Resource Definition (CRD) for a `Person` object**

**1. CRD Definition: `person-crd.yaml`**

```yaml
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: people.example.com
spec:
  group: example.com
  names:
    kind: Person
    plural: people
    singular: person
    shortNames:
      - psn
  scope: Namespaced
  versions:
    - name: v1
      served: true
      storage: true
      schema:
        openAPIV3Schema:
          type: object
          properties:
            spec:
              type: object
              required:
                - fullName
                - age
              properties:
                fullName:
                  type: string
                age:
                  type: integer
                email:
                  type: string
                address:
                  type: string
```

---

**2. Sample Custom Resource: `sample-person.yaml`**

```yaml
apiVersion: example.com/v1
kind: Person
metadata:
  name: john-doe
spec:
  fullName: John Doe
  age: 30
  email: john.doe@example.com
  address: 123 Main Street, Anytown, USA
```

---

**3. Commands to Apply and Use**

```bash
# Apply the CRD
kubectl apply -f person-crd.yaml

# Confirm CRD was created
kubectl get crds

# Create a sample Person object
kubectl apply -f sample-person.yaml

# View the custom resource
kubectl get people

# Get detailed info
kubectl get person john-doe -o yaml
```



**Execute commands in the correct order:**

```
./01_install_plugin.sh
```

**Check crds**

```
kubectl get crd
```

**Install Operator**

```
./02_install_operator.sh
```

**Check Operator Status**

```
./03_check_operator_installed.sh
kubectl get all -n cnpg-system
```

**Install PostgreSQL Cluster**

```
./04_get_cluster_config_file.sh
./05_install_cluster.sh
```

**Open a new session and execute:**

```
./06_show_status.sh
```

**Check postgresql version:**

```
kubectl exec -it cluster-example-1 -- psql
select version();
```

**Open another session and execute MinIO server (S3 Object Storage compatible): Please, check the IP of your computer and replace in file cluster-example-upgrade.yaml.**

- **URL:** http://127.0.0.1:9001
- **User:** admin
- **Password:** password

```
./start_minio_docker_server.sh
```

**Connect to Container and check for minio feature**

```
docker ps -a
docker exec -it <container-id> bash
mc alias list
```

**Insert Data**

```
./07_insert_data.sh
```

**Promote a instance to primary**

```
./08_promote.sh
```

**Upgrade the PostgreSQL Version**

```
./09_upgrade.sh
```

**Backup Cluster Data to Minio's**

```
./10_backup_cluster.sh
./11_backup_describe.sh
```