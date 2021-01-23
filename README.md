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

## Prerequisites:
 - Running MicroK8S installation
 - Clean slate, i.e. no Kubernetes objects in place or running
 - DNS and Registry enabled
 - Available DHCP IP on bridged network to host (VM)

## Lab:
High-level objectives include:

1. States (node.js) application set up with placeholder variables for any environment or external service needs, e.g. MySQL database, host, port, schema, user, password, etc.
2. Install, configure, and host a single-instance stateful deployment of MySQL as a NodePort service. Also, inaccessible from the host (VM) machine.
3. Learn how to create ConfigMap and Secret Kubernetes objects. The ConfigMap for non-sensitive properties and Secret for sensitive matter.
4. Build a docker image of States application and make available in the MicroK8S image registry.
5. Configure a States Service and ultimately a composite scalable Deployment using the stand-alone MySQL. Note that MySQL can be later configured to be scalable but this is much more complex.

