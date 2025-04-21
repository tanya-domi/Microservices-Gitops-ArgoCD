
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingress-ssl-demo
  annotations:
    # Load Balancer Name
    alb.ingress.kubernetes.io/load-balancer-name: ssl-ingress-microservice
    # Ingress Core Settings
    alb.ingress.kubernetes.io/scheme: internet-facing
    # Health Check Settings
    alb.ingress.kubernetes.io/healthcheck-protocol: HTTP 
    alb.ingress.kubernetes.io/healthcheck-port: traffic-port
    alb.ingress.kubernetes.io/target-type: ip
    #Important Note:  Need to add health check path annotations in service level if planning to use multiple targets in a load balancer    
    alb.ingress.kubernetes.io/healthcheck-interval-seconds: '15'
    alb.ingress.kubernetes.io/healthcheck-timeout-seconds: '5'
    alb.ingress.kubernetes.io/success-codes: '200'
    alb.ingress.kubernetes.io/healthy-threshold-count: '2'
    alb.ingress.kubernetes.io/unhealthy-threshold-count: '2'   
    ## SSL Settings
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTPS":443}, {"HTTP":80}]'
    alb.ingress.kubernetes.io/certificate-arn: arn:aws:acm:eu-north-1:381492137122:certificate/4a115c36-439e-4981-8be2-6020324e3400
      # SSL Redirect Setting
    alb.ingress.kubernetes.io/ssl-redirect: '443'
  spec:
  ingressClassName: alb
  rules:
    - host: petclinic.dominicsheytanya.org
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: petclinic-app-service
                port:   
                  number: 8080
          
# Annotations Reference: https://kubernetes-sigs.github.io/aws-load-balancer-controller/latest/guide/ingress/annotations/

                               

