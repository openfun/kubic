---
server:
  ingress:
    enabled: true
    https: true
    annotations:
      cert-manager.io/cluster-issuer: letsencrypt-prod
      nginx.ingress.kubernetes.io/ssl-passthrough: "true"
      nginx.ingress.kubernetes.io/backend-protocol: HTTPS
    ingressClassName: nginx
    hosts:
      - ${hostName}
    tls:
      - hosts:
          - ${hostName}
        secretName: argocd-secret # do not change, this is provided by Argo CD
configs:
  secret:
    argocdServerAdminPassword: ${password}
