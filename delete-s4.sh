#!/bin/bash

microk8s kubectl delete secrets db-secret
microk8s kubectl delete secrets db-credentials

microk8s kubectl delete configmaps db-config-map

microk8s kubectl delete service states
microk8s kubectl delete service mysql

microk8s kubectl delete pods -l app=states
microk8s kubectl delete pods -l app=mysql
 



