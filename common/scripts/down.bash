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

TEMP=`getopt --long -o "w:aogscik" "$@"`
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
    k8s=true ;
fi

if $k8s ; then 
    ingress=true
fi

if $ingress ; then 
    certman=true ;
fi

if $certman ; then 
    sonarqube=true ;
    gitlab=true ;
    observe=true ;
fi

echo -e "ws=$ws\nk8s=$k8s\ningress=$ingress\ncertman=$certman\nsonarqube=$sonarqube\ngitlab=$gitlab\nobserve=$observe"

echo "creating resources for $ws environment"

# 1 - target
destroy() {
    terraform -chdir=$1 init -upgrade
    terraform -chdir=$1 workspace select -or-create $ws
    local states=$(terraform -chdir=$1 state list | wc -l)
    if (( $states > 0 )); then
        echo "destroying $states resources for $1"
        terraform -chdir=$1 destroy -auto-approve
        echo "$1 destoyed!"
    else
        echo "nothing to destroy for $1"
    fi
}

if $observe ; then destroy platform/tools/observability ; fi
if $gitlab ; then destroy platform/tools/gitlab ; fi
if $sonarqube ; then destroy platform/tools/sonarqube ; fi
if $certman ; then destroy platform/infra/k8s/cert-manager ; fi
if $ingress ; then destroy platform/infra/k8s/ingress-controller ; fi
if $k8s ; then destroy platform/infra/k8s/cluster ; fi
