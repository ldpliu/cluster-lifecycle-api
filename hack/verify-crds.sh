#!/bin/bash

if [ ! -f ./_output/tools/bin/yq ]; then
    mkdir -p ./_output/tools/bin
    curl -s -f -L https://github.com/mikefarah/yq/releases/download/2.4.0/yq_$(go env GOHOSTOS)_$(go env GOHOSTARCH) -o ./_output/tools/bin/yq
    chmod +x ./_output/tools/bin/yq
fi

FILES="action/v1beta1/*.crd.yaml
view/v1beta1/*.crd.yaml
clusterinfo/v1beta1/*.crd.yaml
imageregistry/v1alpha1/*.crd.yaml
"

FAILS=false
for f in $FILES
do
    if [[ $(./_output/tools/bin/yq r $f spec.validation.openAPIV3Schema.properties.metadata.description) != "null" ]]; then
        echo "Error: cannot have a metadata description in $f"
        FAILS=true
    fi

    if [[ $(./_output/tools/bin/yq r $f spec.preserveUnknownFields) != "false" ]]; then
        echo "Error: pruning not enabled (spec.preserveUnknownFields != false) in $f"
        FAILS=true
    fi
done

if [ "$FAILS" = true ] ; then
    exit 1
fi
