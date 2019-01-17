package GLB::HTML::createPXBank;
use strict;
use warnings;

use Time::HiRes qw[gettimeofday tv_interval];

use lib '/home/gobland-bot/lib/';
use GLB::variables;

use DBI;

my $dbh = DBI->connect(
       "dbi:SQLite:dbname=/home/gobland-bot/gobland.db",
       "",
       "",
       { RaiseError => 1 },
    ) or die $DBI::errstr;

sub main
{

    print "GLB::HTML::createPXBank[";

    my $t_start  = [gettimeofday()];
    my $filename = '/var/www/localhost/htdocs/pxbank.html';
    open(my $fh, '>', $filename) or die "Could not open file '$filename' $!";
    binmode($fh, ":utf8");
    print $fh $GLB::variables::begin;

    print $fh ' ' x 6, '<div id="content">'."\n";
    print $fh ' ' x 8, '<h1>Banque PI/PX</h1>'."\n";
    print $fh ' ' x 8, '<h3>(Alias: Qui '.Encode::decode_utf8('à').' la plus grosse ...)</h3>'."\n";

    print $fh ' ' x 8, '<table cellspacing="0" id="trollsList">'."\n";
    print $fh ' ' x10, '<tr>'."\n";
    print $fh ' ' x12, '<th onclick="sortTable(0)">Pseudo</th>'."\n";
    print $fh ' ' x12, '<th onclick="sortTable(1)">Num</th>'."\n";
    print $fh ' ' x12, '<th onclick="sortTable(2)">Niv.</th>'."\n";
    print $fh ' ' x12, '<th onclick="sortTable(3)">PX Perso</th>'."\n";
    print $fh ' ' x12, '<th onclick="sortTable(4)">PX</th>'."\n";
    print $fh ' ' x12, '<th onclick="sortTable(5)">PI</th>'."\n";
    print $fh ' ' x12, '<th onclick="sortTable(6)">PI Totaux</th>'."\n";
    print $fh ' ' x12, '<th onclick="sortTable(7)">PX+PI Totaux</th>'."\n";
    print $fh ' ' x10, '</tr>'."\n";

    my @gob_ids = @GLB::variables::gob_ids;

    for my $gob_id ( sort @gob_ids )
    {

        print '.';

        # Request for PX info with a JOIN for PITotal
        my $req_px = $dbh->prepare( "SELECT Gobelins.Id,PX,PXPerso,PI,Gobelin,Niveau,PITotal FROM Gobelins \
                                     INNER JOIN Gobelins2 on Gobelins.Id = Gobelins2.Id \
                                     WHERE Gobelins.Id = $gob_id \
                                     ORDER BY Gobelins.Id" );
        $req_px->execute();
       
        my @row = $req_px->fetchrow_array;
        $req_px->finish();

        my $total = $row[1] + $row[2] + $row[6];

        print $fh ' ' x10, '<tr>'."\n";
        print $fh ' ' x12, '<td>'.$row[4].'</td>'."\n";
        print $fh ' ' x12, '<td>'.$row[0].'</td>'."\n";
        print $fh ' ' x12, '<td>'.$row[5].'</td>'."\n";
        print $fh ' ' x12, '<td>'.$row[2].'</td>'."\n";
        print $fh ' ' x12, '<td>'.$row[1].'</td>'."\n";
        print $fh ' ' x12, '<td>'.$row[3].'</td>'."\n";
        print $fh ' ' x12, '<td>'.$row[6].'</td>'."\n";
        print $fh ' ' x12, '<td>'.$total.'</td>'."\n";
        print $fh ' ' x10, '</tr>'."\n";
    }

    print $fh ' ' x 8, '</table>'."\n";
    print $fh ' ' x 6, '</div>'."\n";

    my $t_elapsed = sprintf ("%0.3f", tv_interval($t_start));
    print $fh ' ' x 6, '<div class="footer">[HTML generated in '.$t_elapsed.' sec.] - [Updated @'.localtime.']</div>'."\n";

    print $fh $GLB::variables::sortscript;
    print $fh $GLB::variables::end;
    close $fh;
    print "]\n";
}

1;
