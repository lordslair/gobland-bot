package GLB::functions;

use warnings;
use strict;

use DBI;

my $dbh = DBI->connect(
       "dbi:SQLite:dbname=/home/gobland-bot/gobland.db",
       "",
       "",
       { RaiseError => 1 },
    ) or die $DBI::errstr;

sub GetCompsTT
{
    my @gob_ids = @GLB::variables::gob_ids;

    for my $gob_id ( @gob_ids )
    {
        # Request for IdSkill info
        my $req_id_skill_c = $dbh->prepare( "SELECT IdSkill,Niveau FROM Skills \
                                             WHERE Type = 'C' AND IdGob = '$gob_id' \
                                             ORDER BY IdSkill" );
        $req_id_skill_c->execute();

        while (my @row = $req_id_skill_c->fetchrow_array)
        {
            my $c_id   = $row[0];
            my $niveau = $row[1];
            my $tt     = '';

            my $sth  = $dbh->prepare( "SELECT PER,BMPER,BPPER FROM Gobelins2 WHERE Id = '$gob_id'" );
            $sth->execute();
            my @per = $sth->fetchrow_array;
            $sth->finish;
            my $vue = $per[0] + $per[1] + $per[2];

            if ( $c_id == 1 )
            {
                $tt = Encode::decode_utf8('Portée').' : '.$vue.' Case(s)';
            }
            elsif ( $c_id == 2 )
            {
                my $proba;
                if    ( $niveau == 1 ) { $proba = 10 }
                elsif ( $niveau == 2 ) { $proba = 12 }
                elsif ( $niveau == 2 ) { $proba = 14 }
                elsif ( $niveau == 2 ) { $proba = 16 }
                $tt = 'Proba. : '.$proba.'%';
            }
            elsif ( $c_id == 9 )
            {
                my $portee  = ($vue, $niveau)[$vue > $niveau];
                $tt = Encode::decode_utf8('Portée').' : '.$portee.' Case(s)';
            }
            elsif ( $c_id == 18 or $c_id == 21 )
            {
                my $coeff;
                if    ( $niveau == 1 ) { $coeff = 1.5 }
                elsif ( $niveau == 2 ) { $coeff = 2   }
                elsif ( $niveau == 3 ) { $coeff = 2.5 }
                elsif ( $niveau == 4 ) { $coeff = 3   }
                my $portee  = sprintf("%d",$coeff * $vue);
                $tt = Encode::decode_utf8('Portée').' : '.$portee.' Case(s)';
            }

            if ( $tt ne '' )
            {
                my $sth  = $dbh->prepare( "UPDATE Skills \
                                           SET Tooltip = '$tt' \
                                           WHERE IdGob = '$gob_id' AND Type = 'C' AND IdSkill = '$c_id'" );
                $sth->execute();
                $sth->finish();
            }
        }
        $req_id_skill_c->finish();

        # Request for IdSkill info
        my $req_id_skill_t = $dbh->prepare( "SELECT IdSkill,Niveau FROM Skills \
                                             WHERE Type = 'T' AND IdGob = '$gob_id' \
                                             ORDER BY IdSkill" );
        $req_id_skill_t->execute();

        while (my @row = $req_id_skill_t->fetchrow_array)
        {
            my $t_id   = $row[0];
            my $niveau = $row[1];
            my $tt     = '';

            my $sth = $dbh->prepare( "SELECT DEG,BMDEG,BPDEG,REG,BMREG,BPREG,PER,BMPER,BPPER,ATT,BMATT,BPATT \
                                      FROM Gobelins2 WHERE Id = '$gob_id'" );
            $sth->execute();
            my @attr = $sth->fetchrow_array;
            $sth->finish;

            if ( $t_id == 2 )
            {
                my $coeff;
                my $coeff_b;
                my $coeff_r;
                my $malus;
                my $malus_r;
                if    ( $niveau == 1 ) { $coeff = 1; $coeff_b = 1; $coeff_r = 0.3; $malus = 0  ; $malus_r = 0   }
                elsif ( $niveau == 2 ) { $coeff = 1; $coeff_b = 1; $coeff_r = 0.4; $malus = 0.5; $malus_r = 0   }
                elsif ( $niveau == 3 ) { $coeff = 1; $coeff_b = 1; $coeff_r = 0.5; $malus = 1  ; $malus_r = 0.5 }
                elsif ( $niveau == 4 ) { $coeff = 1; $coeff_b = 1; $coeff_r = 0.6; $malus = 2  ; $malus_r = 1   }

                my $reg      = $attr[3];
                my $deg      = $attr[0];
                my $deg_bmm  = $attr[1];

                my $deg_full = $coeff*$deg + $coeff_b*$deg_bmm;
                my $deg_r    = sprintf("%d",$coeff_r*$deg);
                my $reg_full = sprintf("%d",$malus*$reg);
                my $reg_r    = sprintf("%d",$malus_r*$reg);

                $tt  = 'Si full'.'<br>';
                $tt .= 'DEG : '.$deg_full.'<br>';
                $tt .= 'Malus : REG -'.$reg_full.'<br>';
                $tt .= '<br>';
                $tt .= Encode::decode_utf8('Si resisté').'<br>';
                $tt .= 'DEG : '.$deg_r.'<br>';
                $tt .= 'Malus : REG -'.$reg_r.'<br>';
            }
            elsif ( $t_id == 7 )
            {
                my $coeff;
                if    ( $niveau == 1 ) { $coeff = 5 }
                elsif ( $niveau == 2 ) { $coeff = 4 }
                elsif ( $niveau == 3 ) { $coeff = 3 }
                elsif ( $niveau == 4 ) { $coeff = 2 }

                $tt = 'Bonus : +1 / '.$coeff.'PVs';
            }
            elsif ( $t_id == 9 )
            {
                my $coeff;
                my $mod;
                if    ( $niveau == 1 ) { $coeff = 4; $mod = 0 }
                elsif ( $niveau == 2 ) { $coeff = 4; $mod = 1 }
                elsif ( $niveau == 3 ) { $coeff = 5; $mod = 0 }
                elsif ( $niveau == 4 ) { $coeff = 5; $mod = 1 }

                my $per        = $attr[6];
                my $per_bmm    = $attr[7];
                my $att        = $attr[9];
                my $att_bmm    = $attr[10];

                my $vue    = $attr[6] + $attr[7] + $attr[8];
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

                $tt  = Encode::decode_utf8('Portée').' : '.$portee.' Case(s)'.'<br>';
                $tt .= '<br>';
                $tt .= 'Si cible < '.$coeff.' Cases'.'<br>';
                $tt .= 'ATT : '.$po_att.' D6 + '.$po_att_bmm.'<br>';
                $tt .= 'DEG : '.$po_deg.' D3 + '.$po_deg_bmm;
                $tt .= '<br>';
                $tt .= 'Si cible > '.$coeff.' Cases'.'<br>';
                $tt .= 'ATT : '.($po_att -1).' D6 + '.$po_att_bmm.'<br>';
                $tt .= 'DEG : '.($po_deg -1).' D3 + '.$po_deg_bmm;
            }
            elsif ( $t_id == 10 )
            {
                my $coeff;
                my $coeff_r;
                if    ( $niveau == 1 ) { $coeff = 4; $coeff_r = 8 }
                elsif ( $niveau == 2 ) { $coeff = 4; $coeff_r = 6 }
                elsif ( $niveau == 3 ) { $coeff = 3; $coeff_r = 5 }
                elsif ( $niveau == 4 ) { $coeff = 3; $coeff_r = 4 }
                my $deg   = ( $attr[6] + $attr[0] ) / $coeff;
                   $deg   = sprintf("%d",$deg);
                my $deg_r = ( $attr[6] + $attr[0] ) / $coeff_r;
                   $deg_r = sprintf("%d",$deg_r);

                $tt = 'Full : '.$deg.'D3'."<br>".'Res. : '.$deg_r.'D3';
            }
            elsif ( $t_id == 11 )
            {
                my $coeff    =  6 - $niveau;
                my $coeff_r  = 12 - $niveau * 2;
                my $malus    = (1 + $niveau) * 10;
                my $malus_r  = $malus / 2;
                my $portee   = $niveau;
                my $per      = $attr[6];
                my $reg      = $attr[3];
                my $esq      = 1 + ( $per + $reg )/$coeff;
                   $esq      = sprintf("%d",$esq);
                my $esq_r    = 1 + ( $per + $reg )/$coeff_r;
                   $esq_r    = sprintf("%d",$esq_r);

                $tt  = Encode::decode_utf8('Portée').' : '.$portee.' Case(s)'.'<br>';
                $tt .= '<br>';
                $tt .= 'Si full'.'<br>';
                $tt .= 'ESQ -'.$esq.'D'.'<br>';
                $tt .= 'RS -'.$malus.'%'.'<br>';
                $tt .= '<br>';
                $tt .= Encode::decode_utf8('Si resisté').'<br>';
                $tt .= 'ESQ -'.$esq_r.'D'.'<br>';
                $tt .= 'RS -'.$malus_r.'%'.'<br>';
            }
            elsif ( $t_id == 12 )
            {
                my $coeff  = $niveau;
                my $reg    = $attr[3];
                my $reg_bm = $attr[4] + $attr[5];
                my $soin   = $coeff * $reg + $reg_bm;

                $tt = 'Soin : '.$soin.' PV(s)';
            }

            if ( $tt ne '' )
            {
                my $sth  = $dbh->prepare( "UPDATE Skills \
                                           SET Tooltip = '$tt' \
                                           WHERE IdGob = '$gob_id' AND Type = 'T' AND IdSkill = '$t_id'" );
                $sth->execute();
                $sth->finish();
            }
        }
        $req_id_skill_t->finish();
    }
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
    my $png       = '';
    my $type      = shift;
    my $nom       = shift;

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
        if    ( $nom eq 'Collier' )              { if ( $desc =~ /MM:[+]10 . RM:[+]10/ ) { return $ok } }
        elsif ( $nom =~ /^Phylact.re$/ )         { if ( $desc =~ /MP:[+]10 . RP:[+]10/ ) { return $ok } }
    }
    elsif ( $type eq 'Bouclier' )
    {
        if    ( $nom eq 'Rondache en bois' )     { if ( $desc =~ /RP:[+]10/ )            { return $ok } }
        elsif ( $nom eq 'Egide' )                { if ( $desc =~ /RC:[+]10/ )            { return $ok } }
        elsif ( $nom eq 'Clipeus' )              { if ( $desc =~ /RS:[+]10/ )            { return $ok } }
    }
    elsif ( $type eq 'Casque' )
    {
        if    ( $nom eq 'Bacinet' )              { if ( $desc =~ /MC:[+]10/ )            { return $ok } }
        elsif ( $nom eq 'Barbute' )              { if ( $desc =~ /RP:[+]10/ )            { return $ok } }
        elsif ( $nom eq 'Cagoule' )              { if ( $desc =~ /MS:[+]10/ )            { return $ok } }
        elsif ( $nom eq 'Casque en cuir' )       { if ( $desc =~ /RS:[+]10/ )            { return $ok } }
        elsif ( $nom =~ /Casque en m.tal/ )      { if ( $desc =~ /RC:[+]10/ )            { return $ok } }
        elsif ( $nom eq 'Casque en os' )         { if ( $desc =~ /RT:[+]10/ )            { return $ok } }
        elsif ( $nom eq 'Cerebro' )              { if ( $desc =~ /MP:[+]10/ )            { return $ok } }
        elsif ( $nom eq 'Chapeau pointu' )       { if ( $desc =~ /MM:[+]10/ )            { return $ok } }
        elsif ( $nom eq 'Lorgnons' )             { if ( $desc =~ /MR:[+]10/ )            { return $ok } }
        elsif ( $nom eq 'Masque d\'Alowin' )     { if ( $desc =~ /RR:[+]10/ )            { return $ok } }
        elsif ( $nom eq 'Scalp' )                { if ( $desc =~ /MT:[+]10/ )            { return $ok } }
        elsif ( $nom eq 'Turban' )               { if ( $desc =~ /RM:[+]10/ )            { return $ok } }

    }
    elsif ( $type eq 'Bottes' )
    {
        if    ( $nom =~ /en os/ )                { if ( $desc =~ /RT:[+]10/ )            { return $ok } }
        elsif ( $nom =~ /en m.tal/ )             { if ( $desc =~ /RC:[+]10/ )            { return $ok } }
    }
    elsif ( $type eq 'Arme 1 Main' )
    {
        if    ( $nom =~ /'os/ )                  { if ( $desc =~ /RT:[+]20/ )            { return $ok } }
        elsif ( $nom eq 'Coutelas' )             { if ( $desc =~ /RM:[+]10/ )            { return $ok } }
        elsif ( $nom eq 'Dague' )                { if ( $desc =~ /RC:[+]10/ )            { return $ok } }
        elsif ( $nom eq 'Machette' )             { if ( $desc =~ /RR:[+]20/ )            { return $ok } }
    }
    elsif ( $type eq 'Bijou' )
    {
        if    ( $nom eq 'Breloques Familiales' ) { if ( $desc =~ /RR:[+]20/ )            { return $ok } }
        elsif ( $nom =~ /^Phal.re Epineuse$/ )   { if ( $desc =~ /RC:[+]20/ )            { return $ok } }
    }
    elsif ( $type eq 'Anneau' )
    {
        if    ( $nom eq 'Anneau Barbare' )       { if ( $desc =~ /MS:[-]5/  )            { return $ok } }
    }
    elsif ( $type eq 'Armure' )
    {
        if ( $desc =~ /ESQ:[+]1 . M.:[+]10 . R.:[+]10/ )            { return $ok } # Armures Legères
        if ( $desc =~ /ESQ:[+]2 . R.:[-]5 . R.:[+]50/ )             { return $ok }
        if ( $desc =~ /Arm:[+]2 . R.:[-]5 . R.:[+]5 . R.:[+]10/ )   { return $ok }

        if ( $desc =~ /ESQ:[-]1 . R.:[+]40/ )                       { return $ok } # Armures Moyennes
        if ( $desc =~ /ESQ:[-]3 . R.:[+]100/ )                      { return $ok }

        if ( $desc =~ /ESQ:[-]6 . R.:[+]200/ )                      { return $ok } # Armures Lourdes
    }
}

sub GetCraft
{
    my $type      = shift;
    my $nom       = shift;
    my $desc      = shift;
    my $template  = shift;

    my $craft     = ' <img height="10px" width="10px" src="/images/stuff/craft.png">';

    if ( $template )
    {
        if ( $template =~ /de Ma.tre/ ) { return $craft }
    }
    else
    {
        if    ( ($nom eq 'Bottes')            && ($desc ne 'ESQ:+2') )                           { return $craft }
        elsif ( ($nom eq 'Tunique')           && ($desc !~ /^ESQ:+1 | MS:+(\d*) | RS:+(\d*)$/) ) { return $craft }
        elsif ( ($nom eq 'Gorgeron en cuir')  && ($desc ne 'Arm:+1') )                           { return $craft }
        elsif ( ($nom eq 'Targe')             && ($desc ne 'ESQ:+1') )                           { return $craft }
    }
}

sub GetCarats
{
    my $quali_id  = shift;
    my $quantite  = shift;
    my $carats;

    if    ( $quali_id == 1 ) { $carats = $quantite * 2    }
    elsif ( $quali_id == 2 ) { $carats = $quantite * 2.75 }
    elsif ( $quali_id == 3 ) { $carats = $quantite * 3.5  }
    elsif ( $quali_id == 4 ) { $carats = $quantite * 4.25 }
    elsif ( $quali_id == 5 ) { $carats = $quantite * 5    }
    else  { $carats = 0 }

    return  sprintf("%d", $carats);
}

1;
