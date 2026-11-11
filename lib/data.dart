// Modèles et données de démonstration (fictives).

const jours = ['Dimanche', 'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi'];
const langues = {'FR': 'Français', 'EN': 'Anglais', 'ES': 'Espagnol', 'PT': 'Portugais'};

/// 0 = dimanche … 6 = samedi.
int jourIndex(DateTime d) => d.weekday % 7;

class Messe {
  final List<int> jours;
  final String heure; // "HH:MM"
  final String langue;
  Messe(this.jours, this.heure, this.langue);

  int get minutes => int.parse(heure.substring(0, 2)) * 60 + int.parse(heure.substring(3, 5));

  Map<String, dynamic> toJson() => {'j': jours, 'h': heure, 'l': langue};
  factory Messe.fromJson(Map<String, dynamic> j) =>
      Messe((j['j'] as List).map((e) => e as int).toList(), j['h'] as String, j['l'] as String);
}

class Paroisse {
  final String id, nom, ville, tel, confessions;
  final double lat, lon;
  List<Messe> messes;
  Paroisse(this.id, this.nom, this.ville, this.lat, this.lon, this.tel, this.confessions, this.messes);
}

class Annonce {
  final String paroisse; // id ou '*' pour le diocèse
  final String date; // AAAA-MM-JJ
  final String titre, texte;
  Annonce(this.paroisse, this.date, this.titre, this.texte);

  Map<String, dynamic> toJson() => {'p': paroisse, 'd': date, 't': titre, 'x': texte};
  factory Annonce.fromJson(Map<String, dynamic> j) =>
      Annonce(j['p'] as String, j['d'] as String, j['t'] as String, j['x'] as String);
}

class Mouvement {
  final String paroisse, nom, type, quand, desc;
  const Mouvement(this.paroisse, this.nom, this.type, this.quand, this.desc);
}

List<Paroisse> demoParoisses() => [
      Paroisse('rabat', 'Cathédrale Saint-Pierre', 'Rabat', 34.02, -6.84, '+212 5 00 00 00 01',
          'Samedi 16h00 – 18h00', [
        Messe([0], '09:00', 'FR'),
        Messe([0], '11:00', 'FR'),
        Messe([0], '17:00', 'EN'),
        Messe([0], '19:00', 'ES'),
        Messe([6], '18:30', 'FR'),
        Messe([1, 2, 3, 4, 5], '18:30', 'FR'),
        Messe([3], '07:30', 'PT'),
      ]),
      Paroisse('casa', 'Notre-Dame de Lourdes', 'Casablanca', 33.58, -7.62, '+212 5 00 00 00 02',
          'Vendredi 17h00 – 19h00', [
        Messe([0], '08:30', 'FR'),
        Messe([0], '10:30', 'FR'),
        Messe([0], '12:30', 'EN'),
        Messe([0], '18:00', 'FR'),
        Messe([6], '19:00', 'FR'),
        Messe([1, 2, 3, 4, 5], '19:00', 'FR'),
        Messe([6], '17:00', 'PT'),
      ]),
      Paroisse('fes', "Saint-François d'Assise", 'Fès', 34.03, -5.00, '+212 5 00 00 00 03',
          'Sur rendez-vous', [
        Messe([0], '10:00', 'FR'),
        Messe([0], '18:00', 'EN'),
        Messe([6], '18:00', 'FR'),
        Messe([3, 5], '18:30', 'FR'),
      ]),
      Paroisse('marrakech', 'Église des Saints-Martyrs', 'Marrakech', 31.63, -8.01,
          '+212 5 00 00 00 04', 'Samedi 17h00 – 18h00', [
        Messe([0], '09:00', 'ES'),
        Messe([0], '10:30', 'FR'),
        Messe([0], '18:30', 'EN'),
        Messe([6], '18:30', 'FR'),
        Messe([1, 2, 3, 4, 5], '18:30', 'FR'),
      ]),
      Paroisse('meknes', 'Paroisse de Meknès', 'Meknès', 33.89, -5.55, '+212 5 00 00 00 05',
          'Avant chaque messe', [
        Messe([0], '10:00', 'FR'),
        Messe([6], '18:00', 'EN'),
      ]),
      Paroisse('agadir', "Paroisse d'Agadir", 'Agadir', 30.42, -9.60, '+212 5 00 00 00 06',
          'Samedi 17h30 – 18h30', [
        Messe([0], '10:30', 'FR'),
        Messe([0], '18:00', 'EN'),
        Messe([6], '18:30', 'FR'),
      ]),
      Paroisse('kenitra', 'Paroisse de Kénitra', 'Kénitra', 34.26, -6.58, '+212 5 00 00 00 07',
          'Sur rendez-vous', [
        Messe([0], '10:00', 'FR'),
        Messe([0], '17:00', 'EN'),
      ]),
    ];

List<Annonce> demoAnnonces() => [
      Annonce('rabat', '2026-11-10', 'Veillée de prière pour les étudiants',
          'Vendredi à 20h30, crypte de la cathédrale. Ouverte à tous.'),
      Annonce('rabat', '2026-11-08', 'Horaire modifié samedi',
          'La messe de samedi 18h30 est exceptionnellement avancée à 18h00.'),
      Annonce('casa', '2026-11-09', 'Fête patronale',
          "Messe solennelle suivie d'un repas partagé. Inscriptions à l'accueil."),
      Annonce('*', '2026-11-05', 'Campagne du denier 2026',
          'Le diocèse lance sa campagne annuelle. Merci pour votre soutien.'),
    ];

const demoMouvements = [
  Mouvement('rabat', 'Chorale Saint-Pierre', 'Chorale', 'Jeudi 19h00',
      'Anime la messe de 11h00. Toutes les voix sont bienvenues.'),
  Mouvement('rabat', 'Aumônerie des étudiants', 'Jeunes', 'Samedi 15h00',
      "Partage d'Évangile, sorties, accueil des nouveaux arrivants."),
  Mouvement('rabat', 'English-speaking community', 'Communauté', 'Dimanche 17h00',
      'Mass and fellowship for English speakers.'),
  Mouvement('rabat', 'Groupe de prière', 'Prière', 'Mardi 20h00', 'Louange, adoration et intercession.'),
  Mouvement('casa', 'Chorale Notre-Dame', 'Chorale', 'Mercredi 19h30',
      'Chants en français, lingala et anglais.'),
  Mouvement('casa', 'Équipe liturgique', 'Liturgie', '1er lundi du mois',
      'Prépare lectures, servants et fleurissement.'),
  Mouvement('*', 'Caritas Maroc — bénévoles', 'Solidarité', 'Selon les missions',
      'Accueil, accompagnement et soutien aux personnes en difficulté.'),
];

class Lecture {
  final String type, reference, resume;
  const Lecture(this.type, this.reference, this.resume);
}

/// Liturgie d'exemple : références et résumés uniquement.
/// La version finale affichera le texte intégral, sous licence de l'éditeur liturgique.
const liturgieDate = 'Mercredi 11 novembre 2026';
const liturgieTemps = '32e semaine du temps ordinaire';
const liturgieCouleur = 'Blanc';
const saintNom = 'Saint Martin de Tours';
const saintBio =
    'Soldat romain devenu moine puis évêque de Tours au IVe siècle. On retient de lui le geste du manteau partagé avec un pauvre à Amiens.';
const versetTexte = '« Relève-toi et va : ta foi t\'a sauvé. »';
const versetRef = 'Luc 17, 19';
const lectures = [
  Lecture('Première lecture', 'Lettre de saint Paul à Tite 3, 1-7',
      'Paul rappelle que le salut est un don de la bonté de Dieu et non le fruit de nos œuvres.'),
  Lecture('Psaume', 'Psaume 22 (23)', 'Le psaume du berger : confiance dans le Seigneur qui guide et nourrit.'),
  Lecture('Évangile', 'Luc 17, 11-19',
      'Dix lépreux sont guéris ; un seul, un Samaritain, revient rendre grâce à Jésus.'),
];

class Priere {
  final String titre, texte;
  const Priere(this.titre, this.texte);
}

const prieres = [
  Priere('Notre Père', '''Notre Père, qui es aux cieux,
que ton nom soit sanctifié,
que ton règne vienne,
que ta volonté soit faite sur la terre comme au ciel.
Donne-nous aujourd'hui notre pain de ce jour.
Pardonne-nous nos offenses,
comme nous pardonnons aussi à ceux qui nous ont offensés.
Et ne nous laisse pas entrer en tentation,
mais délivre-nous du Mal.
Amen.'''),
  Priere('Je vous salue Marie', '''Je vous salue Marie, pleine de grâce ;
le Seigneur est avec vous.
Vous êtes bénie entre toutes les femmes,
et Jésus, le fruit de vos entrailles, est béni.
Sainte Marie, Mère de Dieu,
priez pour nous, pauvres pécheurs,
maintenant et à l'heure de notre mort.
Amen.'''),
  Priere('Gloire au Père', '''Gloire au Père, et au Fils, et au Saint-Esprit,
comme il était au commencement,
maintenant et toujours,
et pour les siècles des siècles.
Amen.'''),
  Priere('Chapelet — mystères glorieux', '''1. La Résurrection
2. L'Ascension
3. La Pentecôte
4. L'Assomption de Marie
5. Le Couronnement de Marie

Pour chaque mystère : un Notre Père, dix Je vous salue Marie, un Gloire au Père.'''),
];

class Prochaine {
  final Messe messe;
  final int jour, dansJours;
  Prochaine(this.messe, this.jour, this.dansJours);
  String get quand => dansJours == 0 ? "Aujourd'hui" : dansJours == 1 ? 'Demain' : jours[jour];
}

Prochaine? prochaineMesse(Paroisse p, {String? langue}) {
  final now = DateTime.now();
  final nowMin = now.hour * 60 + now.minute;
  final today = jourIndex(now);
  for (var k = 0; k < 8; k++) {
    final j = (today + k) % 7;
    final l = p.messes
        .where((m) => m.jours.contains(j) && (langue == null || m.langue == langue) && (k > 0 || m.minutes > nowMin))
        .toList()
      ..sort((a, b) => a.minutes.compareTo(b.minutes));
    if (l.isNotEmpty) return Prochaine(l.first, j, k);
  }
  return null;
}

String joursLabel(List<int> d) {
  if (d.length == 7) return 'Tous les jours';
  if (d.length == 5 && !d.contains(0) && !d.contains(6)) return 'Lun – Ven';
  return d.map((x) => '${jours[x].substring(0, 3)}.').join(' ');
}

const _mois = ['janvier', 'février', 'mars', 'avril', 'mai', 'juin', 'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'];

String dateCourte(String iso) {
  final p = iso.split('-');
  if (p.length != 3) return iso;
  return '${int.parse(p[2])} ${_mois[int.parse(p[1]) - 1]}';
}

String aujourdhuiIso() {
  final d = DateTime.now();
  return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

String mapsUrl(Paroisse p) =>
    'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent('${p.nom} ${p.ville} Maroc')}';
String wazeUrl(Paroisse p) => 'https://waze.com/ul?ll=${p.lat},${p.lon}&navigate=yes';
