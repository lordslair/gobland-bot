<?php
require_once 'inc.db.php';

$req_lastupdate   = "SELECT Date FROM `MPBot` ORDER BY `MPBot`.`Date` DESC LIMIT 1";
$lastupdate = $db->query($req_lastupdate)->fetch_row()[0];

$update  = "[MàJ: $lastupdate]";
$gobelin = '[Gobelin: <b>'.$_SESSION["gob_name"].'</b>]';
$clan    = '[Clan: <b>'.$_SESSION["gob_clan"].'</b>]';
$logout  = '[<a href="/logout.php" title="Déconnexion">🚫 Déconnexion</a>]';
$reset   = '[<a href="/reset.php" title="Reset">🔐 Modifier</a>]';

print('        <div class="footer">'."$gobelin - $clan - $update <br> $logout - $reset".'</div>'."\n");
?>
