# 1.What the project does ?
# 2.Why the project is useful ?
# 3. How users can get started with the project ?
# 4. Where users can get help with your project ?
# 5. Who maintains and contributes to the project , How to contribute?
# contributions 
if you want to contribute to a project, the simplest way is to:
1. Find a repo fork button
3. Clone it to your local system
4. Make a new branch
5. Make your changes
6. Push it back to your repo
7. Click the Compare & pull request button
8. Click Create pull request to open a new pull request






Google project factory require permissions to be given to Service Account

roles/resourcemanager.folderViewer on the folder that you want to create the project in
roles/resourcemanager.organizationViewer on the organization
roles/resourcemanager.projectCreator on the organization
roles/billing.user on the organization
roles/storage.admin on bucket_project

In order to execute this module you must have a Service Account with the following roles:

roles/compute.networkAdmin on the organization or folder

Configure a Service Account
In order to execute this module you must have a Service Account with the following project roles:

roles/compute.viewer
roles/compute.securityAdmin (only required if add_cluster_firewall_rules is set to true)
roles/container.clusterAdmin
roles/container.developer
roles/iam.serviceAccountAdmin
roles/iam.serviceAccountUser
roles/resourcemanager.projectIamAdmin (only required if service_account is set to create)
Additionally, if service_account is set to create and grant_registry_access is requested, the service account requires the following role on the registry_project_ids projects:

roles/resourcemanager.projectIamAdmin
