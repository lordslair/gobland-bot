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
        <h2 class="expanded">Matériaux Gobelins</h2>
        <table cellspacing="0" id="profilInfos">
<?php
    include 'queries.php';
    include 'functions.php';

    foreach ($arr_gob_ids as $gob_id)
    {
        $db_file = '/db/'.$_ENV["DBNAME"];
        $db      = new SQLite3($db_file);
        if(!$db) { echo $db->lastErrorMsg(); }

        $req_materiaux_c   = "SELECT COUNT (*) FROM ItemsGobelins WHERE ( Type = 'Matériau' OR Type = 'Roche' OR Type = 'Minerai' ) AND Gobelin = '$gob_id'";
        $materiaux_count   = $db->querySingle($req_materiaux_c);

        $req_gob_nom       = "SELECT Gobelin FROM Gobelins WHERE Id = '$gob_id'";
        $gob_nom           = $db->querySingle($req_gob_nom);

        if ( $materiaux_count > 0 )
        {
            print('<tr class="expanded">'."\n");
            print('<th>['.$materiaux_count.'] Matériaux de '.$gob_nom.' ('.$gob_id.')</th>'."\n");
            print('</tr>'."\n");
            print('</tr>'."\n");
            print('<tr>'."\n");
            print('<td>'."\n");
            print('<ul class="membreEquipementList">'."\n");

            $req_materiaux   = "SELECT * FROM ItemsGobelins
                                WHERE ( Type = 'Matériau' OR Type = 'Roche' OR Type = 'Minerai' )
                                AND Gobelin = '$gob_id'
                                ORDER BY Type,Nom";
            $query_materiaux = $db->query($req_materiaux);

            while ($row = $query_materiaux->fetchArray())
            {
                $item_id = $row[0];
                $type    = $row[2];
                $nom     = $row[4];
                $desc    = $row[6];
                $min     = sprintf("%.1f",$row[7]/60);
                $nbr     = $row[8];
                $qualite = $row[9];

                $desc    = GetQualite($type,$qualite);
                $m_png   = GetMateriauIcon($nom);
                $carats  = GetCarats($qualite,$nbr);

                print('                <li class="equipementNonEquipe">'."\n");
                print('                  <div class="tt_r">'."\n");
                print('                    '.$m_png.'['.$item_id.'] '.$nom.' de taille '.$nbr.' ('.$desc.'), '.$min.' min'."\n");
                print('                    <span class="tt_r_text">'.$carats.' Carats</span>'."\n");
                print('                  </div>'."\n");
                print('                </li>'."\n");
            }
            $db->close;

            print('              </ul>'."\n");
            print('            </td>'."\n");
            print('          </tr>'."\n");
        }
    }
?>
        </table>
      </div> <!-- content -->
    </div> <!-- page -->
  </body>
</html>
