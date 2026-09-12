name: instance: [
  # --- Self-signed ClusterIssuer
  {
    apiVersion = "cert-manager.io/v1";
    kind = "ClusterIssuer";
    metadata = {
      name = "anubis-${name}-selfsigned";
    };
    spec = {
      selfSigned = {};
    };
  }

  # --- Certificate using self-signed issuer
  {
    apiVersion = "cert-manager.io/v1";
    kind = "Certificate";
    metadata = {
      name = "anubis-${name}-cert";
      namespace = "anubis-system";
    };
    spec = {
      secretName = "anubis-${name}-tls";
      issuerRef = {
        name = "anubis-${name}-selfsigned";
        kind = "ClusterIssuer";
      };
      dnsNames = [instance.ingressHost];
    };
  }
  {
    apiVersion = "apps/v1";
    kind = "Deployment";

    metadata = {
      name = "anubis-${name}";
      namespace = "anubis-system";
    };

    spec = {
      replicas = instance.replicas;

      selector.matchLabels = {
        app = "anubis-${name}";
      };

      template = {
        metadata.labels = {
          app = "anubis-${name}";
        };

        spec.containers = [
          {
            name = "anubis";
            image = "ghcr.io/techarohq/anubis:latest";

            ports = [
              {
                name = "http";
                containerPort = 8080;
              }
            ];

            env = [
              {
                name = "BIND";
                value = ":8080";
              }
              {
                name = "TARGET";
                value = instance.target;
              }
              {
                name = "DIFFICULTY";
                value = instance.difficulty;
              }
              {
                name = "SERVE_ROBOTS_TXT";
                value = "true";
              }
            ];

            securityContext = {
              runAsNonRoot = true;
              allowPrivilegeEscalation = false;
              capabilities.drop = ["ALL"];
            };
          }
        ];
      };
    };
  }

  {
    apiVersion = "v1";
    kind = "Service";

    metadata = {
      name = "anubis-${name}";
      namespace = "anubis-system";
    };

    spec = {
      type = "ClusterIP";

      selector = {
        app = "anubis-${name}";
      };

      ports = [
        {
          name = "http";
          port = 8080;
          targetPort = 8080;
        }
      ];
    };
  }

  {
    apiVersion = "networking.k8s.io/v1";
    kind = "Ingress";

    metadata = {
      name = "anubis-${name}";
      namespace = "anubis-system";
    };

    spec = {
      ingressClassName = "nginx";

      tls = [
        {
          secretName = instance.tlsSecretName;
          hosts = [instance.ingressHost];
        }
      ];

      rules = [
        {
          host = instance.ingressHost;

          http.paths = [
            {
              path = "/";
              pathType = "Prefix";

              backend.service = {
                name = "anubis-${name}";
                port.number = 8080;
              };
            }
          ];
        }
      ];
    };
  }
]
