#!/usr/bin/env sh

# install KinD
curl -Lo ./kind https://github.com/kubernetes-sigs/kind/releases/download/v0.20.0/kind-$(uname)-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/ 

# create cluster
kind create cluster --name wslk8s

# install Istio
curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.18.2 TARGET_ARCH=x86_64 sh -

cd istio-1.18.2

export PATH=$PWD/bin:$PATH

istioctl install --set profile=demo -y

kubectl label namespace default istio-injection=enabled

kubectl apply -f samples/bookinfo/platform/kube/bookinfo.yaml

kubectl apply -f samples/bookinfo/networking/bookinfo-gateway.yaml

# instll Kiali
kubectl apply -f samples/addons
kubectl rollout status deployment/kiali -n istio-system

nohup istioctl dashboard kiali & 

# install kubernetes dashboard
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.1/aio/deploy/recommended.yaml

kubectl apply -f - <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
EOF

kubectl apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
EOF

kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: admin-user-secret
  namespace: kubernetes-dashboard
  annotations:
    kubernetes.io/service-account.name: admin-user
type: kubernetes.io/service-account-token
EOF

kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep admin-user | awk '{print $1}')

nohup kubectl proxy &
