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
<?php
    include 'inc.db.php';
    include 'functions.php';

    if ( preg_match('/^\d*$/', $_GET["id"]) )
    {
        $gob_id = $_GET["id"];
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
    if ( $_GET["small"] && ($_GET["small"] != 'TRUE') )
    {
        goto end;
    }
    if ( $_GET["medium"] && ($_GET["medium"] != 'TRUE') )
    {
        goto end;
    }

    $req_gob_nom       = "SELECT Gobelin FROM Gobelins WHERE Id = '$gob_id'";
    $gob_nom           = $db->query($req_gob_nom)->fetch_row()[0];

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
    $B_emoji = '<img src="/images/1f352.png" width="16" height="16">'; #🍒

    $arr_suivants      = [];
    $req_suivants_full = "SELECT Id FROM Suivants";
    $query_suivants    = $db->query($req_suivants_full);
    while ($row = $query_suivants->fetch_array())
    {
        $arr_suivants[] = $row[0];
    }

    if ( $_GET["id"] && $_GET["suivant"] && ($_GET["suivant"] = 'TRUE') )
    {
        $req_full = "SELECT Suivants.Id,Vue.Nom,Vue.X,Vue.Y,Vue.N
                     FROM Suivants
                     INNER JOIN Vue on Suivants.Id = Vue.Id
                     WHERE Suivants.Id = '$gob_id'";

        $row = $db->query($req_full, true)->fetch_assoc();

        $X       = $row['X'];
        $Y       = $row['Y'];
        $N       = $row['N'];
        $cases   = 4;       # Hardcoded for now

        $getsuiv           = '&suivant=TRUE';
    }
    else
    {
        $req_full      = "SELECT PER,BMPER,BPPER,X,Y,N,Nom FROM Gobelins
                          INNER JOIN Gobelins2 on Gobelins.Id = Gobelins2.Id
                          WHERE Gobelins.Id = $gob_id";

        $row = $db->query($req_full, true)->fetch_assoc();

        $X       = $row['X'];
        $Y       = $row['Y'];
        $N       = $row['N'];
        $cases   = $row['PER'] + $row['BMPER'] + $row['BPPER'];

        $getsuiv           = '';

        # We use $_GET["cases"] to restrict the view
        if ( $_GET['cases'] AND preg_match('/^\d*$/', $_GET['cases'])) { $cases = $_GET['cases']; }

        # We use $_GET["x|y|n"] to center the view
        if ( $_GET["x"] ) { $X = $_GET["x"]; }
        if ( $_GET["y"] ) { $Y = $_GET["y"]; }
        if ( $_GET["n"] ) { $N = $_GET["n"]; }
    }

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

    $req_vue = "WHERE X      BETWEEN '$x_min'   AND '$x_max'
                AND   Y      BETWEEN '$y_min'   AND '$y_max'
                AND   N      BETWEEN '$n_min'   AND '$n_max'";

    # We use $_GET["lvl"] to restrict the view
    $niv_min     = 0;
    $niv_max     = 99;
    if ( $_GET['minlvl'] AND preg_match('/^\d*$/', $_GET['minlvl'])) { $niv_min = $_GET['minlvl']; }
    if ( $_GET['maxlvl'] AND preg_match('/^\d*$/', $_GET['maxlvl'])) { $niv_max = $_GET['maxlvl']; }
    $req_vue    .= " AND (Niveau BETWEEN '$niv_min' AND '$niv_max')";

    # We use $_GET["p|l|c|t"] to restrict the view
    $req_vue_items = "Categorie = 'G'";
    if ( $_GET['p'] ) { $req_vue_items .= " OR Categorie = 'P'"; }
    if ( $_GET['l'] ) { $req_vue_items .= " OR Categorie = 'L'"; }
    if ( $_GET['c'] ) { $req_vue_items .= " OR Categorie = 'C'"; }
    if ( $_GET['t'] ) { $req_vue_items .= " OR Categorie = 'T'"; }

    if ( $req_vue_items != "Categorie = 'G'" )
    {
        $req_vue .= " AND ($req_vue_items)";
    }

    $req_final = "(SELECT Id,Categorie,Nom,Niveau,X,Y,N,Z
                     FROM Vue
                     $req_vue)
                     UNION
                     (SELECT IdLieu,Categorie,Nom,Niveau,X,Y,N,Z
                     FROM global.FP_Lieu
                     $req_vue)";

    $query_vue = $db->query($req_final);

    $ITEMS = [];

    while ($row = $query_vue->fetch_array())
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
        elseif ( $cat == 'P' && $nom == 'Baie' && !preg_match('/1f352/', $ITEMS[$x][$y]['td']) )
        {
            $ITEMS[$x][$y]['td'] .= $B_emoji;
        }

        if ( !preg_match("/N = $n/", $ITEMS[$x][$y]['tt']) )
        {
            $ITEMS[$x][$y]['tt'] .= "&nbsp;&nbsp;<b>N = $n</b><br>";
        }

        $tt_text_c = 'black';
        if   ($cat == 'G')                                  { $tt_text_c = 'deepskyblue';};
        if   ($cat == 'C')                                  { $tt_text_c = 'orange';};
        if ( ($cat == 'C') && ( $id <= 14 ) )               { $tt_text_c = 'yellow';};
        if ( ($cat == 'C') && in_array($id,$arr_suivants) ) { $tt_text_c = 'springgreen';};

        if ($cat == 'G' or $cat == 'C')
        {
            $ITEMS[$x][$y]['tt'] .= "&nbsp;&nbsp;[$id] <span style='color:$tt_text_c'>".$nom.' (Niv. '.$niv.')'.'</span><br>';
        }
        else
        {
            $ITEMS[$x][$y]['tt'] .= "&nbsp;&nbsp;[$id] <span style='color:$tt_text_c'>".$nom.'</span><br>';
        }
    }

    print('        <h1>Vue de ['.$gob_id.'] '.$gob_nom.' ('.$cases.' cases)'.'</h1>'."\n");
    print('        <h3>Centrée sur [ X='.$X.' | Y= '.$Y.' | N= '.$N.' ]'.'</h3>'."\n");

    print('        <center>'."\n");
    print('        <form action="vue.php" method="get">'."\n");
    print('        <fieldset>'."\n");
    print('          <legend>Restreindre: </legend>'."\n");
    print('          <input id="id" name="id" type="hidden" value="'.$gob_id.'">'."\n");
    print('          <div>'."\n");
    print('            <input type="checkbox" id="ncourant" name="niveau" value="TRUE">'."\n");
    print('            <label for="ncourant">Niveau courant (N='.$N.')</label>'."\n");
    print('          </div>'."\n");
    print('          <div>'."\n");
    print('            <label for="minlvl">minLvl:</label>'."\n");
    print('            <input type="text" id="lvl" name="minlvl" placeholder="0" size="4">'."\n");
    print('            <label for="maxlvl">maxLvl:</label>'."\n");
    print('            <input type="text" id="lvl" name="maxlvl" placeholder="40" size="4">'."\n");
    print('          </div>'."\n");
    print('          <div>Vue: '."\n");
    print('            <input type="text" id="portee" name="cases" placeholder="'.$cases.'" size="3">'."\n");
    print('            <label for="cases">Case(s)</label>'."\n");
    print('          </div>'."\n");
    print('          <div>Seulement: '."\n");
    print('            <input type="checkbox" id="onlyp" name="p" value="TRUE">'."\n");
    print('            <label for="ncourant">Plantes</label>'."\n");
    print('            <input type="checkbox" id="onlyl" name="l" value="TRUE">'."\n");
    print('            <label for="ncourant">Lieux</label>'."\n");
    print('            <input type="checkbox" id="onlyc" name="c" value="TRUE">'."\n");
    print('            <label for="ncourant">Créatures</label>'."\n");
    print('            <input type="checkbox" id="onlyt" name="t" value="TRUE">'."\n");
    print('            <label for="ncourant">Trésors</label>'."\n");
    print('          </div>'."\n");
    print('          <div>Centrer sur: '."\n");
    print('            <label for="x">X=</label>'."\n");
    print('            <input type="text" id="center" name="x" placeholder="'.$X.'" size="4">'."\n");
    print('            <label for="y">Y =</label>'."\n");
    print('            <input type="text" id="center" name="y" placeholder="'.$Y.'" size="4">'."\n");
    print('            <label for="n">N =</label>'."\n");
    print('            <input type="text" id="center" name="n" placeholder="'.$N.'" size="4">'."\n");
    print('          </div>'."\n");
    print('          <div>'."\n");
    print('            <button type="submit">Go !</button>'."\n");
    print('          </div>'."\n");
    print('        </fieldset>'."\n");
    print('        </form>'."\n");
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

    $db->close;

    end:
?>
        </div> <!-- profilInfos -->
      </div> <!-- content -->
    </div> <!-- page -->
  </body>
</html>
