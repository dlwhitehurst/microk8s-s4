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

## Notes:
Detailed notes will be captured here as this lab objective is accomplished. This experiment is being done as I learn about Kubernetes and train myself for a huge upcoming project.

These notes will follow the lab objectives in order but may re-order tasks mid-stream if required.

### Analyze and Refactor the Web Application for Kubernetes

**Lab Objective - 1**
I've opened and inspected the states application for any properties that would require a placeholder. The states application was created specifically for my Kubernetes learning. The application project contains a directory specifically for database configuration at `<project>/app/config` and a single file `db-config.js`.

I revised/refactored this file today to look like so:

```
module.exports = {
  HOST: process.env.DB_HOST,
  USER: process.env.DB_USERNAME,
  PASSWORD: process.env.DB_PASSWORD,
  DB: process.env.DB_SCHEMA 
};
```
This change was to replace strings that were there and use `process.env.<ENV_VAR>`. This removes or provides separation-of-concern from the web application (states) and the container platform. Also, our use of ConfigMap and Secret (Kuberbetes) objects provides better security and keeps sensitive information out of the software repository. In my case, the hard-coded credentials "were"in the repository only because all of this is non-production and for training.  


