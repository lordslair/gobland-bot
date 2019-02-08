<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
  <head>
<?php
    print ('<title>Gobland-IT ('.$_ENV["CLANID"].') '.$_ENV["CLANNAME"].'</title>');
?>
    <link rel="stylesheet" type="text/css" href="/style/common.css" />
    <link rel="stylesheet" type="text/css" href="/style/menu.css" />
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
                <li><a href="/equipement.html" title="Equipement des Gob' du Clan">Equipement du Clan</a></li>
                <li><a href="/materiaux.html" title="Materiaux des Gob' du Clan">Materiaux du Clan</a></li>
                <li><a href="/composants.php" title="Composants des Gob' du Clan">Composants du Clan</a></li>
                <li><a href="/cavernes.php" title="Cavernes du Clan">Cavernes du Clan</a></li>
              </ul>
            </li>
            <li><a href="" title="">Outils</a>
              <ul>
                <li><a href="/pxbank.php" title="PX Bank du Clan">PX Bank</a></li>
                <li><a href="/gps.php" title="GPS">GPS</a></li>
                <li><a href="/radar.php" title="Radar">Radar</a></li>
                <li><a href="/CdM.html" title="CdM">CdM Collector</a></li>
              </ul>
            </li>
            <li><a href="" title="">Liens</a></li>
          </ul>
        </div>
      </div>
      <div id="content">
        <link href="/style/tt_r.css"  rel="stylesheet" type="text/css"  />
        <link href="/style/equipement.css"  rel="stylesheet" type="text/css"  />
        <h1>Possessions</h1>
        <h2 class="expanded">Equipements Gobelins dans les Cavernes</h2>
        <table cellspacing="0" id="profilInfos">
          <!-- Equipement -->
          <tr class="expanded">
            <th>Equipements</th>
          </tr>
          <tr>
            <td>
              <ul class="membreEquipementList">
<?php
    include 'functions.php';

    $arr_equipements = ['Arme 1 Main', 'Arme 2 mains', 'Anneau', 'Armure', 'Baguette', 'Bijou', 'Bottes', 'Bouclier', 'Casque', 'Nourriture','Outil', 'Potion', 'Talisman'];
    $arr_count_e     = [];

    foreach ($arr_equipements as $equipement)
    {
        $db_file = '/db/'.$_ENV["DBNAME"];
        $db      = new SQLite3($db_file);
        if(!$db) { echo $db->lastErrorMsg(); }

        $req_equipement   = "SELECT Id,Type,Identifie,Nom,Magie,Desc,Poids,Taille,Qualite,Localisation,Utilise,Prix,Reservation,Matiere
                             FROM   ItemsCavernes
                             WHERE  Type = '$equipement'
                             ORDER  BY Type,Nom;";
        $query_equipement = $db->query($req_equipement);

        $item_png = GetStuffIcon($equipement,$nom);
        print('                <div style="text-align:center; type="'.$equipement.'">'."\n");
        print('                  <br>'.$item_png.'<br>'."\n");
        print('                </div>'."\n");

        while ($row = $query_equipement->fetchArray())
        {
            $item_id   = $row[0];
            $item_type = $row[1];
            $nom       = $row[3];
            $min       = ', '.sprintf("%.1f", $row[6]/60) . ' min';
            $desc      = $row[5];
            $template  = '<b>'.$row[4].'</b>';
            $luxe      = GetLuxe($item_type,$nom,$desc);

            if ( $row[13] ) { $nom .= ' en '.$row[13]; } # Fix for 'en Pierre' equipements

            $arr_count_e["$equipement"]++;

            $item_txt = '['.$item_id.'] '.$item_type.' : '.$nom.' '.$template.' ('.$desc.')'.$min.$luxe.'<br>';

            print('                <li class="equipementNonEquipe">'."\n");
            print('                  '.$item_txt."\n");
            print('                </li>'."\n");
        }
        $db->close;
    }
?>
              </ul>
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
          <!-- /Equipement -->

          <!-- Composants -->
          <tr class="expanded">
            <th>Composants</th>
          </tr>
          <tr>
            <td>
              <ul class="membreEquipementList">
<?php
    $arr_composants = ['Composant', 'Fleur', 'Racine', 'Champignon'];
    $arr_count_c    = [];

    foreach ($arr_composants as $composant)
    {
        $db_file = '/db/'.$_ENV["DBNAME"];
        $db      = new SQLite3($db_file);
        if(!$db) { echo $db->lastErrorMsg(); }

        $req_composant = "SELECT Id,Type,Identifie,Nom,Magie,Desc,Poids,Taille,Qualite,Localisation,Utilise,Prix,Reservation,Matiere
                          FROM   ItemsCavernes
                          WHERE  Type = '$composant'
                          ORDER  BY Nom;";
        $query_composant = $db->query($req_composant);

        $item_png = GetMateriauIcon($composant);
        print('                <div style="text-align:center; type="'.$composant.'">'."\n");
        print('                  <br>'.$item_png.'<br>'."\n");
        print('                </div>'."\n");

        while ($row = $query_composant->fetchArray())
        {
            $item_id  = $row[0];
            $nom      = $row[3];
            $min      = ', '.sprintf("%.1f", $row[6]/60) . ' min';
            $desc     = GetQualite('Composant', $row[8]);

            $arr_count_c["$composant"]++;

            $item_txt = '['.$item_id.'] '.$nom.' ('.$desc.')'.$min."\n";

            print('                <li class="equipementNonEquipe">'."\n");
            print('                  '.$item_txt."\n");
            print('                </li>'."\n");
        }
        $db->close;
    }
?>
              </ul>
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

          <!-- Materiaux -->
          <tr class="expanded">
            <th>Matériaux</th>
          </tr>
          <tr>
            <td>
              <ul class="membreEquipementList">
<?php
    $arr_minerais  = ['Sable', "Minerai d''Or", 'Minerai de Cuivre', "Minerai d''Argent", "Minerai d''Etain", 'Minerai de Mithril', "Minerai d''Adamantium", 'Minerai de Fer'];
    $arr_materiaux = ['Cuir', 'Tissu', 'Rondin'];
    $arr_roches    = ['Pierre'];
    $arr_items     = array_merge($arr_minerais, $arr_materiaux, $arr_roches);
    $arr_count_i   = [];

    foreach ($arr_items as $item)
    {
        $db_file = '/db/'.$_ENV["DBNAME"];
        $db      = new SQLite3($db_file);
        if(!$db) { echo $db->lastErrorMsg(); }

        $req_items = "SELECT Id,Type,Identifie,Nom,Magie,Desc,Poids,Taille,Qualite,Localisation,Utilise,Prix,Reservation,Matiere
                      FROM   ItemsCavernes
                      WHERE  Nom = '$item'
                      ORDER  BY Nom;";
        $query_items = $db->query($req_items);

        $item     = preg_replace('/\'\'/', '\'', $item);
        $item_png = GetMateriauIcon($item);
        print('                <div style="text-align:center; type="'.$item.'">'."\n");
        print('                  <br>'.$item_png.'<br>'."\n");
        print('                </div>'."\n");

        while ($row = $query_items->fetchArray())
        {
            $item_id   = $row[0];
            $item_type = $row[1];
            $nom       = $row[3];
            $min       = ', '.sprintf("%.1f", $row[6]/60) . ' min';
            $desc      = GetQualite($item_type, $row[8]);
            $nbr       = $row[7];
            $carats    = GetCarats($row[8],$nbr);
            #$carats    = 0;

            $arr_count_i["$item"]++;

            if ( $item == 'Rondin' )
            {
                $arr_count_i["$item"] = $arr_count_i["$item"] + $nbr;
            }
            else
            {
                $arr_count_i["$item"] = $arr_count_i["$item"] + $carats;
            }

            print('                <li class="equipementNonEquipe">'."\n");
            print('                  <div class="tt_r">'."\n");
            print('                    ['.$item_id.'] '.$nom.' de taille '.$nbr.' ('.$desc.')'.$min."\n");
            print('                    <span class="tt_r_text">'.$carats.' Carats</span>'."\n");
            print('                  </div>'."\n");
            print('                </li>'."\n");
        }
        $db->close;
    }
?>
              </ul>
            </td>
          </tr>

          <!-- Block with count of Materiaux -->
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
?>
            </td>
          </tr>
          <!-- /Block with count of Materiaux -->
          <!-- /Materiaux -->
        </table>
      </div> <!-- content -->
    </div> <!-- page -->
  </body>
</html>
