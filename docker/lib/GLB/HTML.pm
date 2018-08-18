package GLB::HTML;
use strict;
use warnings;

use Time::HiRes qw[gettimeofday tv_interval];
use YAML::Tiny;

use lib '/home/gobland-bot/lib/';
use GLB::GLAPI;
use GLB::functions;

my $yaml       = '/home/gobland-bot/gl-config.yaml';

my $gobs_ref   = GLB::GLAPI::GetClanMembres($yaml);
my %gobs       = %{$gobs_ref};
my $gobs2_ref  = GLB::GLAPI::GetClanMembres2($yaml);
my %gobs2      = %{$gobs2_ref};
my $stuff_ref  = GLB::GLAPI::GetClanEquipement($yaml);
my %stuff      = %{$stuff_ref};
my $skill_ref  = GLB::GLAPI::getClanSkills($yaml);
my %skill      = %{$skill_ref};

sub createIndex {
    my $t_start  = [gettimeofday()]; 
    my $filename = '/var/www/localhost/htdocs/index.html';
    open(my $fh, '>', $filename) or die "Could not open file '$filename' $!";
    binmode($fh, ":utf8");

    print $fh $GLB::functions::begin;

    print $fh '            <div id="content">'."\n";
    print $fh '              <br><h1>Bienvenue chez les Rabatteurs de Khaket</h1><br>'."\n";
    print $fh '              <table cellspacing="0" id="trollsList">'."\n";
    print $fh '                <tr>'."\n";
    print $fh '                  <th>Pseudo</th>'."\n";
    print $fh '                  <th>Num</th>'."\n";
    print $fh '                  <th>Race</th>'."\n";
    print $fh '                  <th>Niv.</th>'."\n";
    print $fh '                  <th>Position</th>'."\n";
    print $fh '                  <th>PV</th>'."\n";
    print $fh '                  <th>PA</th>'."\n";
    print $fh '                  <th>Dates</th>'."\n";
    print $fh '                  <th>Action</th>'."\n";
    print $fh '                </tr>'."\n";

    my $ct_total   = 0;

    for my $gob_id ( sort keys %gobs )
    {
        my $position = $gobs{$gob_id}{'X'}.', '.$gobs{$gob_id}{'Y'}.', '.$gobs{$gob_id}{'N'};

        my $pad;
        if ( $gobs{$gob_id}{'PA'} > 0 )
        {
            $pad = ' class="PADispo"';
        } else { $pad = ' ' }

        my $color   = GLB::functions::GetColor($gobs{$gob_id}{'PV'},$gobs2{$gob_id}{'PVMax'});
        my $lifebar = '<br><div class="vieContainer"><div style="background-color:'.$color.'; width: '.$percent.'%">&nbsp;</div></div>';

        $ct_total += $gobs{$gob_id}{'CT'};

        print $fh '                <tr>'."\n";
        print $fh '                  <td>'.$gobs{$gob_id}{'Nom'}.'</td>'."\n";
        print $fh '                  <td>'.$gob_id.'</td>'."\n";
        print $fh '                  <td>'.$gobs{$gob_id}{'Tribu'}.'</td>'."\n";
        print $fh '                  <td>'.$gobs{$gob_id}{'Niveau'}.'</td>'."\n";
        print $fh '                  <td>'.$position.'</td>'."\n";
        print $fh '                  <td>'.$gobs{$gob_id}{'PV'}.' / '.$gobs2{$gob_id}{'PVMax'}.$lifebar.'</td>'."\n";
        print $fh '                  <td'.$pad.'>'.$gobs{$gob_id}{'PA'}.'</td>'."\n";
        print $fh '                  <td><span class="DLA"> DLA : '.$gobs{$gob_id}{'DLA'}.'</span><br><span class="pDLA">pDLA : [A CODER]</span></td>'."\n";
        print $fh '                  <td>'."\n";
        print $fh '                      <a href="http://rabatteurs.lordslair.net/gobelins/'.$gob_id.'.html" title="Votre profil">PROFIL</a>'."\n";
        print $fh '                      <a href="http://rabatteurs.lordslair.net/vue/'.$gob_id.'.html" title="Votre vue">VUE</a>'."\n";
        print $fh '                  </td>'."\n";
        print $fh '                </tr>'."\n";
    }

    print $fh '                </table>'."\n";

    print $fh '                <div>'."\n";
    print $fh '                    <h3>Fortune : '.$ct_total.' CT (gobelins)</h3>'."\n";
    print $fh '                </div>'."\n";

    my $t_elapsed = sprintf ("%0.3f", tv_interval($t_start));
    print $fh '                <div class="footer">[HTML generated in '.$t_elapsed.' sec.] - [Updated @'.localtime.']</div>'."\n";

    print $fh $GLB::functions::end;
    close $fh;
}

sub createEquipement {

    my $t_start  = [gettimeofday()];
    my $filename = '/var/www/localhost/htdocs/equipement.html';
    open(my $fh, '>', $filename) or die "Could not open file '$filename' $!";
    binmode($fh, ":utf8");
    print $fh $GLB::functions::begin;

    print $fh '            <div id="content">'."\n";
    print $fh '                <h1>Possessions</h1>'."\n";

    print $fh '                <h2 class="expanded">Equipements Gobelins</h2>'."\n";
    print $fh '                <table cellspacing="0" id="profilInfos">'."\n";
    for my $gob_id ( sort keys %stuff )
    {
        print $fh '                    <tr class="expanded">'."\n";
        print $fh '                        <th>Equipement(s) de '.$gobs{$gob_id}{'Nom'}.' ('.$gob_id.') </th>'."\n";
        print $fh '                    </tr>'."\n";
        print $fh '                    <tr>'."\n";
        print $fh '                        <td>'."\n";
        print $fh '                            <ul class="membreEquipementList">'."\n";
        foreach my $e ( sort keys %{$stuff{$gob_id}} )
        {
            for my $item_id ( sort keys %{$stuff{$gob_id}{$e}} )
            {
                my $min = '';
                my $desc = Encode::decode_utf8('<b>Non identifié</b>');
                my $equipe = $e;
                my $type = '';
                my $nom = $stuff{$gob_id}{$e}{$item_id}{'Nom'};
                my $template = '';

                if ( $stuff{$gob_id}{$e}{$item_id}{'Poids'} )
                {
                    $min = ', '.$stuff{$gob_id}{$e}{$item_id}{'Poids'}/60 . ' min';
                }
                if ( $stuff{$gob_id}{$e}{$item_id}{'Identifie'} eq 'VRAI' )
                {
                    $desc = Encode::decode_utf8($stuff{$gob_id}{$e}{$item_id}{'Desc'});
                }
                if ( $stuff{$gob_id}{$e}{$item_id}{'Type'} )
                {
                    $type = Encode::decode_utf8($stuff{$gob_id}{$e}{$item_id}{'Type'});
                }
                if ( $stuff{$gob_id}{$e}{$item_id}{'Magie'} )
                {                                                                                                                                                                 $template = ' <b>'.Encode::decode_utf8($stuff{$gob_id}{$e}{$item_id}{'Magie'}.'</b>');
                }
                if ( $type ne 'Composant' )
                {
                    print $fh ' ' x 32, '<li class="equipement'.$equipe.'">'."\n";
                    print $fh ' ' x 34, '['.$item_id.'] '.$type.' : '.$nom.$template.' ('.$desc.')'.$min."\n";
                    print $fh ' ' x 32, '</li>'."\n";
                }
            }
            if ( $e eq 'Equipe' ) { print $fh '                                <br>'."\n" }
        }
        print $fh '                            </ul>'."\n";
        print $fh '                        </td>'."\n";
        print $fh '                    </tr>'."\n";
    }
    print $fh '                </table>'."\n";

    print $fh '                <h2 class="expanded">Composants Gobelins</h2>'."\n";
    print $fh '                <table cellspacing="0" id="profilInfos">'."\n";
    for my $gob_id ( sort keys %stuff )
    {
        my $compos = '';
        foreach my $e ( sort keys %{$stuff{$gob_id}} )
        {
            for my $item_id ( sort keys %{$stuff{$gob_id}{$e}} )
            {
                my $min    = '';
                my $desc   = Encode::decode_utf8('<b>Non identifié</b>');
                my $equipe = $e;
                my $type   = '';
                my $nom    = $stuff{$gob_id}{$e}{$item_id}{'Nom'};

                if ( $stuff{$gob_id}{$e}{$item_id}{'Poids'} )
                {
                    $min = ', '.$stuff{$gob_id}{$e}{$item_id}{'Poids'}/60 . ' min';
                }
                if ( $stuff{$gob_id}{$e}{$item_id}{'Identifie'} eq 'VRAI' )
                {
                    $desc = Encode::decode_utf8($stuff{$gob_id}{$e}{$item_id}{'Desc'});
                }
                if ( $stuff{$gob_id}{$e}{$item_id}{'Type'} )
                {
                    $type = Encode::decode_utf8($stuff{$gob_id}{$e}{$item_id}{'Type'});
                }
                if ( $type eq 'Composant' )
                {
                    $compos .= '<li class="equipement'.$equipe.'">['.$item_id.'] '.$type.' : '.$nom.' ('.$desc.')'.$min.'</li>'."\n";
                }
            }
        }
        if ( $compos ne '' )
        {
            print $fh '                    <tr class="expanded">'."\n";
            print $fh '                        <th>Composant(s) de '.$gobs{$gob_id}{'Nom'}.' ('.$gob_id.') </th>'."\n";
            print $fh '                    </tr>'."\n";
            print $fh '                    <tr>'."\n";
            print $fh '                        <td>'."\n";
            print $fh '                            <ul class="membreEquipementList">'."\n";
            print $fh $compos;
            print $fh '                            </ul>'."\n";
            print $fh '                        </td>'."\n";
            print $fh '                    </tr>'."\n";
        }
    }
    print $fh '                </table>'."\n";

    my $t_elapsed = sprintf ("%0.3f", tv_interval($t_start));
    print $fh '                <div class="footer">[HTML generated in '.$t_elapsed.' sec.] - [Updated @'.localtime.']</div>'."\n";

    print $fh $GLB::functions::end;
    close $fh;
}

sub createProfil {

    for my $gob_id ( sort keys %gobs )
    {
        my $t_start  = [gettimeofday()];
        my $filename = '/var/www/localhost/htdocs/gobelins/'.$gob_id.'.html';
        open(my $fh, '>', $filename) or die "Could not open file '$filename' $!";
        binmode($fh, ":utf8");
        print $fh $GLB::functions::begin;

        print $fh '            <div id="content">'."\n";

        my $position = $gobs{$gob_id}{'X'}.', '.$gobs{$gob_id}{'Y'}.', '.$gobs{$gob_id}{'N'};

        print $fh '                <h1>Profil de '.$gobs{$gob_id}{'Nom'}.'</h1>'."\n";
        print $fh '                <div id="profilInfos">'."\n";
        print $fh '                    <fieldset>'."\n";
        print $fh '                        <legend>Caracteristiques</legend>'."\n";
        print $fh '                        <strong>Tribu</strong> : '.$gobs{$gob_id}{'Tribu'}.'<br/>'."\n";
        print $fh '                        <strong>Niveau</strong> : '.$gobs{$gob_id}{'Niveau'}.'<br/>'."\n";
        print $fh '                        <strong>Date Limite d\'Action</strong> : '.$gobs{$gob_id}{'DLA'}.'<br/>'."\n";
        print $fh '                        <strong>Position</strong> : '.$position.'<br/>'."\n";
        print $fh '                        <br>'."\n";
        print $fh '                        <strong>ATT</strong> : '.$gobs2{$gob_id}{'ATT'}.'D +'.$gobs2{$gob_id}{'BPATT'}.' +'.$gobs2{$gob_id}{'BMATT'}.'<br/>'."\n";
        print $fh '                        <strong>ESQ</strong> : '.$gobs2{$gob_id}{'ESQ'}.'D +'.$gobs2{$gob_id}{'BPESQ'}.' +'.$gobs2{$gob_id}{'BMESQ'}.'<br/>'."\n";
        print $fh '                        <strong>DEG</strong> : '.$gobs2{$gob_id}{'DEG'}.'D +'.$gobs2{$gob_id}{'BPDEG'}.' +'.$gobs2{$gob_id}{'BMDEG'}.'<br/>'."\n";
        print $fh '                        <strong>REG</strong> : '.$gobs2{$gob_id}{'REG'}.'D +'.$gobs2{$gob_id}{'BPREG'}.' +'.$gobs2{$gob_id}{'BMREG'}.'<br/>'."\n";
        print $fh '                        <strong>PER</strong> : '.$gobs2{$gob_id}{'PER'}.' +'. $gobs2{$gob_id}{'BPPER'}.' +'.$gobs2{$gob_id}{'BMPER'}.'<br/>'."\n";
        print $fh '                        <strong>ARM</strong> : '.                             $gobs2{$gob_id}{'BPArm'}.' +'.$gobs2{$gob_id}{'BMArm'}.'<br/>'."\n";
        print $fh '                        <strong>PVs</strong> : '.$gobs{$gob_id}{'PV'}.' / '.$gobs2{$gob_id}{'PVMax'}.'<br/>'."\n";
        print $fh '                        <br>'."\n";
        print $fh '                        <strong>Faim</strong> : '.$gobs2{$gob_id}{'Faim'}.'<br/>'."\n";
        print $fh '                        <br>'."\n";
        print $fh '                        <strong>Duree normale du tour</strong> : '.$gobs2{$gob_id}{'DLA'}.'<br/>'."\n";
        print $fh '                        <strong>Bonus / Malus de duree</strong> : '.($gobs2{$gob_id}{'BPDLA'}+$gobs2{$gob_id}{'BMDLA'}).'<br/>'."\n";
        print $fh '                        <strong>Augmentation due aux blessures</strong> : [A CODER]</span><br/>'."\n";
        print $fh '                        <strong>Poids des possessions</strong> : [A CODER]</span><br/>'."\n";
        print $fh '                        <strong>Duree totale du tour</strong> : [A CODER]</span><br/>'."\n";
        print $fh '                        <strong>Prochaine DLA</strong> : [A CODER]</span><br/>'."\n";
        print $fh '                        <br>'."\n";
        print $fh '                        <strong>Canines de Trolls</strong> : '.$gobs{$gob_id}{'CT'}.' CT<br/>'."\n";
        print $fh '                    </fieldset>'."\n";
        print $fh '                    <fieldset>'."\n";
        print $fh '                        <legend>Cafards</legend>'."\n";
        print $fh '                        Pas encore disponible dans les scripts Externes'."\n";
        print $fh '                    </fieldset>'."\n";
        print $fh '                    <fieldset>'."\n";
        print $fh '                        <legend>Talents</legend>'."\n";
        print $fh '                        <strong>Techniques</strong> :<br/>'."\n";
        print $fh '                        <ul>'."\n";

        foreach my $t_id ( sort keys %{$skill{$gob_id}{'Talents'}{'T'}} )
        {
            my $nom     = Encode::decode_utf8($skill{$gob_id}{'Talents'}{'T'}{$t_id}{'Nom'});
            my $percent = $skill{$gob_id}{'Talents'}{'T'}{$t_id}{'Connaissance'};
            my $niveau  = $skill{$gob_id}{'Talents'}{'T'}{$t_id}{'Niveau'};
            print $fh '                            <li>'.$nom.' ('.$percent.' %) [Niv. '.$niveau.']</li>'."\n";
        }

        print $fh '                        </ul>'."\n";
        print $fh '                        <strong>Competences</strong> :<br/>'."\n";
        print $fh '                        <ul>'."\n";

        foreach my $t_id ( sort keys %{$skill{$gob_id}{'Talents'}{'C'}} )
        {
            my $nom     = Encode::decode_utf8($skill{$gob_id}{'Talents'}{'C'}{$t_id}{'Nom'});
            my $percent = $skill{$gob_id}{'Talents'}{'C'}{$t_id}{'Connaissance'};
            my $niveau  = $skill{$gob_id}{'Talents'}{'C'}{$t_id}{'Niveau'};
            print $fh '                            <li>'.$nom.' ('.$percent.' %) [Niv. '.$niveau.']</li>'."\n";
        }

        print $fh '                        </ul>'."\n";
        print $fh '                    </fieldset>'."\n";

        print $fh '                    <fieldset>'."\n";
        print $fh '                        <legend>'.Encode::decode_utf8('Equipement Equipé').'</legend>'."\n";
        foreach my $e ( sort keys %{$stuff{$gob_id}} )
        {
            if ( $e eq 'Equipe' )
            {
                for my $item_id ( sort keys %{$stuff{$gob_id}{$e}} )
                {
                    my $min    = '';
                    my $desc   = Encode::decode_utf8('<b>Non identifié</b>');
                    my $equipe = $e;
                    my $type   = '';
                    my $nom    = $stuff{$gob_id}{$e}{$item_id}{'Nom'};

                    if ( $stuff{$gob_id}{$e}{$item_id}{'Poids'} )
                    {
                        $min = ', '.$stuff{$gob_id}{$e}{$item_id}{'Poids'}/60 . ' min';
                    }
                    if ( $stuff{$gob_id}{$e}{$item_id}{'Identifie'} eq 'VRAI' )
                    {
                        $desc = Encode::decode_utf8($stuff{$gob_id}{$e}{$item_id}{'Desc'});
                    }
                    if ( $stuff{$gob_id}{$e}{$item_id}{'Type'} )
                    {
                        $type = Encode::decode_utf8($stuff{$gob_id}{$e}{$item_id}{'Type'});
                    }
                    my $png = GLB::functions::GetStuffIcon($type,$nom);
                    print $fh '<img src="/images/stuff/'.$png.'">['.$item_id.'] '.$nom.' ('.$desc.')'.$min.'<br>'."\n";
                }
            }
        }
        print $fh '                    </fieldset>'."\n";

        print $fh '                </div>'."\n";

        my $t_elapsed = sprintf ("%0.3f", tv_interval($t_start));
        print $fh '                <div class="footer">[HTML generated in '.$t_elapsed.' sec.] - [Updated @'.localtime.']</div>'."\n";

        print $fh $GLB::functions::end;
        close $fh;
    }
}

sub createVue {

    for my $gob_id ( sort keys %gobs )
    {
        my $glyaml = YAML::Tiny->read( $yaml );
        if ( $glyaml->[0]->{clan}{$gob_id} )
        {
            my $t_start  = [gettimeofday()];
            my $filename = '/var/www/localhost/htdocs/vue/'.$gob_id.'.html';
            open(my $fh, '>', $filename) or die "Could not open file '$filename' $!";
            binmode($fh, ":utf8");
            print $fh $GLB::functions::begin;

            my $VUE_ref    = GLB::GLAPI::getVue($yaml, $gob_id);
            my %VUE        = %{$VUE_ref};
            my %ITEMS;

            my $T_emoji = '<img src="/images/1f4b0.png" width="16" height="16">'; #💰
            my $L_emoji = '<img src="/images/1f3e0.png" width="16" height="16">'; #🏠
            my $G_emoji = '<img src="/images/1f60e.png" width="16" height="16">'; #😎
            my $C_emoji = '<img src="/images/1f47f.png" width="16" height="16">'; #👿
            my $W_emoji = '<img src="/images/1f6a7.png" width="16" height="16">'; #🚧

            my $T_count = 0;
            my $C_count = 0;
            my $L_count = 0;
            my $G_count = 0;

            foreach my $type ( keys %VUE )
            {
                foreach my $id ( keys %{$VUE{$type}} )
                {
                    if ( $type eq 'T' ) { $T_count++ }
                    elsif ( $type eq 'C' ) { $C_count++ }
                    elsif ( $type eq 'G' ) { $G_count++ }
                    elsif ( $type eq 'L' && $VUE{$type}{$id}{'Nom'} ne 'Mur' ) { $L_count++ }

                    my $x = $VUE{$type}{$id}{'X'};
                    my $y = $VUE{$type}{$id}{'Y'};
                    if (! $ITEMS{$x}{$y})
                    {
                        $ITEMS{$x}{$y}{'td'} = '';
                        $ITEMS{$x}{$y}{'tt'} = "<center>&nbsp;&nbsp;X = $x | Y = $y<br><br></center>";
                    }

                    if ( $type eq 'T' && $ITEMS{$x}{$y}{'td'} !~ /1f4b0/ )
                    {
                        $ITEMS{$x}{$y}{'td'} .= $T_emoji;
                    }
                    elsif ( $type eq 'L' && $ITEMS{$x}{$y}{'td'} !~ /1f3e0/ && $VUE{$type}{$id}{'Nom'} ne 'Mur')
                    {
                        $ITEMS{$x}{$y}{'td'} .= $L_emoji;
                    }
                    elsif ( $type eq 'L' && $VUE{$type}{$id}{'Nom'} eq 'Mur')
                    {
                        $ITEMS{$x}{$y}{'td'} .= $W_emoji;
                    }
                    elsif ( $type eq 'C' && $ITEMS{$x}{$y}{'td'} !~ /1f47f/ )
                    {
                        $ITEMS{$x}{$y}{'td'} .= $C_emoji;
                    }
                    elsif ( $type eq 'G' && $ITEMS{$x}{$y}{'td'} !~ /1f60e/ )
                    {
                        $ITEMS{$x}{$y}{'td'} .= $G_emoji;
                    }

                    my $n = $VUE{$type}{$id}{'N'};
                    if ( $ITEMS{$x}{$y}{'tt'} !~ /N = $n/ )
                    {
                        $ITEMS{$x}{$y}{'tt'} .= "&nbsp;&nbsp;N = $n<br>";
                    }

                    my $tt_text_c = 'black';
                    if ($type eq 'G') { $tt_text_c = 'blue'};
                    $ITEMS{$x}{$y}{'tt'} .= "&nbsp;&nbsp;[$id] <span style='color:$tt_text_c'>".Encode::decode_utf8($VUE{$type}{$id}{'Nom'}).'</span><br>';
                }
            }

            my $cases = $gobs2{$gob_id}{'PER'} + $gobs2{$gob_id}{'BPPER'} + $gobs2{$gob_id}{'BMPER'};
            my $X     = $gobs{$gob_id}{'X'};
            my $Y     = $gobs{$gob_id}{'Y'};

            print $fh '            <div id="content">'."\n";

            print $fh '<h1>Vue de '.$gobs{$gob_id}{'Nom'}.' ('.$cases.' cases)'.'</h1>'."\n";
            print $fh '<table cellspacing="0" id="GobVue">'."\n";
            print $fh '    <caption>'."\n";
            print $fh '        <br>'.$T_emoji.'Tresors ('.$T_count.') | '.$G_emoji.'Gobelins ('.$G_count.') | '.$L_emoji.' Lieux ('.$L_count.')<br>'."\n";
            print $fh '            '.$C_emoji.'Monstres ('.$C_count.')<br>'."\n";
            print $fh '    <caption>'."\n";
            print $fh '    <tbody>'."\n";
            print $fh '        <tr>'."\n";
            print $fh '            <td class="blank"></td>'."\n";
            for (my $td = $X - $cases; $td <= $X + $cases; $td++) {print $fh '            <th>'.$td.'</th>'."\n" }

            for (my $tr = $Y + $cases; $tr >= $Y - $cases; $tr--)
            {
                print $fh '        <tr>'."\n";
                print $fh '            <th>'.$tr.'</th>'."\n";
                for (my $td = $X - $cases; $td <= $X + $cases; $td++)
                {
                    my $tdcolor;
                    if ( $td == $X and $tr == $Y ) { $tdcolor = 'style="background-color: white"' } else { $tdcolor = '' }
                    if ( defined $ITEMS{$td}{$tr}{'td'} )
                    {
                        print $fh '            <td '.$tdcolor.'>'."\n";
                        print $fh '                <div class="tt">'."\n";
                        print $fh '                    '.$ITEMS{$td}{$tr}{'td'}."\n";
                        print $fh '                    <span class="tt_text">'.$ITEMS{$td}{$tr}{'tt'}.'</span>'."\n";
                        print $fh '                </div>'."\n";
                        print $fh '            </td>'."\n";
                    }
                    else
                    {
                        print $fh '            <td '.$tdcolor.'></td>'."\n";
                    }
                }
                print $fh '        </tr>'."\n";
            }
            print $fh '    </tbody>'."\n";
            print $fh '</table>'."\n";

            my $t_elapsed = sprintf ("%0.3f", tv_interval($t_start));
            print $fh '                <div class="footer">[HTML generated in '.$t_elapsed.' sec.] - [Updated @'.localtime.']</div>'."\n";

            print $fh $GLB::functions::end;
            close $fh;
        }
    }
}

1;
