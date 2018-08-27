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
        my $percent = ($gobs{$gob_id}{'PV'} / $gobs2{$gob_id}{'PVMax'}) * 100;
        my $lifebar = '<br><div class="vieContainer"><div style="background-color:'.$color.'; width: '.$percent.'%">&nbsp;</div></div>';

        $ct_total += $gobs{$gob_id}{'CT'};

        print $fh '                <tr>'."\n";
        print $fh '                  <td>'."\n";
        print $fh '                    <a href="http://games.gobland.fr/Profil.php?IdPJ='.$gob_id.'" target="_blank">'.$gobs{$gob_id}{'Nom'}."\n";                    print $fh '                    </a>'."\n";
        print $fh '                  </td>'."\n";
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

sub createMateriaux {

    my $t_start  = [gettimeofday()];
    my $filename = '/var/www/localhost/htdocs/materiaux.html';
    open(my $fh, '>', $filename) or die "Could not open file '$filename' $!";
    binmode($fh, ":utf8");
    print $fh $GLB::functions::begin;

    print $fh '            <div id="content">'."\n";
    print $fh '                <h1>Possessions</h1>'."\n";

    print $fh '                <h2 class="expanded">Materiaux Gobelins</h2>'."\n";
    print $fh '                <table cellspacing="0" id="profilInfos">'."\n";

    for my $gob_id ( sort keys %stuff )
    {
        my $materiaux = '';
        foreach my $e ( sort keys %{$stuff{$gob_id}} )
        {
            for my $item_id ( sort keys %{$stuff{$gob_id}{$e}} )
            {
                if ( $stuff{$gob_id}{$e}{$item_id}{'Type'} =~ /^Minerai$|Matériau/)
                {
                    my $min     = ', '.sprintf("%.1f", $stuff{$gob_id}{$e}{$item_id}{'Poids'}/60) . ' min';
                    my $nom     = Encode::decode_utf8($stuff{$gob_id}{$e}{$item_id}{'Nom'});
                    my $desc    = GLB::functions::GetQualite($stuff{$gob_id}{$e}{$item_id}{'Type'}, $stuff{$gob_id}{$e}{$item_id}{'Qualite'});
                    my $nbr     = $stuff{$gob_id}{$e}{$item_id}{'Taille'};
                    my $m_png   = '';
                    $materiaux .= ' ' x 32 . '<li class="equipementNonEquipe">'."\n";
                    if ( $nom eq 'Rondin'         ) { $m_png = '<img src="/images/stuff/icon_109.png">' }
                    if ( $nom eq 'Minerai de Fer' ) { $m_png = '<img src="/images/stuff/icon_104.png">' }
                    if ( $nom eq 'Cuir'           ) { $m_png = '<img src="/images/stuff/icon_98.png">'  }
                    $materiaux .= ' ' x 34 . $m_png;
                    $materiaux .= ' ' x 34 . '['.$item_id.'] '.$nom.' de taille '.$nbr.' ('.$desc.')'.$min."\n";
                    $materiaux .= ' ' x 32 . '</li>'."\n";
                }
            }
        }
        if ( $materiaux ne '' )
        {
            print $fh '                    <tr class="expanded">'."\n";
            print $fh '                        <th>Materiaux de '.$gobs{$gob_id}{'Nom'}.' ('.$gob_id.') </th>'."\n";
            print $fh '                    </tr>'."\n";
            print $fh '                    <tr>'."\n";
            print $fh '                        <td>'."\n";
            print $fh '                            <ul class="membreEquipementList">'."\n";
            print $fh $materiaux;
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

sub createComposants
{
    my $t_start  = [gettimeofday()];
    my $filename = '/var/www/localhost/htdocs/composants.html';
    open(my $fh, '>', $filename) or die "Could not open file '$filename' $!";
    binmode($fh, ":utf8");
    print $fh $GLB::functions::begin;

    print $fh '            <div id="content">'."\n";
    print $fh '                <h1>Possessions</h1>'."\n";

    print $fh '                <h2 class="expanded">Composants Gobelins</h2>'."\n";
    print $fh '                <table cellspacing="0" id="profilInfos">'."\n";
    for my $gob_id ( sort keys %stuff )
    {
        my $compos = '';
        foreach my $e ( sort keys %{$stuff{$gob_id}} )
        {
            for my $item_id ( sort keys %{$stuff{$gob_id}{$e}} )
            {
                if ( $stuff{$gob_id}{$e}{$item_id}{'Type'} eq 'Composant' )
                {
                    my $min     = ', '.sprintf("%.1f", $stuff{$gob_id}{$e}{$item_id}{'Poids'}/60) . ' min';
                    my $nom     = $stuff{$gob_id}{$e}{$item_id}{'Nom'};
                    my $desc    = Encode::decode_utf8($stuff{$gob_id}{$e}{$item_id}{'Desc'});
                    my $nbr     = $stuff{$gob_id}{$e}{$item_id}{'Taille'};
                    $compos    .= ' ' x 32 . '<li class="equipementNonEquipe">'."\n";
                    $compos    .= ' ' x 34 .'['.$item_id.'] '.$nom.' ('.$desc.')'.$min."\n";
                    $compos    .= ' ' x 32 . '</li>'."\n";
                }
            }
        }
        if ( $compos ne '' )
        {
            print $fh '                    <tr class="expanded">'."\n";
            print $fh '                        <th>Composants de '.$gobs{$gob_id}{'Nom'}.' ('.$gob_id.') </th>'."\n";
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
                my $min      = '';
                my $desc     = Encode::decode_utf8('<b>Non identifié</b>');
                my $equipe   = $e;
                my $type     = '';
                my $nom      = $stuff{$gob_id}{$e}{$item_id}{'Nom'};
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
                {
                    $template = ' <b>'.Encode::decode_utf8($stuff{$gob_id}{$e}{$item_id}{'Magie'}.'</b>');
                }
                if ( $type !~ /^Minerai$|Mat.riau|Composant/ )
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

    my $t_elapsed = sprintf ("%0.3f", tv_interval($t_start));
    print $fh '                <div class="footer">[HTML generated in '.$t_elapsed.' sec.] - [Updated @'.localtime.']</div>'."\n";

    print $fh $GLB::functions::end;
    close $fh;
}

sub createProfil {

    my $cafards_ref  = GLB::GLAPI::getClanCafards($yaml);
    my %cafards      = %{$cafards_ref};

    for my $gob_id ( sort keys %gobs )
    {
        my $t_start  = [gettimeofday()];
        my $dir      = '/var/www/localhost/htdocs/gobelins/';
        my $filename = $dir.$gob_id.'.html';
        unless ( -d $dir ) { mkdir $dir }
        open(my $fh, '>', $filename) or die "Could not open file '$filename' $!";
        binmode($fh, ":utf8");
        print $fh $GLB::functions::begin;

        print $fh '            <div id="content">'."\n";

        my $position = $gobs{$gob_id}{'X'}.', '.$gobs{$gob_id}{'Y'}.', '.$gobs{$gob_id}{'N'};
        my $duree_b  = GLB::functions::GetDureeDLA($gobs2{$gob_id}{'DLA'});
        my $duree_p  = GLB::functions::GetDureeDLA($gobs2{$gob_id}{'BPDLA'});
        my $duree_bm = GLB::functions::GetDureeDLA($gobs2{$gob_id}{'BMDLA'});
        my $duree_s  = $gobs2{$gob_id}{'DLA'} + $gobs2{$gob_id}{'BMDLA'} + $gobs2{$gob_id}{'BPDLA'};
        my $duree_t  = GLB::functions::GetDureeDLA($duree_s);
        my $faim_png  = '<img src="/images/stuff/icon_74.png">';
        my $ct_png    = '<img src="/images/stuff/icon_111.png">';

        print $fh '                <h1>Profil de '.$gobs{$gob_id}{'Nom'}.'</h1>'."\n";
        print $fh '                <div id="profilInfos">'."\n";
        print $fh '                    <fieldset>'."\n";
        print $fh '                        <legend>Caracteristiques</legend>'."\n";
        print $fh '                        <strong>Tribu</strong> : '.$gobs{$gob_id}{'Tribu'}.'<br/>'."\n";
        print $fh '                        <strong>Niveau</strong> : '.$gobs{$gob_id}{'Niveau'}.'<br/>'."\n";
        print $fh '                        <strong>Date Limite d\'Action</strong> : '.$gobs{$gob_id}{'DLA'}.'<br/>'."\n";
        print $fh '                        <strong>Position</strong> : '.$position.'<br/>'."\n";
        print $fh '                        <br>'."\n";
        print $fh '                        <strong>ATT</strong> : '.$gobs2{$gob_id}{'ATT'}.'D '.sprintf("%+d",$gobs2{$gob_id}{'BPATT'}).' '.sprintf("%+d",$gobs2{$gob_id}{'BMATT'}).'<br/>'."\n";
        print $fh '                        <strong>ESQ</strong> : '.$gobs2{$gob_id}{'ESQ'}.'D '.sprintf("%+d",$gobs2{$gob_id}{'BPESQ'}).' '.sprintf("%+d",$gobs2{$gob_id}{'BMESQ'}).'<br/>'."\n";
        print $fh '                        <strong>DEG</strong> : '.$gobs2{$gob_id}{'DEG'}.'D '.sprintf("%+d",$gobs2{$gob_id}{'BPDEG'}).' '.sprintf("%+d",$gobs2{$gob_id}{'BMDEG'}).'<br/>'."\n";
        print $fh '                        <strong>REG</strong> : '.$gobs2{$gob_id}{'REG'}.'D '.sprintf("%+d",$gobs2{$gob_id}{'BPREG'}).' '.sprintf("%+d",$gobs2{$gob_id}{'BMREG'}).'<br/>'."\n";
        print $fh '                        <strong>PER</strong> : '.$gobs2{$gob_id}{'PER'}.' '. sprintf("%+d",$gobs2{$gob_id}{'BPPER'}).' '.sprintf("%+d",$gobs2{$gob_id}{'BMPER'}).'<br/>'."\n";
        print $fh '                        <strong>ARM</strong> : '.                             $gobs2{$gob_id}{'BPArm'}.' '.sprintf("%+d",$gobs2{$gob_id}{'BMArm'}).'<br/>'."\n";
        print $fh '                        <strong>PVs</strong> : '.$gobs{$gob_id}{'PV'}.' / '.$gobs2{$gob_id}{'PVMax'}.'<br/>'."\n";
        print $fh '                        <br>'."\n";
        print $fh '                        <strong>'.$faim_png.'Faim</strong> : '.$gobs2{$gob_id}{'Faim'}.'<br/>'."\n";
        print $fh '                        <br>'."\n";
        print $fh '                        <strong>Duree normale du tour</strong> : '.$duree_b.'<br/>'."\n";
        print $fh '                        <strong>Bonus / Malus de duree</strong> : '.$duree_bm.'<br/>'."\n";
        print $fh '                        <strong>Augmentation due aux blessures</strong> : [A CODER]</span><br/>'."\n";
        print $fh '                        <strong>Poids des possessions</strong> : '.$duree_p.'</span><br/>'."\n";
        print $fh '                        <strong>Duree totale du tour</strong> : '.$duree_t.'</span><br/>'."\n";
        print $fh '                        <strong>Prochaine DLA</strong> : [A CODER]</span><br/>'."\n";
        print $fh '                        <br>'."\n";
        print $fh '                        <strong>'.$ct_png.'Canines de Trolls</strong> : '.$gobs{$gob_id}{'CT'}.' CT<br/>'."\n";
        print $fh '                    </fieldset>'."\n";
        print $fh '                    <fieldset>'."\n";
        print $fh '                        <legend>'.Encode::decode_utf8('Affinités').'</legend>'."\n";
        my @ecoles    = ('M','T','R','S','C','P');
        my @rms       = ('M','R');
        print $fh '                        <table style="border: 0px;float: left;margin: 0px;font-family: courier;font-size: 12px;">'."\n";
        foreach my $ecole (@ecoles)
        {
            print $fh '                        <tr>'."\n";
            foreach my $rm (@rms)
            {
                my $affinite = $rm.$ecole;
                my $sum = $gobs2{$gob_id}{$affinite}{$affinite} + $gobs2{$gob_id}{$affinite}{'B'};
                my $aff = $gobs2{$gob_id}{$affinite}{$affinite};
                my $bon = sprintf("%+d",$gobs2{$gob_id}{$affinite}{'B'});
                print $fh '                        <td style="border: 0px;text-align: left;padding: 1px;font-size: 12px;">'."\n";
                print $fh '                            <strong>'.$affinite.'</strong> : '.$sum.' ('.$aff.$bon.')'."\n";
                print $fh '                        </td>'."\n";
            }
            print $fh '                        </tr>'."\n";
        }
        print $fh '                        </table>'."\n";
        print $fh '                    </fieldset>'."\n";
        print $fh '                    <fieldset>'."\n";
        print $fh '                        <legend>Cafards</legend>'."\n";

        foreach my $c_id ( sort keys %{$cafards{$gob_id}} )
        {
            my $nom     = $cafards{$gob_id}{$c_id}{'Nom'};
            my $type    = $cafards{$gob_id}{$c_id}{'Type'};
            my $effet   = $cafards{$gob_id}{$c_id}{'Effet'};
            my $c_png   = $cafards{$gob_id}{$c_id}{'PNG'};

            print $fh '                        <li>'.$c_png.' ['.$c_id.'] '.$type.' ('.$effet.')</li>'."\n";
        }

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
            my $dir      = '/var/www/localhost/htdocs/vue/';
            my $filename = $dir.$gob_id.'.html';
            unless ( -d $dir ) { mkdir $dir }
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
            my $A_emoji = '<img src="/images/1f333.png" width="16" height="16">'; #🌳

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
                    elsif ( $type eq 'L' && $ITEMS{$x}{$y}{'td'} !~ /1f3e0/ && $VUE{$type}{$id}{'Nom'} !~ /Mur|Arbre/)
                    {
                        $ITEMS{$x}{$y}{'td'} .= $L_emoji;
                    }
                    elsif ( $type eq 'L' && $VUE{$type}{$id}{'Nom'} eq 'Mur')
                    {
                        $ITEMS{$x}{$y}{'td'} .= $W_emoji;
                    }
                    elsif ( $type eq 'L' && $VUE{$type}{$id}{'Nom'} eq 'Arbre')
                    {
                        $ITEMS{$x}{$y}{'td'} .= $A_emoji;
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
                        $ITEMS{$x}{$y}{'tt'} .= "&nbsp;&nbsp;<b>N = $n</b><br>";
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

            if ( $cases > 0 )
            {
                for (my $td = $X - $cases; $td <= $X + $cases; $td++) {print $fh '            <th>'.$td.'</th>'."\n" }
                print $fh '        </tr>'."\n";

                for (my $tr = $Y + $cases; $tr >= $Y - $cases; $tr--)
                {
                    print $fh '        <tr>'."\n";
                    print $fh '            <th>'.$tr.'</th>'."\n";
                    for (my $td = $X - $cases; $td <= $X + $cases; $td++)
                    {
                        my $tdcolor = '';
                        if ( $td == $X and $tr == $Y ) { $tdcolor = 'style="background-color: white"' }
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
            }
            else
            {
                my $tdcolor = 'style="background-color: white"';
                print $fh '            <th>'.$X.'</th>'."\n";
                print $fh '        </tr>'."\n";
                print $fh '        <tr>'."\n";
                print $fh '            <th>'.$Y.'</th>'."\n";
                print $fh '            <td '.$tdcolor.'>'."\n";
                print $fh '                <div class="tt">'."\n";
                print $fh '                    '.$ITEMS{$X}{$Y}{'td'}."\n";
                print $fh '                    <span class="tt_text">'.$ITEMS{$X}{$Y}{'tt'}.'</span>'."\n";
                print $fh '                </div>'."\n";
                print $fh '            </td>'."\n";
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

sub createPXBank {

    my $t_start  = [gettimeofday()];
    my $filename = '/var/www/localhost/htdocs/pxbank.html';
    open(my $fh, '>', $filename) or die "Could not open file '$filename' $!";
    binmode($fh, ":utf8");
    print $fh $GLB::functions::begin;

    print $fh '            <div id="content">'."\n";
    print $fh '                <h1>Banque PI/PX</h1>'."\n";
    print $fh '                <h3>(Alias: Qui '.Encode::decode_utf8('à').' la plus grosse ...)</h3>'."\n";

    print $fh '              <table cellspacing="0" id="trollsList">'."\n";
    print $fh '                <tr>'."\n";
    print $fh '                  <th onclick="sortTable(0)">Pseudo</th>'."\n";
    print $fh '                  <th onclick="sortTable(1)">Num</th>'."\n";
    print $fh '                  <th onclick="sortTable(2)">Niv.</th>'."\n";
    print $fh '                  <th onclick="sortTable(3)">PX Perso</th>'."\n";
    print $fh '                  <th onclick="sortTable(4)">PX</th>'."\n";
    print $fh '                  <th onclick="sortTable(5)">PI</th>'."\n";
    print $fh '                  <th onclick="sortTable(6)">PI Totaux</th>'."\n";
    print $fh '                  <th onclick="sortTable(7)">PX+PI Totaux</th>'."\n";
    print $fh '                </tr>'."\n";

    for my $gob_id ( sort keys %gobs )
    {
        my $total = $gobs{$gob_id}{'PXPerso'} + $gobs{$gob_id}{'PX'} + $gobs2{$gob_id}{'PITotal'};

        print $fh '                <tr>'."\n";
        print $fh '                  <td>'.$gobs{$gob_id}{'Nom'}.'</td>'."\n";
        print $fh '                  <td>'.$gob_id.'</td>'."\n";
        print $fh '                  <td>'.$gobs{$gob_id}{'Niveau'}.'</td>'."\n";
        print $fh '                  <td>'.$gobs{$gob_id}{'PXPerso'}.'</td>'."\n";
        print $fh '                  <td>'.$gobs{$gob_id}{'PX'}.'</td>'."\n";
        print $fh '                  <td>'.$gobs{$gob_id}{'PI'}.'</td>'."\n";
        print $fh '                  <td>'.$gobs2{$gob_id}{'PITotal'}.'</td>'."\n";
        print $fh '                  <td>'.$total.'</td>'."\n";
        print $fh '                </tr>'."\n";
    }

    print $fh '              </table>'."\n";
    print $fh '            </div>'."\n";

    my $t_elapsed = sprintf ("%0.3f", tv_interval($t_start));
    print $fh '                <div class="footer">[HTML generated in '.$t_elapsed.' sec.] - [Updated @'.localtime.']</div>'."\n";

    print $fh $GLB::functions::sortscript;
    print $fh $GLB::functions::end;
    close $fh;
}

sub createGPS {

    use YAML::Tiny;
    my $t_start  = [gettimeofday()];
    my $filename = '/var/www/localhost/htdocs/GPS.html';
    open(my $fh, '>', $filename) or die "Could not open file '$filename' $!";
    binmode($fh, ":utf8");
    print $fh $GLB::functions::begin;

    my $lieux_yaml = '/home/gobland-bot/data/Lieux.yaml';
    my $yaml       = YAML::Tiny->read( $lieux_yaml );
    my %LIEUX_YAML = %{$yaml->[0]};

    print $fh ' ' x16, '<div id="content" style="text-align:center;">'."\n";
    print $fh ' ' x18, '<h1>GPS des Lieux</h1>'."\n";
    print $fh ' ' x18, '<h3>Passez la souris sur un point pour afficher l\'infobulle</h3>'."\n";

    print $fh ' ' x18,'<div id="tooltip" display="none" style="position: absolute; display: none;"></div>'."\n";

    print $fh ' ' x18, '<svg version="1.2" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" class="graph" role="img">'."\n";
    print $fh ' ' x20, '<g class="grid x-grid" id="xGrid"><line x1="300" x2="300" y1="000" y2="600"></line></g>'."\n";
    print $fh ' ' x20, '<g class="grid y-grid" id="yGrid"><line x1="000" x2="600" y1="300" y2="300"></line></g>'."\n";
    print $fh ' ' x20, '<g class="grid r-grid" id="rGrid"><line x1="600" x2="600" y1="000" y2="600"></line></g>'."\n";
    print $fh ' ' x20, '<g class="grid t-grid" id="tGrid"><line x1="000" x2="600" y1="000" y2="000"></line></g>'."\n";
    print $fh ' ' x20, '<g class="grid b-grid" id="bGrid"><line x1="000" x2="600" y1="600" y2="600"></line></g>'."\n";
    print $fh ' ' x20, '<g class="grid l-grid" id="lGrid"><line x1="000" x2="000" y1="000" y2="600"></line></g>'."\n";

    foreach my $id_lieu (sort {$a<=>$b} keys %LIEUX_YAML)
    {
        my $position = "<b>X</b> = $LIEUX_YAML{$id_lieu}{'X'} | <b>Y</b> = $LIEUX_YAML{$id_lieu}{'Y'} | <b>N</b> = $LIEUX_YAML{$id_lieu}{'Z'}";
        my $cx = ($LIEUX_YAML{$id_lieu}{'X'} + 200) * 1.5;
        my $cy = (200 - $LIEUX_YAML{$id_lieu}{'Y'}) * 1.5;
        my $tt = '\''.$LIEUX_YAML{$id_lieu}{'Nom'}.' ('.$position.')\'';
        my $dv = $LIEUX_YAML{$id_lieu}{'Type'};
           $dv =~ s/^Amphi.*$/Amphitheatre/g;
           $dv =~ s/^.*cycle$/Hemicycle/g;
           $dv =~ s/^Mona.*$/Monastere/g;

        print $fh ' ' x20, '<g class="'.$dv.'">'."\n";
        print $fh ' ' x22, '<circle cx="'.$cx.'" cy="'.$cy.'" r="2" onmousemove="showTooltip(evt, '.$tt.')";" onmouseout="hideTooltip();">'."\n";
        print $fh ' ' x22, '</circle>'."\n";
        print $fh ' ' x20, '</g>'."\n";
    }

    print $fh ' ' x18, '</svg>'."\n";
    print $fh ' ' x16, '</div>'."\n";

    print $fh ' ' x16, '<br>'."\n";
    print $fh ' ' x16, '<div style="text-align:center;">'."\n";
    print $fh ' ' x18, '<svg version="1.2" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" class="leg" role="img">'."\n";
    print $fh ' ' x20, '<g class="grid r-grid" id="rGrid"><line x1="400" x2="400" y1="000" y2="050"></line></g>'."\n";
    print $fh ' ' x20, '<g class="grid t-grid" id="tGrid"><line x1="000" x2="400" y1="000" y2="000"></line></g>'."\n";
    print $fh ' ' x20, '<g class="grid b-grid" id="bGrid"><line x1="000" x2="400" y1="050" y2="050"></line></g>'."\n";
    print $fh ' ' x20, '<g class="grid l-grid" id="lGrid"><line x1="000" x2="000" y1="000" y2="050"></line></g>'."\n";

    print $fh ' ' x20, '<g class="Tour">        <circle cx="010" cy="10" r="5"</circle></g><text x="20"  y="15">Tour</text>'."\n";
    print $fh ' ' x20, '<g class="Laboratoire"> <circle cx="080" cy="10" r="5"</circle></g><text x="90"  y="15">Laboratoire</text>'."\n";
    print $fh ' ' x20, '<g class="Cercle">      <circle cx="160" cy="10" r="5"</circle></g><text x="170" y="15">Cercle</text>'."\n";
    print $fh ' ' x20, '<g class="Caverne">     <circle cx="240" cy="10" r="5"</circle></g><text x="250" y="15">Caverne</text>'."\n";
    print $fh ' ' x20, '<g class="Cabane">      <circle cx="320" cy="10" r="5"</circle></g><text x="330" y="15">Cabane</text>'."\n";

    print $fh ' ' x20, '<g class="Monastere">   <circle cx="010" cy="40" r="5"</circle></g><text x="020" y="45">Monastere</text>'."\n";
    print $fh ' ' x20, '<g class="Fosse">       <circle cx="080" cy="40" r="5"</circle></g><text x="090" y="45">Fosse</text>'."\n";
    print $fh ' ' x20, '<g class="Amphitheatre"><circle cx="160" cy="40" r="5"</circle></g><text x="170" y="45">Amphi.</text>'."\n";
    print $fh ' ' x20, '<g class="Hemicycle">   <circle cx="240" cy="40" r="5"</circle></g><text x="250" y="45">Hemicycle</text>'."\n";

    print $fh ' ' x18, '</svg>'."\n";
    print $fh ' ' x16, '</div>'."\n";
    print $fh ' ' x16, '<br>'."\n";

    my $t_elapsed = sprintf ("%0.3f", tv_interval($t_start));
    print $fh ' ' x16, '<div class="footer">[HTML generated in '.$t_elapsed.' sec.] - [Updated @'.localtime.']</div>'."\n";

    print $fh $GLB::functions::vuescript;
    print $fh $GLB::functions::end;
    close $fh;
}

1;
