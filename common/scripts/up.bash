#!/bin/bash

set -e

ws=""
k8s=false
ingress=false
certman=false
sonarqube=false
gitlab=false
observe=false
all=false

TEMP=`getopt --long -o "w:kicsgoa" "$@"`
eval set -- "$TEMP"
while true ; do
    case "$1" in
        -w )
            ws=$2
            shift 2
        ;;
        -k)
            k8s=true
            shift 1
        ;;
        -i)
            ingress=true
            shift 1
        ;;
        -c)
            certman=true
            shift 1
        ;;
        -s)
            sonarqube=true
            shift 1
        ;;
        -g)
            gitlab=true
            shift 1
        ;;
        -o)
            observe=true
            shift 1
        ;;
        -a )
            all=true
            shift 1
        ;;
        *)
            break
        ;;
    esac 
done;

if $all ; then 
    sonarqube=true ;
    gitlab=true ;
    observe=true
fi

if [ $sonarqube ] || [ $gitlab ] || [ $observe ] ; then 
    certman=true ;
fi

if $certman ; then 
    ingress=true ;
fi

if $ingress ; then 
    k8s=true
fi

echo -e "ws=$ws\nk8s=$k8s\ningress=$ingress\ncertman=$certman\nsonarqube=$sonarqube\ngitlab=$gitlab\nobserve=$observe"

echo "creating resources for $ws environment"

# 1 - target
create() {
    echo "creating resources for $1"
    terraform -chdir=$1 init -upgrade
    terraform -chdir=$1 workspace select -or-create $ws
    terraform -chdir=$1 apply -auto-approve
    echo "$1 created!"
}

if $k8s ; then create platform/infra/k8s/cluster ; fi
if $ingress ; then create platform/infra/k8s/ingress-controller ; fi
if $certman ; then create platform/infra/k8s/cert-manager ; fi
if $sonarqube ; then create platform/tools/sonarqube ; fi
if $gitlab ; then create platform/tools/gitlab ; fi
if $observe ; then create platform/tools/observability ; fi
