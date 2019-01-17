package GLB::HTML::createComposants;
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

    print "GLB::HTML::createComposants[";

    my $t_start  = [gettimeofday()];
    my $filename = '/var/www/localhost/htdocs/composants.html';
    open(my $fh, '>', $filename) or die "Could not open file '$filename' $!";
    binmode($fh, ":utf8");
    print $fh $GLB::variables::begin;

    print $fh ' ' x 6, '<div id="content">'."\n";
    print $fh ' ' x 6, '<link href="/style/equipement.css"  rel="stylesheet" type="text/css"  />'."\n";
    print $fh ' ' x 8, '<h1>Possessions</h1>'."\n";

    print $fh ' ' x 8, '<h2 class="expanded">Composants Gobelins</h2>'."\n";
    print $fh ' ' x 8, '<table cellspacing="0" id="profilInfos">'."\n";

    my @gob_ids = @GLB::variables::gob_ids;

    for my $gob_id ( sort @gob_ids )
    {

        print '.';

        my $req_comp_count = $dbh->prepare( "SELECT COUNT (*) FROM ItemsGobelins WHERE Type = 'Composant' AND Gobelin = $gob_id" );
           $req_comp_count->execute();
        my ($comp_count) = $req_comp_count->fetchrow_array;

        if ( $comp_count > 0 )
        {
            print $fh ' ' x10, '<tr class="expanded">'."\n";
            print $fh ' ' x12, '<th>Composants de '.$id2gob{$gob_id}.' ('.$gob_id.')</th>'."\n";
            print $fh ' ' x10, '</tr>'."\n";
            print $fh ' ' x10, '</tr>'."\n";
            print $fh ' ' x10, '<tr>'."\n";
            print $fh ' ' x12, '<td>'."\n";
            print $fh ' ' x14, '<ul class="membreEquipementList">'."\n";

            my $req_comp = $dbh->prepare( "SELECT * FROM ItemsGobelins WHERE Type = 'Composant' AND Gobelin = $gob_id" );
               $req_comp->execute();

            while (my @row = $req_comp->fetchrow_array)
            {
                my $item_id = $row[0];
                my $min     = sprintf("%.1f",$row[7]/60);
                my $nom     = Encode::decode_utf8($row[4]);
                my $desc    = Encode::decode_utf8($row[6]);

                print $fh ' ' x16, '<li class="equipementNonEquipe">'.'['.$item_id.'] '.$nom.' ('.$desc.'), '.$min.' min</li>'."\n";
            }

            print $fh ' ' x14, '</ul>'."\n";
            print $fh ' ' x12, '</td>'."\n";
            print $fh ' ' x10, '</tr>'."\n";
        }
    }
    print $fh ' ' x 8, '</table>'."\n";

    my $t_elapsed = sprintf ("%0.3f", tv_interval($t_start));
    print $fh ' ' x 8, '<div class="footer">[HTML generated in '.$t_elapsed.' sec.] - [Updated @'.localtime.']</div>'."\n";

    print $fh $GLB::variables::end;
    close $fh;
    print "]\n";
}

1;
