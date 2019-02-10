<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
  <head>
<?php
    print ('<title>Gobland-IT ('.$_ENV["CLANID"].') '.$_ENV["CLANNAME"].'</title>');
?>
    <link rel="stylesheet" type="text/css" href="/style/common.css" />
    <link rel="stylesheet" type="text/css" href="/style/menu.css" />
    <link rel="stylesheet" type="text/css" href="/style/tt_r.css" />
    <script type="text/javascript" src="/js/common.js"></script>
    <script type="text/javascript" src="/js/domcollapse.js"></script>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
  </head>
  <body>
    <div id="page">
      <div id="header">
        <br><br><br><br><br><br><br><br>
        <div id="nav">
          <ul id="menu">
            <li><a href="/index.php" title="Page d'accueil">Accueil</a></li>
            <li><a href="#">Consulter</a>
              <ul>
                <li><a href="/equipements.php" title="Équipement des Gob' du Clan">Équipement du Clan</a></li>
                <li><a href="/materiaux.php" title="Matériaux des Gob' du Clan">Matériaux du Clan</a></li>
                <li><a href="/composants.php" title="Composants des Gob' du Clan">Composants du Clan</a></li>
                <li><a href="/cavernes.php" title="Cavernes du Clan">Cavernes du Clan</a></li>
              </ul>
            </li>
            <li><a href="" title="">Outils</a>
              <ul>
                <li><a href="/pxbank.php" title="PX Bank du Clan">PX Bank</a></li>
                <li><a href="/gps.php" title="GPS">GPS</a></li>
                <li><a href="/radar.php" title="Radar">Radar</a></li>
                <li><a href="/cdm.php" title="CdM">CdM Collector</a></li>
              </ul>
            </li>
            <li><a href="" title="">Liens</a>
              <ul>
                <li><a href="/admin.php" title="Admin">Admin</a></li>
              </ul>
            </li>
          </ul>
        </div>
      </div>
      <div id="content">
        <h1>Page d'administration</h1>
        <div id="profilInfos">
        <fieldset>
          <legend>Ajout d'un gobelin</legend>
          <form method="post" action="admin.php">
          <strong>ID</strong> : <input type="text" id="id" name="id" maxlength="6" size="10">
          <strong>Type de mot de passe</strong> :
            <select id="type" name="type">
              <option value="perso">Perso</option> 
              <option value="clan" selected>Clan</option>
              <option value="meute">Meute</option>
            </select>
          <strong>Mot de passe</strong> : <input type="text" id="pass" name="pass" maxlength="32" size="35">
          <input type="submit" value="Go !">
          </form>
        </fieldset>
<?php
    include 'functions.php';
    include 'queries.php';

    $db_file = '/db/'.$_ENV["DBNAME"];
    $db      = new SQLite3($db_file);
    if(!$db) { echo $db->lastErrorMsg(); }

    if ( $_POST['id'] && $_POST['type'] && $_POST['pass'] )
    {
        if ( preg_match('/^\d*$/', $_POST['id']) )
        {
            if ( preg_match('/perso|clan|meute/', $_POST['type']) )
            {
                if ( preg_match('/\w*/', $_POST['pass']) && strlen($_POST['pass']) == 32 )
                {
                    $gob_id    = $_POST['id'];
                    $gob_pass  = $_POST['pass'];
                    $pass_type = $_POST['type'];

                    $req_insert_gob = "INSERT OR REPLACE INTO Credentials VALUES ('$gob_pass', '$gob_id', '$pass_type')";
                    $res_insert_gob = $db->exec($req_insert_gob);
                    print("<center>ID: $gob_id ajouté en DB</center>");
                    $db->close;
                }
                else
                {
                    print("Mauvais format de password Gob<br>");
                }
            }
            else
            {
                print("Mauvais type de password Gob<br>");
            }
        }
        else
        {
            print("Mauvais format pour l'ID Gob<br>");
        }
    }
    else
    {
        # Pas match criteres
    }

    if ( $_GET['action'] == 'delete' )
    {
        if ( preg_match('/^\d*$/', $_GET['id']) && preg_match('/perso|clan|meute/', $_GET['type']) )
        {
            $gob_id    = $_GET['id'];
            $pass_type = $_GET['type'];
            $req_delete_gob = "DELETE FROM Credentials WHERE Id = '$gob_id' AND Type = '$pass_type'";
            $res_delete_gob = $db->exec($req_delete_gob);
            print("<center>ID: $gob_id supprimé de la DB</center>");
            $db->close;
        }
    }
?>
        <fieldset>
          <legend>Gobelins présents en DB</legend>
<?php

    $req_credentials   = "SELECT Id,Type,Hash FROM Credentials ORDER BY Type,Id";
    $query_credentials = $db->query($req_credentials);

    print('          <table cellspacing="0" id="trollsList">'."\n");
    print('            <tr>'."\n");
    print('              <th>ID</th>'."\n");
    print('              <th>Type</th>'."\n");
    print('              <th>Hash</th>'."\n");
    print('              <th>Actions</th>'."\n");
    print('            </tr>'."\n");
    while ($row = $query_credentials->fetchArray())
    {
        $id   = $row[0];
        $type = $row[1];
        $hash = $row[2];
        $hash = preg_replace('/\w/', '*', $hash, 24);
        print('            <tr>'."\n");
        print("              <td>$id</td>"."\n");
        print("              <td>$type</td>"."\n");
        print("              <td>$hash</td>"."\n");
        print('              <td><a href="/admin.php?action=delete&id='.$id.'&type='.$type.'" title="Supprimer">🚫</a></td>'."\n");
        print('            <tr>'."\n");
    }
    $db->close;
    print('          </table>'."\n");
?>
        </fieldset>
      </div> <!-- content -->
    </div> <!-- page -->
  </body>
</html>
