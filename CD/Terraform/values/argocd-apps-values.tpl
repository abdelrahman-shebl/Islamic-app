applications:

  aws-load-balancer-controller:
    namespace: argocd
    project: default
    source:
      chart: aws-load-balancer-controller
      repoURL: https://aws.github.io/eks-charts
      targetRevision: 1.8.1
    destination:
      namespace: kube-system
      server: https://kubernetes.default.svc
    helm:
      values: |
        serviceAccount:
          create: true
          name: lbc-sa
          annotations:
            eks.amazonaws.com/role-arn: ${lbc_role_arn}
            argocd.argoproj.io/sync-wave: "0"
        clusterName: ${cluster_name}
    syncPolicy:
      automated:
        prune: true
        selfHeal: true
      syncOptions:
        - CreateNamespace=true

  external-secrets:
    namespace: argocd
    project: default
    source:
      chart: external-secrets
      repoURL: https://charts.external-secrets.io
      targetRevision: 0.20.1
    destination:
      namespace: eso
      server: https://kubernetes.default.svc
    helm:
      values: |
        serviceAccount:
          create: true
          name: eso-sa
          annotations:
            eks.amazonaws.com/role-arn: ${eso_role_arn}
            argocd.argoproj.io/sync-wave: "1"
    syncPolicy:
      automated:
        prune: true
        selfHeal: true
      syncOptions:
        - CreateNamespace=true

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
        argocd.argoproj.io/sync-wave: "2"
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
        argocd.argoproj.io/sync-wave: "3"
    syncPolicy:
      automated:
        prune: true
        selfHeal: true
      syncOptions:
        - CreateNamespace=true
