# microk8s-s4
This repository contains the documentation, configuration, set-up, and notes to 
perform my training scenario in my MicroK8S Lab.

## Objective:
Run the states app on MicroK8S with a stateful MySql hosting and use ConfigMap and Secret objects (Kubernetes).

## References:
 - https://github.com/dlwhitehurst/states/
 - https://github.com/dlwhitehurst/integration-tools

## Assumptions:
 - HTTP only
 - Single instance of MySQL
 - Update database after deployment with schema and data
 - Create schema user on MySQL and add to ConfigMap and Secrets in another scenario. Use root (insecure) for now.

## Prerequisites:
 - Running MicroK8S installation on Ubuntu 20.04 LTS (Long Term Support)
 - Clean slate, i.e. no Kubernetes objects in place or running
 - DNS and Registry enabled
 - Available DHCP IP on bridged network to host (VM)
 - Node.js and npm are installed

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

```javascript
module.exports = {
  HOST: process.env.DB_HOST,
  USER: process.env.DB_USERNAME,
  PASSWORD: process.env.DB_PASSWORD,
  DB: process.env.DB_SCHEMA 
};
```
This change was to replace strings that were there and use `process.env.<ENV_VAR>`. This removes or provides separation-of-concern from the web application (states) and the container platform. Also, our use of ConfigMap and Secret (Kuberbetes) objects provides better security and keeps sensitive information out of the software repository. In my case, the hard-coded credentials "were"in the repository only because all of this is non-production and for training.

Open up a shell to your VM.

`multipass shell "discerning-dragonfly"`

I'm doing all my MicroK8S lab work at `/home/ubuntu` or login account. I have a clone of `states` already so I'm going to remove it and clone fresh.

```bash
rm -rf states
git clone https://github.com/dlwhitehurst/states.git
```
The updated states application is available and ready for lab objective no. 4. Let's move on to MySQL next.

### Single-Instance Stateful MySQL

**Lab Objective - 2**

Remember the environment variables in our `states` application's database configuration or `DB_HOST`, `DB_USERNAME`, `DB_PASSWORD`, and `DB_SCHEMA`? We will use the Kubernetes objects ConfigMap and Secret to pass the values into the `states` application also when we create the MySQL service here. The ConfigMap and Secret will be created within our cluster. These objects will only be available for interaction between objects that specify their use. These objects will not be available external to the cluster (or host).

The ConfigMap will be used like a property file for `DB_HOST` and `DB_SCHEMA`. Our database user and password will be captured in the Secret object.

Create a file called `config-map.yaml` for the non-sensitive database information. I've created that file and it is part of this software repository. Here are the file contents:

```yaml
# Non-sensitive database configuration 
apiVersion: v1
kind: ConfigMap
metadata:
  name: db-config-map 
data:
  host: mysql   # service dns
  schema: reference
```

Now create a file called `secret.yaml` for the sensitive stuff. Again, I've created this file and its contents are shown here:

```yaml
# sensitive database information
apiVersion: v1
kind: Secret
metadata:
  name: db-secret 
data:
  username: <base64-me>  	# base64 encoded 'Secret' username
  password: <base64-me> 	# base64 encoded 'Secret' password
```

I should note first that I'm breaking security rules here because I'm going use the `root` for my database credentials all over. My second note is about the username and password. One is useless with the other. And, you should never store the username and password in your software repo. The placeholder `<base64-me>` means that we will add a base64 representation of these credentials in our Secret before we `apply` it to our cluster.

I'll document the base64 how-to here using `abc123` as a plain-text example:

```bash
echo 'abc123' | base64
```

The `base64` Linux utility should be part of every Linux distribution and the command above pipes the text `abc123` to the utility and the output would look like this:

```bash
YWJjMTIzCg==
```

**NOTE:** The base64 representation is just an obfuscation of the plain-text and provides a *reasonable* security for the password. It also exhibits the behaviour where the base64 equivalent of `root` is always `cm9vdAo=` and thereby shoring up my note that the `root` user should not be used in place of an application user in production.

Now that we have our ConfigMap and Secret, we can `apply` or create these Kubernetes objects in our cluster. Please note that we are only creating a ConfigMap and a Secret configuration with the namespaces `db-config-map` and `db-secret` respectively. At this time they are not being used.

Create the configurations using the manifest files we created (or you cloned).

```bash
kubectl apply -f config-map.yaml
kubectl apply -f secret.yaml
```
Now that our configurations are in place, we will turn to the specification of our MySQL service. In Kubernetes terms, MySQL is a stateful or storage application, i.e. the data is timely and needs to be persisted. Also care of the instances under control of Kubernetes is very different from more ephemeral and highly-scalable compute instances. While stateful applications can scale, we are starting small with a single-instance (non-replicated) MySQL image.

