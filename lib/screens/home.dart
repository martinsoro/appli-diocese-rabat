import 'package:flutter/material.dart';

import '../data.dart';
import '../state.dart';
import '../ui.dart';
import 'plus.dart';

class HomeScreen extends StatelessWidget {
  final void Function(int) onGo;
  const HomeScreen({super.key, required this.onGo});

  @override
  Widget build(BuildContext context) {
    return Watch(builder: (context) {
      final p = app.paroisse;
      final n = prochaineMesse(p);
      final ann = app.annoncesDe(p.id).take(2).toList();
      return ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
        children: [
          Titre(app.prenom.isEmpty ? 'Bonjour' : 'Bonjour ${app.prenom}', sous: 'Ma paroisse : ${p.nom}, ${p.ville}'),
          Container(
            padding: const EdgeInsets.all(18),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(colors: [brand, brand2], begin: Alignment.topLeft, end: Alignment.bottomRight),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('PROCHAINE MESSE', style: TextStyle(color: Colors.white70, fontSize: 11, letterSpacing: 1)),
              const SizedBox(height: 6),
              Text(n == null ? '—' : '${n.quand} · ${n.messe.heure}',
                  style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w600, fontFamily: 'serif')),
              if (n != null)
                Text('${p.nom} · en ${langues[n.messe.langue]!.toLowerCase()}', style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 14),
              Wrap(spacing: 8, children: [
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: brand),
                  onPressed: () => ouvrir(context, mapsUrl(p)),
                  child: const Text('Itinéraire'),
                ),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white38)),
                  onPressed: () => onGo(1),
                  child: const Text('Tous les horaires'),
                ),
              ]),
            ]),
          ),
          Carte(
            onTap: () => onGo(3),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Parole du jour', style: TextStyle(color: muted, fontSize: 12.5)),
              const SizedBox(height: 6),
              const Text(versetTexte, style: TextStyle(fontFamily: 'serif', fontSize: 19, height: 1.3)),
              const SizedBox(height: 6),
              const Text('$versetRef · $saintNom', style: TextStyle(color: muted, fontSize: 12.5)),
            ]),
          ),
          const Section('Annonces de ma paroisse'),
          for (final a in ann)
            Carte(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Text(a.titre, style: const TextStyle(fontWeight: FontWeight.w600))),
                  Text(dateCourte(a.date), style: const TextStyle(color: muted, fontSize: 12)),
                ]),
                const SizedBox(height: 4),
                Text(a.texte, style: const TextStyle(fontSize: 13.5)),
                if (a.paroisse == '*')
                  const Padding(padding: EdgeInsets.only(top: 6), child: Text('Diocèse', style: TextStyle(color: muted, fontSize: 12))),
              ]),
            ),
          const Section('Raccourcis'),
          Card(
            child: Column(children: [
              ListTile(
                leading: const Icon(Icons.groups_outlined, color: brand),
                title: const Text('Mouvements et chorales'),
                subtitle: const Text('Rejoindre un groupe'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(context, page(const MouvementsPage())),
              ),
              ListTile(
                leading: const Icon(Icons.chat_bubble_outline, color: brand),
                title: const Text('Poser une question'),
                subtitle: const Text("Assistant de l'application"),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(context, page(const AssistantPage())),
              ),
              ListTile(
                leading: const Icon(Icons.waving_hand_outlined, color: brand),
                title: const Text('Nouvel arrivant ?'),
                subtitle: const Text("Guide d'accueil du diocèse"),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(context, page(const AccueilPage())),
              ),
            ]),
          ),
        ],
      );
    });
  }
}
