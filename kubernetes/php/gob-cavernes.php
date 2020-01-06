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
        <link href="/style/cavernes.css"  rel="stylesheet" type="text/css"  />
<?php
    include 'inc.db.php';
    include 'inc.var.php';
    include 'functions.php';

    if ( $_SESSION["gob_name"] )
    {
        if ( preg_match('/^\d*$/', $_SESSION["gob_name"]) )
        {
            $gob_id = $_SESSION["gob_name"];

            $req_gob_nom       = "SELECT Gobelin FROM Gobelins WHERE Id = '$gob_id'";
            $gob_nom           = $db->query($req_gob_nom)->fetch_row()[0];
        }
        else
        {
            $gob_nom = $_SESSION["gob_name"];

            $req_gob_id       = "SELECT Gobelin FROM Gobelins WHERE Gobelin = '$gob_nom'";
            $gob_id           = $db->query($req_gob_id)->fetch_row()[0];
        }
    }
    else
    {
        print("<center>Cet ID n'est pas valide</center>"."\n");
        goto end;
    }

    print('        <h1>Possessions des Cavernes de '.$gob_nom.'</h1>'."\n");

    print('        <center>'."\n");
    print('          Afficher les Non Identifiés : '."\n");
    print('          <a href="/cavernes.php?IdT=TRUE" title="Afficher les non-IdT">[🔎]</a>'."\n");
    print('          <br>'."\n");
    print('          Retirer les Non Identifiés : '."\n");
    print('          <a href="/cavernes.php"          title="Retirer les non-IdT">[🚫]</a>'."\n");
    print('        <center>'."\n");
?>
        <table cellspacing="0" id="profilInfos" style="border-style:none;">
          <!-- Équipement -->
          <tr class="expanded">
            <th style="border-style:none;">Équipements</th>
          </tr>
          <tr style="border-style:none;">
            <td style="border-style:none;">
<?php
    $arr_equipements = ['Arme 1 Main', 'Arme 2 mains', 'Anneau', 'Armure', 'Baguette', 'Bijou', 'Bottes', 'Bouclier', 'Casque', 'Nourriture','Outil', 'Potion', 'Talisman'];
    $arr_count_e     = [];

    print('              <table cellspacing="0" id="stuff">'."\n");
    print('                <thread>'."\n");
    print('                  <tr>'."\n");
    print('                    <th style="cursor: pointer;" data-sort-method="default">Type</th>'."\n");
    print('                    <th style="cursor: pointer;" data-sort-method="number">ID</th>'."\n");
    print('                    <th style="cursor: pointer;" data-sort-method="default">Nom (Description)</th>'."\n");
    print('                    <th style="cursor: pointer;" data-sort-method="number">Poids</th>'."\n");
    print('                    <th style="cursor: pointer;" data-sort-method="default">Infos</th>'."\n");
    print('                    <th style="cursor: pointer;" data-sort-method="default">Reservé</th>'."\n");
    print('                    <th style="cursor: pointer;" data-sort-method="number">Prix</th>'."\n");
    print('                    <th style="cursor: pointer;" data-sort-method="default">Lieu</th>'."\n");
    print('                  </tr>'."\n");
    print('                </thread>'."\n");
    print('                <tbody id="stuff">'."\n");

    foreach ($arr_equipements as $equipement)
    {
        $req_equipement   = "SELECT Id,Type,Identifie,Nom,Magie,`Desc`,Poids,Taille,Qualite,Localisation,Utilise,Prix,Reservation,Matiere
                             FROM   Cavernes
                             WHERE  Type = '$equipement' AND IdGob = '$gob_id'
                             ORDER  BY Type,Nom;";
        $query_equipement = $db->query($req_equipement);

        $item_png = GetStuffIcon($equipement,$nom);

        while ($row = $query_equipement->fetch_array())
        {
            $item_id   = $row[0];
            $item_type = $row[1];
            $nom       = $row[3];
            $template  = '<b>'.$row[4].'</b>';
            $desc      = $row[5];
            $min       = sprintf("%.1f", $row[6]/60).' min';
            $luxe      = GetLuxe($item_type,$nom,$desc);
            $craft     = GetCraft($item_type,$nom,$desc,$row[4]);
            $prix      = '';
            $reserve   = '';
            $info      = $luxe.' '.$craft;
            $loc       = $row[9];

            if ( $row[11] > 0                ) { $prix      = $row[11]; }
            if ( $row[12] != 'Tout le monde' ) { $reserve   = $row[12]; }
            if ( $row[13]                    ) { $nom .= ' en '.$row[13]; } # Fix for 'en Pierre' equipements

            $arr_count_e["$equipement"]++;

            if ( $desc != '<b>Non identifié</b>' or $_GET["IdT"] == 'TRUE' )
            {
                print('                  <tr>'."\n");
                print('                   <td>'.$item_png.'</td>'."\n");
                print('                   <td>['.$item_id.']</td>'."\n");
                print('                   <td>'.$nom.' '.$template.' ('.$desc.')</td>'."\n");
                print('                   <td>'.$min.'</td>'."\n");
                print('                   <td>'.$info.'</td>'."\n");
                print('                   <td>'.$reserve.'</td>'."\n");
                print('                   <td>'.$prix.'</td>'."\n");
                print('                   <td>'.$loc.'</td>'."\n");
                print('                  </tr>'."\n");
            }
        }
    }
        print('                </tbody>'."\n");
        print('              </table>'."\n");

    $db->close;
?>
            </td>
          </tr>

          <!-- Block with count of pieces of equipement -->
          <tr>
            <td>
<?php
    foreach ($arr_equipements as $equipement)
    {
        $item_png = GetStuffIcon($equipement, '');
        print('              '.$item_png.' ('.$arr_count_e["$equipement"].') '."\n");
    }
?>
            </td>
          </tr>
          <!-- /Block with count of pieces of equipement -->
          <!-- /Équipement -->

          <!-- Composants -->
          <tr class="expanded">
            <th style="border-style:none;">Composants</th>
          <tr style="border-style:none;">
            <td style="border-style:none;">

<?php
    include 'inc.db.php';

    $arr_composants = ['Composant', 'Fleur', 'Racine', 'Champignon'];
    $arr_count_c    = [];

    print('              <table cellspacing="0" id="composants">'."\n");
    print('                <thread>'."\n");
    print('                  <tr>'."\n");
    print('                    <th style="cursor: pointer;" data-sort-method="default">Type</th>'."\n");
    print('                    <th style="cursor: pointer;" data-sort-method="number">ID</th>'."\n");
    print('                    <th style="cursor: pointer;" data-sort-method="default">Nom (Description)</th>'."\n");
    print('                    <th style="cursor: pointer;" data-sort-method="number">Poids</th>'."\n");
    print('                    <th style="cursor: pointer;" data-sort-method="default">Infos</th>'."\n");
    print('                    <th style="cursor: pointer;" data-sort-method="default">Reservé</th>'."\n");
    print('                    <th style="cursor: pointer;" data-sort-method="number">Prix</th>'."\n");
    print('                    <th style="cursor: pointer;" data-sort-method="default">Lieu</th>'."\n");
    print('                  </tr>'."\n");
    print('                </thread>'."\n");
    print('                <tbody id="composants">'."\n");

    foreach ($arr_composants as $composant)
    {
        $req_composant = "SELECT Id,Type,Identifie,Nom,Magie,`Desc`,Poids,Taille,Qualite,Localisation,Utilise,Prix,Reservation,Matiere
                          FROM   Cavernes
                          WHERE  Type = '$composant' AND IdGob = '$gob_id'
                          ORDER  BY Nom;";
        $query_composant = $db->query($req_composant);

        $item_png = GetMateriauIcon($composant);

        while ($row = $query_composant->fetch_array())
        {
            $item_id  = $row[0];
            $nom      = $row[3];
            $min      = sprintf("%.1f", $row[6]/60).' min';
            $desc     = GetQualite('Composant', $row[8]);
            $loc      = $row[9];
            $prix     = '';
            $reserve  = '';

            if ( $row[11] > 0                ) { $prix      = $row[11]; }
            if ( $row[12] != 'Tout le monde' ) { $reserve   = $row[12]; }

            $arr_count_c["$composant"]++;

            if ( $desc != '<b>Non identifié</b>')
            {
                print('                  <tr>'."\n");
                print('                   <td>'.$item_png.'</td>'."\n");
                print('                   <td>['.$item_id.']</td>'."\n");
                print('                   <td>'.$nom.' ('.$desc.')</td>'."\n");
                print('                   <td>'.$min.'</td>'."\n");
                print('                   <td></td>'."\n");
                print('                   <td>'.$reserve.'</td>'."\n");
                print('                   <td>'.$prix.'</td>'."\n");
                print('                   <td>'.$loc.'</td>'."\n");
                print('                  </tr>'."\n");
            }

        }
    }

    print('                </tbody>'."\n");
    print('              </table>'."\n");

    $db->close;
?>
            </td>
          </tr>

          <!-- Block with count of Composants -->
          <tr>
            <td>
<?php
    foreach ($arr_composants as $composant)
    {
        $item_png = GetMateriauIcon($composant, '');
        print('              '.$item_png.' ('.$arr_count_c["$composant"].') '."\n");
    }
?>
            </td>
          </tr>
          <!-- /Block with count of Composants -->
          <!-- /Composants -->

          <!-- Matériaux -->
          <tr class="expanded">
            <th style="border-style:none;">Matériaux</th>
          </tr>
          <tr style="border-style:none;">
            <td style="border-style:none;">

<?php
    include 'inc.db.php';

    $arr_minerais  = ["Minerai d''Or", 'Minerai de Cuivre', "Minerai d''Argent", "Minerai d''Etain", 'Minerai de Mithril', "Minerai d''Adamantium", 'Minerai de Fer'];
    $arr_materiaux = ['Cuir', 'Tissu', 'Rondin'];
    $arr_roches    = ['Pierre', 'Tas de Terre', 'Sable', 'Minerai de Titane', 'Minerai de Pétrole'];
    $arr_pierres   = ['Diamant', 'Emeraude', 'Obsidienne', 'Opale', 'Rubis', 'Saphir'];
    $arr_items     = array_merge($arr_minerais, $arr_materiaux, $arr_roches, $arr_pierres);
    $arr_count_i   = [];

    print('              <table cellspacing="0" id="materiaux">'."\n");
    print('                <thread>'."\n");
    print('                  <tr>'."\n");
    print('                    <th style="cursor: pointer;" data-sort-method="default">Type</th>'."\n");
    print('                    <th style="cursor: pointer;" data-sort-method="number">ID</th>'."\n");
    print('                    <th style="cursor: pointer;" data-sort-method="default">Nom (Description)</th>'."\n");
    print('                    <th style="cursor: pointer;" data-sort-method="number">Carats</th>'."\n");
    print('                    <th style="cursor: pointer;" data-sort-method="number">Poids</th>'."\n");
    print('                    <th style="cursor: pointer;" data-sort-method="default">Infos</th>'."\n");
    print('                    <th style="cursor: pointer;" data-sort-method="default">Reservé</th>'."\n");
    print('                    <th style="cursor: pointer;" data-sort-method="number">Prix</th>'."\n");
    print('                    <th style="cursor: pointer;" data-sort-method="default">Lieu</th>'."\n");
    print('                  </tr>'."\n");
    print('                </thread>'."\n");
    print('                <tbody id="materiaux">'."\n");

    foreach ($arr_items as $item)
    {
        $req_items = "SELECT Id,Type,Identifie,Nom,Magie,`Desc`,Poids,Taille,Qualite,Localisation,Utilise,Prix,Reservation,Matiere
                      FROM   Cavernes
                      WHERE  Nom = '$item' AND IdGob = '$gob_id'
                      ORDER  BY Nom;";
        $query_items = $db->query($req_items);

        $item     = preg_replace('/\'\'/', '\'', $item);
        $item_png = GetMateriauIcon($item);

        while ($row = $query_items->fetch_array())
        {
            $item_id   = $row[0];
            $item_type = $row[1];
            $nom       = $row[3];
            $min       = sprintf("%.1f", $row[6]/60).' min';
            $desc      = GetQualite($item_type, $row[8]);
            $nbr       = $row[7];
            $carats    = GetCarats($row[8],$nbr);
            $loc       = $row[9];
            $prix      = '';
            $reserve   = '';

            if ( $row[11] > 0                ) { $prix      = $row[11]; }
            if ( $row[12] != 'Tout le monde' ) { $reserve   = $row[12]; }

            $arr_count_i["$item"]++;

            if ( $item == 'Rondin' )
            {
                $arr_count_i["$item"] = $arr_count_i["$item"] + $nbr;
                $carats = $row[7];
            }
            else
            {
                $arr_count_i["$item"] = $arr_count_i["$item"] + $carats;
            }

            if ( $desc != '<b>Non identifié</b>')
            {
                print('                  <tr>'."\n");
                print('                   <td>'.$item_png.'</td>'."\n");
                print('                   <td>['.$item_id.']</td>'."\n");
                print('                   <td>'.$nom.' ('.$desc.')</td>'."\n");
                print('                   <td>'.$carats.'</td>'."\n");
                print('                   <td>'.$min.'</td>'."\n");
                print('                   <td></td>'."\n");
                print('                   <td>'.$reserve.'</td>'."\n");
                print('                   <td>'.$prix.'</td>'."\n");
                print('                   <td>'.$loc.'</td>'."\n");
                print('                  </tr>'."\n");
            }

        }
    }

    print('                </tbody>'."\n");
    print('              </table>'."\n");

    $db->close;
?>
            </td>
          </tr>

          <!-- Block with count of Matériaux -->
          <tr>
            <td>
<?php

    foreach ($arr_minerais as $minerai)
    {
        $minerai  = preg_replace('/\'\'/', '\'', $minerai);
        $item_png = GetMateriauIcon($minerai);
        print('              '.$item_png.' ('.$arr_count_i["$minerai"].') '."\n");
    }
    print('            <br>'."\n");
    foreach ($arr_materiaux as $materiau)
    {
        $item_png = GetMateriauIcon($materiau);
        print('              '.$item_png.' ('.$arr_count_i["$materiau"].') '."\n");
    }
    print('            <br>'."\n");
    foreach ($arr_roches as $roche)
    {
        $item_png = GetMateriauIcon($roche);
        print('              '.$item_png.' ('.$arr_count_i["$roche"].') '."\n");
    }
    print('            <br>'."\n");
    foreach ($arr_pierres as $pierre)
    {
        $item_png = GetMateriauIcon($pierre);
        print('              '.$item_png.' ('.$arr_count_i["$pierre"].') '."\n");
    }
end:
?>
            </td>
          </tr>
          <!-- /Block with count of Matériaux -->
          <!-- /Matériaux -->
        </table>
        <script type="text/javascript" src="/js/tristen-tablesort.js"></script>
        <script type="text/javascript" src="/js/tristen-tablesort.number.js"></script>
        <script>new Tablesort(document.getElementById('stuff'));</script>
        <script>new Tablesort(document.getElementById('composants'));</script>
        <script>new Tablesort(document.getElementById('materiaux'));</script>
      </div> <!-- content -->
    </div> <!-- page -->
  </body>
</html>
