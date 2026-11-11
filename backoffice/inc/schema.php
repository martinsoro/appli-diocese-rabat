<?php
declare(strict_types=1);

// Création des tables et du premier compte administrateur.

function schema_sql(string $driver): array
{
    $mysql = $driver !== 'sqlite';
    $id = $mysql ? 'INT UNSIGNED AUTO_INCREMENT PRIMARY KEY' : 'INTEGER PRIMARY KEY AUTOINCREMENT';
    $fk = $mysql ? 'INT UNSIGNED' : 'INTEGER';
    $end = $mysql ? ' ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci' : '';
    $now = $mysql ? 'DEFAULT CURRENT_TIMESTAMP' : "DEFAULT (datetime('now'))";
    return [
        "CREATE TABLE IF NOT EXISTS paroisses (
            id $id,
            slug VARCHAR(80) NOT NULL UNIQUE,
            nom VARCHAR(160) NOT NULL,
            ville VARCHAR(80) NOT NULL,
            adresse VARCHAR(255) NULL,
            lat DOUBLE NULL,
            lon DOUBLE NULL,
            telephone VARCHAR(40) NULL,
            email VARCHAR(160) NULL,
            confessions VARCHAR(255) NULL,
            actif TINYINT NOT NULL DEFAULT 1
        )$end",
        "CREATE TABLE IF NOT EXISTS users (
            id $id,
            email VARCHAR(160) NOT NULL UNIQUE,
            nom VARCHAR(120) NOT NULL,
            password_hash VARCHAR(255) NOT NULL,
            role VARCHAR(20) NOT NULL DEFAULT 'paroisse',
            paroisse_id $fk NULL,
            actif TINYINT NOT NULL DEFAULT 1,
            created_at DATETIME $now,
            FOREIGN KEY (paroisse_id) REFERENCES paroisses(id) ON DELETE SET NULL
        )$end",
        "CREATE TABLE IF NOT EXISTS messes (
            id $id,
            paroisse_id $fk NOT NULL,
            jours VARCHAR(20) NOT NULL,
            heure VARCHAR(5) NOT NULL,
            langue VARCHAR(4) NOT NULL DEFAULT 'FR',
            note VARCHAR(160) NULL,
            FOREIGN KEY (paroisse_id) REFERENCES paroisses(id) ON DELETE CASCADE
        )$end",
        "CREATE TABLE IF NOT EXISTS annonces (
            id $id,
            paroisse_id $fk NULL,
            titre VARCHAR(160) NOT NULL,
            texte TEXT NOT NULL,
            date_pub DATE NOT NULL,
            notifier TINYINT NOT NULL DEFAULT 0,
            auteur_id $fk NULL,
            created_at DATETIME $now,
            FOREIGN KEY (paroisse_id) REFERENCES paroisses(id) ON DELETE CASCADE
        )$end",
        "CREATE TABLE IF NOT EXISTS mouvements (
            id $id,
            paroisse_id $fk NULL,
            nom VARCHAR(160) NOT NULL,
            type VARCHAR(60) NULL,
            quand VARCHAR(120) NULL,
            description TEXT NULL,
            contact_email VARCHAR(160) NULL,
            FOREIGN KEY (paroisse_id) REFERENCES paroisses(id) ON DELETE CASCADE
        )$end",
        "CREATE TABLE IF NOT EXISTS paroles (
            id $id,
            jour DATE NOT NULL UNIQUE,
            reference VARCHAR(120) NOT NULL,
            verset TEXT NOT NULL,
            saint VARCHAR(160) NULL,
            saint_bio TEXT NULL,
            lectures TEXT NULL
        )$end",
        "CREATE TABLE IF NOT EXISTS tentatives (
            id $id,
            ip VARCHAR(64) NOT NULL,
            at INT NOT NULL
        )$end",
    ];
}

function install_run(PDO $pdo, string $driver, array $admin, bool $exemples): void
{
    foreach (schema_sql($driver) as $sql) $pdo->exec($sql);

    if ($exemples && (int)$pdo->query('SELECT COUNT(*) FROM paroisses')->fetchColumn() === 0) {
        $par = [
            ['Cathédrale Saint-Pierre', 'Rabat', 34.02, -6.84, [['0', '09:00', 'FR'], ['0', '11:00', 'FR'], ['0', '17:00', 'EN'], ['6', '18:30', 'FR'], ['1,2,3,4,5', '18:30', 'FR']]],
            ['Notre-Dame de Lourdes', 'Casablanca', 33.58, -7.62, [['0', '08:30', 'FR'], ['0', '10:30', 'FR'], ['0', '12:30', 'EN'], ['6', '19:00', 'FR']]],
            ["Saint-François d'Assise", 'Fès', 34.03, -5.00, [['0', '10:00', 'FR'], ['0', '18:00', 'EN']]],
            ['Église des Saints-Martyrs', 'Marrakech', 31.63, -8.01, [['0', '10:30', 'FR'], ['0', '18:30', 'EN'], ['6', '18:30', 'FR']]],
        ];
        $insP = $pdo->prepare('INSERT INTO paroisses (slug, nom, ville, lat, lon, confessions) VALUES (?, ?, ?, ?, ?, ?)');
        $insM = $pdo->prepare('INSERT INTO messes (paroisse_id, jours, heure, langue) VALUES (?, ?, ?, ?)');
        foreach ($par as [$nom, $ville, $lat, $lon, $messes]) {
            $insP->execute([slugify($nom . '-' . $ville), $nom, $ville, $lat, $lon, 'À compléter']);
            $pid = (int)$pdo->lastInsertId();
            foreach ($messes as [$j, $h, $l]) $insM->execute([$pid, $j, $h, $l]);
        }
        $pdo->prepare('INSERT INTO annonces (paroisse_id, titre, texte, date_pub) VALUES (NULL, ?, ?, ?)')
            ->execute(['Bienvenue', "L'application du diocèse est en cours de mise en place. Les données sont des exemples.", date('Y-m-d')]);
    }

    $pdo->prepare('INSERT INTO users (email, nom, password_hash, role, paroisse_id) VALUES (?, ?, ?, ?, NULL)')
        ->execute([strtolower(trim($admin['email'])), trim($admin['nom']), password_hash($admin['password'], PASSWORD_DEFAULT), 'diocese']);
}
