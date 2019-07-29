<?php
require_once 'inc.db.php';

$req_lastupdate   = "SELECT Date FROM `Carte` ORDER BY `Carte`.`Time` DESC LIMIT 1";
$lastupdate = $db->query($req_lastupdate)->fetch_row()[0];

$update  = "[MàJ: $lastupdate]";
$gobelin = '[Gobelin: <b>'.$_SESSION["gob_name"].'</b>]';
$clan    = '[Clan: <b>'.$_SESSION["gob_clan"].'</b>]';
$logout  = '[<a href="/logout.php" title="Déconnexion">🚫 Déconnexion</a>]';

print('        <div class="footer">'."$gobelin - $clan - $update <br> $logout".'</div>'."\n");
?>
