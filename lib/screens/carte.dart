import 'package:flutter/material.dart';

import '../data.dart';
import '../state.dart';
import '../ui.dart';

const _lon0 = -10.0, _lon1 = -4.5, _lat0 = 30.0, _lat1 = 35.0;

Offset _proj(double lat, double lon, Size s) =>
    Offset(16 + (lon - _lon0) / (_lon1 - _lon0) * (s.width - 32), 16 + (_lat1 - lat) / (_lat1 - _lat0) * (s.height - 32));

class CarteScreen extends StatefulWidget {
  const CarteScreen({super.key});
  @override
  State<CarteScreen> createState() => _CarteScreenState();
}

class _CarteScreenState extends State<CarteScreen> {
  String? _sel;

  @override
  Widget build(BuildContext context) {
    return Watch(builder: (context) {
      final sel = (_sel == null ? null : app.byId(_sel!)) ?? app.paroisse;
      final n = prochaineMesse(sel);
      return ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
        children: [
          Titre('Carte du diocèse', sous: '${app.paroisses.length} églises et chapelles. Touchez un point.'),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 340,
              child: LayoutBuilder(builder: (context, c) {
                final size = Size(c.maxWidth, 340);
                return GestureDetector(
                  onTapUp: (d) {
                    String? best;
                    var bestDist = 40.0;
                    for (final p in app.paroisses) {
                      final dist = (_proj(p.lat, p.lon, size) - d.localPosition).distance;
                      if (dist < bestDist) {
                        bestDist = dist;
                        best = p.id;
                      }
                    }
                    if (best != null) setState(() => _sel = best);
                  },
                  child: CustomPaint(size: size, painter: _MapPainter(app.paroisses, sel.id, app.paroisseId)),
                );
              }),
            ),
          ),
          const SizedBox(height: 12),
          Carte(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(sel.nom, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
              Text('${sel.ville} · ${sel.tel}', style: const TextStyle(color: muted, fontSize: 12.5)),
              if (n != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                      'Prochaine messe : ${n.quand} ${n.messe.heure} (${langues[n.messe.langue]!.toLowerCase()})'),
                ),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: FilledButton(onPressed: () => ouvrir(context, mapsUrl(sel)), child: const Text('Google Maps'))),
                const SizedBox(width: 8),
                Expanded(child: FilledButton.tonal(onPressed: () => ouvrir(context, wazeUrl(sel)), child: const Text('Waze'))),
              ]),
            ]),
          ),
          const Text(
              'Carte schématique pour la démo ; la version finale utilisera une vraie carte avec « messe la plus proche ».',
              style: TextStyle(color: muted, fontSize: 12)),
        ],
      );
    });
  }
}

class _MapPainter extends CustomPainter {
  final List<Paroisse> ps;
  final String sel;
  final String? mine;
  _MapPainter(this.ps, this.sel, this.mine);

  static const _labels = {
    'rabat': [-14.0, -8.0, 1.0], // dx, dy, ancrage (1 = à droite du texte)
    'kenitra': [0.0, -26.0, 0.5],
    'meknes': [0.0, 12.0, 0.5],
  };

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFFE8EEF3));
    final grid = Paint()
      ..color = const Color(0xFFD6E0E8)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 22) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (double y = 0; y < size.height; y += 22) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }
    // Côte atlantique, approximative.
    const cote = [[35.8, -5.9], [34.9, -6.4], [33.9, -7.0], [33.2, -8.5], [32.3, -9.3], [31.3, -9.8], [30.4, -9.7], [29.9, -10.1]];
    final path = Path();
    for (var i = 0; i < cote.length; i++) {
      final o = _proj(cote[i][0], cote[i][1], size);
      if (i == 0) {
        path.moveTo(o.dx, o.dy);
      } else {
        path.lineTo(o.dx, o.dy);
      }
    }
    canvas.drawPath(
        path,
        Paint()
          ..color = const Color(0xFF9FB6C8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round);
    _text(canvas, 'Océan Atlantique', _proj(34.3, -9.8, size), const Color(0xFF7D93A5), 11, FontWeight.w400, 0, italic: true);

    for (final p in ps) {
      final o = _proj(p.lat, p.lon, size);
      final on = p.id == sel;
      canvas.drawCircle(o, on ? 11 : 8, Paint()..color = on ? brand : Colors.white);
      canvas.drawCircle(
          o,
          on ? 11 : 8,
          Paint()
            ..color = brand
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2);
      if (p.id == mine) canvas.drawCircle(o, 3, Paint()..color = on ? Colors.white : brand);
      final l = _labels[p.id] ?? [14.0, -8.0, 0.0];
      _text(canvas, p.ville, o + Offset(l[0], l[1]), ink, 12, on ? FontWeight.w700 : FontWeight.w500, l[2]);
    }
  }

  void _text(Canvas c, String s, Offset at, Color color, double size, FontWeight w, double anchor, {bool italic = false}) {
    final tp = TextPainter(
      text: TextSpan(
          text: s,
          style: TextStyle(color: color, fontSize: size, fontWeight: w, fontStyle: italic ? FontStyle.italic : FontStyle.normal)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(c, Offset(at.dx - tp.width * anchor, at.dy));
  }

  @override
  bool shouldRepaint(covariant _MapPainter old) => old.sel != sel || old.mine != mine || old.ps != ps;
}
