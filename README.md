# REST to gRPC Portal Example

This example assumes that you have Gloo Edge and Gloo Portal installed and functional.


### Step 1
Fork and Clone this repo and cd into the examples directory.
```sh
git clone https://github.com/nickschuetz/resttogrpc.git

cd resttogrpc/examples
```

*Note that you'll need to change the domain references to your specific domain(s).

### Step 2
Review and run the `edge-restgrpc-example.sh` script to install and deploy a gRPC micro-service and transform its gRPC API to a REST API via Gloo Edge

```sh
edge-restgrpc-example.sh
```

Apply all the supporting gloo manifests
```sh
kubectl apply -f grpcstore-demo-apidoc.yaml
kubectl apply -f grpcstore-demo-apiproduct.yaml
kubectl apply -f grpcstore-demo-environment.yaml
kubectl apply -f grpcstore-demo-portal.yaml
```

If you take a look at [grpcstore-demo-apidoc.yaml](https://github.com/nickschuetz/resttogrpc/blob/main/example/grpcstore-demo-apidoc.yaml) we're using `fetchURL` to grab the pre defined OpenAPI schema:

```yaml
  openApi:
    content:
      # we use a fetchUrl here to tell the Gloo Portal
      # to fetch the schema contents directly from the petstore service.
      #
      # configmaps and inline strings are also supported.
      fetchUrl: https://raw.githubusercontent.com/nickschuetz/resttogrpc/main/example/grpcstore-swagger.json
  watchService:
    name: grpcstore-demo
    namespace: default
```

The `watchService` section tells Gloo Edge to pull in any updates to your OpenAPI schema upon any service updates.

