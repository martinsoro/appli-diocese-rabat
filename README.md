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

## Organisation du code

- `lib/data.dart` : modèles et données de démonstration
- `lib/state.dart` : état de l'application et assistant simulé
- `lib/screens/` : écrans
- `.github/workflows/apk.yml` : construction automatique de l'APK

Les dossiers Android sont générés pendant la construction (`flutter create`).
