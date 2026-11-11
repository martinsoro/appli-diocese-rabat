import 'package:flutter/material.dart';

import '../data.dart';
import '../state.dart';
import '../ui.dart';

class HorairesScreen extends StatefulWidget {
  const HorairesScreen({super.key});
  @override
  State<HorairesScreen> createState() => _HorairesScreenState();
}

class _HorairesScreenState extends State<HorairesScreen> {
  String _jour = 'today'; // today | sun | all
  String _langue = 'ALL';

  Widget _chip(String label, bool on, VoidCallback tap) => Padding(
        padding: const EdgeInsets.only(right: 6),
        child: ChoiceChip(label: Text(label), selected: on, onSelected: (_) => tap(), showCheckmark: false),
      );

  @override
  Widget build(BuildContext context) {
    return Watch(builder: (context) {
      final int? jour = _jour == 'today' ? jourIndex(DateTime.now()) : _jour == 'sun' ? 0 : null;
      final ps = [...app.paroisses]..sort((a, b) {
          if (a.id == app.paroisseId) return -1;
          if (b.id == app.paroisseId) return 1;
          return a.ville.compareTo(b.ville);
        });
      final cartes = <Widget>[];
      for (final p in ps) {
        final ms = p.messes
            .where((m) => (_langue == 'ALL' || m.langue == _langue) && (jour == null || m.jours.contains(jour)))
            .toList()
          ..sort((a, b) => a.minutes.compareTo(b.minutes));
        if (ms.isEmpty) continue;
        cartes.add(Carte(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(p.nom, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  Text(p.id == app.paroisseId ? '${p.ville} · ma paroisse' : p.ville,
                      style: const TextStyle(color: muted, fontSize: 12.5)),
                ]),
              ),
              TextButton(onPressed: () => ouvrir(context, mapsUrl(p)), child: const Text('Y aller')),
            ]),
            const SizedBox(height: 6),
            for (final m in ms)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(children: [
                  SizedBox(
                      width: 58,
                      child: Text(m.heure, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16))),
                  Pastille(m.langue),
                  const SizedBox(width: 10),
                  Text(joursLabel(m.jours), style: const TextStyle(color: muted, fontSize: 12.5)),
                ]),
              ),
            const SizedBox(height: 6),
            Text('Confessions : ${p.confessions}', style: const TextStyle(color: muted, fontSize: 12.5)),
          ]),
        ));
      }
      return ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
        children: [
          const Titre('Horaires des messes', sous: 'Toutes les paroisses du diocèse, la vôtre en premier.'),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              _chip("Aujourd'hui", _jour == 'today', () => setState(() => _jour = 'today')),
              _chip('Dimanche', _jour == 'sun', () => setState(() => _jour = 'sun')),
              _chip('Toute la semaine', _jour == 'all', () => setState(() => _jour = 'all')),
            ]),
          ),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              _chip('Toutes langues', _langue == 'ALL', () => setState(() => _langue = 'ALL')),
              for (final e in langues.entries) _chip(e.value, _langue == e.key, () => setState(() => _langue = e.key)),
            ]),
          ),
          const SizedBox(height: 12),
          if (cartes.isEmpty) const Carte(child: Text('Aucune messe pour ce filtre.', style: TextStyle(color: muted))),
          ...cartes,
        ],
      );
    });
  }
}
