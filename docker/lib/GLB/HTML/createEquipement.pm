package GLB::HTML::createEquipement;
use strict;
use warnings;

use Time::HiRes qw[gettimeofday tv_interval];

use lib '/home/gobland-bot/lib/';
use GLB::variables;

my %id2gob     = %GLB::variables::id2gob;

use DBI;

my $dbh = DBI->connect(
       "dbi:SQLite:dbname=/home/gobland-bot/gobland.db",
       "",
       "",
       { RaiseError => 1 },
    ) or die $DBI::errstr;

sub main
{

    print "GLB::HTML::createEquipement[";

    my $t_start  = [gettimeofday()];
    my $filename = '/var/www/localhost/htdocs/equipement.html';
    open(my $fh, '>', $filename) or die "Could not open file '$filename' $!";
    binmode($fh, ":utf8");
    print $fh $GLB::variables::begin;

    print $fh ' ' x 6, '<div id="content">'."\n";
    print $fh ' ' x 6, '<link href="/style/equipement.css"  rel="stylesheet" type="text/css"  />'."\n";
    print $fh ' ' x 8, '<h1>Possessions</h1>'."\n";

    print $fh ' ' x 8, '<h2 class="expanded">Equipements Gobelins</h2>'."\n";
    print $fh ' ' x 8, '<table cellspacing="0" id="profilInfos">'."\n";

    my @gob_ids = @GLB::variables::gob_ids;

    for my $gob_id ( sort @gob_ids )
    {

        print '.';

        print $fh ' ' x10, '<tr class="expanded">'."\n";
        print $fh ' ' x12, '<th>Equipement(s) de '.$id2gob{$gob_id}.' ('.$gob_id.') </th>'."\n";
        print $fh ' ' x10, '</tr>'."\n";
        print $fh ' ' x10, '<tr>'."\n";
        print $fh ' ' x12, '<td>'."\n";
        print $fh ' ' x14, '<ul class="membreEquipementList">'."\n";

        # First request for Equiped stuff
        my $req_comp_1 = $dbh->prepare( "SELECT * FROM ItemsGobelins \
                                       WHERE Type NOT IN ('Minerai', 'Composant', 'Matériau') \
                                       AND Utilise  = 'VRAI' \
                                       AND Gobelin = $gob_id" );
        $req_comp_1->execute();

        while (my @row = $req_comp_1->fetchrow_array)
        {
            my $item_id  = Encode::decode_utf8($row[0]);
            my $type     = $row[2];
            my $min      = sprintf("%.1f",$row[7]/60);
            my $nom      = Encode::decode_utf8($row[4]);
            my $desc     = Encode::decode_utf8($row[6]);
            my $template = '<b>'.Encode::decode_utf8($row[5]).'</b>';
            my $luxe     = GLB::functions::GetLuxe($type,$nom,$desc);
            my $craft    = GLB::functions::GetCraft($type,$nom,$desc,$template);

            print $fh ' ' x 16, '<li class="equipementEquipe">'.'['.$item_id.'] '.$type.' : '.$nom.' '.$template.' ('.$desc.'), '.$min.' min'.$luxe.$craft.'</li>'."\n";
        }

        print $fh ' ' x 16, '<br>'."\n";

        # Second request for NonEquiped stuff
        my $req_comp_2 = $dbh->prepare( "SELECT * FROM ItemsGobelins \
                                       WHERE Type NOT IN ('Minerai', 'Composant', 'Mat..riau') \
                                       AND Utilise  = 'FAUX' \
                                       AND Gobelin = $gob_id" );
        $req_comp_2->execute();

        while (my @row = $req_comp_2->fetchrow_array)
        {
            my $item_id  = $row[0];
            my $type     = Encode::decode_utf8($row[2]);
            my $min      = sprintf("%.1f",$row[7]/60);
            my $nom      = Encode::decode_utf8($row[4]);
            my $desc     = Encode::decode_utf8($row[6]);
            my $template = '<b>'.Encode::decode_utf8($row[5]).'</b>';
            my $luxe     = GLB::functions::GetLuxe($type,$nom,$desc);
            my $craft    = GLB::functions::GetCraft($type,$nom,$desc,$template);

            print $fh ' ' x 16, '<li class="equipementNonEquipe">'.'['.$item_id.'] '.$type.' : '.$nom.' '.$template.' ('.$desc.'), '.$min.' min'.$luxe.$craft.'</li>'."\n";
        }

        print $fh ' ' x14, '</ul>'."\n";
        print $fh ' ' x12, '</td>'."\n";
        print $fh ' ' x10, '</tr>'."\n";
    }
    print $fh ' ' x 8, '</table>'."\n";

    my $t_elapsed = sprintf ("%0.3f", tv_interval($t_start));
    print $fh ' ' x 8, '<div class="footer">[HTML generated in '.$t_elapsed.' sec.] - [Updated @'.localtime.']</div>'."\n";

    print $fh $GLB::variables::end;
    close $fh;
    print "]\n";
}

1;
