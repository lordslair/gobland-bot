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

    $db_file = '/db/'.$_ENV["DBNAME"];
    $db      = new SQLite3($db_file);
    if(!$db) { echo $db->lastErrorMsg(); }

    $req_gob_nom       = "SELECT Gobelin FROM Gobelins WHERE Id = '$gob_id'";
    $gob_nom           = $db->querySingle($req_gob_nom);

    print('        <h1>Profil de ['.$gob_id.'] '.$gob_nom.'</h1>'."\n");
    print('        <div id="profilInfos">'."\n");

    $req_gob_full      = "SELECT Gobelins.Id,Gobelin,Tribu,Niveau,X,Y,N,PA,PV,PVMax,CT,
                                 Gobelins2.DLA AS DLA_s,BPDLA,BMDLA,Gobelins.DLA,
                                 ATT,BPATT,BMATT,
                                 ESQ,BPESQ,BMESQ,
                                 DEG,BPDEG,BMDEG,
                                 REG,BPREG,BMREG,
                                 PER,BPPER,BMPER,
                                 BPArm,BMArm,
                                 PV,PVMax,Faim
                          FROM Gobelins
                          INNER JOIN Gobelins2 on Gobelins.Id = Gobelins2.Id
                          WHERE Gobelins.Id = '$gob_id'";
    $row = $db->querySingle($req_gob_full, true);
    $db->close;

    $position  = $row['X'].', '.$row['Y'].', '.$row['N'];

    $duree_b   = GetDureeDLA($row['DLA_s']);
    $duree_p   = GetDureeDLA($row['BPDLA']);
    $duree_bm  = GetDureeDLA($row['BMDLA']);

    $duree_s   = $row['DLA'] + $row['BPDLA'] + $row['BMDLA'];
    $duree_t   = GetDureeDLA($duree_s);

    $faim_png  = '<img src="/images/stuff/icon_74.png">';
    $ct_png    = '<img src="/images/stuff/icon_111.png">';

    $pdla      = GetpDLA($row['DLA'], $duree_s);

    print('        <fieldset>'."\n");
    print('          <legend>Caractéristiques</legend>'."\n");
    print('          <strong>Tribu</strong> : '.$row['Tribu'].'<br/>'."\n");
    print('          <strong>Niveau</strong> : '.$row['Niveau'].'<br/>'."\n");
    print('          <strong>Date Limite d\'Action</strong> : '.$row['DLA'].'<br/>'."\n");
    print('          <strong>Position</strong> : '.$position.'<br/>'."\n");
    print('          <br>'."\n");
    print('          <strong>ATT</strong> : '.$row['ATT'].'D '.sprintf("%+d",$row['BPATT']).' '.sprintf("%+d",$row['BMATT']).'<br/>'."\n");
    print('          <strong>ESQ</strong> : '.$row['ESQ'].'D '.sprintf("%+d",$row['BPESQ']).' '.sprintf("%+d",$row['BMESQ']).'<br/>'."\n");
    print('          <strong>DEG</strong> : '.$row['DEG'].'D '.sprintf("%+d",$row['BPDEG']).' '.sprintf("%+d",$row['BMDEG']).'<br/>'."\n");
    print('          <strong>REG</strong> : '.$row['REG'].'D '.sprintf("%+d",$row['BPREG']).' '.sprintf("%+d",$row['BMREG']).'<br/>'."\n");
    print('          <strong>PER</strong> : '.$row['PER'].' ' .sprintf("%+d",$row['BPPER']).' '.sprintf("%+d",$row['BMPER']).'<br/>'."\n");
    print('          <strong>ARM</strong> : '.$row['BPArm'].' ' .sprintf("%+d",$row['BMArm']).'<br/>'."\n");
    print('          <strong>PVs</strong> : '.$row['PV'].' / '.$row['PVMax'].'<br/>'."\n");
    print('          <br>'."\n");
    print('          <strong>'.$faim_png.'Faim</strong> : '.$row['Faim'].'<br/>'."\n");
    print('          <br>'."\n");
    print('          <strong>Durée normale du tour</strong> : '.$duree_b.'<br/>'."\n");
    print('          <strong>Bonus / Malus de durée</strong> : '.$duree_bm.'<br/>'."\n");
    print('          <strong>Augmentation due aux blessures</strong> : [A CODER]</span><br/>'."\n");
    print('          <strong>Poids des possessions</strong> : '.$duree_p.'</span><br/>'."\n");
    print('          <strong>Duree totale du tour</strong> : '.$duree_t.'</span><br/>'."\n");
    print('          <strong>Prochaine DLA</strong> : '.$pdla.'</span><br/>'."\n");
    print('          <br>'."\n");
    print('          <strong>'.$ct_png.'Canines de Trolls</strong> : '.$row['CT'].' CT<br/>'."\n");
    print('        </fieldset>'."\n");

    # Affinites
    print('        <fieldset>'."\n");
    print('          <legend>Affinités</legend>'."\n");

    $req_aff = "SELECT MM,BMM,
                       RM,BRM,
                       MT,BMT,
                       RT,BRT,
                       MR,BMR,
                       RR,BRR,
                       MS,BMS,
                       RS,BRS,
                       MC,BMC,
                       RC,BRC,
                       MP,BMP,
                       RP,BRP
                FROM Gobelins2
                WHERE Id = '$gob_id'";
    $row = $db->querySingle($req_aff, true);
    $db->close;

    $style = 'style="border: 0px;float: left;margin: 0px;font-family: courier;font-size: 12px;"';

    print('            <table '.$style.'>'."\n");

    $arr_ecoles    = ['M','T','R','S','C','P'];
    $arr_rms       = ['M','R'];

    foreach ( $arr_ecoles as $ecole )
    {
        print('              <tr>'."\n");
        foreach ( $arr_rms as $rm )
        {
            $affinite = $rm.$ecole;
            $sum = $row[$affinite]+$row['B'.$affinite];
            $aff = $row[$affinite];
            $bon = sprintf("%+d",$row['B'.$affinite]);

            print('              <td style="border: 0px;text-align: left;padding: 1px;font-size: 12px;">'."\n");
            print('                <strong>'.$affinite.'</strong> : '.$sum.' ('.$aff.$bon.')'."\n");
            print('              </td>'."\n");
        }
        print('              </tr>'."\n");
    }

    print('          </table>'."\n");
    print('        </fieldset>'."\n");

    # Suivants
    print('        <fieldset>'."\n");
    print('          <legend>Suivants</legend>'."\n");

    $req_suivants   = "SELECT Suivants.Id,Suivants.Nom,Vue.Niveau,Vue.X,Vue.Y,Vue.N
                       FROM Suivants
                       INNER JOIN Vue on Suivants.Id = Vue.Id
                       WHERE Suivants.IdGob = '$gob_id'
                       ORDER BY Suivants.Id";
    $query_suivants = $db->query($req_suivants);

    $arr_links = [];
    $arr_nivs  = [];

    while ($row = $query_suivants->fetchArray())
    {
        $suivant_id  = $row[0];
        $suivant_nom = $row[1];
        $suivant_niv = $row[2];
        $X           = $row[3];
        $Y           = $row[4];
        $N           = $row[5];
        $title       = '[ X='.$X.' | Y= '.$Y.' | N= '.$N.' ] '.$suivant_nom;
        $link        = '<a href="/vue.php?id='.$suivant_id.'&suivant=TRUE" title="'.$title.'">'.$suivant_nom.'</a>';

        $arr_links[$suivant_id] = $link;
        $arr_nivs[$suivant_id]  = $suivant_niv;
    }
    $db->close;

    $req_suivants_all   = "SELECT Id,IdGob,Nom
                           FROM Suivants
                           WHERE IdGob = '$gob_id'
                           ORDER BY Id";
    $query_suivants_all = $db->query($req_suivants_all);

    while ($row = $query_suivants_all->fetchArray())
    {
        $suivant_id  = $row[0];
        $suivant_nom = $row[2];
        $suivant_actions = GetSuivantsActions($gob_id,$suivant_id);
        $suivant_amelios = GetSuivantsAmelios($gob_id,$suivant_id);

            if ( $arr_links[$suivant_id] )
            {
                $suivant_niv = $arr_nivs[$suivant_id];
                $link        = $arr_links[$suivant_id];

                print('          <li>'."\n");
                print('            '.$suivant_actions.' '."\n");
                print('            '.$suivant_amelios.' '."\n");
                print('            ['.$suivant_id.'] '.$link.' (Niv. '.$suivant_niv.')'."\n");
                print('          </li>'."\n");
            }
            else
            {
                print('          <li>'."\n");
                print('            '.$suivant_actions.' '."\n");
                print('            '.$suivant_amelios.' '."\n");
                print('            ['.$suivant_id.'] '.$suivant_nom."\n");
                print('          </li>'."\n");
            }
    }
    $db->close;
    print('        </fieldset>'."\n");

    # Cafards
    $CARACS = [];
    print('        <fieldset>'."\n");
    print('          <legend>Cafards</legend>'."\n");

    $req_cafards   = "SELECT IdCafard,Type,Effet,PNG
                      FROM Cafards
                      WHERE Id = '$gob_id'";
    $query_cafards = $db->query($req_cafards);

    while ($row = $query_cafards->fetchArray())
    {
        print('          <li><img src="'.$row[3].'"> ['.$row[0].'] '.$row[1].' ('.$row[2].')</li>'."\n");
        $CARACS = GetSumCaracs($row[2],$CARACS);
    }
    $db->close;

    print('          </br>'."\n");
    print('          </br>'."\n");
    print('          <li style="border: 0px;float: left;margin: 0px;font-family: courier;font-size: 12px;"> Total: | ');
    foreach ( $CARACS as $carac => $value )
    {
        if ( $value != 0 )
        {
            printf ("<b>%s</b>:%+d | ", $carac,$value);
        }
    }
    print('</li>'."\n");
    print('        </fieldset>'."\n");

    # Meute
    print('        <fieldset>'."\n");

    $req_meute_id = "SELECT IdMeute  FROM Meutes WHERE Id = $gob_id";
    $meute_id     = $db->querySingle($req_meute_id);
    $db->close;

    if ( $meute_id )
    {
        $req_meute_nom = "SELECT NomMeute FROM Meutes WHERE Id = $gob_id";
        $meute_nom     = $db->querySingle($req_meute_nom);
        print('          <legend>Meute ['.$meute_id.'] '.$meute_nom.'</legend>'."\n");

        $req_meute   = "SELECT Id,Nom,Tribu,Niveau,X,Y,N,PV
                        FROM Meutes
                        WHERE IdMeute = '$meute_id'";
        $query_meute = $db->query($req_meute);

        print('          <table cellspacing="0" id="trollsList" style="margin-right:auto;margin-left:0px">'."\n");
        print('            <tr>'."\n");
        print('              <th>Pseudo</th>'."\n");
        print('              <th>Num</th>'."\n");
        print('              <th>Race</th>'."\n");
        print('              <th>Niv.</th>'."\n");
        print('              <th>Position</th>'."\n");
        print('              <th>PV</th>'."\n");
        print('              <th>Carte</th>'."\n");
        print('            </tr>'."\n");

        $rowspan = 0;
        while ($row = $query_meute->fetchArray())
        {
            print('            <tr>'."\n");
            $position = "<b>X</b> = $row[4] | <b>Y</b> = $row[5] | <b>N</b> = $row[6]";

            print('              <td>'."\n");
            print('                <a href="http://games.gobland.fr/Profil.php?IdPJ='.$row[0].'" target="_blank">'.$row[1].'</a>'."\n");
            print('              </td>'."\n");
            print('              <td>'.$row[0].'</td>'."\n");
            print('              <td>'.$row[2].'</td>'."\n");
            print('              <td>'.$row[3].'</td>'."\n");
            print('              <td>'.$position.'</td>'."\n");
            print('              <td>'.$row[7].' PV</td>'."\n");

            if ( $rowspan == 0 )
            {
                $arr_colors = ["AliceBlue","AntiqueWhite","Aqua","Aquamarine","Azure",
                               "Beige","Bisque","Black","BlanchedAlmond","Blue",
                               "BlueViolet","Brown","BurlyWood","CadetBlue","Chartreuse",
                               "Chocolate","Coral","CornflowerBlue","Cornsilk","Crimson"];

                $req_carte = "SELECT Id,Nom,X,Y,N
                              FROM Meutes
                              WHERE IdMeute = '$meute_id'";
                $query_carte = $db->query($req_carte);

                print('              <td rowspan="10">'."\n");
                print('                <svg version="1.2" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" class="minigraph" role="img">'."\n");
                print('                  <g class="grid x-grid" id="xGrid"><line x1="100" x2="100" y1="000" y2="200"></line></g>'."\n");
                print('                  <g class="grid y-grid" id="yGrid"><line x1="000" x2="200" y1="100" y2="100"></line></g>'."\n");

                while ($row = $query_carte->fetchArray())
                {
                    $color    = $arr_colors[array_rand($arr_colors, 1)];
                    $cx       = round(100 + $row[2]/2);
                    $cy       = round(100 - $row[3]/2);
                    $position = "<b>X</b> = $row[2] | <b>Y</b> = $row[3] | <b>N</b> = $row[4]";
                    $tt       = '\''.'['.$row[0].'] '.$row[1].' ('.$position.')\'';

                    print('                  <g fill="'.$color.'">'."\n");
                    print('                    <circle cx="'.$cx.'" cy="'.$cy.'" r="4" onmousemove="showTooltip(evt, '.$tt.')";" onmouseout="hideTooltip();"></circle>'."\n");
                    print('                  </g>'."\n");
                }

                print('                </svg>'."\n");
                print('              </td>'."\n");
            }
            print('            </tr>'."\n");
            $rowspan++;
        }
        $db->close;

        print('          </table>'."\n");
    }
    else
    {
        print('          <legend>Meute</legend>'."\n");
    }
    print('        </fieldset>'."\n");

    # Talents
    print('        <fieldset>'."\n");
    print('          <legend>Talents</legend>'."\n");
    print('          <strong>Competences</strong> :<br/>'."\n");
    print('          <ul>'."\n");

    $req_talents_c   = "SELECT IdGob,Skills.IdSkill,Niveau,Connaissance,NomSkill,Tooltip
                        FROM Skills
                        INNER JOIN FP_C on Skills.IdSkill = FP_C.IdSkill
                        WHERE Skills.Type = 'C' AND Skills.IdGob = '$gob_id'";
    $query_talents_c = $db->query($req_talents_c);

    while ($row = $query_talents_c->fetchArray())
    {
        $niveau  = $row[2];
        $percent = $row[3];
        $nom     = $row[4];
        $tt      = $row[5];

        if ( $tt )
        {
            print('            <li>'."\n");
            print('              <div class="tt_r">'."\n");
            print('                '.$nom.' ('.$percent.' %) [Niv. '.$niveau.']'."\n");
            print('                <span class="tt_r_text">'.$tt.'</span>'."\n");
            print('              </div>'."\n");
            print('            </li>'."\n");
        }
        else
        {
            print('            <li>'.$nom.' ('.$percent.' %) [Niv. '.$niveau.']</li>'."\n");
        }
    }
    $db->close;

    print('          </ul>'."\n");
    print('          <strong>Techniques</strong> :<br/>'."\n");
    print('          <ul>'."\n");

    $req_talents_t   = "SELECT IdGob,Skills.IdSkill,Niveau,Connaissance,NomSkill,Tooltip
                        FROM Skills
                        INNER JOIN FP_T on Skills.IdSkill = FP_T.IdSkill
                        WHERE Skills.Type = 'T' AND Skills.IdGob = '$gob_id'";
    $query_talents_t = $db->query($req_talents_t);

    while ($row = $query_talents_t->fetchArray())
    {
        $niveau  = $row[2];
        $percent = $row[3];
        $nom     = $row[4];
        $tt      = $row[5];

        if ( $tt )
        {
            print('            <li>'."\n");
            print('              <div class="tt_r">'."\n");
            print('                '.$nom.' ('.$percent.' %) [Niv. '.$niveau.']'."\n");
            print('                <span class="tt_r_text">'.$tt.'</span>'."\n");
            print('              </div>'."\n");
            print('            </li>'."\n");
        }
        else
        {
            print('            <li>'.$nom.' ('.$percent.' %) [Niv. '.$niveau.']</li>'."\n");
        }
    }
    $db->close;

    print('          </ul>'."\n");
    print('        </fieldset>'."\n");

    # Equipement
    $CARACS = [];
    print('        <fieldset>'."\n");
    print('          <legend>Equipement Porté</legend>'."\n");

    $req_equipement = "SELECT Id,Type,Nom,Magie,Desc,Matiere
                       FROM ItemsGobelins
                       WHERE Utilise = 'VRAI' AND Gobelin = '$gob_id'";
    $query_equipement = $db->query($req_equipement);

    while ($row = $query_equipement->fetchArray())
    {
        $type     = $row[1];
        $nom      = $row[2];
        $template = '';
        if ( $row[3] ) { $template = '<b>'.$row[3].'</b>'; }
        $desc     = $row[4];
        if ( $row[5] ) { $nom .= ' en '.$row[5]; } # Fix for 'en Pierre' equipements

        $item_png = GetStuffIcon($type, $nom);
        $luxe     = GetLuxe($type,$nom,$desc);
        $craft    = GetCraft($type,$nom,$desc,$template);

        if ( preg_match('/Diamant|Obsidienne|Opale|Saphir|Emeraude|Rubis/', $nom, $matches) )
        {
            $nom = preg_replace("/en $matches[0]/", "<b> en $matches[0]</b>", $nom);
        }
        if ( preg_match('/Adamantium|Argent|Or|Cuivre|Mithril|Etain/', $nom, $matches) )
        {
            $nom = preg_replace("/en $matches[0]/", "<b> en $matches[0]</b>", $nom);
        }

        $item_txt = '['.$row[0].'] '.$type.' : '.$nom.' '.$template.' ('.$desc.') '.$luxe.' '.$craft.'<br>';
        print('              '.$item_png.$item_txt."\n");
        $CARACS = GetSumCaracs($desc,$CARACS);
    }
    $db->close;

    asort($CARACS);
    print('          </br>'."\n");
    print('          </br>'."\n");
    print('          <li style="border: 0px;float: left;margin: 0px;font-family: courier;font-size: 12px;"> Total: | ');
    foreach ( $CARACS as $carac => $value )
    {
        if ( $value != 0 )
        {
            printf ("<b>%s</b>:%+d | ", $carac,$value);
        }
    }
    print('</li>'."\n");

    print('        </fieldset>'."\n");

end:
?>
        </div> <!-- profilInfos -->
      </div> <!-- content -->
      <script type="text/javascript" src="/js/tt-gps.js"></script>
    </div> <!-- page -->
  </body>
</html>
