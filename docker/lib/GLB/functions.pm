package GLB::functions;

use warnings;
use strict;

sub GetComps
{
    my %SKILLS;
    my $skills_csv = '/home/gobland-bot/data/FP_Skill.csv';
    open (my $fh, '<:encoding(Latin1)', $skills_csv) or die "Could not open file '$skills_csv' $!";
        while (my $row = <$fh>)
        {
            $row =~ s/"//g;
            my @row = split /;/, $row;
            $SKILLS{$row[0]}{'Nom'} = Encode::encode_utf8($row[1]);
        }
    close($fh);
    return \%SKILLS;
}

sub GetCompsTT
{
    my $gob_id     = shift;
    my $skills_ref = shift;
    my %skills     = %{$skills_ref};
    my $gobs2_ref  = shift;
    my %gobs2      = %{$gobs2_ref};

    my %SKILLS_TT;

    foreach my $t_id ( sort keys %{$skills{$gob_id}{'Talents'}{'C'}} )
    {
        # Connaissance des Monstres
        if ( $t_id == 1 )
        {
            my $vue = $gobs2{$gob_id}{'PER'} + $gobs2{$gob_id}{'BPPER'} + $gobs2{$gob_id}{'BMPER'};
            $SKILLS_TT{$gob_id}{'C'}{$t_id}{'tt'} = Encode::decode_utf8('Portée').' : '.$vue.' Case(s)';
        }
        # Mouvement Rapide
        if ( $t_id == 2 )
        {
            my $niveau  = $skills{$gob_id}{'Talents'}{'C'}{$t_id}{'Niveau'};
            my $proba;
            if    ( $niveau == 1 ) { $proba = 10 }
            elsif ( $niveau == 2 ) { $proba = 12 }
            elsif ( $niveau == 2 ) { $proba = 14 }
            elsif ( $niveau == 2 ) { $proba = 16 }
            $SKILLS_TT{$gob_id}{'C'}{$t_id}{'tt'} = 'Proba. : '.$proba.'%';
        }
        # Jet de Pierres
        if ( $t_id == 9 )
        {
            my $vue     = $gobs2{$gob_id}{'PER'} + $gobs2{$gob_id}{'BPPER'} + $gobs2{$gob_id}{'BMPER'};
            my $niveau  = $skills{$gob_id}{'Talents'}{'C'}{$t_id}{'Niveau'};
            my $portee  = ($vue, $niveau)[$vue > $niveau];
            $SKILLS_TT{$gob_id}{'C'}{$t_id}{'tt'} = Encode::decode_utf8('Portée').' : '.$portee.' Case(s)';
        }
        # Flairer le gibier
        # Herboriser
        elsif ( $t_id == 18 or $t_id == 21 )
        {
            my $vue     = $gobs2{$gob_id}{'PER'} + $gobs2{$gob_id}{'BPPER'} + $gobs2{$gob_id}{'BMPER'};
            my $niveau  = $skills{$gob_id}{'Talents'}{'C'}{$t_id}{'Niveau'};
            my $coeff;
            if    ( $niveau == 1 ) { $coeff = 1.5 }
            elsif ( $niveau == 2 ) { $coeff = 2   }
            elsif ( $niveau == 3 ) { $coeff = 2.5 }
            elsif ( $niveau == 4 ) { $coeff = 3   }
            my $portee  = sprintf("%d",$coeff * $vue);
            $SKILLS_TT{$gob_id}{'C'}{$t_id}{'tt'} = Encode::decode_utf8('Portée').' : '.$portee.' Case(s)';
        }
    }
    foreach my $t_id ( sort keys %{$skills{$gob_id}{'Talents'}{'T'}} )
    {
        # Rafale Psychique
        if ( $t_id == 2 )
        {
            my $niveau  = $skills{$gob_id}{'Talents'}{'T'}{$t_id}{'Niveau'};
            my $coeff;
            my $coeff_b;
            my $coeff_r;
            my $malus;
            my $malus_r;
            if    ( $niveau == 1 ) { $coeff = 1; $coeff_b = 1; $coeff_r = 0.3; $malus = 0  ; $malus_r = 0   }
            elsif ( $niveau == 2 ) { $coeff = 1; $coeff_b = 1; $coeff_r = 0.4; $malus = 0.5; $malus_r = 0   }
            elsif ( $niveau == 3 ) { $coeff = 1; $coeff_b = 1; $coeff_r = 0.5; $malus = 1  ; $malus_r = 0.5 }
            elsif ( $niveau == 4 ) { $coeff = 1; $coeff_b = 1; $coeff_r = 0.6; $malus = 2  ; $malus_r = 1   }
            my $reg      = $gobs2{$gob_id}{'REG'};
            my $deg      = $gobs2{$gob_id}{'DEG'};
            my $deg_bmm  = $gobs2{$gob_id}{'BMDEG'};
            my $deg_full = $coeff*$deg + $coeff_b*$deg_bmm;
            my $deg_r    = sprintf("%d",$coeff_r*$deg);
            my $reg_full = sprintf("%d",$malus*$reg);
            my $reg_r    = sprintf("%d",$malus_r*$reg);
            $SKILLS_TT{$gob_id}{'T'}{$t_id}{'tt'}  = 'Si full'.'<br>';
            $SKILLS_TT{$gob_id}{'T'}{$t_id}{'tt'} .= 'DEG : '.$deg_full.'<br>';
            $SKILLS_TT{$gob_id}{'T'}{$t_id}{'tt'} .= 'Malus : REG -'.$reg_full.'<br>';
            $SKILLS_TT{$gob_id}{'T'}{$t_id}{'tt'} .= '<br>';
            $SKILLS_TT{$gob_id}{'T'}{$t_id}{'tt'} .= Encode::decode_utf8('Si resisté').'<br>';
            $SKILLS_TT{$gob_id}{'T'}{$t_id}{'tt'} .= 'DEG : '.$deg_r.'<br>';
            $SKILLS_TT{$gob_id}{'T'}{$t_id}{'tt'} .= 'Malus : REG -'.$reg_r.'<br>';
        }
        # Attaque a double tranchant
        elsif ( $t_id == 7 )
        {
            my $niveau  = $skills{$gob_id}{'Talents'}{'T'}{$t_id}{'Niveau'};
            my $coeff;
            if    ( $niveau == 1 ) { $coeff = 5 }
            elsif ( $niveau == 2 ) { $coeff = 4 }
            elsif ( $niveau == 3 ) { $coeff = 3 }
            elsif ( $niveau == 4 ) { $coeff = 2 }
            $SKILLS_TT{$gob_id}{'T'}{$t_id}{'tt'} = 'Bonus : +1 / '.$coeff.'PVs';
        }
        # Projectile d'Ombre
        elsif ( $t_id == 9 )
        {
            my $niveau  = $skills{$gob_id}{'Talents'}{'T'}{$t_id}{'Niveau'};
            my $coeff;
            my $mod;
            if    ( $niveau == 1 ) { $coeff = 4; $mod = 0 }
            elsif ( $niveau == 2 ) { $coeff = 4; $mod = 1 }
            elsif ( $niveau == 3 ) { $coeff = 5; $mod = 0 }
            elsif ( $niveau == 4 ) { $coeff = 5; $mod = 1 }

            my $per     = $gobs2{$gob_id}{'PER'};
            my $per_bmm = $gobs2{$gob_id}{'BMPER'};
            my $att     = $gobs2{$gob_id}{'ATT'};
            my $att_bmm = $gobs2{$gob_id}{'BMATT'};

            my $vue     = $gobs2{$gob_id}{'PER'} + $gobs2{$gob_id}{'BPPER'} + $gobs2{$gob_id}{'BMPER'};
            my $portee;
            if    ( $vue <=  4 ) { $portee = 1 }
            elsif ( $vue <=  9 ) { $portee = 2 }
            elsif ( $vue <= 15 ) { $portee = 3 }
            elsif ( $vue <= 22 ) { $portee = 4 }
            elsif ( $vue <= 30 ) { $portee = 5 }
            elsif ( $vue <= 39 ) { $portee = 6 }
            my $po_deg     = ( $att + $per ) /2;
            my $po_deg_bmm = ( $att_bmm + $per_bmm ) /2;
            my $po_att     = (($per+$att)/2);
            my $po_att_bmm = ( $att_bmm + $per_bmm ) /2;

            $SKILLS_TT{$gob_id}{'T'}{$t_id}{'tt'}  = Encode::decode_utf8('Portée').' : '.$portee.' Case(s)'.'<br>';
            $SKILLS_TT{$gob_id}{'T'}{$t_id}{'tt'} .= '<br>';
            $SKILLS_TT{$gob_id}{'T'}{$t_id}{'tt'} .= 'Si cible < '.$coeff.' Cases'.'<br>';
            $SKILLS_TT{$gob_id}{'T'}{$t_id}{'tt'} .= 'ATT : '.$po_att.' D6 + '.$po_att_bmm.'<br>';
            $SKILLS_TT{$gob_id}{'T'}{$t_id}{'tt'} .= 'DEG : '.$po_deg.' D3 + '.$po_deg_bmm;
        }
        # Bombe a retardement
        elsif ( $t_id == 10 )
        {
            my $niveau  = $skills{$gob_id}{'Talents'}{'T'}{$t_id}{'Niveau'};
            my $coeff;
            my $coeff_r;
            if    ( $niveau == 1 ) { $coeff = 4; $coeff_r = 8 }
            elsif ( $niveau == 2 ) { $coeff = 4; $coeff_r = 6 }
            elsif ( $niveau == 3 ) { $coeff = 3; $coeff_r = 5 }
            elsif ( $niveau == 4 ) { $coeff = 3; $coeff_r = 4 }
            my $deg     = ( $gobs2{$gob_id}{'PER'} + $gobs2{$gob_id}{'DEG'} ) / $coeff;
               $deg     = sprintf("%d",$deg);
            my $deg_r   = ( $gobs2{$gob_id}{'PER'} + $gobs2{$gob_id}{'DEG'} ) / $coeff_r;
               $deg_r   = sprintf("%d",$deg_r);
            $SKILLS_TT{$gob_id}{'T'}{$t_id}{'tt'} = 'Full : '.$deg.'D3'."<br>".'Res. : '.$deg_r.'D3';
        }
        # Batatin
        elsif ( $t_id == 11 )
        {
            my $niveau   = $skills{$gob_id}{'Talents'}{'T'}{$t_id}{'Niveau'};
            my $coeff    =  6 - $niveau;
            my $coeff_r  = 12 - $niveau * 2;
            my $malus    = (1 + $niveau) * 10;
            my $malus_r  = $malus / 2;
            my $portee   = $niveau;
            my $per      = $gobs2{$gob_id}{'PER'};
            my $reg      = $gobs2{$gob_id}{'REG'};
            my $esq      = 1 + ( $per + $reg )/$coeff;
               $esq      = sprintf("%d",$esq);
            my $esq_r    = 1 + ( $per + $reg )/$coeff_r;
               $esq_r    = sprintf("%d",$esq_r);
            $SKILLS_TT{$gob_id}{'T'}{$t_id}{'tt'}  = Encode::decode_utf8('Portée').' : '.$portee.' Case(s)'.'<br>';
            $SKILLS_TT{$gob_id}{'T'}{$t_id}{'tt'} .= '<br>';
            $SKILLS_TT{$gob_id}{'T'}{$t_id}{'tt'} .= 'Si full'.'<br>';
            $SKILLS_TT{$gob_id}{'T'}{$t_id}{'tt'} .= 'ESQ -'.$esq.'D'.'<br>';
            $SKILLS_TT{$gob_id}{'T'}{$t_id}{'tt'} .= 'RS -'.$malus.'%'.'<br>';
            $SKILLS_TT{$gob_id}{'T'}{$t_id}{'tt'} .= '<br>';
            $SKILLS_TT{$gob_id}{'T'}{$t_id}{'tt'} .= Encode::decode_utf8('Si resisté').'<br>';
            $SKILLS_TT{$gob_id}{'T'}{$t_id}{'tt'} .= 'ESQ -'.$esq_r.'D'.'<br>';
            $SKILLS_TT{$gob_id}{'T'}{$t_id}{'tt'} .= 'RS -'.$malus_r.'%'.'<br>';
        }
        # Soin
        elsif ( $t_id == 12 )
        {
            my $niveau  = $skills{$gob_id}{'Talents'}{'T'}{$t_id}{'Niveau'};
            my $coeff   = $niveau;
            my $reg     = $gobs2{$gob_id}{'REG'};
            my $reg_bm  = $gobs2{$gob_id}{'BPREG'} + $gobs2{$gob_id}{'BMREG'};
            my $soin    = $coeff * $reg + $reg_bm;
            $SKILLS_TT{$gob_id}{'T'}{$t_id}{'tt'} = 'Soin : '.$soin.' PV(s)';
        }
    }
    return \%SKILLS_TT;
}

sub GetTechs
{
    my %TECHS;
    my $techs_csv = '/home/gobland-bot/data/FP_Tech.csv';
    open (my $hf, '<:encoding(UTF-8)', $techs_csv) or die "Could not open file '$techs_csv' $!";
        while (my $row = <$hf>)
        {
            $row =~ s/"//g;
            my @row = split /;/, $row;
            $TECHS{$row[0]}{'Nom'} = Encode::encode_utf8($row[1]);
        }
    close($hf);
    return \%TECHS;
}

sub GetColor
{
    my $pv_now = shift;
    my $pv_max = shift;

    my $green  = '#77EE77';
    my $jaune  = '#EEEE77';
    my $orange = '#EEAA77';
    my $red    = '#B22222';

    my $color  = '#FFFFFF';
    my $percent = 100 * ($pv_now / $pv_max);

    if    ( $percent > 75 )
    {
        $color = $green;
    }
    elsif ( $percent > 50 )
    {
        $color = $jaune;
    }
    elsif ( $percent > 25 )
    {
        $color = $orange;
    }
    else
    {
        $color = $red;
    }
}

sub GetStuffIcon
{
    my $type      = shift;
    my $nom       = shift;
    my $png       = '';

    if    ( $type eq 'Armure' )                           { $png = 'icon_04.png' }
    elsif ( $type eq 'Casque' )                           { $png = 'icon_14.png' }
    elsif ( $type eq 'Bottes' )                           { $png = 'icon_24.png' }
    elsif ( $type eq 'Arme 1 Main' and $nom =~ /Hache/ )  { $png = 'icon_52.png' }
    elsif ( $type eq 'Arme 1 Main' )                      { $png = 'icon_47.png' }
    elsif ( $type eq 'Arme 2 mains' and $nom =~ /Hache/ ) { $png = 'icon_56.png' }
    elsif ( $type eq 'Arme 2 mains' )                     { $png = 'icon_45.png' }
    elsif ( $type eq 'Talisman' )                         { $png = 'icon_18.png' }
    elsif ( $type eq 'Anneau' )                           { $png = 'icon_29.png' }
    elsif ( $type eq 'Bouclier' )                         { $png = 'icon_09.png' }
    elsif ( $type eq 'Baguette' )                         { $png = 'icon_61.png' }
    elsif ( $type eq 'Bijou' )                            { $png = 'icon_108.png' }
    elsif ( $type eq 'Nourriture' )                       { $png = 'icon_74.png' }
    elsif ( $type eq 'Potion' )                           { $png = 'icon_86.png' }
    elsif ( $type eq 'Composant' )                        { $png = 'icon_102.png' }
    elsif ( $type eq 'Outil' )                            { $png = 'icon_1083.png' }
    elsif ( $type eq 'Fleur' )                            { $png = 'icon_1173.png' }
    elsif ( $type eq 'Corps' )                            { $png = 'icon_1130.png' }
    else  { $png = '' }

    return '<img src="/images/stuff/'.$png.'">';
}

sub GetMateriauIcon
{
    my $nom  = shift;
    my $png  = '';

    if    ( $nom eq 'Rondin'         ) { $png = '<img src="/images/stuff/icon_109.png">'  }
    elsif ( $nom eq 'Minerai de Fer' ) { $png = '<img src="/images/stuff/icon_104.png">'  }
    elsif ( $nom eq 'Cuir'           ) { $png = '<img src="/images/stuff/icon_98.png">'   }
    elsif ( $nom eq 'Tissu'          ) { $png = '<img src="/images/stuff/icon_103.png">'  }
    elsif ( $nom eq 'Pierre'         ) { $png = '<img src="/images/stuff/icon_1142.png">' }

    return $png;
}

sub GetDureeDLA
{
    my $sec = shift;
    my @DLA;
    my $DLA;
    if ( $sec <= 60 )
    {
        @DLA = (($sec/(60*60))%24,$sec/60,$sec%60);
    }
    else
    {
        @DLA = (($sec/(60*60))%24,($sec/60)%60,$sec%60);
    }

    if ( $sec == abs($sec) )
    {
        $DLA = sprintf("%02d",$DLA[0]).'h'.sprintf("%02d",$DLA[1]);
    }
    else
    {
        if ( abs($DLA[1]) >= 60 )
        {
            my $hour = abs($DLA[1]/60)%24;
            my $min  = abs($DLA[1])%60;
            $DLA     = '-'.sprintf("%02d",$hour).'h'.sprintf("%02d",$min);
        }
        else
        {
            $DLA = '-'.sprintf("%02d",$DLA[0]).'h'.sprintf("%02d",abs($DLA[1]));
        }
    }
    return $DLA;
}

sub GetQualite
{
    my $type      = shift;
    my $quali_id  = shift;
    my $quali_str = '';

    my %M_QUALITY;

    $M_QUALITY{'Materiau'}{'0'} = ''; # AFAIK only used for Rondins
    $M_QUALITY{'Materiau'}{'1'} = Encode::decode_utf8('Médiocre');
    $M_QUALITY{'Materiau'}{'2'} = 'Moyenne';
    $M_QUALITY{'Materiau'}{'3'} = 'Normale';
    $M_QUALITY{'Materiau'}{'4'} = 'Bonne';
    $M_QUALITY{'Materiau'}{'5'} = '<b>Exceptionnelle</b>';

    $M_QUALITY{'Composant'}{'1'} = Encode::decode_utf8('Très Mauvaise');
    $M_QUALITY{'Composant'}{'2'} = 'Mauvaise';
    $M_QUALITY{'Composant'}{'3'} = 'Moyenne';
    $M_QUALITY{'Composant'}{'4'} = 'Bonne';
    $M_QUALITY{'Composant'}{'5'} = '<b>'.Encode::decode_utf8('Très Bonne').'</b>';

    if ( $type eq 'Matériau' or $type eq 'Minerai' or $type eq 'Roche' )
    {
        $quali_str = $M_QUALITY{'Materiau'}{$quali_id};
    }
    elsif ( $type eq 'Composant' )
    {
        $quali_str = $M_QUALITY{'Composant'}{$quali_id};
    }
    return $quali_str;
}

sub GetLuxe
{
    my $type      = shift;
    my $nom       = shift;
    my $desc      = shift;
    my $ok        = ' <img height="10px" width="10px" src="/images/stuff/OK.png">';

    if ( $type eq 'Talisman' )
    {
        if ( $nom eq 'Collier' )             { if ( $desc =~ /MM:[+]10 | RM:[+]10/ ) { return $ok } }
    }
    elsif ( $type eq 'Bouclier' )
    {
        if ( $nom eq 'Rondache en bois' )    { if ( $desc =~ /RP:[+]10/ )          { return $ok } }
        if ( $nom eq 'Clipeus' )             { if ( $desc =~ /RS:[+]10/ )          { return $ok } }
    }
    elsif ( $type eq 'Casque' )
    {
        if    ( $nom eq 'Bacinet' )          { if ( $desc =~ /MC:[+]10/ )          { return $ok } }
        elsif ( $nom eq 'Barbute' )          { if ( $desc =~ /RP:[+]10/ )          { return $ok } }
        elsif ( $nom eq 'Cagoule' )          { if ( $desc =~ /MS:[+]10/ )          { return $ok } }
        elsif ( $nom eq 'Casque en cuir' )   { if ( $desc =~ /RS:[+]10/ )          { return $ok } }
        elsif ( $nom =~ /Casque en m.tal/ )  { if ( $desc =~ /RC:[+]10/ )          { return $ok } }
        elsif ( $nom eq 'Casque en os' )     { if ( $desc =~ /RT:[+]10/ )          { return $ok } }
        elsif ( $nom eq 'Cerebro' )          { if ( $desc =~ /MP:[+]10/ )          { return $ok } }
        elsif ( $nom eq 'Chapeau pointu' )   { if ( $desc =~ /MM:[+]10/ )          { return $ok } }
        elsif ( $nom eq 'Lorgnons' )         { if ( $desc =~ /MR:[+]10/ )          { return $ok } }
        elsif ( $nom eq 'Masque d\'Alowin' ) { if ( $desc =~ /RR:[+]10/ )          { return $ok } }
        elsif ( $nom eq 'Scalp' )            { if ( $desc =~ /MT:[+]10/ )          { return $ok } }
        elsif ( $nom eq 'Turban' )           { if ( $desc =~ /RM:[+]10/ )          { return $ok } }
    }
    elsif ( $type eq 'Bottes' )
    {
        if    ( $nom =~ /en os/ )            { if ( $desc =~ /RT:[+]10/ )          { return $ok } }
        elsif ( $nom =~ /en m.tal/ )         { if ( $desc =~ /RC:[+]10/ )          { return $ok } }
    }
    elsif ( $type eq 'Arme 1 Main' )
    {
        if    ( $nom =~ /'os/ )              { if ( $desc =~ /RT:[+]20/ )          { return $ok } }
        elsif ( $nom eq 'Coutelas' )         { if ( $desc =~ /RM:[+]10/ )          { return $ok } }
    }
}

1;
