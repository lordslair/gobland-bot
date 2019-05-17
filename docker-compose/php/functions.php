<?php

function GetColor($pv_now,$pv_max)
{
    $green  = '#77EE77';
    $jaune  = '#EEEE77';
    $orange = '#EEAA77';
    $red    = '#B22222';

    $color  = '#FFFFFF';
    $percent = 100 * ($pv_now / $pv_max);

    if    ( $percent > 75 )
    {
        $color = $green;
    }
    elseif ( $percent > 50 )
    {
        $color = $jaune;
    }
    elseif ( $percent > 25 )
    {
        $color = $orange;
    }
    else
    {
        $color = $red;
    }
    return $color;
}

function GetColorFaim($faim)
{
    $green  = '#77EE77';
    $jaune  = '#EEEE77';
    $orange = '#EEAA77';
    $red    = '#B22222';

    $color  = '#FFFFFF';

    if    ( $faim < 15 )
    {
        $color = $green;
    }
    elseif ( $faim < 20 )
    {
        $color = $jaune;
    }
    elseif ( $faim < 30 )
    {
        $color = $orange;
    }
    else
    {
        $color = $red;
    }
    return $color;
}

function GetpDLA($dla_str,$duree_s)
{
    # $dla_str = 2019-01-30 19:40:16

    $dla  = strtotime(date($dla_str));
    $pdla = date("Y-m-d H:i:s", ($dla + $duree_s));

    return $pdla;
}

function GetDureeDLA($sec)
{
    $arr_dla = [];
    $DLA     = '';

    if ( $sec <= 60 )
    {
        $arr_dla = [($sec/(60*60))%24,$sec/60,$sec%60];
    }
    else
    {
        $arr_dla = [($sec/(60*60))%24,($sec/60)%60,$sec%60];
    }

    if ( $sec == abs($sec) )
    {
        $DLA = sprintf("%02d",$arr_dla[0]).'h'.sprintf("%02d",$arr_dla[1]);
    }
    else
    {
        if ( abs($arr_dla[1]) >= 60 )
        {
            $hour = abs($arr_dla[1]/60)%24;
            $min  = abs($arr_dla[1])%60;
            $DLA     = '-'.sprintf("%02d",$hour).'h'.sprintf("%02d",$min);
        }
        else
        {
            $DLA = '-'.sprintf("%02d",$arr_dla[0]).'h'.sprintf("%02d",abs($arr_dla[1]));
        }
    }
    return $DLA;
}

function GetStuffIcon($type,$nom)
{
    $png       = '';
    if ( ! $nom ) { $nom = ''; }

    if     ( $type == 'Armure' )                                      { $png = 'icon_04.png';  }
    elseif ( $type == 'Casque' )                                      { $png = 'icon_14.png';  }
    elseif ( $type == 'Bottes' )                                      { $png = 'icon_24.png';  }
    elseif ( $type == 'Arme 1 Main' and preg_match('/Hache/', $nom))  { $png = 'icon_52.png';  }
    elseif ( $type == 'Arme 1 Main' )                                 { $png = 'icon_47.png';  }
    elseif ( $type == 'Arme 2 mains' and preg_match('/Hache/', $nom)) { $png = 'icon_56.png';  }
    elseif ( $type == 'Arme 2 mains' )                                { $png = 'icon_45.png';  }
    elseif ( $type == 'Talisman' )                                    { $png = 'icon_18.png';  }
    elseif ( $type == 'Anneau' )                                      { $png = 'icon_29.png';  }
    elseif ( $type == 'Bouclier' )                                    { $png = 'icon_09.png';  }
    elseif ( $type == 'Baguette' )                                    { $png = 'icon_61.png';  }
    elseif ( $type == 'Bijou' )                                       { $png = 'icon_108.png'; }
    elseif ( $type == 'Nourriture' )                                  { $png = 'icon_74.png';  }
    elseif ( $type == 'Potion' )                                      { $png = 'icon_86.png';  }
    elseif ( $type == 'Composant' )                                   { $png = 'icon_102.png'; }
    elseif ( $type == 'Outil' )                                       { $png = 'icon_1083.png';}
    else   { $png = ''; }

    return '<img src="/images/stuff/'.$png.'">';
}

function GetMateriauIcon($nom)
{
    $png  = '';

    if     ( $nom == 'Rondin' )                { $png = '<img src="/images/stuff/icon_109.png"  title="'.$nom.'">'; }
    elseif ( $nom == 'Sable' )                 { $png = '<img src="/images/stuff/icon_1054.png" title="'.$nom.'">'; }
    elseif ( $nom == 'Minerai d\'Or' )         { $png = '<img src="/images/stuff/icon_1066.png" title="'.$nom.'">'; }
    elseif ( $nom == 'Minerai de Cuivre' )     { $png = '<img src="/images/stuff/icon_1067.png" title="'.$nom.'">'; }
    elseif ( $nom == 'Minerai d\'Argent' )     { $png = '<img src="/images/stuff/icon_1068.png" title="'.$nom.'">'; }
    elseif ( $nom == 'Minerai d\'Etain' )      { $png = '<img src="/images/stuff/icon_1069.png" title="'.$nom.'">'; }
    elseif ( $nom == 'Minerai de Mithril' )    { $png = '<img src="/images/stuff/icon_1070.png" title="'.$nom.'">'; }
    elseif ( $nom == 'Minerai d\'Adamantium' ) { $png = '<img src="/images/stuff/icon_1071.png" title="'.$nom.'">'; }
    elseif ( $nom == 'Minerai de Fer' )        { $png = '<img src="/images/stuff/icon_1072.png" title="'.$nom.'">'; }
    elseif ( $nom == 'Cuir' )                  { $png = '<img src="/images/stuff/icon_98.png"   title="'.$nom.'">'; }
    elseif ( $nom == 'Tissu' )                 { $png = '<img src="/images/stuff/icon_103.png"  title="'.$nom.'">'; }
    elseif ( $nom == 'Pierre' )                { $png = '<img src="/images/stuff/icon_1142.png" title="'.$nom.'">'; }
    elseif ( $nom == 'Fleur' )                 { $png = '<img src="/images/stuff/icon_1173.png" title="'.$nom.'">'; }
    elseif ( $nom == 'Champignon' )            { $png = '<img src="/images/stuff/icon_1174.png" title="'.$nom.'">'; }
    elseif ( $nom == 'Composant' )             { $png = '<img src="/images/stuff/icon_102.png"  title="'.$nom.'">'; }
    elseif ( $nom == 'Racine' )                { $png = '<img src="/images/stuff/icon_1155.png" title="'.$nom.'">'; }
    elseif ( $nom == 'Tas de Terre' )          { $png = '<img src="/images/stuff/icon_126.png"  title="'.$nom.'">'; }
    elseif ( $nom == 'Diamant' )               { $png = '<img src="/images/stuff/icon_1045.png" title="'.$nom.'">'; }
    elseif ( $nom == 'Emeraude' )              { $png = '<img src="/images/stuff/icon_1042.png" title="'.$nom.'">'; }
    elseif ( $nom == 'Obsidienne' )            { $png = '<img src="/images/stuff/icon_1040.png" title="'.$nom.'">'; }
    elseif ( $nom == 'Opale' )                 { $png = '<img src="/images/stuff/icon_1046.png" title="'.$nom.'">'; }
    elseif ( $nom == 'Rubis' )                 { $png = '<img src="/images/stuff/icon_1043.png" title="'.$nom.'">'; }
    elseif ( $nom == 'Saphir' )                { $png = '<img src="/images/stuff/icon_1041.png" title="'.$nom.'">'; }

    return $png;
}

function GetQualite($type,$quali_id)
{
    $quali_str = '';

    if ( $type == 'Matériau' or $type == 'Minerai' or $type == 'Roche' or $type == 'Pierre Précieuse' )
    {
        if     ( $quali_id == 0 ) { $quali_str = ''; } # AFAIK only used for Rondins
        elseif ( $quali_id == 1 ) { $quali_str = 'Médiocre'; }
        elseif ( $quali_id == 2 ) { $quali_str = 'Moyenne'; }
        elseif ( $quali_id == 3 ) { $quali_str = 'Normale'; }
        elseif ( $quali_id == 4 ) { $quali_str = 'Bonne'; }
        elseif ( $quali_id == 5 ) { $quali_str = '<b>Exceptionnelle</b>'; }
    }
    elseif ( $type == 'Composant' )
    {
        if     ( $quali_id == 0 ) { $quali_str = ''; } # AFAIK only used for non-IdT Plants
        elseif ( $quali_id == 1 ) { $quali_str = 'Très Mauvaise'; }
        elseif ( $quali_id == 2 ) { $quali_str = 'Mauvaise'; }
        elseif ( $quali_id == 3 ) { $quali_str = 'Moyenne'; }
        elseif ( $quali_id == 4 ) { $quali_str = 'Bonne'; }
        elseif ( $quali_id == 5 ) { $quali_str = '<b>Très Bonne</b>'; }
    }

    return $quali_str;
}

function GetCarats($quali_id,$quantite)
{
    if     ( $quali_id == 1 ) { $carats = $quantite * 2;    }
    elseif ( $quali_id == 2 ) { $carats = $quantite * 2.75; }
    elseif ( $quali_id == 3 ) { $carats = $quantite * 3.5;  }
    elseif ( $quali_id == 4 ) { $carats = $quantite * 4.25; }
    elseif ( $quali_id == 5 ) { $carats = $quantite * 5;    }
    elseif ( $quali_id == 'Médiocre'       ) { $carats = $quantite * 2;    }
    elseif ( $quali_id == 'Moyenne'        ) { $carats = $quantite * 2.75; }
    elseif ( $quali_id == 'Normale'        ) { $carats = $quantite * 3.5;  }
    elseif ( $quali_id == 'Bonne'          ) { $carats = $quantite * 4.25; }
    elseif ( $quali_id == 'Exceptionnelle' ) { $carats = $quantite * 5;    }
    else   { $carats = 0; }

    return  sprintf("%d", $carats);
}

function GetLuxe($type,$nom,$desc)
{
    $ok = '✅';

    if ( $type == 'Talisman' )
    {
        if     ( preg_match('/M.:[+]10 . R.:[+]10/', $desc ))                   { return $ok; }
        elseif ( preg_match('/...:[-]1 . M.:[+]20 . R.:[+]20/', $desc ))        { return $ok; }
        elseif ( preg_match('/...:[-]4 . M.:[+]40 . R.:[+]40/', $desc ))        { return $ok; }
    }
    elseif ( $type == 'Bouclier' )
    {
        if     ( preg_match('/Arm:[+]1 . ESQ:[+]1 . R.:[+]10/', $desc ))        { return $ok; } # Petit Bouclier
        elseif ( preg_match('/Arm:[+]2 . ESQ:[+]1 . R.:[+]15/', $desc ))        { return $ok; } # Grand Bouclier
    }
    elseif ( $type == 'Casque' )
    {
        if ( preg_match('/M.:[+]10/', $desc ))                                  { return $ok; }
        if ( preg_match('/R.:[+]10/', $desc ))                                  { return $ok; }
    }
    elseif ( $type == 'Bottes' )
    {
        if ( preg_match('/R.:[+]10/', $desc ))                                  { return $ok; }
    }
    elseif ( $type == 'Arme 1 Main' )
    {
        if     ( preg_match('/os$/', $nom))
        {
            if ( preg_match('/RT:[+]20/', $desc ))                              { return $ok; }
        }
        elseif ( $nom == 'Coutelas' )
        {
            if ( preg_match('/RM:[+]10/', $desc ))                              { return $ok; }
        }
        elseif ( $nom == 'Dague' )
        {
            if ( preg_match('/RC:[+]10/', $desc ))                              { return $ok; }
        }
        elseif ( $nom == 'Machette' )
        {
            if ( preg_match('/RR:[+]20/', $desc ))                              { return $ok; }
        }
    }
    elseif ( $type == 'Bijou' )
    {
        if    ( $nom == 'Breloques Familiales' )
        {
            if ( preg_match('/RR:[+]20/', $desc ))                              { return $ok; }
        }
        elseif ( $nom == 'Phalère Epineuse' )
        {
            if ( preg_match('/RC:[+]20/', $desc ))                              { return $ok; }
        }
    }
    elseif ( $type == 'Anneau' )
    {
        if ( $nom == 'Anneau Barbare' )
        {
            if ( preg_match('/MS:[-]5/', $desc ))                               { return $ok; }
        }
    }
    elseif ( $type == 'Armure' )
    {
        if ( preg_match('/ESQ:[+]1 . M.:[+]10 . R.:[+]10/', $desc ))            { return $ok; } # Armures Legères
        if ( preg_match('/ESQ:[+]2 . R.:[-]5 . R.:[+]50/', $desc ))             { return $ok; }
        if ( preg_match('/Arm:[+]2 . R.:[-]5 . R.:[+]5 . R.:[+]10/', $desc ))   { return $ok; }

        if ( preg_match('/ESQ:[-]1 . R.:[+]40/', $desc ))                       { return $ok; } # Armures Moyennes
        if ( preg_match('/ESQ:[-]3 . R.:[+]100/', $desc ))                      { return $ok; }

        if ( preg_match('/ESQ:[-]6 . R.:[+]200/', $desc ))                      { return $ok; } # Armures Lourdes
    }
}

function GetCraft($type,$nom,$desc,$template)
{
    $craft     = '⚒️';

    if ( $template )
    {
        if ( preg_match('/de Maître/', $template) ) { return $craft; }
    }
    else
    {
        if    ( $desc != '<b>Non Identifié</b>' )
        {
            if     ( ($nom == 'Bottes')             && ($desc != 'ESQ:+2') )                                     { return $craft; }
            elseif ( ($nom == 'Sandales')           && ($desc != 'ESQ:+1') )                                     { return $craft; }
            elseif ( ($nom == 'Targe')              && ($desc != 'ESQ:+1') )                                     { return $craft; }
            elseif ( ($nom == 'Gorgeron en cuir')   && ($desc != 'Arm:+1') )                                     { return $craft; }
            elseif ( ($nom == 'Gorgeron en métal')  && ($desc != 'Arm:+2 | REG:-1') )                            { return $craft; }
            elseif ( ($nom == 'Turban')             && ( !preg_match('/Arm:[+]1/', $desc) ) )                    { return $craft; }
            elseif ( ($nom == 'Collier à pointes')  && ($desc != 'Arm:+1 | DEG:+1 | ESQ:-1') )                   { return $craft; }
            elseif ( ($nom == 'Casque à pointes')   && ($desc != 'ATT:+1 | Arm:+3 | DEG:+1 | PER:-1') )          { return $craft; }
            elseif ( ($nom == 'Bouclier à pointes') && ($desc != 'ATT:+1 | Arm:+4 | DEG:+1 | ESQ:-1') )          { return $craft; }
            elseif ( ($nom == 'Gantelet')           && ($desc != 'ATT:-2 | Arm:+2 | DEG:+1 | ESQ:+1') )          { return $craft; }
            elseif ( ($nom == 'Casque à cornes')    && ($desc != 'ATT:+1 | Arm:+3 | DEG:+1 | ESQ:-1 | PER:-1') ) { return $craft; }
            elseif ( ($nom == 'Chapeau pointu')     && ( !preg_match('/DEG:-1 | PER:+1 | MM:+\d\d?/', $desc) ) ) { return $craft; }

            if     ( preg_match('/Temps:-5min/', $desc) )                                                        { return $craft; }
            if     ( $desc  == 'En cours de fabrication' )                                                       { return $craft; }
        }
    }
}

function GetSumCaracs($string,$hash)
{
    if ( preg_match('/ATT:[+](\d*)/',       $string, $arr_att ))   { $hash['ATT']           += $arr_att[1];}
    if ( preg_match('/ATT:[-](\d*)/',       $string, $arr_att ))   { $hash['ATT']           -= $arr_att[1];}
    if ( preg_match('/Arm\w*?:[+](\d*)/',   $string, $arr_arm ))   { $hash['Arm']           += $arr_arm[1];}
    if ( preg_match('/Arm\w*?:[-](\d*)/',   $string, $arr_arm ))   { $hash['Arm']           -= $arr_arm[1];}
    if ( preg_match('/DEG:[+](\d*)/',       $string, $arr_deg ))   { $hash['DEG']           += $arr_deg[1];}
    if ( preg_match('/DEG:[-](\d*)/',       $string, $arr_deg ))   { $hash['DEG']           -= $arr_deg[1];}
    if ( preg_match('/ESQ:[+](\d*)/',       $string, $arr_esq ))   { $hash['ESQ']           += $arr_esq[1];}
    if ( preg_match('/ESQ:[-](\d*)/',       $string, $arr_esq ))   { $hash['ESQ']           -= $arr_esq[1];}
    if ( preg_match('/PER:[+](\d*)/',       $string, $arr_per ))   { $hash['PER']           += $arr_per[1];}
    if ( preg_match('/PER:[-](\d*)/',       $string, $arr_per ))   { $hash['PER']           -= $arr_per[1];}
    if ( preg_match('/REG:[+](\d*)/',       $string, $arr_reg ))   { $hash['REG']           += $arr_reg[1];}
    if ( preg_match('/REG:[-](\d*)/',       $string, $arr_reg ))   { $hash['REG']           -= $arr_reg[1];}
    if ( preg_match('/Tour:[+](\d*)min/',   $string, $arr_tour ))  { $hash['Tour']          += $arr_tour[1];}
    if ( preg_match('/Tour:[-](\d*)min/',   $string, $arr_tour ))  { $hash['Tour']          -= $arr_tour[1];}

    if ( preg_match('/([R|M]\w):[+](\d*)/', $string, $arr_magie )) { $hash["$arr_magie[1]"] += $arr_magie[2];}
    if ( preg_match('/([R|M]\w):[-](\d*)/', $string, $arr_magie )) { $hash["$arr_magie[1]"] -= $arr_magie[2];}

    return $hash;
}

function GetCompo($type,$nom,$qualite)
{
    $db_file = '/db/'.$_ENV["DBNAME"];
    $db      = new SQLite3($db_file);
    if(!$db) { echo $db->lastErrorMsg(); }

    $ok = ' ✅';
    $ko = ' 🔴';

    $nom = preg_replace('/\'/', '\'\'', $nom);

    if ( $type == 'Plante' )
    {
        if     ( $qualite == 'Amer' ) { $q_nbr = 1; }
        elseif ( $qualite == 'Acide' ) { $q_nbr = 2; }
        elseif ( $qualite == 'Plip'  ) { $q_nbr = 3; }
        elseif ( $qualite == 'Plop'  ) { $q_nbr = 4; }
        elseif ( $qualite == 'Sucré' ) { $q_nbr = 5; }
    }
    elseif ( $type == 'Composant' )
    {
        if     ( $qualite == 'Très Mauvaise' ) { $q_nbr = 1; }
        elseif ( $qualite == 'Mauvaise'      ) { $q_nbr = 2; }
        elseif ( $qualite == 'Moyenne'       ) { $q_nbr = 3; }
        elseif ( $qualite == 'Bonne'         ) { $q_nbr = 4; }
        elseif ( $qualite == 'Très Bonne'    ) { $q_nbr = 5; }
    }

    # Check if compo present in Cavernes
    $req_stock = "SELECT COUNT (*)
                  FROM ItemsCavernes
                  WHERE ( Nom = '$nom' AND Qualite = '$q_nbr' )";
    $res_stock = $db->querySingle($req_stock);

    # Check if compo present in Equipement
    $req_equip = "SELECT COUNT (*)
                  FROM ItemsGobelins
                  WHERE ( Nom = '$nom' AND Qualite = '$q_nbr' )";
    $res_equip = $db->querySingle($req_equip);

    if ( $res_stock > 0 || $res_equip > 0 )
    {
        return $ok; # Composant found in either Cavernes or Equipement
    }
    else
    {
        return $ko; # Composant not found
    }
}

?>
