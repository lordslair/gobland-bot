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
        <h1>Enchantor</h1>
        <div id="profilInfos">
        <fieldset>
          <legend>Message Gobland</legend>
          <form method="post" action="enchantor.php">
          <textarea id="search" name="search" rows="5" cols="80"></textarea>
          <input type="submit" value="Go !">
          </form>
        </fieldset>
<?php
    include 'inc.db.php';

    if ( $_GET['delete'] && (preg_match('/^\d*$/', $_GET['delete'])) )
    {
        $item_id      = $_GET['delete'];

        $req_delete_enchant = "DELETE FROM Enchantements WHERE Id = '$item_id'";
        $res_delete_enchant = $db->query($req_delete_enchant);
        print("<center>ID: $item_id supprimé de la DB</center>");
        $db->close;
    }

    if ( $_POST['search'] )
    {
        if     ( preg_match('/Pour enchanter ton objet (.*) \[(\d*)\] j/', $_POST['search'], $matches) )
        {
            # Item to enchant found
            $item = $db->real_escape_string($matches[1]);
            $id   = $matches[2];

            $array = explode(PHP_EOL, $_POST['search']);
            $counter = 0;
            for ($i = 0; $i <= count($array); $i++)
            {
                if ( preg_match('/^([A-Z\'\s]*) (\w*) \[(Mousse|Graine|Racine|Fleur)\]/', $array[$i], $matches_compo) )
                {
                    $counter += 1;
                    $ENCHANT[$counter] = $matches_compo[1];
                    $ENCHANT[$counter] = preg_replace('/\'/', '\'\'', $ENCHANT[$counter]);
                    $counter += 1;
                    $ENCHANT[$counter] = $matches_compo[2];
                }
                elseif ( preg_match('/^(.*) de qualité (.*) \[/u', $array[$i], $matches_compo) )
                {
                    $counter += 1;
                    $ENCHANT[$counter] = $matches_compo[1];
                    $ENCHANT[$counter] = preg_replace('/\'/', '\'\'', $ENCHANT[$counter]);
                    $counter += 1;
                    $ENCHANT[$counter] = $matches_compo[2];
                }
            }

            $req_insert_enchant = "REPLACE
                                   INTO Enchantements
                                   VALUES ('$id',         '$item',
                                           '$ENCHANT[5]', '$ENCHANT[6]',
                                           '$ENCHANT[1]', '$ENCHANT[2]',
                                           '$ENCHANT[3]', '$ENCHANT[4]',
                                           'DOING')";
            $res_insert_enchant = $db->query($req_insert_enchant);
	      print("<center>Enchantement sur <b>[$matches[2]] $matches[1]</b> ajouté en DB</center>");
        }

        if     ( preg_match('/[!]debug[!]/', $_POST['search'], $matches) )
        {
            print_r( $_POST);
        }
    }
    $db->close;
?>
        <fieldset>
          <legend>En cours :</legend>
<?php
    include 'functions.php';

    $req_enchantements   = "SELECT * FROM Enchantements ORDER BY Id";
    $query_enchantements = $db->query($req_enchantements);

    while ($row = $query_enchantements->fetch_array())
    {
        $ok = ' ✅';
        $ko = ' 🔴';
        $delete = ' <a href="/enchantor.php?delete='.$row[0].'" title="Supprimer">[🚫]</a>';
        $p_ok  = '';
        $c1_ok = '';
        $c2_ok = '';

        $c1_ok = GetCompo('Composant',$row[4],$row[5]);
        $c2_ok = GetCompo('Composant',$row[6],$row[7]);
        $p_ok  = GetCompo('Plante',   $row[2],$row[3]);

        print('            <li>'.$delete.'['.$row[0].'] '.$row[1]."\n");
        print('              <ul style="margin: 4px;"><img src="/images/stuff/icon_102.png" title="Composant"> '.$row[4].' '.$row[5].$c1_ok.'</ul>'."\n");
        print('              <ul style="margin: 4px;"><img src="/images/stuff/icon_102.png" title="Composant"> '.$row[6].' '.$row[7].$c2_ok.'</ul>'."\n");
        print('              <ul style="margin: 4px;"><img src="/images/stuff/icon_1173.png" title="Fleur"> '.$row[2].' '.$row[3].$p_ok.'</ul>'."\n");
        print('            </li>'."\n");
    }
    $db->close;
?>
        </fieldset>
        <fieldset>
          <legend>Komenonfé ?</legend>
          - Tu entres le message de l'Enchanteur AU COMPLET<br>
          - Il va commencer par "Pour enchanter ton objet ..."<br>
          - Il va finir par les 3 lignes d'ingrédients (2 compos, 1 plante)<br>
          <br>
          - La recherche est faite dans l'inventaire <b>du Clan</b>, et dans ses Cavernes<br>
          - 🔴, l'ingrédient n'a pas été trouvé dans le stock<br>
          - ✅, l'ingrédient a été trouvé dans le stock<br>
          <br>
          - Quand un enchantement est réalisé, le supprimer en cliquant sur 🚫<br>
        </fieldset>
      </div> <!-- content -->
    </div> <!-- page -->
  </body>
</html>
