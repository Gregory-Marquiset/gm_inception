> Ce projet a été réalisé dans le cadre du cursus **42**.

# Inception — Projet 42 School

Ce dépôt implémente une infrastructure web complète à l’aide de **Docker** et **Docker Compose**, autour de **WordPress** et **MariaDB**, exposée en **HTTPS** via **nginx**, et enrichie de plusieurs services bonus.

---

## 📌 Table des matières

* [Description](#description)
* [Arborescence](#arborescence)
* [Architecture & Services](#architecture--services)
* [Installation & Utilisation](#installation--utilisation)
* [Configuration DNS & `.env`](#configuration-dns--env)
* [Ports & Routes](#ports--routes)
* [Volumes, Réseau & Persistance](#volumes-réseau--persistance)
* [Secrets](#secrets)
* [Ressources](#resources)

---

<a id="description"></a>

## 🌐 Description

Le projet **Inception** (42) consiste à construire une infrastructure **multi‑conteneurs** sans dépendre d’images « prêtes à l’emploi » (hors base minimale Alpine), avec :

* **nginx** en frontal (HTTPS)
* **wordpress** (PHP‑FPM)
* **mariadb** (base de données)
* Services **bonus** intégrés : **redis**, **ftp**, **adminer**, **portainer**, **static-site**

L’ensemble est orchestré par `srcs/docker-compose.yml` et piloté via le `Makefile`.

---

<a id="arborescence"></a>

## 🗂️ Arborescence

```txt
.
├── Makefile
└── srcs
    ├── docker-compose.yml
    ├── .env.exemple
    ├── requirements
    │   ├── nginx
    │   ├── wordpress
    │   └── mariadb
    ├── bonus
    │   ├── redis
    │   ├── ftp
    │   ├── adminer
    │   ├── portainer
    │   └── static-site
    └── secrets
        ├── ftp_password
        ├── mysql_password
        ├── mysql_root_password
        ├── portainer_admin_password_hash
        ├── redis_password
        └── wp_admin_password
```

---

<a id="architecture--services"></a>

## 🏗️ Architecture & Services

### Services (compose)

| Service               | Rôle                | Notes                                                           |
| --------------------- | ------------------- | --------------------------------------------------------------- |
| `nginx`               | Reverse‑proxy HTTPS | écoute **8443** en interne, mappé sur **443** hôte (`443:8443`) |
| `wordpress`           | WordPress + PHP‑FPM | écoute **9000** (FastCGI)                                       |
| `mariadb`             | DB SQL              | init auto si data dir vide, healthcheck `mariadb-admin ping`    |
| `redis` *(bonus)*     | Cache Redis         | `requirepass` via secret, healthcheck `PING`                    |
| `ftp` *(bonus)*       | Upload FTP          | pointe sur `wp-content/uploads`, ports **21** + **30000-30009** |
| `adminer` *(bonus)*   | UI DB               | HTTP sur **8080** (interne)                                     |
| `portainer` *(bonus)* | UI Docker           | HTTPS sur **9443** + socket Docker                              |
| `static` *(bonus)*    | Site statique       | servi sur **8080** (interne), sans listing                      |

### Intégrations nginx

Le fichier `srcs/requirements/nginx/conf/nginx.conf` :

* sert WordPress en `/` via **FastCGI** → `wordpress:9000`
* proxy **Adminer** via `/adminer/` → `adminer:8080`
* proxy le **site statique** via `/static/` → `static:8080`
* expose **Portainer** via `/portainer/` → `https://portainer:9443/`
* fournit une route de santé HTTPS : `/health`

---

<a id="installation--utilisation"></a>

## 🚀 Installation & Utilisation

### Prérequis

* Docker
* Docker Compose
* Accès root pour éditer `/etc/hosts` (DNS local)

### Démarrage

1. Créer le fichier `.env`

```bash
cp srcs/.env.exemple srcs/.env
```

2. Adapter (si besoin) `LOGIN` et `DATA_DIR`

Par défaut :

* `LOGIN ?= gmarquis`
* `DATA_DIR ?= /home/$(LOGIN)/data`

3. Lancer

```bash
make
```

### Commandes utiles

```bash
make build          # build images
make build-nocache  # build sans cache
make up             # up -d
make up-build       # up -d --build
make down           # stop
make show           # infos docker + ls data dir
make clean          # down + supprime DATA_DIR/*
make fclean         # nettoyage agressif (containers/images/volumes + prune)
make re             # fclean + all
```

---

<a id="configuration-dns--env"></a>

## 🔧 Configuration DNS & `.env`

### DNS / `hosts` (OBLIGATOIRE)

Le serveur nginx est configuré pour un **nom de domaine** (ex : `gmarquis.42.fr`).
Tu dois donc ajouter une entrée sur la machine hôte :

```bash
sudo sh -c 'printf "127.0.0.1\tgmarquis.42.fr\n127.0.0.1\twww.gmarquis.42.fr\n" >> /etc/hosts'
```

> Remplace `gmarquis.42.fr` par la valeur de `DOMAIN_NAME` dans ton `.env`.

### `.env` fourni (projet d’étude)

Le dépôt inclut `srcs/.env.exemple` **déjà rempli**, car c’est un **projet pédagogique**.
Il contient notamment :

* `DOMAIN_NAME` (ex : `gmarquis.42.fr`)
* infos DB (`MYSQL_DATABASE`, `MYSQL_USER`, `MYSQL_HOST`, `MYSQL_PORT`)
* paramètres WordPress (`WP_URL`, `WP_TITLE`, `WP_ADMIN_*`)
* paramètres FTP (user + ports passifs)
* `UID` / `GID` pour aligner les permissions des volumes

---

<a id="ports--routes"></a>

## 🔌 Ports & Routes

### Ports exposés (hôte)

* **443** → nginx (**8443** interne)
* **9443** → portainer
* **21** + **30000‑30009** → ftp

### Routes principales (via nginx)

* `https://<DOMAIN_NAME>/` → WordPress
* `https://<DOMAIN_NAME>/wp-admin` → Admin WordPress
* `https://<DOMAIN_NAME>/adminer/` → Adminer
* `https://<DOMAIN_NAME>/static/` → Site statique
* `https://<DOMAIN_NAME>/portainer/` → Portainer
* `https://<DOMAIN_NAME>/health` → healthcheck

---

<a id="volumes-réseau--persistance"></a>

## 📦 Volumes, Réseau & Persistance

### Réseau

Le compose déclare :

* `inception_net` avec nom réel : `inception_network`

### Volumes

* `wordpress_volume` bind‑mount → `/home/gmarquis/data/wordpress`
* `mariadb_volume` bind‑mount → `/home/gmarquis/data/mariadb`
* `portainer_volume` volume Docker standard

> Les bind‑mounts permettent d’avoir des données persistantes visibles côté hôte.

---

<a id="secrets"></a>

## 🔐 Secrets

Le dépôt inclut un dossier `srcs/secrets` avec les fichiers de secrets utilisés par Docker Compose :

* `mysql_root_password`
* `mysql_password`
* `wp_admin_password`
* `redis_password`
* `ftp_password`
* `portainer_admin_password_hash`

✅ **Ils sont volontairement fournis** car il s’agit d’un **projet d’étude / démonstration**.

⚠️ En production, ces secrets ne devraient jamais être commit.

---

<a id="resources"></a>

## 📑 Ressources

* Docker : [https://docs.docker.com/](https://docs.docker.com/)
* Docker Compose : [https://docs.docker.com/compose/](https://docs.docker.com/compose/)
* WordPress CLI : [https://wp-cli.org/](https://wp-cli.org/)
* NGINX : [https://nginx.org/en/docs/](https://nginx.org/en/docs/)

---

> Projet 42 School — aucune licence fournie.
