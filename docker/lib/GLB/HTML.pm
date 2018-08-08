package GLB::HTML;

use lib '/home/gobland-bot/lib/';
use GLB::GLAPI;

my $begin = <<"START_LOOP";
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
    <head>
        <title>Sopratrolls</title>
        <link rel="stylesheet" type="text/css" href="/style/common.css" />
        <link rel="stylesheet" type="text/css" href="/style/menu.css" />
        <link rel="stylesheet" type="text/css" href="/style/equipement.css" />
        <script type="text/javascript" src="/js/common.js"></script>
        <script type="text/javascript" src="/js/domcollapse.js"></script>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    </head>
    <body>
        <div id="page">
            <div id="header">
                <br><br><br><br><br><br><br><br>
                <div id="nav">
                    <ul id="menu">
                        <li><a href="http://rabatteurs.lordslair.net/index.html" title="Page d'accueil">Accueil</a></li>
                        <li><a href="#">Consulter</a>
                            <ul>
                                <li><a href="equipement.html" title="Equipement des Gob' du Clan">Equipement du Clan</a></li>
                            </ul>
                       </li>
                        <li><a href="" title="">Outils</a></li>
                        <li><a href="" title="">Liens</a></li>
                    </ul>
                </div>
            </div>
START_LOOP

my $end   = <<"END_LOOP";
            </div>
        </div>
    </body>
</html>
END_LOOP

sub createIndex {
    my $filename = '/var/www/localhost/htdocs/index.html';
    open(my $fh, '>', $filename) or die "Could not open file '$filename' $!";
    binmode($fh, ":utf8");

    print $fh $begin;

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

    my $yaml       = '/home/gobland-bot/gl-config.yaml';
    my $gobs_ref   = GLB::GLAPI::GetClanMembres($yaml);
    my %gobs       = %{$gobs_ref};

    my $gobs2_ref  = GLB::GLAPI::GetClanMembres2($yaml);
    my %gobs2      = %{$gobs2_ref};

    my $ct_total   = 0;

    for my $gob_id ( sort keys %gobs )
    {
        my $position = $gobs{$gob_id}{'X'}.', '.$gobs{$gob_id}{'Y'}.', '.$gobs{$gob_id}{'N'};

        my $pad;
        if ( $gobs{$gob_id}{'PA'} > 0 )
        {
            $pad = ' class="PADispo"';
        } else { $pad = ' ' }

        my $green  = '#77EE77';
        my $jaune  = '#EEEE77';
        my $orange = '#EEAA77';
        my $red    = '#B22222';
        my $color  = '#FFFFFF';
        my $percent = 100 * ($gobs{$gob_id}{'PV'} / $gobs2{$gob_id}{'PVMax'});
        if    ( $percent > 75 ) { $color = $green }
        elsif ( $percent > 50 ) { $color = $jaune }
        elsif ( $percent > 25 ) { $color = $orange }
        else  { $color = $red }
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

    print $fh $end;
    close $fh;
}

sub createEquipement {

    use POSIX qw(strftime);

    my $filename = '/var/www/localhost/htdocs/equipement.html';
    open(my $fh, '>', $filename) or die "Could not open file '$filename' $!";
    binmode($fh, ":utf8");
    print $fh $begin;

    print $fh '            <div id="content">'."\n";
    print $fh '                <h1>Possessions</h1>'."\n";
    print $fh '                <h2 class="expanded">Equipements Gobelins</h2>'."\n";
    print $fh '                <table cellspacing="0" id="profilInfos">'."\n";

    my $yaml      = '/home/gobland-bot/gl-config.yaml';
    my $stuff_ref = GLB::GLAPI::GetClanEquipement($yaml);
    my %stuff     = %{$stuff_ref};
    my $gobs_ref  = GLB::GLAPI::GetClanMembres($yaml);
    my %gobs      = %{$gobs_ref};

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
    print $fh $end;
    close $fh;
}

sub createProfil {

    my $yaml      = '/home/gobland-bot/gl-config.yaml';
    my $gobs_ref  = GLB::GLAPI::GetClanMembres($yaml);
    my %gobs      = %{$gobs_ref};
    my $gobs2_ref = GLB::GLAPI::GetClanMembres2($yaml);
    my %gobs2     = %{$gobs2_ref};

    for my $gob_id ( sort keys %gobs )
    {
        my $filename = '/var/www/localhost/htdocs/gobelins/'.$gob_id.'.html';
        open(my $fh, '>', $filename) or die "Could not open file '$filename' $!";
        binmode($fh, ":utf8");
        print $fh $begin;

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
        print $fh '                </div>'."\n";

        print $fh $end;
        close $fh;
    }
}

1;
