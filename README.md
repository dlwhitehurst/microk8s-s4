# microk8s-s4
This repository contains the documentation, configuration, set-up, and notes to 
perform my training scenario in my MicroK8S Lab.

## Objective:
Run the states app on MicroK8S with a stateful MySql hosting and use ConfigMap and Secret objects (Kubernetes).

## References:
https://github.com/dlwhitehurst/states/
https://github.com/dlwhitehurst/integration-tools

## Assumptions:
 - HTTP only
 - Single instance of MySQL
 - Update database after deployment with schema and data
 - Create schema user on MySQL and add to ConfigMap and Secrets in another scenario. Use root (insecure) for now.


## Lab:
High-level objectives include:

1. 

