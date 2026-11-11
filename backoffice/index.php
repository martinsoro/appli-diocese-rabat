<?php
declare(strict_types=1);

require __DIR__ . '/inc/bootstrap.php';
require __DIR__ . '/inc/entities.php';

if (!config()) redirect('install.php');
start_session();
header('X-Frame-Options: DENY');
header('X-Content-Type-Options: nosniff');
header('Referrer-Policy: same-origin');

$p = $_GET['p'] ?? 'dashboard';
$a = $_GET['a'] ?? 'list';

// ---------- Connexion ----------
if ($p === 'login') {
    if (user()) redirect('index.php');
    $err = null;
    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        check_csrf();
        $ip = substr((string)($_SERVER['REMOTE_ADDR'] ?? '?'), 0, 64);
        q('DELETE FROM tentatives WHERE at < ?', [time() - 900]);
        $n = (int)q('SELECT COUNT(*) FROM tentatives WHERE ip = ?', [$ip])->fetchColumn();
        if ($n >= 8) {
            $err = 'Trop de tentatives. Réessayez dans 15 minutes.';
        } else {
            $u = q('SELECT * FROM users WHERE email = ? AND actif = 1', [strtolower(trim((string)($_POST['email'] ?? '')))])->fetch();
            if ($u && password_verify((string)($_POST['password'] ?? ''), $u['password_hash'])) {
                session_regenerate_id(true);
                $_SESSION['uid'] = (int)$u['id'];
                q('DELETE FROM tentatives WHERE ip = ?', [$ip]);
                redirect('index.php');
            }
            q('INSERT INTO tentatives (ip, at) VALUES (?, ?)', [$ip, time()]);
            $err = 'E-mail ou mot de passe incorrect.';
        }
    }
    layout_start('Connexion');
    if ($err) echo '<div class="flash err">' . e($err) . '</div>';
    echo '<p class="muted">Administration de l\'application de l\'Archidiocèse de Rabat.</p>';
    echo '<form method="post" class="form">' . csrf_field()
        . '<label>E-mail<input type="email" name="email" required autofocus value="' . e($_POST['email'] ?? '') . '"></label>'
        . '<label>Mot de passe<input type="password" name="password" required autocomplete="current-password"></label>'
        . '<button class="btn">Se connecter</button></form>'
        . '<p class="muted small">Mot de passe oublié ? Demandez à l\'équipe du diocèse de le réinitialiser.</p>';
    layout_end();
    exit;
}

if ($p === 'logout') {
    $_SESSION = [];
    session_destroy();
    redirect('index.php?p=login');
}

require_login();

// ---------- Tableau de bord ----------
if ($p === 'dashboard') {
    $dio = is_diocese();
    $pid = (int)user()['paroisse_id'];
    $w = $dio ? '1=1' : 'paroisse_id = ' . $pid;
    $stats = [
        ['Messes par semaine', 'messes', array_sum(array_map(fn($r) => count(explode(',', $r['jours'])), q("SELECT jours FROM messes WHERE $w")->fetchAll()))],
        ['Annonces publiées', 'annonces', (int)q("SELECT COUNT(*) FROM annonces WHERE $w")->fetchColumn()],
        ['Mouvements', 'mouvements', (int)q("SELECT COUNT(*) FROM mouvements WHERE $w")->fetchColumn()],
    ];
    if ($dio) {
        array_unshift($stats, ['Paroisses', 'paroisses', (int)q('SELECT COUNT(*) FROM paroisses')->fetchColumn()]);
        $stats[] = ['Comptes', 'users', (int)q('SELECT COUNT(*) FROM users')->fetchColumn()];
    }
    layout_start('Bonjour ' . user()['nom']);
    echo '<div class="stats">';
    foreach ($stats as [$l, $k, $n]) echo '<a class="stat" href="index.php?p=' . $k . '"><span>' . e($l) . '</span><b>' . $n . '</b></a>';
    echo '</div>';
    echo '<h2>Actions rapides</h2><div class="quick">'
        . '<a class="btn" href="index.php?p=annonces&a=edit">Publier une annonce</a>'
        . '<a class="btn ghost" href="index.php?p=messes&a=edit">Ajouter une messe</a>'
        . ($dio ? '<a class="btn ghost" href="index.php?p=paroles&a=edit">Saisir la parole du jour</a><a class="btn ghost" href="index.php?p=users&a=edit">Créer un compte de paroisse</a>' : '')
        . '</div>';
    $dern = q("SELECT * FROM annonces WHERE " . ($dio ? '1=1' : '(paroisse_id = ' . $pid . ' OR paroisse_id IS NULL)') . " ORDER BY date_pub DESC, id DESC LIMIT 5")->fetchAll();
    echo '<h2>Dernières annonces</h2>';
    if (!$dern) echo '<p class="empty">Aucune annonce.</p>';
    foreach ($dern as $r) {
        echo '<div class="card"><div class="muted small">' . e(date('d/m/Y', strtotime($r['date_pub']))) . ' · ' . e(paroisse_nom($r['paroisse_id'] ? (int)$r['paroisse_id'] : null)) . '</div><b>' . e($r['titre']) . '</b><p>' . nl2br(e($r['texte'])) . '</p></div>';
    }
    echo '<p class="muted small">L\'application lit ces données en direct via <a href="api.php">api.php</a>.</p>';
    layout_end();
    exit;
}

// ---------- Mon compte ----------
if ($p === 'compte') {
    $err = null;
    if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        check_csrf();
        $u = user();
        $new = (string)($_POST['new'] ?? '');
        if (!password_verify((string)($_POST['old'] ?? ''), $u['password_hash'])) $err = 'Mot de passe actuel incorrect.';
        elseif (strlen($new) < 10) $err = 'Le nouveau mot de passe doit contenir au moins 10 caractères.';
        elseif ($new !== ($_POST['new2'] ?? '')) $err = 'Les deux nouveaux mots de passe ne sont pas identiques.';
        else {
            q('UPDATE users SET password_hash = ? WHERE id = ?', [password_hash($new, PASSWORD_DEFAULT), $u['id']]);
            flash('Mot de passe modifié.');
            redirect('index.php?p=compte');
        }
    }
    layout_start('Mon compte');
    if ($err) echo '<div class="flash err">' . e($err) . '</div>';
    echo '<p>' . e(user()['nom']) . ' · ' . e(user()['email']) . '</p>';
    echo '<form method="post" class="form">' . csrf_field() . '<h2>Changer de mot de passe</h2>'
        . '<label>Mot de passe actuel<input type="password" name="old" required autocomplete="current-password"></label>'
        . '<label>Nouveau mot de passe (10 caractères min.)<input type="password" name="new" minlength="10" required autocomplete="new-password"></label>'
        . '<label>Confirmer<input type="password" name="new2" minlength="10" required autocomplete="new-password"></label>'
        . '<button class="btn">Enregistrer</button></form>';
    layout_end();
    exit;
}

// ---------- Contenus ----------
if (array_key_exists($p, entities())) {
    if ($a === 'edit') page_edit($p);
    elseif ($a === 'delete' && $_SERVER['REQUEST_METHOD'] === 'POST') do_delete($p);
    else page_list($p);
    exit;
}

http_response_code(404);
layout_start('Page introuvable');
echo '<p><a href="index.php">Retour au tableau de bord</a></p>';
layout_end();
