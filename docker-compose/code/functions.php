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

    if     ( $nom == 'Rondin' )                { $png = '<img src="/images/stuff/icon_109.png">';  }
    elseif ( $nom == 'Sable' )                 { $png = '<img src="/images/stuff/icon_1054.png">'; }
    elseif ( $nom == 'Minerai d\'Or' )         { $png = '<img src="/images/stuff/icon_1066.png">'; }
    elseif ( $nom == 'Minerai de Cuivre' )     { $png = '<img src="/images/stuff/icon_1067.png">'; }
    elseif ( $nom == 'Minerai d\'Argent' )     { $png = '<img src="/images/stuff/icon_1068.png">'; }
    elseif ( $nom == 'Minerai d\'Etain' )      { $png = '<img src="/images/stuff/icon_1069.png">'; }
    elseif ( $nom == 'Minerai de Mithril' )    { $png = '<img src="/images/stuff/icon_1070.png">'; }
    elseif ( $nom == 'Minerai d\'Adamantium' ) { $png = '<img src="/images/stuff/icon_1071.png">'; }
    elseif ( $nom == 'Minerai de Fer' )        { $png = '<img src="/images/stuff/icon_1072.png">'; }
    elseif ( $nom == 'Cuir' )                  { $png = '<img src="/images/stuff/icon_98.png">';   }
    elseif ( $nom == 'Tissu' )                 { $png = '<img src="/images/stuff/icon_103.png">';  }
    elseif ( $nom == 'Pierre' )                { $png = '<img src="/images/stuff/icon_1142.png">'; }
    elseif ( $nom == 'Fleur' )                 { $png = '<img src="/images/stuff/icon_1173.png">'; }
    elseif ( $nom == 'Champignon' )            { $png = '<img src="/images/stuff/icon_1174.png">'; }
    elseif ( $nom == 'Composant' )             { $png = '<img src="/images/stuff/icon_102.png">';  }
    elseif ( $nom == 'Racine' )                { $png = '<img src="/images/stuff/icon_1155.png">'; }

    return $png;
}

function GetQualite($type,$quali_id)
{
    $quali_str = '';

    if ( $type == 'Matériau' or $type == 'Minerai' or $type == 'Roche' )
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
    else   { $carats = 0; }

    return  sprintf("%d", $carats);
}

function GetLuxe($type,$nom,$desc)
{
    $ok = ' <img height="10px" width="10px" src="/images/stuff/OK.png">';

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
        elseif ( preg_match('/^Phal.re Epineuse$/', $nom))
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
    $craft     = ' <img height="10px" width="10px" src="/images/stuff/craft.png">';

    if ( $template )
    {
        if ( preg_match('/de Maître/', $template) ) { return $craft; }
    }
    else
    {
        if    ( $desc != '<b>Non Identifié</b>' )
        {
            if     ( ($nom == 'Bottes')           && ($desc != 'ESQ:+2') )         { return $craft; }
            elseif ( ($nom == 'Sandales')         && ($desc != 'ESQ:+1') )         { return $craft; }
            elseif ( ($nom == 'Gorgeron en cuir') && ($desc != 'Arm:+1') )         { return $craft; }
            elseif ( ($nom == 'Targe')            && ($desc != 'ESQ:+1') )         { return $craft; }

            if     ( ($type == 'Armure') && (preg_match('/Temps:-5min/', $desc)) ) { return $craft; }
        }
    }
}

?>
