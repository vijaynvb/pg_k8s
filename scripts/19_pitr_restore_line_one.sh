#!/bin/bash

. ./config.sh

# Get PITR timestamp
pitr_date=$(kubectl exec -i cluster-example-1 -- psql -X -A -t -c "select min(timestamp + interval '1 second') from test;" < /dev/null | tr -d '\r')
echo "PITR Date: $pitr_date"

# Get IP address
ip=$(./get_ip.sh)
echo "IP: $ip"

# Generate restore.yaml for PITR
cat > ./pitr/restore.yaml <<EOF
apiVersion: postgresql.cnpg.io/v1
kind: Cluster
metadata:
  name: cluster-restore
spec:
  instances: 1
  imageName: ghcr.io/cloudnative-pg/postgresql:16.4

  storage:
    size: 1Gi
  walStorage:
    size: 1Gi
  tablespaces:
  - name: idx
    storage:
      size: 1Gi
  - name: tmptbs
    temporary: true
    storage:
      size: 1Gi

  bootstrap:
    recovery:
      source: cluster-example
      recoveryTarget:
        targetTime: '${pitr_date}'

  externalClusters:
    - name: cluster-example
      barmanObjectStore:
        destinationPath: "s3://cnp/"
        endpointURL: "http://minio.default.svc.cluster.local:9000"
        s3Credentials:
          accessKeyId:
            name: minio-creds
            key: MINIO_ACCESS_KEY
          secretAccessKey:
            name: minio-creds
            key: MINIO_SECRET_KEY
EOF

# Cleanup previous restore if any
kubectl delete cluster cluster-restore --ignore-not-found
sleep 5

# Force WAL rotation before PITR
kubectl exec -it cluster-example-1 -- psql -c "select pg_switch_wal();"

# Apply restore manifest
kubectl apply -f ./pitr/restore.yaml

echo -e "\n\033[0;32m/!\\ Verify that only the first record will be restored :-)\033[0m\n"

# Wait for recovery
sleep 60

# Check restored data
kubectl exec -it cluster-restore-1 -- psql -c "select * from test;"