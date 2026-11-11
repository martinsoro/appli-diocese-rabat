import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data.dart';

class ChatMsg {
  final bool moi;
  final String texte;
  final String? source;
  ChatMsg(this.moi, this.texte, [this.source]);
}

/// État de l'application de démonstration, gardé sur le téléphone.
class AppState extends ChangeNotifier {
  String? paroisseId;
  String prenom = '';
  List<Paroisse> paroisses = demoParoisses();
  List<Annonce> annonces = demoAnnonces();
  final List<Mouvement> mouvements = demoMouvements;
  Set<String> vues = {};
  bool adminMode = false;
  final List<ChatMsg> chat = [
    ChatMsg(false,
        'Bonjour ! Je peux vous aider à trouver une messe, une paroisse ou à comprendre une démarche. Essayez : « messe en anglais dimanche à Casablanca ».'),
  ];
  SharedPreferences? _prefs;

  Paroisse get paroisse => paroisses.firstWhere((p) => p.id == paroisseId, orElse: () => paroisses.first);
  Paroisse? byId(String id) {
    for (final p in paroisses) {
      if (p.id == id) return p;
    }
    return null;
  }

  Future<void> load() async {
    try {
      final p = await SharedPreferences.getInstance();
      _prefs = p;
      paroisseId = p.getString('paroisse');
      prenom = p.getString('prenom') ?? '';
      vues = (p.getStringList('vues') ?? []).toSet();
      final a = p.getString('annonces');
      if (a != null) {
        annonces = (jsonDecode(a) as List).map((e) => Annonce.fromJson(e as Map<String, dynamic>)).toList();
      }
      final m = p.getString('messes');
      if (m != null) {
        final map = jsonDecode(m) as Map<String, dynamic>;
        for (final par in paroisses) {
          final l = map[par.id];
          if (l != null) {
            par.messes = (l as List).map((e) => Messe.fromJson(e as Map<String, dynamic>)).toList();
          }
        }
      }
    } catch (_) {
      // Démo : en cas de problème, on repart des données par défaut.
    }
  }

  void _save() {
    final p = _prefs;
    if (p == null) return;
    if (paroisseId != null) p.setString('paroisse', paroisseId!);
    p.setString('prenom', prenom);
    p.setStringList('vues', vues.toList());
    p.setString('annonces', jsonEncode(annonces.map((a) => a.toJson()).toList()));
    p.setString('messes', jsonEncode({for (final x in paroisses) x.id: x.messes.map((m) => m.toJson()).toList()}));
  }

  void choisir(String id, String nom) {
    paroisseId = id;
    prenom = nom.trim();
    _save();
    notifyListeners();
  }

  List<Annonce> annoncesDe(String? id) =>
      annonces.where((a) => a.paroisse == id || a.paroisse == '*').toList()..sort((a, b) => b.date.compareTo(a.date));

  int get nonLues => annoncesDe(paroisseId).where((a) => !vues.contains(a.titre)).length;

  void marquerLues() {
    vues.addAll(annoncesDe(paroisseId).map((a) => a.titre));
    _save();
    notifyListeners();
  }

  void publier(String titre, String texte) {
    annonces.add(Annonce(paroisseId!, aujourdhuiIso(), titre, texte.isEmpty ? '—' : texte));
    _save();
    notifyListeners();
  }

  void ajouterMesse(Messe m) {
    paroisse.messes.add(m);
    _save();
    notifyListeners();
  }

  void retirerMesse(int i) {
    paroisse.messes.removeAt(i);
    _save();
    notifyListeners();
  }

  void setAdmin(bool v, {String? id}) {
    adminMode = v;
    if (id != null) paroisseId = id;
    _save();
    notifyListeners();
  }

  void ask(String q) {
    q = q.trim();
    if (q.isEmpty) return;
    chat.add(ChatMsg(true, q));
    chat.add(repondre(q));
    notifyListeners();
  }

  Future<void> reset() async {
    await _prefs?.clear();
    paroisseId = null;
    prenom = '';
    paroisses = demoParoisses();
    annonces = demoAnnonces();
    vues = {};
    adminMode = false;
    notifyListeners();
  }

  // ---------- Assistant (simulation, sans IA) ----------

  static String _norm(String s) {
    const from = 'àâäáãéèêëíìîïóòôöõúùûüçñ';
    const to = 'aaaaaeeeeiiiiooooouuuucn';
    final b = StringBuffer();
    for (final ch in s.toLowerCase().split('')) {
      final i = from.indexOf(ch);
      b.write(i >= 0 ? to[i] : ch);
    }
    return b.toString();
  }

  Paroisse? _villeDans(String s) {
    for (final p in paroisses) {
      if (s.contains(_norm(p.ville))) return p;
    }
    return null;
  }

  ChatMsg repondre(String q) {
    final s = _norm(q);
    final Paroisse? ville = _villeDans(s);
    final langue = s.contains('anglais') || s.contains('english')
        ? 'EN'
        : s.contains('espagnol')
            ? 'ES'
            : s.contains('portugais')
                ? 'PT'
                : null;
    final today = jourIndex(DateTime.now());
    final int? jour = s.contains('dimanche')
        ? 0
        : s.contains('samedi')
            ? 6
            : s.contains('aujourd')
                ? today
                : null;

    if (s.contains('messe') || s.contains('mass') || s.contains('horaire')) {
      final ps = ville == null ? paroisses : paroisses.where((p) => p.ville == ville.ville).toList();
      final hits = <String>[];
      for (final p in ps) {
        for (final m in p.messes) {
          if ((langue == null || m.langue == langue) && (jour == null || m.jours.contains(jour))) {
            final quand = jour == null ? ' — ${joursLabel(m.jours)}' : '';
            hits.add('• ${p.nom} (${p.ville}) : ${m.heure}, ${langues[m.langue]!.toLowerCase()}$quand');
          }
        }
      }
      if (hits.isEmpty) {
        return ChatMsg(false, 'Je ne trouve pas de messe correspondant à cette demande. Essayez une autre ville ou une autre langue.',
            "Horaires de l'application");
      }
      final titre = jour == null ? 'Voici ce que je trouve :' : 'Voici ce que je trouve (${jours[jour].toLowerCase()}) :';
      final suite = hits.length > 6 ? "\n… et ${hits.length - 6} autres dans l'onglet Horaires." : '';
      return ChatMsg(false, '$titre\n${hits.take(6).join('\n')}$suite', "Horaires de l'application");
    }
    if (s.contains('confess') || s.contains('reconcili')) {
      final p = ville ?? paroisse;
      return ChatMsg(false,
          'Confessions à ${p.nom} : ${p.confessions}.\nVous pourrez aussi demander un rendez-vous avec un prêtre (module prévu plus tard).',
          'Fiches paroisses');
    }
    if (s.contains('bapt')) {
      return ChatMsg(false,
          'Pour un baptême, contactez le secrétariat de votre paroisse au moins 3 mois avant la date souhaitée. Une préparation est demandée aux parents, au parrain et à la marraine.',
          'Guide des démarches (exemple à valider par le diocèse)');
    }
    if (s.contains('mariage')) {
      return ChatMsg(false, 'Pour un mariage, prenez contact avec le curé de votre paroisse environ un an à l\'avance pour la préparation.',
          'Guide des démarches (exemple à valider par le diocèse)');
    }
    if (s.contains('choral') || s.contains('chant') || s.contains('jeune') || s.contains('etudiant') || s.contains('groupe')) {
      final ms = mouvements.where((m) => ville == null || m.paroisse == ville.id || m.paroisse == '*').take(4);
      return ChatMsg(false, 'Quelques groupes :\n${ms.map((m) => '• ${m.nom} — ${m.quand}').join('\n')}', 'Annuaire des mouvements');
    }
    if (s.contains('evangile') || s.contains('lecture') || s.contains('saint')) {
      return ChatMsg(
          false,
          'Lectures de l\'exemple du jour : ${lectures.map((l) => l.reference).join(' ; ')}. ${lectures[2].resume} Saint du jour : $saintNom.',
          'Liturgie du jour');
    }
    return ChatMsg(false,
        'Je suis une démonstration et je réponds seulement sur les messes, confessions, baptêmes, mariages, mouvements et la liturgie du jour. Pour une question personnelle ou spirituelle, je vous oriente vers un prêtre de votre paroisse.');
  }
}

final app = AppState();
