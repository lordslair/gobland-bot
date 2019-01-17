package GLB::HTML::createMateriaux;
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

    print "GLB::HTML::createMateriaux[";

    my $t_start  = [gettimeofday()];
    my $filename = '/var/www/localhost/htdocs/materiaux.html';
    open(my $fh, '>', $filename) or die "Could not open file '$filename' $!";
    binmode($fh, ":utf8");
    print $fh $GLB::variables::begin;

    print $fh ' ' x 6, '<div id="content">'."\n";
    print $fh ' ' x 6, '<link href="/style/tt_r.css"  rel="stylesheet" type="text/css"  />'."\n";
    print $fh ' ' x 6, '<link href="/style/equipement.css"  rel="stylesheet" type="text/css"  />'."\n";
    print $fh ' ' x 8, '<h1>Possessions</h1>'."\n";

    print $fh ' ' x 8, '<h2 class="expanded">Materiaux Gobelins</h2>'."\n";
    print $fh ' ' x 8, '<table cellspacing="0" id="profilInfos">'."\n";

    my @gob_ids = @GLB::variables::gob_ids;

    for my $gob_id ( sort @gob_ids )
    {

        print '.';

        my $req_comp_count = $dbh->prepare( "SELECT COUNT (*) FROM ItemsGobelins WHERE ( Type = 'Matériau' OR Type = 'Roche' OR Type = 'Minerai' ) AND Gobelin = $gob_id" );
           $req_comp_count->execute();
        my ($comp_count) = $req_comp_count->fetchrow_array;

        if ( $comp_count > 0 )
        {
            print $fh ' ' x10, '<tr class="expanded">'."\n";
            print $fh ' ' x12, '<th>Materiau de '.$id2gob{$gob_id}.' ('.$gob_id.')</th>'."\n";
            print $fh ' ' x10, '</tr>'."\n";
            print $fh ' ' x10, '</tr>'."\n";
            print $fh ' ' x10, '<tr>'."\n";
            print $fh ' ' x12, '<td>'."\n";
            print $fh ' ' x14, '<ul class="membreEquipementList">'."\n";

            my $req_comp = $dbh->prepare( "SELECT * FROM ItemsGobelins \
                                           WHERE ( Type = 'Matériau' OR Type = 'Roche' OR Type = 'Minerai' ) \
                                           AND Gobelin = $gob_id \
                                           ORDER BY Type,Nom" );
               $req_comp->execute();

            while (my @row = $req_comp->fetchrow_array)
            {
                my $item_id = $row[0];
                my $min     = sprintf("%.1f",$row[7]/60);
                my $nom     = Encode::decode_utf8($row[4]);
                my $type    = $row[2];
                my $qualite = $row[9];
                my $desc    = GLB::functions::GetQualite($type,$qualite);
                my $nbr     = $row[8];
                my $m_png   = GLB::functions::GetMateriauIcon($nom);
                my $carats  = GLB::functions::GetCarats($qualite,$nbr);

                print $fh ' ' x16, '<li class="equipementNonEquipe">'."\n";
                print $fh ' ' x18, '<div class="tt_r">'."\n";
                print $fh ' ' x20, $m_png.' ['.$item_id.'] '.$nom.' de taille '.$nbr.' ('.$desc.'), '.$min.' min<span class="tt_r_text">'.$carats.' Carats</span>'."\n";
                print $fh ' ' x18, '<div>'."\n";
                print $fh ' ' x16, '</li>'."\n";
            }

            print $fh ' ' x14, '</ul>'."\n";
            print $fh ' ' x12, '</td>'."\n";
            print $fh ' ' x10, '</tr>'."\n";
        }
    }

    print $fh ' ' x 8, '</table>'."\n";

    my $t_elapsed = sprintf ("%0.3f", tv_interval($t_start));
    print $fh ' ' x 8, '<div class="footer">[HTML generated in '.$t_elapsed.' sec.] - [Updated @'.localtime.']</div>'."\n";

    print $fh $GLB::variables::vuescript;
    print $fh $GLB::variables::end;
    close $fh;
    print "]\n";
}

1;
