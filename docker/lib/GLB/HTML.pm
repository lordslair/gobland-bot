package GLB::HTML;

use Time::HiRes qw[gettimeofday tv_interval];

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
        print $fh '                  <td><a href="http://rabatteurs.lordslair.net/gobelins/'.$gob_id.'.html" title="Votre profil">PROFIL</a><br></td>'."\n";
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

    use POSIX qw(strftime);

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
        my $date = strftime "%d/%m/%y %H:%M:%S", localtime;
        print $fh '                    <tr class="expanded">'."\n";
        print $fh '                        <th>Equipement(s) de '.$gobs{$gob_id}{'Nom'}.' ('.$gob_id.') '."<em>[maj : $date]</em></th>\n";
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
                print $fh ' ' x 32, '<li class="equipement'.$equipe.'">['.$item_id.'] '.$type.' : '.$nom.' ('.$desc.')'.$min.'</li>'."\n";
            }
            if ( $e eq 'Equipe' ) { print $fh '                                <br>'."\n" }
        }
        print $fh '                            </ul>'."\n";
        print $fh '                        </td>'."\n";
        print $fh '                    </tr>'."\n";
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
        print $fh '                </div>'."\n";

        my $t_elapsed = sprintf ("%0.3f", tv_interval($t_start));
        print $fh '                <div class="footer">[HTML generated in '.$t_elapsed.' sec.] - [Updated @'.localtime.']</div>'."\n";

        print $fh $GLB::functions::end;
        close $fh;
    }
}

1;
