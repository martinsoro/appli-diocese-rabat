<?php
declare(strict_types=1);

// API publique en lecture seule, utilisée par l'application mobile.
// api.php?r=paroisses | annonces[&paroisse=slug] | mouvements | parole[&date=AAAA-MM-JJ]

require __DIR__ . '/inc/bootstrap.php';

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Cache-Control: public, max-age=120');

function out($data, int $code = 200): never
{
    http_response_code($code);
    echo json_encode($data, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES | JSON_PRETTY_PRINT);
    exit;
}

if (!config()) out(['erreur' => 'Back-office non installé'], 503);

try {
    $slugs = [];
    foreach (q('SELECT id, slug FROM paroisses')->fetchAll() as $r) $slugs[(int)$r['id']] = $r['slug'];
    $slugOf = fn($id) => $id ? ($slugs[(int)$id] ?? null) : '*';

    switch ($_GET['r'] ?? '') {
        case 'paroisses':
            $messes = [];
            foreach (q('SELECT * FROM messes ORDER BY heure')->fetchAll() as $m) {
                $messes[(int)$m['paroisse_id']][] = [
                    'j' => array_map('intval', explode(',', $m['jours'])),
                    'h' => $m['heure'],
                    'l' => $m['langue'],
                    'note' => $m['note'],
                ];
            }
            $list = [];
            foreach (q('SELECT * FROM paroisses WHERE actif = 1 ORDER BY ville, nom')->fetchAll() as $p) {
                $list[] = [
                    'id' => $p['slug'], 'nom' => $p['nom'], 'ville' => $p['ville'], 'adresse' => $p['adresse'],
                    'lat' => $p['lat'] !== null ? (float)$p['lat'] : null, 'lon' => $p['lon'] !== null ? (float)$p['lon'] : null,
                    'tel' => $p['telephone'], 'email' => $p['email'], 'confessions' => $p['confessions'],
                    'messes' => $messes[(int)$p['id']] ?? [],
                ];
            }
            out($list);

        case 'annonces':
            $sql = 'SELECT * FROM annonces WHERE date_pub <= ?';
            $params = [today()];
            if (!empty($_GET['paroisse'])) {
                $pid = array_search((string)$_GET['paroisse'], $slugs, true);
                $sql .= ' AND (paroisse_id IS NULL OR paroisse_id = ?)';
                $params[] = $pid === false ? -1 : $pid;
            }
            $rows = q($sql . ' ORDER BY date_pub DESC, id DESC LIMIT 100', $params)->fetchAll();
            out(array_map(fn($a) => [
                'id' => (int)$a['id'], 'p' => $slugOf($a['paroisse_id']), 'd' => $a['date_pub'],
                't' => $a['titre'], 'x' => $a['texte'], 'notifier' => (bool)$a['notifier'],
            ], $rows));

        case 'mouvements':
            $rows = q('SELECT * FROM mouvements ORDER BY nom')->fetchAll();
            out(array_map(fn($m) => [
                'id' => (int)$m['id'], 'p' => $slugOf($m['paroisse_id']), 'nom' => $m['nom'], 'type' => $m['type'],
                'quand' => $m['quand'], 'desc' => $m['description'],
            ], $rows));

        case 'parole':
            $d = (string)($_GET['date'] ?? today());
            if (!preg_match('/^\d{4}-\d{2}-\d{2}$/', $d)) out(['erreur' => 'Date invalide'], 400);
            $r = q('SELECT * FROM paroles WHERE jour = ?', [$d])->fetch();
            out($r ? [
                'jour' => $r['jour'], 'reference' => $r['reference'], 'verset' => $r['verset'], 'saint' => $r['saint'],
                'saint_bio' => $r['saint_bio'],
                'lectures' => array_values(array_filter(array_map('trim', preg_split('/\R/', (string)$r['lectures']) ?: []))),
            ] : null);

        default:
            out(['api' => APP_NAME, 'points' => ['paroisses', 'annonces?paroisse=slug', 'mouvements', 'parole?date=AAAA-MM-JJ']]);
    }
} catch (Throwable $ex) {
    out(['erreur' => 'Erreur serveur'], 500);
}
