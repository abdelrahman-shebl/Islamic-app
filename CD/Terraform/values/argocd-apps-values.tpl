applications:

  prometheus:
    namespace: argocd
    project: default
    sources:
      - repoURL: https://prometheus-community.github.io/helm-charts
        chart: kube-prometheus-stack
        targetRevision: "*"
        helm:
          releaseName: my-kube-prometheus-stack
          valueFiles:
            - $values/CD/Terraform/values/prom-values.yaml
      - repoURL: https://github.com/abdelrahman-shebl/Islamic-app.git
        targetRevision: main
        ref: values
    destination:
      namespace: monitoring
      server: https://kubernetes.default.svc
    metadata:
      annotations:
        argocd.argoproj.io/sync-wave: "-2"
    syncPolicy:
      automated:
        prune: true
        selfHeal: true
      syncOptions:
        - CreateNamespace=true

  argocd-full-app:
    namespace: argocd  
    project: default
    sources:
      - repoURL: https://argoproj.github.io/argo-helm
        chart: argo-cd
        targetRevision: "*"
        helm:
          valueFiles:
            - $values/CD/Terraform/values/argo-full-values.yaml
      - repoURL: https://github.com/abdelrahman-shebl/Islamic-app.git
        targetRevision: main
        ref: values
    destination:
      namespace: argocd
      server: https://kubernetes.default.svc
    metadata:
      annotations:
        argocd.argoproj.io/sync-wave: "-1"
    syncPolicy:
      automated:
        prune: false  
        selfHeal: true

        
  aws-load-balancer-controller:
    namespace: argocd
    project: default
    source:
      chart: aws-load-balancer-controller
      repoURL: https://aws.github.io/eks-charts
      targetRevision: 1.8.1
      helm:
        parameters:
          - name: clusterName
            value: ${cluster_name}
        values: |
          clusterName: ${cluster_name}
          serviceAccount:
            create: true
            name: lbc-sa
            annotations:
              eks.amazonaws.com/role-arn: ${lbc_role_arn}
          vpcId: ${vpc_id}
          region: ${aws_region}
    destination:
      namespace: kube-system
      server: https://kubernetes.default.svc
    metadata:
      annotations:
        argocd.argoproj.io/sync-wave: "1"
    syncPolicy:
      automated:
        prune: true
        selfHeal: true
      syncOptions:
        - CreateNamespace=true


  external-dns:
    namespace: argocd
    project: default
    source:
      chart: external-dns
      repoURL: https://kubernetes-sigs.github.io/external-dns/
      targetRevision: 1.19.0
      helm:
        values: |
          provider: aws
          
          aws:
            region: ${aws_region}
            zoneType: public

          
          domainFilters:
            - shebl22.me  
          
          sources:
            - service
            - ingress

          serviceAccount:
            create: true
            name: edns-sa
            annotations:
              eks.amazonaws.com/role-arn: ${edns_role_arn}
          
          replicas: 1
          
          policy: sync  
          
          registry: txt
          txtOwnerId: ${cluster_name}
          txtPrefix: external-dns-

          logLevel: info
          logFormat: text
          
          interval: 1m
 
          securityContext:
            fsGroup: 65534
            runAsNonRoot: true
            runAsUser: 65534

          
    destination:
      namespace: kube-system
      server: https://kubernetes.default.svc
    metadata:
      annotations:
        argocd.argoproj.io/sync-wave: "2"
    syncPolicy:
      automated:
        prune: true
        selfHeal: true


  external-secrets:
    namespace: argocd
    project: default
    source:
      chart: external-secrets
      repoURL: https://charts.external-secrets.io
      targetRevision: 0.20.1
      helm:  # MOVED: This should be under source:, not after destination:
        values: |
          installCRDs: true
          serviceAccount:
            create: true
            name: eso-sa
            annotations:
              eks.amazonaws.com/role-arn: ${eso_role_arn}
    destination:
      namespace: eso
      server: https://kubernetes.default.svc
    metadata:
      annotations:
        argocd.argoproj.io/sync-wave: "3"
    syncPolicy:
      automated:
        prune: true
        selfHeal: true
      syncOptions:
        - CreateNamespace=true
        - Replace=true

  external-secrets-manifests:
    namespace: argocd
    project: default
    source:
      path: CI/K8s/eso
      repoURL: https://github.com/abdelrahman-shebl/Islamic-app.git
      targetRevision: HEAD
    destination:
      namespace: eso
      server: https://kubernetes.default.svc
    metadata:
      annotations:
        argocd.argoproj.io/sync-wave: "4"
    syncPolicy:
      automated:
        prune: true
        selfHeal: true

  islamic-app:
    namespace: argocd
    project: default
    source:
      path: CI/K8s
      repoURL: https://github.com/abdelrahman-shebl/Islamic-app.git
      targetRevision: HEAD
    destination:
      namespace: islamic-app
      server: https://kubernetes.default.svc
    metadata:
      annotations:
        argocd.argoproj.io/sync-wave: "5"
    syncPolicy:
      automated:
        selfHeal: true
      syncOptions:
        - CreateNamespace=true


  ingress-app:
    namespace: islamic-app
    project: default
    source:
      path: CI/K8s/ingress
      repoURL: https://github.com/abdelrahman-shebl/Islamic-app.git
      targetRevision: HEAD
      helm:
        values: |
          sslCertificateArn: ${sslCertificateArn}
    destination:
      namespace: islamic-app
      server: https://kubernetes.default.svc
    metadata:
      annotations:
        argocd.argoproj.io/sync-wave: "6"
    syncPolicy:
      automated:
        selfHeal: true
      syncOptions:
        - CreateNamespace=true
