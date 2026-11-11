<?php
declare(strict_types=1);

// Socle commun : configuration, base de données, session, sécurité, mise en page.

const APP_NAME = 'Archidiocèse de Rabat';
const LANGUES = ['FR' => 'Français', 'EN' => 'Anglais', 'ES' => 'Espagnol', 'PT' => 'Portugais'];
const JOURS = ['Dimanche', 'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi'];

define('ROOT', dirname(__DIR__));
define('CONFIG_FILE', ROOT . '/config.php');

date_default_timezone_set('Africa/Casablanca');

function config(): ?array
{
    static $c = false;
    if ($c === false) {
        $c = is_file(CONFIG_FILE) ? (require CONFIG_FILE) : null;
        if (!is_array($c)) $c = null;
    }
    return $c;
}

function make_pdo(array $c): PDO
{
    if (($c['driver'] ?? 'mysql') === 'sqlite') {
        $pdo = new PDO('sqlite:' . $c['path']);
        $pdo->exec('PRAGMA foreign_keys = ON');
    } else {
        $dsn = sprintf('mysql:host=%s;port=%d;dbname=%s;charset=utf8mb4', $c['host'], (int)($c['port'] ?? 3306), $c['name']);
        $pdo = new PDO($dsn, $c['user'], $c['pass']);
    }
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    $pdo->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);
    return $pdo;
}

function db(): PDO
{
    static $pdo = null;
    if ($pdo) return $pdo;
    $c = config();
    if (!$c) {
        header('Location: install.php');
        exit;
    }
    return $pdo = make_pdo($c);
}

function q(string $sql, array $params = []): PDOStatement
{
    $st = db()->prepare($sql);
    $st->execute($params);
    return $st;
}

function e($s): string
{
    return htmlspecialchars((string)$s, ENT_QUOTES, 'UTF-8');
}

function redirect(string $url): never
{
    header('Location: ' . $url);
    exit;
}

function today(): string
{
    return date('Y-m-d');
}

function slugify(string $s): string
{
    $s = strtr($s, ['à'=>'a','â'=>'a','ä'=>'a','é'=>'e','è'=>'e','ê'=>'e','ë'=>'e','î'=>'i','ï'=>'i','ô'=>'o','ö'=>'o','ù'=>'u','û'=>'u','ü'=>'u','ç'=>'c','À'=>'a','É'=>'e','È'=>'e']);
    $s = strtolower(trim(preg_replace('/[^A-Za-z0-9]+/', '-', $s) ?? '', '-'));
    return $s !== '' ? $s : 'paroisse';
}

// ---------- Session, utilisateur, sécurité ----------

function start_session(): void
{
    if (session_status() === PHP_SESSION_ACTIVE) return;
    session_name('dioadmin');
    session_set_cookie_params([
        'httponly' => true,
        'samesite' => 'Lax',
        'secure' => !empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off',
    ]);
    session_start();
}

function user(): ?array
{
    static $u = false;
    if ($u === false) {
        $u = null;
        if (!empty($_SESSION['uid'])) {
            $u = q('SELECT * FROM users WHERE id = ? AND actif = 1', [$_SESSION['uid']])->fetch() ?: null;
        }
    }
    return $u;
}

function is_diocese(): bool
{
    return (user()['role'] ?? '') === 'diocese';
}

function require_login(): void
{
    if (!user()) redirect('index.php?p=login');
}

function require_diocese(): void
{
    if (!is_diocese()) {
        http_response_code(403);
        layout_start('Accès refusé');
        echo '<p>Cette page est réservée à l\'équipe du diocèse.</p>';
        layout_end();
        exit;
    }
}

function csrf(): string
{
    if (empty($_SESSION['csrf'])) $_SESSION['csrf'] = bin2hex(random_bytes(16));
    return $_SESSION['csrf'];
}

function csrf_field(): string
{
    return '<input type="hidden" name="csrf" value="' . csrf() . '">';
}

function check_csrf(): void
{
    if (!hash_equals(csrf(), (string)($_POST['csrf'] ?? ''))) {
        http_response_code(400);
        exit('Jeton de sécurité invalide. Revenez en arrière et rechargez la page.');
    }
}

function flash(?string $msg = null, string $type = 'ok'): ?array
{
    if ($msg !== null) {
        $_SESSION['flash'] = [$type, $msg];
        return null;
    }
    $f = $_SESSION['flash'] ?? null;
    unset($_SESSION['flash']);
    return $f;
}

function paroisses_all(): array
{
    return q('SELECT id, nom, ville FROM paroisses ORDER BY ville, nom')->fetchAll();
}

function paroisse_nom(?int $id): string
{
    if (!$id) return 'Tout le diocèse';
    static $cache = [];
    if (!isset($cache[$id])) {
        $r = q('SELECT nom, ville FROM paroisses WHERE id = ?', [$id])->fetch();
        $cache[$id] = $r ? $r['nom'] . ' (' . $r['ville'] . ')' : '—';
    }
    return $cache[$id];
}

function jours_label(string $csv): string
{
    $d = array_map('intval', array_filter(explode(',', $csv), 'strlen'));
    sort($d);
    if (count($d) === 7) return 'Tous les jours';
    if ($d === [1, 2, 3, 4, 5]) return 'Lundi – vendredi';
    return implode(', ', array_map(fn($x) => JOURS[$x] ?? '?', $d));
}

// ---------- Mise en page ----------

function layout_start(string $titre): void
{
    $u = user();
    $p = $_GET['p'] ?? 'dashboard';
    $nav = [];
    if ($u) {
        $nav = [
            'dashboard' => 'Tableau de bord',
            'messes' => 'Horaires des messes',
            'annonces' => 'Annonces',
            'mouvements' => 'Mouvements',
            'paroisses' => is_diocese() ? 'Paroisses' : 'Fiche de ma paroisse',
        ];
        if (is_diocese()) {
            $nav['paroles'] = 'Parole du jour';
            $nav['users'] = 'Comptes administrateurs';
        }
        $nav['compte'] = 'Mon compte';
    }
    ?><!DOCTYPE html>
<html lang="fr">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title><?= e($titre) ?> — <?= e(APP_NAME) ?></title>
<link rel="stylesheet" href="assets/style.css">
</head>
<body>
<?php if ($u): ?>
<header class="top">
  <a class="brand" href="index.php"><span class="cross">✝</span> <?= e(APP_NAME) ?></a>
  <span class="who"><?= e($u['nom']) ?> · <?= $u['role'] === 'diocese' ? 'Diocèse' : e(paroisse_nom((int)$u['paroisse_id'])) ?>
    · <a href="index.php?p=logout">Se déconnecter</a></span>
</header>
<div class="wrap">
<nav class="side">
<?php foreach ($nav as $k => $l): ?>
  <a href="index.php?p=<?= $k ?>" class="<?= $p === $k ? 'on' : '' ?>"><?= e($l) ?></a>
<?php endforeach; ?>
</nav>
<main>
<?php else: ?>
<div class="center"><main class="narrow">
<?php endif;
    if ($f = flash()) echo '<div class="flash ' . e($f[0]) . '">' . e($f[1]) . '</div>';
    echo '<h1>' . e($titre) . '</h1>';
}

function layout_end(): void
{
    echo user() ? '</main></div>' : '</main></div>';
    echo '</body></html>';
}
