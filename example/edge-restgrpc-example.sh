#!/bin/bash

# This script is based on the following gRPC to REST example: 
# https://docs.solo.io/gloo-edge/latest/guides/traffic_management/destination_types/grpc_to_rest/

# You must label your namespace to allow function discovery 
# Doc https://docs.solo.io/gloo-edge/latest/installation/advanced_configuration/fds_mode/#whitelisting-namespaces--upstreams

kubectl label ns default discovery.solo.io/function_discovery=enable

kubectl create deployment grpcstore-demo --image=docker.io/soloio/grpcstore-demo
kubectl expose deployment grpcstore-demo --port 80 --target-port=8080

sleep 15

kubectl get upstream -n gloo-system default-grpcstore-demo-80 -o yaml

kubectl create -f - <<EOF
apiVersion: gateway.solo.io/v1
kind: VirtualService
metadata:
  name: default
  namespace: gloo-system
spec:
  virtualHost:
    routes:
    - matchers:
       - methods:
         - GET
         prefix: /items/
      routeAction:
       single:
         destinationSpec:
           grpc:
             function: GetItem
             package: solo.examples.v1
             parameters:
               path: /items/{name}
             service: StoreService
         upstream:
           name: default-grpcstore-demo-80
           namespace: gloo-system
    - matchers:
       - methods:
         - DELETE
         prefix: /items/
      routeAction:
       single:
         destinationSpec:
           grpc:
             function: DeleteItem
             package: solo.examples.v1
             parameters:
               path: /items/{name}
             service: StoreService
         upstream:
           name: default-grpcstore-demo-80
           namespace: gloo-system
    - matchers:
       - methods:
         - GET
         exact: /items
      routeAction:
       single:
         destinationSpec:
           grpc:
             function: ListItems
             package: solo.examples.v1
             service: StoreService
         upstream:
           name: default-grpcstore-demo-80
           namespace: gloo-system
    - matchers:
       - methods:
         - POST
         exact: /items
      routeAction:
       single:
         destinationSpec:
           grpc:
             function: CreateItem
             package: solo.examples.v1
             service: StoreService
         upstream:
           name: default-grpcstore-demo-80
           namespace: gloo-system
EOF

sleep 20

echo
echo "Testing REST API"
echo
URL=$(glooctl proxy url)
echo
echo "Create an item in the store."
curl $URL/items -d '{"item":{"name":"item1"}}'
echo
echo
echo "List all items in the store. You should see an object with a list containing the item created above." 
echo
curl $URL/items
echo
echo "Access a specific item. You should see the item as a single object."
echo
curl $URL/items/item1
echo
echo "Delete the item created."
curl $URL/items/item1 -XDELETE
echo
echo "No items - this will return an empty object."
echo
curl $URL/items
echo
