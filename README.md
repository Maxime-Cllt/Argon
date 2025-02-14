<div align="center">
  <h1>Argon</h1>
    <p>
        <strong>Entrepôt de données pour la plateforme Yelp</strong>
</div>


<div align="center">
<img src="/assets/argon.png" alt="Argon" align="center" width="256px" height="256px" />
</div>


[Rapport](https://docs.google.com/document/d/1sLP6f43I187cvIch9RbBHyOVyccv67lUW4Wt1hDGoM4/edit?usp=sharing)

## 📄 Visualiser les rapports

Les rapports sont disponibles dans le dossier `metabase/pdf`.

## 📝 Description

**Argon** est un entrepôt de données conçu pour exploiter les données de la plateforme Yelp, un site web populaire
d'avis et de recommandations pour les restaurants, bars, boutiques et services locaux.

Le nom **Argon** s'inspire de l'élément chimique argon, un gaz noble et stable de la table périodique. Tout comme cet
élément chimique, Argon vise à fournir une base solide et fiable pour le stockage et l'analyse des données. Sa stabilité
symbolise la robustesse et la fiabilité de cet entrepôt de données.

Cet entrepôt permet aux utilisateurs de :

- Poser des questions analytiques sur les données de Yelp.
- Obtenir des réponses en temps réel grâce à des structures de données optimisées.
- Faciliter les analyses pour des data analysts, data scientists et chercheurs.

## 🚀 Fonctionnalités

- **Importation** : Ingestion des données de Yelp dans un entrepôt relationnel.
- **Stockage** : Gestion des données dans une base de données relationnelle.
- **Optimisation** : Création de vues matérialisées pour améliorer les performances des requêtes.

## 💻 Plateformes Compatibles

Argon est compatible avec les systèmes d'exploitation suivants :

<div align="center">
  <img src="https://img.shields.io/badge/OS-MacOS-informational?style=flat&logo=apple&logoColor=white&color=007aff" alt="MacOS" />
  <img src="https://img.shields.io/badge/OS-Linux-informational?style=flat&logo=linux&logoColor=white&color=ff7f00" alt="Linux" />
  <img src="https://img.shields.io/badge/OS-Windows-informational?style=flat&logo=windows&logoColor=white&color=1e90ff" alt="Windows" />
</div>

## 🛠️ Prérequis

Avant de commencer, assurez-vous d’avoir les éléments suivants installés sur votre machine :

- Python 3.12 ou supérieur
- Sqlite3
- Metabase

## Technologies

Argon utilise les technologies suivantes :

<div align="center">
  <img src="https://img.shields.io/badge/Python-4B8BBE?style=for-the-badge&logo=python&logoColor=FFD43B" alt="Python" />
  <img src="https://img.shields.io/badge/SQLite-003B57?style=for-the-badge&logo=sqlite&logoColor=9ED9D8" alt="SQLite" />
  <img src="https://img.shields.io/badge/Metabase-3182CE?style=for-the-badge&logo=metabase&logoColor=white" alt="Metabase" />
  <img src="https://img.shields.io/badge/PostgreSQL-336791?style=for-the-badge&logo=postgresql&logoColor=white" alt="PostgreSQL" />
</div>

## 📦 Installation

Suivez ces étapes pour configurer et exécuter le projet Argon :

1. **Clonez le dépôt Git** :

```bash
git clone https://github.com/Maxime-Cllt/Argon.git

```

2. Accédez au répertoire du projet :

```bash
cd Argon
```

3. Installez les dépendances Python et executer le fichier run.sh (Linux ou MacOS) :

```bash
pip install -r requirements.txt
```

4. Exécutez le script run.sh (Linux ou MacOS) pour importer les données dans la base de données :

```bash
./run.sh
```


