#!/usr/bin/env bash

PROD=0
RELEASE=0
LIVE_RELEASE=0
DEV_REPO=564623767830.dkr.ecr.eu-west-1.amazonaws.com
PROD_REPO=920763156836.dkr.ecr.eu-west-1.amazonaws.com

while getopts ":prl" opt; do
  case $opt in
    p)
      PROD=1
      ;;
    r)
      RELEASE=1
      ;;
    l)
      LIVE_RELEASE=1
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
    *)
      echo "Unknown argument $opt"
      exit 1
      ;;  
  esac
done

AWS_REGION=${REGION}
AWS_DEFAULT_REGION=${REGION}

IMAGE=nexmo-wa-monitoring

version=`cat .version`
if [[ -z "${version}" ]]; then
    echo "Could not determine version, aborting."
    exit 1
fi

echo "+--- Version checks"
echo "| Docker: $(docker --version)"
echo "| Kubectl: $(kubectl version --short --client)"
echo "| AWS cli: $(aws --version)"

# suppress a legal -e flag that docker no longer supports
docker_login=$(aws ecr get-login --region eu-west-1 | sed 's/ -e none//')
echo "Logging into Def ECR"
eval $docker_login

regversion=$(aws ecr describe-images --registry-id 564623767830  --repository-name nexmo-wa-monitoring --query 'sort_by(imageDetails,& imagePushedAt)[-1].imageTags' | grep -e [0-9] | sed 's/[ ",]//g' )

echo "Git repo version: $version"
echo "Registry latest version: ${regversion}"

if [[ "${version}" = "${regversion}" ]]; then 
  echo "Latest version already exists in registry - did you remember to bump the version?"
else
    docker build . -t $IMAGE:$version
    docker tag $IMAGE:$version $IMAGE:latest

    echo "Preparing to publish ${IMAGE}:${version} to ${DEV_REPO}/${IMAGE}:${version}"

    docker tag $IMAGE:latest $DEV_REPO/$IMAGE:latest
    docker tag $IMAGE:$version $DEV_REPO/$IMAGE:$version
    docker push $DEV_REPO/$IMAGE:latest
    docker push $DEV_REPO/$IMAGE:$version
fi

# roll out to production ecr as well
if [[ "1" -eq "${PROD}" ]]; then
    docker_login=$(AWS_PROFILE=nexmo-prod aws ecr get-login --region eu-west-1 | sed 's/ -e none//')

    echo "Logging into Production ECR."
    eval $docker_login

    docker tag $IMAGE:latest $PROD_REPO/$IMAGE:latest
    docker tag $IMAGE:$version $PROD_REPO/$IMAGE:$version
    docker push $PROD_REPO/$IMAGE:latest
    docker push $PROD_REPO/$IMAGE:$version
fi

if [[ "1" -eq "${RELEASE}" ]]; then
    echo "Deploying ${IMAGE}=${REPO}/${IMAGE}:${version} to deployment/${IMAGE}"
    kubectx nexmo-wa-dev
    patchstr="{\"spec\": {\"template\": {\"spec\": {\"containers\": [{\"name\": \"teleport\", \"image\": \"${DEV_REPO}/${IMAGE}:${version}\"}]}}}}"
    echo Patching: ${patchstr} to nexmo-wa-dev
    AWS_PROFILE=nexmo-dev kubectl patch deployment wa-monitor -n monitoring -p \ "${patchstr}"
fi

if [[ "1" -eq "${LIVE_RELEASE}" ]]; then
    echo "Deploying ${IMAGE}=${PROD_REPO}/${IMAGE}:${version} to deployment/${IMAGE}"
    kubectx arn:aws:eks:eu-west-1:920763156836:cluster/nexmo-eks-prod-eu-west-1
    patchstr="{\"spec\": {\"template\": {\"spec\": {\"containers\": [{\"name\": \"teleport\", \"image\": \"${PROD_REPO}/${IMAGE}:${version}\"}]}}}}"
    echo Patching: ${patchstr} to arn:aws:eks:eu-west-1:920763156836:cluster/nexmo-eks-prod-eu-west-1
    AWS_PROFILE=nexmo-prod kubectl patch deployment wa-monitor -n monitoring -p \ "${patchstr}"
fi