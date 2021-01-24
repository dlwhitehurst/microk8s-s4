#!/bin/bash

microk8s kubectl apply -f config-map.yaml
microk8s kubectl apply -f secret.yaml
microk8s kubectl apply -f creds.yaml

microk8s kubectl apply -f mysql.yaml
microk8s kubectl apply -f states.yaml

microk8s kubectl patch svc states -p '{"spec": {"type": "LoadBalancer", "externalIPs":["192.168.1.25"]}}'
