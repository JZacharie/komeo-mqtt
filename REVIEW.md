# Review: komeo-mqtt

**Type:** Rust — Exportateur MQTT pour Komeo  
**Stack:** Rust, MQTT, Docker, Kubernetes CronJob  
**Status:** Actif ⭐1 — Dernière màj Septembre 2025

## Points forts
- Exporter Rust léger pour MQTT
- Déploiement K8s via CronJob
- Dockerisé

## Sécurité
✅ Fichier `.env` et `cronjobs.yaml` nettoyés (IPs et credentials rendus génériques)  
✅ Plus aucun secret en clair

## Verdict
Projet utilitaire propre. Leak historique résolu.
