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
        <h1>Wanted 🎯</h1>
        <div id="profilInfos">
        <fieldset>
          <legend>Kestucherches ?</legend>
          <form method="post" action="wanted.php">
          <input type="text" id="search" name="search" size="80"></textarea>
          <input type="submit" value="Go !">
          </form>
        </fieldset>
<?php
    include 'inc.db.php';

    if ( $_GET['delete'] && (preg_match('/^\d*$/', $_GET['delete'])) )
    {
        $item_id      = $_GET['delete'];

        $req_delete_wanted = "DELETE FROM Wanted WHERE Id = '$item_id'";
        $res_delete_wanted = $db->query($req_delete_wanted);
        print("<center>ID: $item_id supprimé de la DB</center>");
        $db->close;
    }

    if ( $_POST['search'] )
    {

        # Level selector
        if ( preg_match('/(level):(\d*)[.][.](\d*)\s?/', $_POST['search'], $matches) )
        {
            $min = min($matches[2],$matches[3]);
            $max = max($matches[2],$matches[3]);
        }
        elseif ( preg_match("/(level):(\d*)\s?/", $_POST['search'], $matches) )
        {
            $min = $matches[2];
            $max = $matches[2];
        }

        # Gobelin/Monstre selector
        if ( preg_match('/@(gobelin|monstre):[\'"]([\w\s]*)[\'"]\s?/u', $_POST['search'], $matches) )
        {
            $type = $matches[2];
        }
        elseif ( preg_match('/@(gobelin|monstre):([\w]*)\s?/u', $_POST['search'], $matches) )
        {
            $type = $matches[2];
        }

        if ( $type )
        {
            if ( ($min) and ($max) )
            {
                $req_wanted   = "INSERT INTO Wanted (Target,NivMin,NivMax) VALUES ('$type', '$min', '$max')";
            }
            else
            {
                $req_wanted   = "INSERT INTO Wanted (Target) VALUES ('$type')";
            }
            $query_wanted = $db->query($req_wanted);
        }

        # DEBUG selector
        if     ( preg_match('/[!]debug[!]/', $_POST['search'], $matches) )
        {
            print($req_wanted."<br>");
            print_r( $_POST);
        }

    }
    $db->close;
?>
        <fieldset>
          <legend>En cours :</legend>
<?php
    include 'functions.php';

    $req_wanted   = "SELECT * FROM Wanted ORDER BY Id";
    $query_wanted = $db->query($req_wanted);

    while ($row = $query_wanted->fetch_assoc())
    {
        $ok = ' ✅';
        $ko = ' 🔴';
        $delete = ' <a href="/wanted.php?delete='.$row['Id'].'" title="Supprimer">[🚫]</a>';

        if (($row['NivMin']) and ($row['NivMax']))
        {
            $req_search    = "SELECT COUNT(*)
                              FROM `Vue`
                              WHERE ( Niveau BETWEEN '".$row['NivMin']."' AND '".$row['NivMax']."' )
                              AND   ( Type = '".$row['Target']."' OR Nom = '".$row['Target']."' )";
            $count         = $db->query($req_search, true)->fetch_row()[0];

            if ( $count > 0 ) { $icon = $ok; } else { $icon = $ko; }

            print('            <li>'.$delete.' '.$icon.' '.$row['Target'].' de niveau '.$row['NivMin'].' à '.$row['NivMax']."\n");
        }
        else
        {
            $req_search    = "SELECT COUNT(*)
                              FROM `Vue`
                              WHERE ( Type = '".$row['Target']."' OR Nom = '".$row['Target']."' )";
            $count         = $db->query($req_search, true)->fetch_row()[0];

            if ( $count > 0 ) { $icon = $ok; } else { $icon = $ko; }

            print('            <li>'.$delete.' '.$icon.' '.$row['Target'].' de tout niveau'."\n");
        }

        print('            </li>'."\n");
    }
    $db->close;
?>
        </fieldset>
        <fieldset>
          <legend>Komenonfé ?</legend>
          - Tu entres le nom de ce que tu cherches, comme dans locator<br>
          - Si c'est un nom composé, entre le entre quotes<br>
          - Exemple pour placer un wanted : <b>@monstre:Strige</b><br>
          - Exemple pour placer un wanted complexe : <b>@monstre:"Arbre à gobelins" @level:4..6</b><br>
          - Tu peux en ajouter autant que tu veux<br>
          <br>
          - La recherche est faite dans la vue <b>du Clan</b><br>
          - 🔴, la cible n'a pas été trouvée dans la vue actuelle<br>
          - ✅, la cible a été trouvée dans la vue actuelle<br>
          <br>
          - Si tu souhaites supprimer une recherche, le supprimer en cliquant sur 🚫<br>
          <br>
          - Dans ta page de Vue, tu verras les 'Wanted' marquées d'un 🎯 sur la carte<br>
        </fieldset>
      </div> <!-- content -->
    </div> <!-- page -->
  </body>
</html>
