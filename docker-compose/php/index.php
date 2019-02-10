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
              </ul>
            </li>
          </ul>
        </div>
      </div>
      <div id="content">
<?php
    print ('<br><h1>'.$_ENV["CLANNAME"].'</h1><br>');
?>
        <table cellspacing="0" id="trollsList">
          <tr>
            <th>Pseudo</th>
            <th>Num</th>
            <th>Race</th>
            <th>Niv.</th>
            <th>Position</th>
            <th>Meute</th>
            <th>PV</th>
            <th>PA</th>
            <th>Dates</th>
            <th>Action</th>
          </tr>
<?php
    include 'queries.php';
    include 'functions.php';

    $ct_total   = 0;

    foreach ($arr_gob_ids as $gob_id)
    {

        $db_file = '/db/'.$_ENV["DBNAME"];
        $db      = new SQLite3($db_file);
        if(!$db) { echo $db->lastErrorMsg(); }

        $req_profile   = "SELECT Gobelins.Id,Tribu,Gobelin,Niveau,X,Y,N,PA,PV,PVMax,CT,Gobelins.DLA,Gobelins2.DLA,BPDLA,BMDLA
                          FROM Gobelins
                          INNER JOIN Gobelins2 on Gobelins.Id = Gobelins2.Id
                          WHERE Gobelins.Id = $gob_id
                          ORDER BY Gobelins.Id";
        $query_profile = $db->query($req_profile);

        while ($row = $query_profile->fetchArray())
        {
            $position    = $row[4].', '.$row[5].', '.$row[6];

            $req_meute_id    = "SELECT IdMeute  FROM Meutes WHERE Id = $gob_id";
            $meute_id  = $db->querySingle($req_meute_id);
            if ( $meute_id ) { $meute_id = '('.$meute_id.')'; }

            $req_meute_nom   = "SELECT NomMeute FROM Meutes WHERE Id = $gob_id";
            $meute_nom = $db->querySingle($req_meute_nom);

            $pad = ' ';
            if ( $row[7] > 0 )
            {
                $pad = ' class="PADispo"';
            }

            $color   = GetColor($row[8],$row[9]);
            $percent = ($row[8] / $row[9]) * 100;
            $lifebar = '<br><div class="vieContainer"><div style="background-color:'.$color.'; width: '.$percent.'%">&nbsp;</div></div>';

            $ct_total += $row[10];

            $duree_s   = $row[12] + $row[13] + $row[14];
            $pdla      = GetpDLA($row[11], $duree_s);
            
            print('          <tr>'."\n");
            print('            <td>'."\n");
            print('              <a href="http://games.gobland.fr/Profil.php?IdPJ='.$gob_id.'" target="_blank">'.$row[2].'</a>'."\n");
            print('            </td>'."\n");
            print('            <td>'.$gob_id.'</td>'."\n");
            print('            <td>'.$row[1].'</td>'."\n");
            print('            <td>'.$row[3].'</td>'."\n");
            print('            <td>'.$position.'</td>'."\n");
            print('            <td>'.$meute_nom.' '.$meute_id.'</td>'."\n");
            print('            <td>'.$row[8].' / '.$row[9].$lifebar.'</td>'."\n");
            print('            <td'.$pad.'>'.$row[7].'</td>'."\n");
            print('            <td><span class="DLA"> DLA : '.$row[11].'</span><br><span class="pDLA">pDLA : '.$pdla.'</span></td>'."\n");
            print('            <td>'."\n");
            print('            <a href="/gobelins.php?id='.$gob_id.'" title="Votre profil">PROFIL</a>'."\n");
            print('            <a href="/vue.php?id='.$gob_id.'" title="Votre vue">VUE</a>'."\n");
            print('            </td>'."\n");
            print('            </tr>'."\n");
        }
        $db->close;
    }

    print('        </table>'."\n");

    print('        <div>'."\n");
    print('          <h3>Fortune : '.$ct_total.' CT (gobelins)</h3>'."\n");
    print('        </div>'."\n");

?>
      </div> <!-- content -->
    </div> <!-- page -->
  </body>
</html>
