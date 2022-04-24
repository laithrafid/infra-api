# Creating kubernetes cluster/s on AWS

# Requirements
Tool required before building the cluster are:
1. kubectl  `brew install kubectl`
command line tool for interacting with Kubernetes cluster
2. kops `brew install kops`
 The Kubernetes Operations (kops) project handles the building and operation of Kubernetes clusters on the cloud (stable support for Google Cloud and AWS)

4. terraform `brew install terraform`
 IaC tool for infrastructure state management and build/deployment
3. awscli `brew install awscli`
 AWS command line tool
5. jq `brew install jq`
 lightweight and flexible command-line JSON processor.
 

# USAGE

## 1. Configure DNS

In order to build a Kubernetes cluster with kops, we need to prepare somewhere to build the required DNS records. There are three scenarios below and you should choose the one that most closely matches your AWS situation.

Note: if you want to use [gossip-based DNS](https://kops.sigs.k8s.io/gossip/), you can skip this section.

### Scenario 1: purchased/hosted via AWS 
there's two options subdomain or full domain:

#### Scenario 1a: A Domain purchased/hosted via AWS

If you bought your domain with AWS, then you should already have a hosted zone in Route53. If you plan to use this domain then no more work is needed.

In this example you own `example.com` and your records for Kubernetes would look like `etcd-us-east-1c.internal.clustername.example.com`

#### Scenario 1b: A subdomain under a domain purchased/hosted via AWS

In this scenario you want to contain all kubernetes records under a subdomain of a domain you host in Route53. This requires creating a second hosted zone in route53, and then setting up route delegation to the new zone.

In this example you own example.com and your records for Kubernetes would look like `etcd-us-east-1c.internal.clustername.subdomain.example.com`

This is copying the NS servers of your SUBDOMAIN up to the PARENT domain in Route53. To do this you should:

- Create the subdomain, and note your SUBDOMAIN name servers (If you have already done this you can also get the values)

- Note: This example assumes you have jq installed locally.

```
$ ID=$(uuidgen) && aws route53 create-hosted-zone --name subdomain.example.com --caller-reference $ID | \
    jq .DelegationSet.NameServers
```

Note your PARENT hosted zone id

- Note: This example assumes you have jq installed locally.

```
$ aws route53 list-hosted-zones | jq '.HostedZones[] | select(.Name=="example.com.") | .Id'
```

- Create a new JSON file with your values (subdomain.json)
Note: The NS values here are for the SUBDOMAIN

```
{
  "Comment": "Create a subdomain NS record in the parent domain",
  "Changes": [
    {
      "Action": "CREATE",
      "ResourceRecordSet": {
        "Name": "subdomain.example.com",
        "Type": "NS",
        "TTL": 300,
        "ResourceRecords": [
          {
            "Value": "ns-1.<example-aws-dns>-1.co.uk"
          },
          {
            "Value": "ns-2.<example-aws-dns>-2.org"
          },
          {
            "Value": "ns-3.<example-aws-dns>-3.com"
          },
          {
            "Value": "ns-4.<example-aws-dns>-4.net"
          }
        ]
      }
    }
  ]
}
```

- Apply the SUBDOMAIN NS records to the PARENT hosted zone.

```
$ aws route53 change-resource-record-sets \
 --hosted-zone-id <parent-zone-id> \
 --change-batch file://subdomain.json
```

Now traffic to `*.subdomain.example.com` will be routed to the correct subdomain hosted zone in Route53.

### Scenario 2: Setting up Route53 for a domain purchased with another registrar¶
If you bought your domain elsewhere, and would like to dedicate the entire domain to AWS you should follow the guide [here](http://docs.aws.amazon.com/Route53/latest/DeveloperGuide/domain-transfer-to-route-53.html)

Scenario 3: Subdomain for clusters in route53, leaving the domain at another registrar¶
If you bought your domain elsewhere, but only want to use a subdomain in AWS Route53 you must modify your registrar's NS (NameServer) records. We'll create a hosted zone in Route53, and then migrate the subdomain's NS records to your other registrar.

You might need to grab jq for some of these instructions.

Create the subdomain, and note your name servers (If you have already done this you can also [get the values](https://kops.sigs.k8s.io/advanced/ns/))

```ID=$(uuidgen) && aws route53 create-hosted-zone --name subdomain.example.com --caller-reference $ID | jq .DelegationSet.NameServers```

You will now go to your registrar's page and log in. You will need to create a new SUBDOMAIN, and use the 4 NS records received from the above command for the new SUBDOMAIN. This MUST be done in order to use your cluster. Do NOT change your top level NS record, or you might take your site offline.

Information on adding NS records with Godaddy.com

Information on adding NS records with Google Cloud Platform

* Using Public/Private DNS (kOps 1.5+)¶
By default the assumption is that NS records are publicly available. If you require private DNS records you should modify the commands we run later in this guide to include:

`kops create cluster --dns private $NAME`
If you have a mix of public and private zones, you will also need to include the --dns-zone argument with the hosted zone id you wish to deploy in:

`kops create cluster --dns private --dns-zone ZABCDEFG $NAME`

Testing your DNS setup
This section is not required if a gossip-based cluster is created.

You should now be able to dig your domain (or subdomain) and see the AWS Name Servers on the other end.

dig ns subdomain.example.com
Should return something similar to:

;; ANSWER SECTION:
subdomain.example.com.        172800  IN  NS  ns-1.<example-aws-dns>-1.net.
subdomain.example.com.        172800  IN  NS  ns-2.<example-aws-dns>-2.org.
subdomain.example.com.        172800  IN  NS  ns-3.<example-aws-dns>-3.com.
subdomain.example.com.        172800  IN  NS  ns-4.<example-aws-dns>-4.co.uk.
This is a critical component when setting up clusters. If you are experiencing problems with the Kubernetes API not coming up, chances are something is wrong with the cluster's DNS.

Please DO NOT MOVE ON until you have validated your NS records! This is not required if a gossip-based cluster is created.


## 2. Clone this repository 

 `git clone `

## 3. Configure script permissions and set up environment variables
```
$ chmod +x ./create_cluster.sh
$ aws configure 
```

## 4. Run create cluster script

`
$ ./create_cluster.sh $STAGE
`
to check the deployment run command :

`
$ kops validate cluster
`
## 5. Cleanup 
In case you want to destroy the cluster deployed, you can simply use this command inside the [your-stage]/cluster and [your-stage]/prereq folder
`
$ terraform destroy
`

# References 
* https://kops.sigs.k8s.io/gossip/
* https://kops.sigs.k8s.io/getting_started/aws/#customize-cluster-configuration
* https://github.com/dayta-ai/kubernetes-cluster-tutorial