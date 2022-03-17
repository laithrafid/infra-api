[![DigitalOcean Referral Badge](https://web-platforms.sfo2.cdn.digitaloceanspaces.com/WWW/Badge%201.svg)](https://www.digitalocean.com/?refcode=d166e9ee2b50&utm_campaign=Referral_Invite&utm_medium=Referral_Program&utm_source=badge)
# Infrastructure for Rest-Api Microservices Written in go 

## Archietecture of APIs
![alt text](https://github.com/laithrafid/infra-api/blob/main/Images/infra-api-architecture.png?raw=true)

## TODO: DevOps Workflow , Refine documentation

## TODO: APIs Workflow and Documantation : swaggerApi

## TODO: k8s , Helm chart 

## How to Run

```
docker compose -f docker-compose-db.yml up -d 
```
creates containers ,volumes and two networks below

1. Cassandra 
- ports 
7199 - JMX (was 8080 pre Cassandra 0.8.xx)
7000 - Internode communication (not used if TLS enabled)
7001 - TLS Internode communication (used if TLS enabled)
9160 - Thrift client API
9042 - CQL native transport port
Env: to make it accessable 
- CASSANDRA_BROADCAST_ADDRESS=host.docker.internal
- CASSANDRA_SEEDS=host.docker.internal 
2. Temp Cassandra container to create keyspace and schema
3. MYSQL Instance
4. Temp Mysql Container to Create DB and schema

```
docker compose -f docker-compose-elk.yml up -d 
```
creates containers ,volumes and a network below
1. Elasticsearch
2. Kibana
3. logstash 






## Generating enrollment tokens

The enrollment token is valid for 30 minutes. If you need to generate a new enrollment token, run the elasticsearch-create-enrollment-token tool on your existing node. This tool is available in the Elasticsearch bin directory of the Docker container.

For example, run the following command on the existing Elastic-container node to generate an enrollment token for new Elasticsearch nodes:
```
docker exec -it elastic-container /usr/share/elasticsearch/bin/elasticsearch-create-enrollment-token -s node
```


for kibana run :
```
docker exec -it elastic-container /usr/share/elasticsearch/bin/elasticsearch-create-enrollment-token -s kibana
```


then put this token in your kibana , it will ask for Your verification code ,Which you can generate by runnig 
```
docker exec -it kibana-container bin/kibana-verification-code
```
#TODO: Automating

## Enrolling additional nodes

- In the terminal where you started your first node, copy the generated enrollment token for adding new Elasticsearch nodes.
- On your new node, start Elasticsearch and include the generated enrollment token.

```
docker run -e ENROLLMENT_TOKEN="<token>" --name elastic-container2 --net backend -it docker.elastic.co/elasticsearch/elasticsearch:8.0.1
```
- If you experience issues where the container where your first node is running exits when your second node starts, explicitly set values for the JVM heap size. To manually configure the heap size, include the ES_JAVA_OPTS variable and set values for -Xms and -Xmx when starting each node. For example, the following command starts node elastic-container2  sets the minimum and maximum JVM heap size to 1 GB:
(This already in eviornment variables file)

```
docker run -e ES_JAVA_OPTS="-Xms1g -Xmx1g" -e ENROLLMENT_TOKEN="<token>" --name elastic-container2 -p 9201:9200 --net elastic -it docker.elastic.co/elasticsearch/elasticsearch:8.0.1
```


to start apis 

```
docker compose -f docker-compose-api.yml up -d 
```



 This DevOps (createcluster) workflow installs the latest version of Terraform CLI and configures the Terraform CLI configuration file
on Push tag k8s.* events to the main branch, this workflow will run
 `terraform init`, `terraform fmt`, and `terraform plan` if no errors then `terraform apply` will be executed.


# contributions 
if you want to contribute to a project, the simplest way is to:
1. Find a repo fork button
3. Clone it to your local system
4. Make a new branch
5. Make your changes
6. Push it back to your repo
7. Click the Compare & pull request button
8. Click Create pull request to open a new pull request