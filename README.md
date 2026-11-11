# Application de l'Archidiocèse de Rabat

Version de démonstration (V1) de l'application mobile du diocèse, écrite en Flutter.
Toutes les paroisses, horaires, annonces et contacts sont des **données fictives**.

## Télécharger l'APK

À chaque envoi de code, GitHub construit automatiquement l'APK Android :

1. Ouvrez l'onglet **Releases** du dépôt (colonne de droite sur la page d'accueil du dépôt).
2. Dans la dernière « Démo », téléchargez `diocese-rabat-demo.apk`.
3. Ouvrez le fichier sur un téléphone Android et autorisez l'installation depuis cette source.

## Contenu de la démo

- Choix de la paroisse au premier lancement
- Accueil « Ma paroisse » : prochaine messe, parole du jour, annonces
- Horaires de toutes les paroisses, filtrés par jour et par langue
- Carte schématique avec itinéraire Google Maps ou Waze
- Liturgie du jour (exemple) et prières usuelles
- Annonces, mouvements et chorales, guide du nouvel arrivant
- Assistant (simulation sans IA, réponses tirées des données de l'application)
- Espace paroisse : publier une annonce, ajouter ou retirer une messe

## Back-office (Hostinger)

Le dossier `backoffice/` contient le site d'administration (PHP 8 + MySQL) et l'API lue par l'application.
Deux niveaux d'accès : **Diocèse** (tout) et **Paroisse** (uniquement sa paroisse).

### Première installation

1. **Créer la base** : hPanel → Bases de données → Gestion → créez une base MySQL et un utilisateur. Notez le nom de la base, l'utilisateur et le mot de passe.
2. **Envoyer les fichiers** : dans la section Releases du dépôt, téléchargez le dernier `backoffice.zip`. Dans hPanel → Gestionnaire de fichiers, ouvrez `public_html`, créez un dossier `admin`, envoyez-y le zip et faites « Extraire ».
3. **Installer** : ouvrez `https://votre-domaine/admin/install.php`, saisissez les informations MySQL et créez le premier compte (équipe du diocèse).
4. **Se connecter** : `https://votre-domaine/admin/`. Créez ensuite un compte par paroisse dans « Comptes administrateurs ».

### Mises à jour automatiques (facultatif)

Pour que chaque modification du back-office soit mise en ligne sans rien faire, ajoutez dans GitHub → Settings → Secrets and variables → Actions → **New repository secret** :

| Nom | Valeur |
| --- | --- |
| `FTP_SERVER` | l'adresse FTP (hPanel → Fichiers → Comptes FTP), ex. `ftp.votre-domaine.ma` |
| `FTP_USERNAME` | l'utilisateur FTP |
| `FTP_PASSWORD` | le mot de passe FTP |
| `FTP_DIR` | le dossier cible, avec `/` à la fin, ex. `public_html/admin/` |

Le fichier `config.php` (identifiants MySQL) reste sur le serveur et n'est jamais remplacé.

### API

- `api.php?r=paroisses` : paroisses et horaires
- `api.php?r=annonces&paroisse=<id>` : annonces d'une paroisse et du diocèse
- `api.php?r=mouvements`
- `api.php?r=parole&date=AAAA-MM-JJ`

## Organisation du code

- `lib/data.dart` : modèles et données de démonstration
- `lib/state.dart` : état de l'application et assistant simulé
- `lib/screens/` : écrans
- `.github/workflows/apk.yml` : construction automatique de l'APK

Les dossiers Android sont générés pendant la construction (`flutter create`).
