<?php include 'inc.session.php'; ?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
  <head>
<?php include 'inc.head.php'; ?>
  </head>
  <body>
    <div id="page">
      <div id="header">
<?php include 'inc.header.php'; ?>
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
    include 'inc.db.php';

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

                    $req_insert_gob = "REPLACE INTO Credentials VALUES ('$gob_pass', '$gob_id', '$pass_type')";
                    $res_insert_gob = $db->query($req_insert_gob);
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
            $res_delete_gob = $db->query($req_delete_gob);
            print("<center>ID: $gob_id supprimé de la DB</center>");
            $db->close;
        }
    }

    print('        <fieldset>'."\n");
    print('          <legend>Gobelins pr..sents en DB</legend>'."\n");

    $req_credentials   = "SELECT Id,Type,Hash FROM Credentials ORDER BY Type,Id";
    $query_credentials = $db->query($req_credentials);

    print('          <table cellspacing="0" id="trollsList">'."\n");
    print('            <tr>'."\n");
    print('              <th>ID</th>'."\n");
    print('              <th>Type</th>'."\n");
    print('              <th>Hash</th>'."\n");
    print('              <th>Actions</th>'."\n");
    print('            </tr>'."\n");

    while ($row = $query_credentials->fetch_array())
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
    print('          </table>'."\n");

    $db->close;
?>
        </fieldset>
      </div> <!-- content -->
    </div> <!-- page -->
  </body>
</html>
