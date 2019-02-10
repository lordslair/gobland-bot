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
              </ul>
            </li>
          </ul>
        </div>
      </div>
      <div id="content">
<?php
    include 'functions.php';
    include 'queries.php';

    if ( preg_match('/^\d*$/', $_GET["id"]) )
    {
        if ( in_array($_GET["id"], $arr_gob_ids) )
        {
            $gob_id = $_GET["id"];
        }
        else
        {
            print("<center>Cet ID n'est pas présent en DB</center>"."\n");
            goto end;
        }
    }
    else
    {
        print("<center>Cet ID n'est pas valide</center>"."\n");
        goto end;
    }

    if ( $_GET["niveau"] && ($_GET["niveau"] != 'TRUE') )
    {
        goto end;
    }

    $db_file = '/db/'.$_ENV["DBNAME"];
    $db      = new SQLite3($db_file);
    if(!$db) { echo $db->lastErrorMsg(); }

    $req_gob_nom       = "SELECT Gobelin FROM Gobelins WHERE Id = '$gob_id'";
    $gob_nom           = $db->querySingle($req_gob_nom);

    $T_emoji = '<img src="/images/1f4b0.png" width="16" height="16">'; #💰
    $L_emoji = '<img src="/images/1f3e0.png" width="16" height="16">'; #🏠
    $G_emoji = '<img src="/images/1f60e.png" width="16" height="16">'; #😎
    $C_emoji = '<img src="/images/1f47f.png" width="16" height="16">'; #👿
    $W_emoji = '<img src="/images/1f6a7.png" width="16" height="16">'; #🚧
    $A_emoji = '<img src="/images/1f333.png" width="16" height="16">'; #🌳
    $S_emoji = '<img src="/images/1f434.png" width="16" height="16">'; #🐴
    $M_emoji = '<img src="/images/1f344.png" width="16" height="16">'; #🍄
    $F_emoji = '<img src="/images/1f33a.png" width="16" height="16">'; #🌺
    $R_emoji = '<img src="/images/1f331.png" width="16" height="16">'; #🌱


    $arr_suivants      = [];
    $req_suivants_full = "SELECT Id FROM Suivants";
    $query_suivants    = $db->query($req_suivants_full);
    while ($row = $query_suivants->fetchArray())
    {
        $arr_suivants[] = $row[0];
    }

    $req_gob_full      = "SELECT PER,BMPER,BPPER,X,Y,N,Nom FROM Gobelins
                          INNER JOIN Gobelins2 on Gobelins.Id = Gobelins2.Id
                          WHERE Gobelins.Id = $gob_id";
    $row = $db->querySingle($req_gob_full, true);
    $db->close;

    $cases   = $row['PER'] + $row['BMPER'] + $row['BPPER'];
    $X       = $row['X'];
    $Y       = $row['Y'];
    $N       = $row['N'];

    if ( $cases > 0 )
    {
        $x_min = $X - $cases;
        $x_max = $X + $cases;
        $y_min = $Y - $cases;
        $y_max = $Y + $cases;
        $n_max = sprintf("%d",$N + ($cases / 2));
        $n_min = sprintf("%d",$N - ($cases / 2));
    }
    else
    {
        $x_min = $X;
        $x_max = $X;
        $y_min = $Y;
        $y_max = $Y;
        $n_max = $N;
        $n_min = $N;
    }

    $T_count = 0;
    $C_count = 0;
    $L_count = 0;
    $G_count = 0;

    # We use $_GET["niveau"] to restrict the view
    if ( $_GET["niveau"] ) { $n_min = $n_max = $N;}

    $req_vue = "SELECT Id,Categorie,Nom,Niveau,Type,Clan,X,Y,N,Z
                FROM Vue
                WHERE X BETWEEN '$x_min' AND '$x_max'
                AND   Y BETWEEN '$y_min' AND '$y_max'
                AND   N BETWEEN '$n_min' AND '$n_max'";
    $query_vue = $db->query($req_vue);

    $ITEMS = [];

    while ($row = $query_vue->fetchArray())
    {
        $id   = $row[0];
        $cat  = $row[1];
        $nom  = $row[2];
        $niv  = $row[3];
        $x    = $row[6];
        $y    = $row[7];
        $n    = $row[8];

        if     ( $cat == 'T'                                     ) { $T_count++; }
        elseif ( $cat == 'C'                                     ) { $C_count++; }
        elseif ( $cat == 'G'                                     ) { $G_count++; }
        elseif ( $cat == 'L' && $nom != 'Mur' && $nom != 'Arbre' ) { $L_count++; }

        if (! $ITEMS[$x][$y])
        {
            $ITEMS[$x][$y]['td'] = '';
            $ITEMS[$x][$y]['tt'] = "<center>&nbsp;&nbsp;X = $x | Y = $y<br><br></center>";
        }

        if     ( $cat == 'T' && !preg_match('/1f4b0/', $ITEMS[$x][$y]['td']) )
        {
            $ITEMS[$x][$y]['td'] .= $T_emoji;
        }
        elseif ( $cat == 'L' && !preg_match('/1f3e0/', $ITEMS[$x][$y]['td']) && !preg_match('/Mur|Arbre/', $nom) )
        {
            $ITEMS[$x][$y]['td'] .= $L_emoji;
        }
        elseif ( $cat == 'L' && $nom == 'Mur')
        {
            $ITEMS[$x][$y]['td'] .= $W_emoji;
        }
        elseif ( $cat == 'L' && $nom == 'Arbre')
        {
            $ITEMS[$x][$y]['td'] .= $A_emoji;
        }
        elseif ( $cat == 'C' && !preg_match('/1f434/', $ITEMS[$x][$y]['td']) && in_array($id,$arr_suivants) )
        {
            $ITEMS[$x][$y]['td'] .= $S_emoji;
        }
        elseif ( $cat == 'C' && !preg_match('/1f47f/', $ITEMS[$x][$y]['td']) )
        {
            $ITEMS[$x][$y]['td'] .= $C_emoji;
        }
        elseif ( $cat == 'G' && !preg_match('/1f60e/', $ITEMS[$x][$y]['td']) )
        {
            $ITEMS[$x][$y]['td'] .= $G_emoji;
        }
        elseif ( $cat == 'P' && $nom == 'Champignon' && !preg_match('/1f344/', $ITEMS[$x][$y]['td']) )
        {
            $ITEMS[$x][$y]['td'] .= $M_emoji;
        }
        elseif ( $cat == 'P' && $nom == 'Racine' && !preg_match('/1f331/', $ITEMS[$x][$y]['td']) )
        {
            $ITEMS[$x][$y]['td'] .= $R_emoji;
        }
        elseif ( $cat == 'P' && $nom == 'Fleur' && !preg_match('/1f33a/', $ITEMS[$x][$y]['td']) )
        {
            $ITEMS[$x][$y]['td'] .= $F_emoji;
        }

        if ( !preg_match("/N = $n/", $ITEMS[$x][$y]['tt']) )
        {
            $ITEMS[$x][$y]['tt'] .= "&nbsp;&nbsp;<b>N = $n</b><br>";
        }

        $tt_text_c = 'black';
        if ($cat == 'G') { $tt_text_c = 'cyan';};
        if ($cat == 'C') { $tt_text_c = 'grey';};

        if ($cat == 'G' or $cat == 'C')
        {
            $ITEMS[$x][$y]['tt'] .= "&nbsp;&nbsp;[$id] <span style='color:$tt_text_c'>".$nom.' (Niv. '.$niv.')'.'</span><br>';
        }
        else
        {
            $ITEMS[$x][$y]['tt'] .= "&nbsp;&nbsp;[$id] <span style='color:$tt_text_c'>".$nom.'</span><br>';
        }
    }
    $db->close;

    print('        <h1>Vue de ['.$gob_id.'] '.$gob_nom.' ('.$cases.' cases)'.'</h1>'."\n");
    print('        <h3>Centrée sur [ X='.$X.' | Y= '.$Y.' | N= '.$N.' ]'.'</h3>'."\n");
    print('        <center>'."\n");
    print('          <a href="/vue.php?id='.$gob_id.'&niveau=TRUE" title="Vue Restreinte">[Restreindre au niveau courant (N='.$N.')]</a>'."\n");
    print('          <a href="/vue.php?id='.$gob_id.'" title="Vue Normale">[🚫]</a>'."\n");
    print('        <center>'."\n");
    print('        <table cellspacing="0" id="GobVue">'."\n");
    print('          <caption>'."\n");
    print('            <br>'.$T_emoji.'Tresors ('.$T_count.') | '."\n");
    print('                '.$G_emoji.'Gobelins ('.$G_count.') | '."\n");
    print('                '.$L_emoji.'Lieux ('.$L_count.')'."\n");
    print('            <br>'.$C_emoji.'Monstres ('.$C_count.')<br>'."\n");
    print('          <caption>'."\n");
    print('          <tbody>'."\n");

    if ( $cases > 0 )
    {
        print('            <tr>'."\n");
        print('              <td class="blank"></td>'."\n");

        for ($td = $X - $cases; $td <= $X + $cases; $td++)
        {
            print('              <th>'.$td.'</th>'."\n");
        }

        for ($tr = $Y + $cases; $tr >= $Y - $cases; $tr--)
        {
            print('            <tr>'."\n");
            print('              <th>'.$tr.'</th>'."\n");
            for ($td = $X - $cases; $td <= $X + $cases; $td++)
            {
                $tdcolor = '';
                if ( $td == $X and $tr == $Y ) { $tdcolor = 'style="background-color: white"'; }
                if ( $ITEMS[$td][$tr]['td'] )
                {
                    print('              <td '.$tdcolor.'>'."\n");
                    print('                <div class="tt">'."\n");
                    print('                '.$ITEMS[$td][$tr]['td']."\n");
                    print('                  <span class="tt_text">'.$ITEMS[$td][$tr]['tt'].'</span>'."\n");
                    print('                </div>'."\n");
                    print('              </td>'."\n");
                }
                else
                {
                    print('              <td '.$tdcolor.'></td>'."\n");
                }
            }
            print('            </tr>'."\n");
        }
    }
    else
    {
        $tdcolor = 'style="background-color: white"';

        print('            <tr>'."\n");
        print('              <td class="blank"></td>'."\n");
        print('              <th>'.$X.'</th>'."\n");
        print('            </tr>'."\n");
        print('            <tr>'."\n");
        print('              <th>'.$Y.'</th>'."\n");
        print('              <td '.$tdcolor.'>'."\n");
        print('                <div class="tt">'."\n");
        print('                  '.$ITEMS[$X][$Y]['td']."\n");
        print('                  <span class="tt_text">'.$ITEMS[$X][$Y]['tt'].'</span>'."\n");
        print('                </div>'."\n");
        print('              </td>'."\n");
        print('            </tr>'."\n");
    }

    print('          </tbody>'."\n");
    print('        </table>'."\n");

    end:
?>
        </div> <!-- profilInfos -->
      </div> <!-- content -->
    </div> <!-- page -->
  </body>
</html>
