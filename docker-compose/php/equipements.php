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
                <li><a href="/locator.php" title="Locator">Locator</a></li>
              </ul>
            </li>
          </ul>
        </div>
      </div>
      <div id="content">
        <link href="/style/tt_r.css"  rel="stylesheet" type="text/css"  />
        <link href="/style/equipement.css"  rel="stylesheet" type="text/css"  />
        <h1>Possessions</h1>
        <h2 class="expanded">Équipements Gobelins</h2>
        <table cellspacing="0" id="profilInfos">
<?php
    include 'queries.php';
    include 'functions.php';

    foreach ($arr_gob_ids as $gob_id)
    {
        $db_file = '/db/'.$_ENV["DBNAME"];
        $db      = new SQLite3($db_file);
        if(!$db) { echo $db->lastErrorMsg(); }

        $req_gob_nom       = "SELECT Gobelin FROM Gobelins WHERE Id = '$gob_id'";
        $gob_nom           = $db->querySingle($req_gob_nom);

        print('<tr class="expanded">'."\n");
        print('<th>Équipements de '.$gob_nom.' ('.$gob_id.')</th>'."\n");
        print('</tr>'."\n");
        print('</tr>'."\n");
        print('<tr>'."\n");
        print('<td>'."\n");
        print('<ul class="membreEquipementList">'."\n");

        $req_equipements   = "SELECT * FROM ItemsGobelins 
                              WHERE Gobelin = '$gob_id'
                              AND Type NOT IN ('Minerai', 'Composant', 'Matériau', 'Roche')
                              ORDER BY Utilise DESC";
        $query_equipements = $db->query($req_equipements);

        $counter = 0;

        while ($row = $query_equipements->fetchArray())
        {
            $item_id  = $row[0];
            $type     = $row[2];
            $nom      = $row[4];
            $template = '';
            $desc     = $row[6];
            $min      = sprintf("%.1f",$row[7]/60);
            $equipe   = '';

            if ( $row[5] )  { $template = '<b>'.$row[5].'</b>'; }
            if ( $row[11] ) { $nom .= ' en '.$row[11]; }
            if ( $row[10] == 'FAUX' ) { $equipe = 'Non'; }

            $luxe     = GetLuxe($type,$nom,$desc);
            $craft    = GetCraft($type,$nom,$desc,$template);

            if ( $counter == 0 and $equipe == 'Non' )
            {
                print('                <br>'."\n");
                $counter++;
            }

            print('                <li class="equipement'.$equipe.'Equipe">'."\n");
            print('                    ['.$item_id.'] '.$type.' : '.$nom.' '.$template.' ('.$desc.'), '.$min.' min'.$luxe.$craft."\n");
            print('                </li>'."\n");
        }
        $db->close;

        print('              </ul>'."\n");
        print('            </td>'."\n");
        print('          </tr>'."\n");
    }
?>
        </table>
      </div> <!-- content -->
    </div> <!-- page -->
  </body>
</html>