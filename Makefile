kind.local.cluster:
	kind create cluster --name="banzai"

kind.local.setup:
	echo "follow config >>> https://banzaicloud.com/blog/kind-ingress/"
	kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/mandatory.yaml
	kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/cloud-generic.yaml
	kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/baremetal/service-nodeport.yaml

kind.local.socat:
	$(foreach port,80 443, \
		node_port=`kubectl get service -n ingress-nginx ingress-nginx -o=jsonpath="{.spec.ports[?(@.port == ${port})].nodePort}"`; \
		echo $$node_port; \
		docker run -d --name banzai-kind-proxy-${port} \
		--publish 127.0.0.1:${port}:${port} \
		--link banzai-control-plane:target \
		alpine/socat -dd \
		tcp-listen:${port},fork,reuseaddr tcp-connect:target:$$node_port; \
	)

k8s.local.apply:
	kubectl apply -f secrets.yaml
	kubectl apply -f ingress-local.yaml
	kubectl apply -f mysql-deployment.yaml
	kubectl apply -f wordpress-deployment.yaml

k8s.local.delete:
	kubectl delete -f secrets.yaml
	kubectl delete -f ingress-local.yaml
	kubectl delete -f mysql-deployment.yaml
	kubectl delete -f wordpress-deployment.yaml

