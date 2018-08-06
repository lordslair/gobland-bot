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
                        <li><a href="index.html" title="Page d'accueil">Accueil</a></li>
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
    print $fh $end;
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

1;
