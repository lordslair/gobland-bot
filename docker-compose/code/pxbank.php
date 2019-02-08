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
        <h1>Banque PI/PX</h1>
        <h3>(Alias: Qui a la plus grosse ...)</h3>
        <table cellspacing="0" id="trollsList">
          <tr>
            <th onclick="sortTable(0)">Pseudo</th>
            <th onclick="sortTable(1)">Num</th>
            <th onclick="sortTable(2)">Niv.</th>
            <th onclick="sortTable(3)">PX Perso</th>
            <th onclick="sortTable(4)">PX</th>
            <th onclick="sortTable(5)">PI</th>
            <th onclick="sortTable(6)">PI Totaux</th>
            <th onclick="sortTable(7)">PX+PI Totaux</th>
          </tr>
<?php
        $db_file = '/db/'.$_ENV["DBNAME"];
        $db      = new SQLite3($db_file);
        if(!$db) { echo $db->lastErrorMsg(); }

        $req_pxbank    = "SELECT Gobelins.Id,PX,PXPerso,PI,Gobelin,Niveau,PITotal
                          FROM Gobelins
                          INNER JOIN Gobelins2 on Gobelins.Id = Gobelins2.Id
                          ORDER BY Gobelins.Id";
        $query_pxbank = $db->query($req_pxbank);

        while ($row = $query_pxbank->fetchArray())
        {
            $total = $row[1] + $row[2] + $row[6];

            print('          <tr>'."\n");
            print('            <td>'.$row[4].'</td>'."\n");
            print('            <td>'.$row[0].'</td>'."\n");
            print('            <td>'.$row[5].'</td>'."\n");
            print('            <td>'.$row[2].'</td>'."\n");
            print('            <td>'.$row[1].'</td>'."\n");
            print('            <td>'.$row[3].'</td>'."\n");
            print('            <td>'.$row[6].'</td>'."\n");
            print('            <td>'.$total.'</td>'."\n");
            print('          </tr>'."\n");
        }
        $db->close;

    print('        </table>'."\n");
?>
        <script type="text/javascript" src="/js/sort-px.js"></script>
      </div> <!-- content -->
    </div> <!-- page -->
  </body>
</html>
