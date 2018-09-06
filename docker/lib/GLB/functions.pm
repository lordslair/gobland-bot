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
            $SKILLS_TT{$gob_id}{'C'}{$t_id}{'tt'} = Encode::decode_utf8('Port..e').' : '.$portee.' Case(s)';
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
    my $stuff_ref = shift;
    my %stuff     = %{$stuff_ref};
    my $gob_id    = shift;
    my $equipe    = shift;
    my $item_id   = shift;

    my $png       = '';
    my $type      = Encode::decode_utf8($stuff{$gob_id}{$equipe}{$item_id}{'Type'});
    my $nom       = $stuff{$gob_id}{$equipe}{$item_id}{'Nom'};

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
        $DLA = '-'.sprintf("%02d",$DLA[0]).'h'.sprintf("%02d",abs($DLA[1]));
    }
    return $DLA;
}

sub GetQualite
{
    my $type      = shift;
    my $quali_id  = shift;
    my $quali_str = '';

    my %M_QUALITY;
    $M_QUALITY{'0'} = '';
    $M_QUALITY{'1'} = Encode::decode_utf8('Médiocre');
    $M_QUALITY{'2'} = 'Moyenne';
    $M_QUALITY{'3'} = 'Normale';
    $M_QUALITY{'4'} = 'Bonne';
    $M_QUALITY{'5'} = '<b>Exceptionnelle</b>';

    if ( $type eq 'Mat..riau' or $type eq 'Minerai' or $type eq 'Roche' )
    {
        $quali_str = $M_QUALITY{$quali_id};
    }
    return $quali_str;
}

sub GetStuff
{
    my $stuff_ref = shift;
    my %stuff     = %{$stuff_ref};
    my $gob_id    = shift;
    my $equipe    = shift;
    my $item_id   = shift;
    my $style     = shift;

    my $min       = ', '.$stuff{$gob_id}{$equipe}{$item_id}{'Poids'}/60 . ' min';
    my $desc      = Encode::decode_utf8('<b>Non identifi..</b>');
    my $type      = Encode::decode_utf8($stuff{$gob_id}{$equipe}{$item_id}{'Type'});
    my $nom       = $stuff{$gob_id}{$equipe}{$item_id}{'Nom'};
    my $template  = '';

    if ( $stuff{$gob_id}{$equipe}{$item_id}{'Identifie'} eq 'VRAI' )
    {
        $desc = Encode::decode_utf8($stuff{$gob_id}{$equipe}{$item_id}{'Desc'});
    }
    if ( $stuff{$gob_id}{$equipe}{$item_id}{'Magie'} )
    {
        $template = ' <b>'.Encode::decode_utf8($stuff{$gob_id}{$equipe}{$item_id}{'Magie'}.'</b>');
    }

    if ( $style eq 'full' )
    {
        return my $item_txt = '['.$item_id.'] '.$type.' : '.$nom.$template.' ('.$desc.')'.$min.'<br>';
    }
    else
    {
        return my $item_txt = '['.$item_id.'] '.$nom.$template.' ('.$desc.')'.$min.'<br>';
    }
}

1;
