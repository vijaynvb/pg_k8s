#!/bin/bash
. ../config.sh
printf "${green}kubectl port-forward svc/prometheus-community-kube-prometheus 9090${reset}\n"
printf "${green}kubectl port-forward svc/prometheus-community-grafana 3000:80${reset}\n"
printf "\n"

# Prometheus port forwarding
kubectl port-forward svc/prometheus-community-kube-prometheus 9090 --namespace prometheus&
pid1=$!
printf "${green}Prometheus pid: ${red}$pid1${reset}\n"

# Grafana port forwarding
kubectl port-forward svc/prometheus-community-grafana 3000:80 --namespace prometheus&
pid2=$!
printf "${green}Grafana pid: ${red}$pid2${reset}\n"
printf "\n"
sleep 30000