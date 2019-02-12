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
                <li><a href="/locator.php" title="Locator">Locator</a></li>
              </ul>
            </li>
          </ul>
        </div>
      </div>
      <div id="content">
        <h1>Locator</h1>
        <div id="profilInfos">
        <fieldset>
          <legend>Kestuveu ?</legend>
          <form method="post" action="locator.php">
          <strong>Requête</strong> : <input type="text" id="search" name="search" maxlength="80" size="80">
          <input type="submit" value="Go !">
          </form>
        </fieldset>
        <fieldset>
          <legend>Kestatrouvé :</legend>
<?php
    $db_file = '/db/'.$_ENV["DBNAME"];
    $db      = new SQLite3($db_file);
    if(!$db) { echo $db->lastErrorMsg(); }

    if ( $_POST['search'] )
    {
        $count = 0;
        if     ( preg_match('/(id)=(\d*)[!]/', $_POST['search'], $matches) )
        {
            if ($count == 0)
            {
                $clause = "Id = '$matches[2]'";
            }
            else
            {
                $clause = " AND Id = '$matches[2]'";
            }
            $count++;
        }
        if ( preg_match('/(gob|mob)=([\w\s]*)[!]/u', $_POST['search'], $matches) )
        {
            if ($count == 0)
            {
                $clause .= "( Type = '$matches[2]' OR Nom = '$matches[2]')";
            }
            else
            {
                $clause .= " AND ( Type = '$matches[2]' OR Nom = '$matches[2]' )";
            }
            $count++;
        }
        if ( preg_match('/(niv)=(\d*):(\d*)[!]/', $_POST['search'], $matches) )
        {
            if ($count == 0)
            {
                $clause .= "Niveau BETWEEN '$matches[2]' AND '$matches[3]'";
            }
            else
            {
                $clause .= " AND Niveau BETWEEN '$matches[2]' AND '$matches[3]'";
            }
            $count++;
        }
        if ( preg_match('/(objet|lieu)=([\w\s]*)[!]/u', $_POST['search'], $matches) )
        {
            if ($count == 0)
            {
                $clause .= "( Type = '$matches[2]' OR Nom = '$matches[2]' )";
            }
            else
            {
                $clause .= " AND ( Type = '$matches[2]' OR Nom = '$matches[2]' )";
            }
            $count++;
        }

        # Position selector
        $arr_pos = ['x', 'y', 'n'];
        foreach ( $arr_pos as $pos )
        {
            if ( preg_match("/($pos)=([-]?\d*):([-]?\d*)[!]/", $_POST['search'], $matches) )
            {
                if ($count == 0)
                {
                    $clause .= strtoupper($matches[1])." BETWEEN '$matches[2]' AND '$matches[3]'";
                }
                else
                {
                   $clause .= " AND ".strtoupper($matches[1])." BETWEEN '$matches[2]' AND '$matches[3]'";
               }
               $count++;
           }
        }

        if ( $count > 0 )
        {
            $req_locator = "SELECT Id,Type,Nom,Niveau,X,Y,N,Z FROM Vue WHERE ".$clause;
        }

        # DEBUG selector
        if     ( preg_match('/[!]debug[!]/', $_POST['search'], $matches) )
        {
            print($req_locator."<br>");
            print_r( $_POST);
        }
    }

    if ($req_locator)
    {
        $query_locator = $db->query($req_locator);

            print('          <table cellspacing="0" id="trollsList">'."\n");
            print('            <tr>'."\n");
            print('              <th>ID</th>'."\n");
            print('              <th>Type</th>'."\n");
            print('              <th>Nom</th>'."\n");
            print('              <th>Niv</th>'."\n");
            print('              <th>X</th>'."\n");
            print('              <th>Y</th>'."\n");
            print('              <th>N</th>'."\n");
            print('            </tr>'."\n");

        while ($row = $query_locator->fetchArray())
        {
            print('            <tr>'."\n");
            print('              <td>'.$row[0].'</td>'."\n");
            print('              <td>'.$row[1].'</td>'."\n");
            print('              <td>'.$row[2].'</td>'."\n");
            print('              <td>'.$row[3].'</td>'."\n");
            print('              <td>'.$row[4].'</td>'."\n");
            print('              <td>'.$row[5].'</td>'."\n");
            print('              <td>'.$row[6].'</td>'."\n");
            print('            </tr>'."\n");
        }
        $db->close;
        print('          </table>'."\n");
    }
?>
        </fieldset>
        <fieldset>
          <legend>Komenonfé ?</legend>
          - Tu cherches un Monstre de type Strige -> <input type="text" size="20" value="mob=Strige!"><br>
          - Tu cherches un Gobelin d'ID 355 -> <input type="text" size="20" value="id=355!"><br>
          - Tu cherches un Gobelin en surface -> <input type="text" size="20" value="mob=Gobelin! n=0:0!"><br>
          - Tu cherches un Monstre de niveau 6 -> <input type="text" size="20" value="niv=6:6!"><br>
          - Tu cherches un Monstre de type Strige ET d'un niveau 6 à 8 -> <input type="text" size="20" value="mob=Strige! niv=6:8!"><br>
          - Tu cherches un Objet de type Anneau -> <input type="text" size="20" value="objet=Anneau!"><br>
          - Tu cherches un Objet de type Anneau avec zone ( 0 < X < 20; 0 < Y < 20; -20 < N < -10 ) -> <input type="text" size="40" value="objet=Anneau! x=0:20! y=0:20! n=-20:-10!"><br>
          - Tu cherches un Lieu de type Mine -> <input type="text" size="20" value="lieu=Mine!"><br>
          - Tu n'oublies pas de terminer chaque champ de requête par un <b>!</b> ⚠️ 
        </fieldset>
      </div> <!-- content -->
    </div> <!-- page -->
  </body>
</html>
