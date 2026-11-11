<?php
declare(strict_types=1);

// Installation guidée : à ouvrir une seule fois après la mise en ligne.

require __DIR__ . '/inc/bootstrap.php';
require __DIR__ . '/inc/schema.php';
start_session();

$erreur = null;
$configAColler = null;

if (config()) {
    layout_start('Installation déjà faite');
    echo '<p>Le back-office est installé. <a href="index.php">Se connecter</a>.</p>';
    echo '<p class="muted">Pour réinstaller, supprimez le fichier <code>config.php</code> sur le serveur.</p>';
    layout_end();
    exit;
}

$v = fn(string $k, string $d = '') => trim((string)($_POST[$k] ?? $d));

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    check_csrf();
    $cfg = [
        'driver' => 'mysql',
        'host' => $v('host', 'localhost'),
        'port' => (int)$v('port', '3306'),
        'name' => $v('name'),
        'user' => $v('user'),
        'pass' => (string)($_POST['pass'] ?? ''),
    ];
    $admin = ['nom' => $v('admin_nom'), 'email' => $v('admin_email'), 'password' => (string)($_POST['admin_password'] ?? '')];

    if ($cfg['name'] === '' || $cfg['user'] === '') {
        $erreur = 'Indiquez le nom de la base et l\'utilisateur MySQL.';
    } elseif ($admin['nom'] === '' || !filter_var($admin['email'], FILTER_VALIDATE_EMAIL)) {
        $erreur = 'Indiquez votre nom et une adresse e-mail valide.';
    } elseif (strlen($admin['password']) < 10) {
        $erreur = 'Le mot de passe doit contenir au moins 10 caractères.';
    } elseif ($admin['password'] !== ($_POST['admin_password2'] ?? '')) {
        $erreur = 'Les deux mots de passe ne sont pas identiques.';
    } else {
        try {
            $pdo = make_pdo($cfg);
            install_run($pdo, 'mysql', $admin, !empty($_POST['exemples']));
            $php = "<?php\n// Configuration du back-office. Ne pas partager ce fichier.\nreturn " . var_export($cfg, true) . ";\n";
            if (@file_put_contents(CONFIG_FILE, $php) === false) {
                $configAColler = $php;
            } else {
                flash('Installation terminée. Connectez-vous avec le compte que vous venez de créer.');
                redirect('index.php?p=login');
            }
        } catch (PDOException $ex) {
            $erreur = 'Connexion à la base impossible : vérifiez les informations MySQL. (' . $ex->getMessage() . ')';
        }
    }
}

layout_start('Installation du back-office');

if ($configAColler !== null) {
    echo '<div class="flash warn">Les tables sont créées, mais le serveur n\'a pas pu écrire le fichier de configuration.</div>';
    echo '<p>Dans le gestionnaire de fichiers Hostinger, créez un fichier <code>config.php</code> à côté de <code>install.php</code> et collez-y ce contenu :</p>';
    echo '<pre class="code">' . e($configAColler) . '</pre>';
    echo '<p><a class="btn" href="index.php?p=login">J\'ai créé le fichier, me connecter</a></p>';
    layout_end();
    exit;
}

if ($erreur) echo '<div class="flash err">' . e($erreur) . '</div>';
?>
<p class="muted">Étape unique. Les informations MySQL se trouvent dans hPanel → Bases de données → Gestion.</p>
<form method="post" class="form">
  <?= csrf_field() ?>
  <h2>Base de données MySQL</h2>
  <label>Hôte<input name="host" value="<?= e($v('host', 'localhost')) ?>" required></label>
  <label>Port<input name="port" value="<?= e($v('port', '3306')) ?>" required></label>
  <label>Nom de la base<input name="name" value="<?= e($v('name')) ?>" placeholder="u123456789_diocese" required></label>
  <label>Utilisateur<input name="user" value="<?= e($v('user')) ?>" placeholder="u123456789_admin" required></label>
  <label>Mot de passe MySQL<input type="password" name="pass" autocomplete="off"></label>

  <h2>Premier compte (équipe du diocèse)</h2>
  <label>Votre nom<input name="admin_nom" value="<?= e($v('admin_nom')) ?>" required></label>
  <label>E-mail<input type="email" name="admin_email" value="<?= e($v('admin_email')) ?>" required></label>
  <label>Mot de passe (10 caractères minimum)<input type="password" name="admin_password" minlength="10" required autocomplete="new-password"></label>
  <label>Confirmer le mot de passe<input type="password" name="admin_password2" minlength="10" required autocomplete="new-password"></label>
  <label class="check"><input type="checkbox" name="exemples" value="1" checked> Ajouter 4 paroisses d'exemple (modifiables ou supprimables ensuite)</label>
  <button class="btn">Installer</button>
</form>
<?php
layout_end();
