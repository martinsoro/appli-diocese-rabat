<?php
declare(strict_types=1);

// Description des contenus gérés et formulaires génériques (liste, ajout, modification, suppression).

function paroisse_options(bool $avecDiocese): array
{
    $o = $avecDiocese ? ['' => 'Tout le diocèse'] : [];
    foreach (paroisses_all() as $p) $o[(string)$p['id']] = $p['nom'] . ' (' . $p['ville'] . ')';
    return $o;
}

function entities(): array
{
    $dio = is_diocese();
    return [
        'paroisses' => [
            'table' => 'paroisses', 'titre' => $dio ? 'Paroisses' : 'Fiche de ma paroisse', 'un' => 'une paroisse',
            'scope' => 'self', 'create' => $dio, 'delete' => $dio, 'order' => 'ville, nom',
            'fields' => [
                ['nom', 'Nom', 'text', true],
                ['ville', 'Ville', 'text', true],
                ['adresse', 'Adresse', 'text'],
                ['lat', 'Latitude (ex. 34.02)', 'number'],
                ['lon', 'Longitude (ex. -6.84)', 'number'],
                ['telephone', 'Téléphone', 'text'],
                ['email', 'E-mail du secrétariat', 'email'],
                ['confessions', 'Confessions (ex. Samedi 16h – 18h)', 'text'],
                ['actif', 'Visible dans l\'application', 'checkbox'],
            ],
            'cols' => ['nom' => 'Nom', 'ville' => 'Ville', 'telephone' => 'Téléphone', 'actif' => 'Visible'],
            'help' => 'Pour placer une église sur la carte : dans Google Maps, faites un clic droit sur l\'église, puis cliquez sur les coordonnées pour les copier.',
        ],
        'messes' => [
            'table' => 'messes', 'titre' => 'Horaires des messes', 'un' => 'une messe',
            'scope' => 'paroisse', 'create' => true, 'delete' => true, 'order' => 'paroisse_id, heure',
            'fields' => [
                ['paroisse_id', 'Paroisse', 'select', true, fn() => paroisse_options(false)],
                ['jours', 'Jours', 'days', true],
                ['heure', 'Heure', 'time', true],
                ['langue', 'Langue', 'select', true, fn() => LANGUES],
                ['note', 'Précision (facultatif, ex. « messe des familles »)', 'text'],
            ],
            'cols' => ['paroisse_id' => 'Paroisse', 'jours' => 'Jours', 'heure' => 'Heure', 'langue' => 'Langue', 'note' => 'Précision'],
        ],
        'annonces' => [
            'table' => 'annonces', 'titre' => 'Annonces', 'un' => 'une annonce',
            'scope' => 'paroisse', 'nullable_scope' => true, 'create' => true, 'delete' => true, 'order' => 'date_pub DESC, id DESC',
            'fields' => [
                ['paroisse_id', 'Destinataires', 'select', false, fn() => paroisse_options(true)],
                ['titre', 'Titre', 'text', true],
                ['texte', 'Texte', 'textarea', true],
                ['date_pub', 'Date de publication', 'date', true],
                ['notifier', 'Envoyer une notification aux fidèles', 'checkbox'],
            ],
            'cols' => ['date_pub' => 'Date', 'titre' => 'Titre', 'paroisse_id' => 'Destinataires', 'notifier' => 'Notification'],
            'defaults' => ['date_pub' => today(), 'notifier' => 1],
        ],
        'mouvements' => [
            'table' => 'mouvements', 'titre' => 'Mouvements et chorales', 'un' => 'un mouvement',
            'scope' => 'paroisse', 'nullable_scope' => true, 'create' => true, 'delete' => true, 'order' => 'paroisse_id, nom',
            'fields' => [
                ['paroisse_id', 'Paroisse', 'select', false, fn() => paroisse_options(true)],
                ['nom', 'Nom', 'text', true],
                ['type', 'Type (chorale, jeunes, prière…)', 'text'],
                ['quand', 'Rencontres (ex. Jeudi 19h)', 'text'],
                ['description', 'Description', 'textarea'],
                ['contact_email', 'E-mail du responsable (jamais affiché aux fidèles)', 'email'],
            ],
            'cols' => ['nom' => 'Nom', 'type' => 'Type', 'quand' => 'Rencontres', 'paroisse_id' => 'Paroisse'],
        ],
        'paroles' => [
            'table' => 'paroles', 'titre' => 'Parole du jour', 'un' => 'un jour',
            'scope' => 'diocese', 'create' => true, 'delete' => true, 'order' => 'jour DESC',
            'fields' => [
                ['jour', 'Date', 'date', true],
                ['reference', 'Référence du verset (ex. Luc 17, 19)', 'text', true],
                ['verset', 'Verset', 'textarea', true],
                ['saint', 'Saint du jour', 'text'],
                ['saint_bio', 'Quelques mots sur le saint', 'textarea'],
                ['lectures', 'Références des lectures (une par ligne)', 'textarea'],
            ],
            'cols' => ['jour' => 'Date', 'reference' => 'Référence', 'saint' => 'Saint du jour'],
            'defaults' => ['jour' => today()],
        ],
        'users' => [
            'table' => 'users', 'titre' => 'Comptes administrateurs', 'un' => 'un compte',
            'scope' => 'diocese', 'create' => true, 'delete' => true, 'order' => 'role, nom',
            'fields' => [
                ['nom', 'Nom', 'text', true],
                ['email', 'E-mail (identifiant de connexion)', 'email', true],
                ['role', 'Rôle', 'select', true, fn() => ['paroisse' => 'Paroisse (curé ou secrétaire)', 'diocese' => 'Diocèse (accès complet)']],
                ['paroisse_id', 'Paroisse gérée (pour le rôle Paroisse)', 'select', false, fn() => ['' => '—'] + paroisse_options(false)],
                ['password', 'Mot de passe (10 caractères min. ; laisser vide pour ne pas le changer)', 'password'],
                ['actif', 'Compte actif', 'checkbox'],
            ],
            'cols' => ['nom' => 'Nom', 'email' => 'E-mail', 'role' => 'Rôle', 'paroisse_id' => 'Paroisse', 'actif' => 'Actif'],
            'defaults' => ['actif' => 1, 'role' => 'paroisse'],
        ],
    ];
}

function entity(string $key): array
{
    $all = entities();
    if (!isset($all[$key])) {
        http_response_code(404);
        exit('Page introuvable.');
    }
    $ent = $all[$key];
    if ($ent['scope'] === 'diocese') require_diocese();
    return $ent + ['key' => $key];
}

/** Clause WHERE limitant ce qu'un compte de paroisse peut voir et modifier. */
function scope_where(array $ent): array
{
    if (is_diocese()) return ['1=1', []];
    $pid = (int)user()['paroisse_id'];
    if ($ent['scope'] === 'self') return ['id = ?', [$pid]];
    if ($ent['scope'] === 'paroisse') return ['paroisse_id = ?', [$pid]];
    return ['1=0', []];
}

function find_row(array $ent, int $id): ?array
{
    [$w, $p] = scope_where($ent);
    $r = q("SELECT * FROM {$ent['table']} WHERE id = ? AND $w", array_merge([$id], $p))->fetch();
    return $r ?: null;
}

function cell(array $ent, string $col, array $row): string
{
    $v = $row[$col] ?? null;
    return match (true) {
        $col === 'paroisse_id' => e(paroisse_nom($v ? (int)$v : null)),
        $col === 'jours' => e(jours_label((string)$v)),
        $col === 'langue' => e(LANGUES[$v] ?? $v),
        $col === 'role' => $v === 'diocese' ? 'Diocèse' : 'Paroisse',
        in_array($col, ['actif', 'notifier'], true) => $v ? 'Oui' : 'Non',
        $col === 'date_pub' || $col === 'jour' => e(date('d/m/Y', strtotime((string)$v))),
        default => e($v),
    };
}

function page_list(string $key): void
{
    $ent = entity($key);
    [$w, $p] = scope_where($ent);
    $filtre = null;
    if (is_diocese() && $ent['scope'] === 'paroisse' && isset($_GET['paroisse']) && $_GET['paroisse'] !== '') {
        $filtre = (int)$_GET['paroisse'];
        $w .= ' AND paroisse_id = ?';
        $p[] = $filtre;
    }
    $rows = q("SELECT * FROM {$ent['table']} WHERE $w ORDER BY {$ent['order']}", $p)->fetchAll();

    layout_start($ent['titre']);
    echo '<div class="bar">';
    if ($ent['create']) echo '<a class="btn" href="index.php?p=' . $key . '&a=edit">Ajouter ' . e($ent['un']) . '</a>';
    if (is_diocese() && $ent['scope'] === 'paroisse') {
        echo '<form method="get" class="filter"><input type="hidden" name="p" value="' . $key . '"><select name="paroisse" onchange="this.form.submit()"><option value="">Toutes les paroisses</option>';
        foreach (paroisses_all() as $par) {
            echo '<option value="' . $par['id'] . '"' . ($filtre === (int)$par['id'] ? ' selected' : '') . '>' . e($par['nom'] . ' (' . $par['ville'] . ')') . '</option>';
        }
        echo '</select></form>';
    }
    echo '</div>';
    if (!empty($ent['help'])) echo '<p class="muted">' . e($ent['help']) . '</p>';

    if (!$rows) {
        echo '<p class="empty">Rien pour l\'instant.</p>';
    } else {
        echo '<table class="list"><thead><tr>';
        foreach ($ent['cols'] as $l) echo '<th>' . e($l) . '</th>';
        echo '<th></th></tr></thead><tbody>';
        foreach ($rows as $r) {
            echo '<tr>';
            foreach ($ent['cols'] as $c => $l) echo '<td data-label="' . e($l) . '">' . cell($ent, $c, $r) . '</td>';
            echo '<td class="actions"><a href="index.php?p=' . $key . '&a=edit&id=' . $r['id'] . '">Modifier</a>';
            if ($ent['delete'] && !($key === 'users' && (int)$r['id'] === (int)user()['id'])) {
                echo '<form method="post" action="index.php?p=' . $key . '&a=delete&id=' . $r['id'] . '" onsubmit="return confirm(\'Supprimer définitivement ?\')">' . csrf_field() . '<button class="link danger">Supprimer</button></form>';
            }
            echo '</td></tr>';
        }
        echo '</tbody></table>';
    }
    layout_end();
}

function page_edit(string $key): void
{
    $ent = entity($key);
    $id = (int)($_GET['id'] ?? 0);
    $row = $id ? find_row($ent, $id) : null;
    if ($id && !$row) {
        http_response_code(404);
        exit('Élément introuvable ou non autorisé.');
    }
    if (!$id && !$ent['create']) redirect('index.php?p=' . $key);

    $vals = $row ?? ($ent['defaults'] ?? []);
    if (!$row && !is_diocese() && $ent['scope'] === 'paroisse') $vals['paroisse_id'] = user()['paroisse_id'];
    $err = null;

    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        check_csrf();
        [$data, $err] = collect($ent, $row);
        if (!$err) {
            try {
                save($ent, $data, $id);
                flash($id ? 'Modifications enregistrées.' : 'Ajout enregistré.');
                redirect('index.php?p=' . $key);
            } catch (PDOException $ex) {
                $err = str_contains($ex->getMessage(), 'UNIQUE') || $ex->getCode() === '23000'
                    ? 'Cette valeur existe déjà (adresse e-mail ou date en double).'
                    : 'Enregistrement impossible : ' . $ex->getMessage();
            }
        }
        $vals = array_merge($vals, $data ?? [], $_POST);
    }

    layout_start(($id ? 'Modifier ' : 'Ajouter ') . $ent['un']);
    if ($err) echo '<div class="flash err">' . e($err) . '</div>';
    echo '<form method="post" class="form">' . csrf_field();
    foreach ($ent['fields'] as $f) echo field_html($ent, $f, $vals, (bool)$row);
    echo '<div class="row"><button class="btn">Enregistrer</button> <a href="index.php?p=' . $key . '">Annuler</a></div></form>';
    layout_end();
}

function field_html(array $ent, array $f, array $vals, bool $edition): string
{
    [$name, $label, $type] = $f;
    $req = !empty($f[3]);
    $v = $vals[$name] ?? '';
    $r = $req ? ' required' : '';
    // Un compte de paroisse ne choisit pas la paroisse : c'est toujours la sienne.
    if ($name === 'paroisse_id' && !is_diocese()) {
        return '<p class="muted">' . e($label) . ' : <b>' . e(paroisse_nom((int)user()['paroisse_id'])) . '</b></p>';
    }
    switch ($type) {
        case 'textarea':
            return '<label>' . e($label) . '<textarea name="' . $name . '" rows="5"' . $r . '>' . e($v) . '</textarea></label>';
        case 'checkbox':
            return '<label class="check"><input type="hidden" name="' . $name . '" value="0"><input type="checkbox" name="' . $name . '" value="1"' . ($v || (!$edition && $v === '') ? ' checked' : '') . '> ' . e($label) . '</label>';
        case 'select':
            $h = '<label>' . e($label) . '<select name="' . $name . '"' . $r . '>';
            foreach (($f[4])() as $k => $l) $h .= '<option value="' . e($k) . '"' . ((string)$k === (string)$v ? ' selected' : '') . '>' . e($l) . '</option>';
            return $h . '</select></label>';
        case 'days':
            $sel = is_array($v) ? array_map('intval', $v) : array_map('intval', array_filter(explode(',', (string)$v), 'strlen'));
            $h = '<fieldset><legend>' . e($label) . '</legend><div class="days">';
            foreach ([1, 2, 3, 4, 5, 6, 0] as $d) {
                $h .= '<label class="check"><input type="checkbox" name="jours[]" value="' . $d . '"' . (in_array($d, $sel, true) ? ' checked' : '') . '> ' . JOURS[$d] . '</label>';
            }
            return $h . '</div></fieldset>';
        case 'password':
            return '<label>' . e($label) . '<input type="password" name="' . $name . '" autocomplete="new-password"' . ($edition ? '' : ' required minlength="10"') . '></label>';
        default:
            $t = ['number' => 'text', 'email' => 'email', 'time' => 'time', 'date' => 'date'][$type] ?? 'text';
            return '<label>' . e($label) . '<input type="' . $t . '" name="' . $name . '" value="' . e($v) . '"' . $r . '></label>';
    }
}

/** Lit et vérifie le formulaire. Renvoie [données, erreur]. */
function collect(array $ent, ?array $row): array
{
    $data = [];
    foreach ($ent['fields'] as $f) {
        [$name, $label, $type] = $f;
        $req = !empty($f[3]);
        if ($name === 'paroisse_id' && !is_diocese()) {
            $data[$name] = (int)user()['paroisse_id'];
            continue;
        }
        $raw = $_POST[$name] ?? null;
        switch ($type) {
            case 'checkbox':
                $data[$name] = ($raw === '1') ? 1 : 0;
                break;
            case 'days':
                $d = array_values(array_unique(array_filter(array_map('intval', (array)($_POST['jours'] ?? [])), fn($x) => $x >= 0 && $x <= 6)));
                sort($d);
                if (!$d) return [$data, 'Choisissez au moins un jour.'];
                $data[$name] = implode(',', $d);
                break;
            case 'number':
                $s = str_replace(',', '.', trim((string)$raw));
                if ($s !== '' && !is_numeric($s)) return [$data, "« $label » doit être un nombre."];
                $data[$name] = $s === '' ? null : (float)$s;
                break;
            case 'time':
                $s = trim((string)$raw);
                if (!preg_match('/^([01]\d|2[0-3]):[0-5]\d$/', substr($s, 0, 5))) return [$data, 'Heure invalide (format HH:MM).'];
                $data[$name] = substr($s, 0, 5);
                break;
            case 'date':
                $s = trim((string)$raw);
                if (!preg_match('/^\d{4}-\d{2}-\d{2}$/', $s)) return [$data, "« $label » : date invalide."];
                $data[$name] = $s;
                break;
            case 'email':
                $s = strtolower(trim((string)$raw));
                if ($s !== '' && !filter_var($s, FILTER_VALIDATE_EMAIL)) return [$data, "« $label » : adresse e-mail invalide."];
                $data[$name] = $s === '' ? null : $s;
                break;
            case 'password':
                $s = (string)$raw;
                if ($s === '' && $row) break; // inchangé
                if (strlen($s) < 10) return [$data, 'Le mot de passe doit contenir au moins 10 caractères.'];
                $data['password_hash'] = password_hash($s, PASSWORD_DEFAULT);
                break;
            case 'select':
                $s = (string)$raw;
                $opts = ($f[4])();
                if (!array_key_exists($s, $opts) && !($s === '' && !$req)) return [$data, "« $label » : choix invalide."];
                $data[$name] = $s === '' ? null : ($name === 'paroisse_id' ? (int)$s : $s);
                break;
            default:
                $data[$name] = trim((string)$raw);
                if ($data[$name] === '') $data[$name] = null;
        }
        if ($req && ($data[$name] ?? null) === null && $type !== 'password') return [$data, "« $label » est obligatoire."];
    }
    if ($ent['key'] === 'users') {
        if (($data['role'] ?? '') === 'paroisse' && empty($data['paroisse_id'])) return [$data, 'Choisissez la paroisse gérée par ce compte.'];
        if (($data['role'] ?? '') === 'diocese') $data['paroisse_id'] = null;
        if ($row && (int)$row['id'] === (int)user()['id'] && (($data['role'] ?? '') !== 'diocese' || empty($data['actif']))) {
            return [$data, 'Vous ne pouvez pas retirer vos propres droits ni désactiver votre propre compte.'];
        }
    }
    if ($ent['key'] === 'messes' && !is_diocese() && (int)$data['paroisse_id'] !== (int)user()['paroisse_id']) {
        return [$data, 'Paroisse non autorisée.'];
    }
    return [$data, null];
}

function save(array $ent, array $data, int $id): void
{
    if ($ent['key'] === 'annonces' && !$id) $data['auteur_id'] = (int)user()['id'];
    if ($ent['key'] === 'paroisses' && !$id) {
        $base = slugify($data['nom'] . '-' . $data['ville']);
        $slug = $base;
        for ($i = 2; q('SELECT 1 FROM paroisses WHERE slug = ?', [$slug])->fetch(); $i++) $slug = $base . '-' . $i;
        $data['slug'] = $slug;
    }
    $cols = array_keys($data);
    if ($id) {
        $set = implode(', ', array_map(fn($c) => "$c = ?", $cols));
        q("UPDATE {$ent['table']} SET $set WHERE id = ?", array_merge(array_values($data), [$id]));
    } else {
        $ph = implode(', ', array_fill(0, count($cols), '?'));
        q("INSERT INTO {$ent['table']} (" . implode(', ', $cols) . ") VALUES ($ph)", array_values($data));
    }
}

function do_delete(string $key): void
{
    $ent = entity($key);
    check_csrf();
    $id = (int)($_GET['id'] ?? 0);
    if (!$ent['delete'] || !find_row($ent, $id) || ($key === 'users' && $id === (int)user()['id'])) {
        flash('Suppression impossible.', 'err');
    } else {
        q("DELETE FROM {$ent['table']} WHERE id = ?", [$id]);
        flash('Élément supprimé.');
    }
    redirect('index.php?p=' . $key);
}
