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
        <link href="/style/tt_r.css"  rel="stylesheet" type="text/css"  />
        <link href="/style/gps.css"  rel="stylesheet" type="text/css"  />
        <div id="tooltip" display="none" style="position: absolute; display: none;"></div>
        <h1>Locator</h1>
        <div id="profilInfos">
        <fieldset>
          <legend>Kestuveu ?</legend>
          <form method="post" action="locator.php">
          <strong>Requête</strong> : <input type="search" id="search" name="search" maxlength="80" size="80">
          <br>
          <br>
          <div>
          <input type="radio" id="vue"   name="table" value="vue"   checked><label for="vue">Vues actuelles du Clan</label><br>
          <input type="radio" id="carte" name="table" value="carte"        ><label for="carte">Vues archivées du Clan (Expérimental)</label><br>
          <div>
          <br>
          <input type="submit" value="Go !">
          </form>
        </fieldset>
        <fieldset>
          <legend>Kestatrouvé :</legend>
<?php
    include 'inc.db.php';

    if ( $_POST['search'] )
    {

        $when = '< 5 minutes';
        if ( $_POST['table'] == 'vue' )
        {
            $table = 'Vue';
        }
        else
        {
            $table = 'Carte';
        }

        $count = 0;

        # Id selector
        if ( preg_match('/(id):(\d*)[.][.](\d*)\s?/', $_POST['search'], $matches) )
        {
            $min = min($matches[2],$matches[3]);
            $max = max($matches[2],$matches[3]);
            if ($count == 0)
            {
                $clause = "Id BETWEEN '$min' AND '$max'";
            }
            else
            {
                $clause = " Id Niveau BETWEEN '$min' AND '$max'";
            }
            $count++;
        }
        elseif ( preg_match("/(id):(\d*)\s?/", $_POST['search'], $matches) )
        {
            if ($count == 0)
            {
                $clause = 'Id = '.$matches[2];
            }
            else
            {
                $clause = ' AND Id = '.$matches[2];
            }
            $count++;
        }

        # Position selector
        $arr_pos = ['x', 'y', 'n'];
        foreach ( $arr_pos as $pos )
        {
            if ( preg_match("/($pos):([-]?\d*)[.][.]([-]?\d*)\s?/", $_POST['search'], $matches) )
            {
                $min = min($matches[2],$matches[3]);
                $max = max($matches[2],$matches[3]);
                if ($count == 0)
                {
                    $clause .= strtoupper($matches[1])." BETWEEN '$min' AND '$max'";
                }
                else
                {
                   $clause .= " AND ".strtoupper($matches[1])." BETWEEN '$min' AND '$max'";
               }
               $count++;
            }
            elseif ( preg_match("/($pos):([-]?\d*)\s?/", $_POST['search'], $matches) )
            {
                if ($count == 0)
                {
                    $clause .= strtoupper($matches[1]).'='.$matches[2];
                }
                else
                {
                    $clause .= " AND ".strtoupper($matches[1]).'='.$matches[2];
                }
                $count++;
            }
        }

        # Level selector
        if ( preg_match('/(level):(\d*)[.][.](\d*)\s?/', $_POST['search'], $matches) )
        {
            $min = min($matches[2],$matches[3]);
            $max = max($matches[2],$matches[3]);
            if ($count == 0)
            {
                $clause .= "Niveau BETWEEN '$min' AND '$max'";
            }
            else
            {
                $clause .= " AND Niveau BETWEEN '$min' AND '$max'";
            }
            $count++;
        }
        elseif ( preg_match("/(level):(\d*)\s?/", $_POST['search'], $matches) )
        {
            if ($count == 0)
            {
                $clause .= 'Niveau = '.$matches[2];
            }
            else
            {
                $clause .= ' AND Niveau = '.$matches[2];
            }
            $count++;
        }

        if ( preg_match('/@(gobelin|monstre):([\w]*)\s?/u', $_POST['search'], $matches) )
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

        # Item/Lieu selector
        if ( preg_match('/(tresor|lieu):([\w]*)\s?/u', $_POST['search'], $matches) )
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

        if ( $count > 0 AND $_POST['table'] == 'vue')
        {
            $req_locator = "SELECT Id,Type,Nom,Niveau,X,Y,N,Z FROM ".$table." WHERE ".$clause;
        }
        elseif ( $count > 0 AND $_POST['table'] == 'carte')
        {
            $req_locator = "SELECT Id,Type,Nom,Niveau,X,Y,N,Z,Date FROM ".$table." WHERE ".$clause;
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

        print('          <table cellspacing="0" id="trollsList" style="border: 0px">'."\n");
        print('            <tr style="border: 0px">'."\n");
        print('              <th style="border: 0px"></th>'."\n");
        print('              <th style="border: 0px"></th>'."\n");
        print('            </tr>'."\n");
        print('            <tr style="border: 0px">'."\n");
        print('              <td  style="border: 0px">'."\n");

        print('                <table cellspacing="0" id="trollsList">'."\n");
        print('                  <tr>'."\n");
        print('                    <th>ID</th>'."\n");
        print('                    <th>Type</th>'."\n");
        print('                    <th>Nom</th>'."\n");
        print('                    <th>Niv</th>'."\n");
        print('                    <th>X</th>'."\n");
        print('                    <th>Y</th>'."\n");
        print('                    <th>N</th>'."\n");
        print('                    <th>Mise à jour</th>'."\n");
        print('                  </tr>'."\n");

        while ($row = $query_locator->fetch_array())
        {
            if ( $row[8] ) { $when = $row[8]; };

            print('                  <tr>'."\n");
            print('                    <td>'.$row[0].'</td>'."\n");
            print('                    <td>'.$row[1].'</td>'."\n");
            print('                    <td>'.$row[2].'</td>'."\n");
            print('                    <td>'.$row[3].'</td>'."\n");
            print('                    <td>'.$row[4].'</td>'."\n");
            print('                    <td>'.$row[5].'</td>'."\n");
            print('                    <td>'.$row[6].'</td>'."\n");
            print('                    <td>'.$when.'</td>'."\n");
            print('                  </tr>'."\n");
        }

        print('                </table>'."\n");
        print('              </td>'."\n");

        $query_locator = $db->query($req_locator);
        $rowspan = 0;
        while ($row = $query_locator->fetch_array())
        {
            if ( $rowspan == 0 )
            {
                $arr_colors = ["AliceBlue","AntiqueWhite","Aqua","Aquamarine","Azure",
                               "Beige","Bisque","Black","BlanchedAlmond","Blue",
                               "BlueViolet","Brown","BurlyWood","CadetBlue","Chartreuse",
                               "Chocolate","Coral","CornflowerBlue","Cornsilk","Crimson"];

                $req_carte = "SELECT Id,Nom,Niveau,X,Y,N
                              FROM ".$table."
                              WHERE ".$clause;
                $query_carte = $db->query($req_carte);

                print('              <td rowspan="10" style="border: 0px">'."\n");
                print('                <svg version="1.2" id="minigraph" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" class="minigraph" role="img">'."\n");
                print('                  <g class="grid x-grid" id="xGrid"><line x1="100" x2="100" y1="000" y2="200"></line></g>'."\n");
                print('                  <g class="grid y-grid" id="yGrid"><line x1="000" x2="200" y1="100" y2="100"></line></g>'."\n");

                while ($row = $query_carte->fetch_array())
                {
                    $color    = $arr_colors[array_rand($arr_colors, 1)];
                    $cx       = round(100 + $row[3]/2);
                    $cy       = round(100 - $row[4]/2);
                    $position = "<b>X</b> = $row[3] | <b>Y</b> = $row[4] | <b>N</b> = $row[5]";
                    $tt       = '\''.'['.$row[0].'] '.$row[1].' ('.$position.')\'';

                    print('                  <g fill="'.$color.'">'."\n");
                    print('                    <circle cx="'.$cx.'" cy="'.$cy.'" r="3" onmousemove="showTooltip(evt, '.$tt.')";" onmouseout="hideTooltip();"></circle>'."\n");
                    print('                  </g>'."\n");
                }

                print('                </svg>'."\n");
            }
            $rowspan++;
        }
        print('              </td>'."\n");
        print('            </tr>'."\n");
        print('          </table>'."\n");
    }
    $db->close;
?>
        </fieldset>
        <fieldset>
          <legend>Komenonfé ?</legend>
          - Tu connais Troogle pour MH ? La syntaxe est ~ la même<br>
          <br>
          - Tu cherches un Monstre de type Strige -> <b>@monstre:Strige</b><br>
          - Tu cherches un Gobelin d'ID 355 -> <b>@id:355</b><br>
          - Tu cherches un Monstre de type Strige en surface -> <b>@monstre:Strige n:0</b><br>
          - Tu cherches un Monstre de niveau 6 -> <b>level=6</b><br>
          - Tu cherches un Monstre de type Strige ET d'un niveau 6 à 8 -> <b>@monstre:Strige level:6..8</b><br>
          - Tu cherches un Objet de type Anneau -> <b>@tresor:Anneau</b><br>
          - Tu cherches un Objet de type Anneau avec zone ( 0 < X < 20; 0 < Y < 20; -20 < N < -10 ) -> <b>@tresor:Anneau x:0..20 y:0..20 n:-20..-10</b><br>
          - Tu cherches un Lieu de type Mine -> <b>@lieu:Mine</b><br>
        </fieldset>
      </div> <!-- content -->
      <script type="text/javascript" src="/js/tt-gps.js"></script>
    </div> <!-- page -->
  </body>
</html>
