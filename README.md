# Teleport

Author: Jeremy Botha
Version: 0.0.26

[![Build Status](https://travis-ci.org/sacrebleu/teleport.svg?branch=master)](https://travis-ci.org/sacrebleu/teleport)
#### Overview

Teleport is a authentication proxy for services like the whatsapp business client 
that guard metrics and other necessary endoints behind authentication.

Teleport is a ruby application packaged to run as a docker container that exposes HTTP on port 3000

It requires access to the whatsapp shared credentials mysql database.

#### Need

Prometheus has no concept of authenticiation or secure metrics endpoints.  The most complex
endpoint it could collect from is one which permits authentication via HTTP query parameters -
many services require header-based auth using Bearer tokens or more advanced schemes.

#### Building and deploying

to deploy to the development cluster `arn:aws:eks:eu-west-1:564623767830:cluster/nexmo-eks-dev`

1. increment [.version](.version)
2. `./release.sh -r` 
3. verify the new version is running on the cluster.

        $ kubectl get po -n monitoring | grep wa-monitor | awk '{print $1 }' | xargs kubectl describe -n monitoring po
        ...
        Image ID:       docker-pullable://564623767830.dkr.ecr.eu-west-1.amazonaws.com/nexmo-wa-monitoring@sha256:162a3c8be09b2814eb1df6f0e5cea0c9411fc9e583a34c6119f7c144a691fe7d
    

to deploy to the production cluster `arn:aws:eks:eu-west-1:920763156836:cluster/nexmo-eks-prod-eu-west-1`

1. increment [.version](.version) if necessary
2. `./release.sh -l -p`
3. verify the new version is running on the cluster

        $ kubectl get po -n monitoring | grep wa-monitor | awk '{print $1 }' | xargs kubectl describe -n monitoring po
        ... 
        Image ID:       docker-pullable://920763156836.dkr.ecr.eu-west-1.amazonaws.com/nexmo-wa-monitoring@sha256:c19fddfbf95f7a5b04889e2f19d03defc4ba4b80f2f407817e755400ff877f94
        
#### Metrics

metrics for an individual whatsapp cluster are exposed on the route `/metrics/<cluster number>` for each cluster that
teleport can authenticate onto

health checks for an individual whatsapp cluster are exposed on the route `/health/<cluster nmumber>` for each cluster teleport can
authenticate onto. 
