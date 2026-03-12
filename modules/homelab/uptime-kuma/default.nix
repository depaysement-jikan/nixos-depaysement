{
  config,
  lib,
  ...
}: {
  imports = [./namespace ./certificate];
  options.homelab = {
    uptime-kuma = {
      enable = lib.mkEnableOption "uptime-kuma";
      loadBalancerIP = lib.mkOption {
        type = lib.types.str;
      };
      ingressHost = lib.mkOption {
        type = lib.types.str;
        default = "kuma.home";
      };
    };
  };

  config.services.k3s = lib.mkIf config.homelab.uptime-kuma.enable {
    autoDeployCharts.uptime-kuma = {
      name = "uptime-kuma";
      repo = "https://dirsigler.github.io/uptime-kuma-helm";
      version = "4.0.0";
      hash = "sha256-z8aDxqB57XGqo2HOOh4aKmy6gDi4pIRPr8HaHaz7B5I=";
      targetNamespace = "kuma-system";
      values = {
        service = {
          type = "LoadBalancer";
          loadBalancerIP = config.homelab.uptime-kuma.loadBalancerIP;
        };
        ingress = {
          enabled = true;
          ingressClassName = "nginx";

          hosts = [
            config.homelab.uptime-kuma.ingressHost
          ];
          tls = [
            {
              secretName = "uptime-kuma-tls";
              hosts = [config.homelab.uptime-kuma.ingressHost];
            }
          ];
        };
      };
    };
  };
}
# TODO: Automate Kuma tracking with a simple script
#
## Sample script
# import { UptimeKumaAPI } from "uptime-kuma-api";
#
# const api = new UptimeKumaAPI({
#   url: "http://kuma.home",
#   username: "admin",
#   password: "password"
# });
#
# await api.login();
#
# await api.addMonitor({
#   type: "http",
#   name: "Vaultwarden",
#   url: "https://vault.home",
#   interval: 60
# });
#
## Sample job
#
# apiVersion: batch/v1
# kind: Job
# metadata:
#   name: kuma-bootstrap
#   namespace: kuma-system
# spec:
#   template:
#     spec:
#       containers:
#       - name: bootstrap
#         image: node:20
#         command:
#           - node
#           - /scripts/setup.js
#       restartPolicy: Never

