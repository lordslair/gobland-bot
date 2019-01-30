package GLB::HTML::createIndex;
use strict;
use warnings;

use Time::HiRes qw[gettimeofday tv_interval];

use lib '/home/gobland-bot/lib/';
use GLB::functions;
use GLB::variables;

my $clan_name  = $GLB::variables::clan_name;

use DBI;

my $dbh = DBI->connect(
       "dbi:SQLite:dbname=/home/gobland-bot/gobland.db",
       "",
       "",
       { RaiseError => 1 },
    ) or die $DBI::errstr;

sub main
{

    print "GLB::HTML::createIndex[";

    my $t_start  = [gettimeofday()]; 
    my $filename = '/var/www/localhost/htdocs/index.html';
    open(my $fh, '>', $filename) or die "Could not open file '$filename' $!";
    binmode($fh, ":utf8");

    print $fh $GLB::variables::begin;

    print $fh ' ' x 6, '<div id="content">'."\n";
    print $fh ' ' x 8, '<br><h1>'.$clan_name.'</h1><br>'."\n";
    print $fh ' ' x 8, '<table cellspacing="0" id="trollsList">'."\n";
    print $fh ' ' x10, '<tr>'."\n";
    print $fh ' ' x12, '<th>Pseudo</th>'."\n";
    print $fh ' ' x12, '<th>Num</th>'."\n";
    print $fh ' ' x12, '<th>Race</th>'."\n";
    print $fh ' ' x12, '<th>Niv.</th>'."\n";
    print $fh ' ' x12, '<th>Position</th>'."\n";
    print $fh ' ' x12, '<th>Meute</th>'."\n";
    print $fh ' ' x12, '<th>PV</th>'."\n";
    print $fh ' ' x12, '<th>PA</th>'."\n";
    print $fh ' ' x12, '<th>Dates</th>'."\n";
    print $fh ' ' x12, '<th>Action</th>'."\n";
    print $fh ' ' x10, '</tr>'."\n";

    my $ct_total   = 0;

    my @gob_ids = @GLB::variables::gob_ids;

    for my $gob_id ( sort @gob_ids )
    {

        print '.';

        # Request for Profil info with a JOIN for PVTotal
        my $req_gob = $dbh->prepare( "SELECT Gobelins.Id,Tribu,Gobelin,Niveau,X,Y,N,PA,PV,PVMax,CT,Gobelins.DLA,Gobelins2.DLA,BPDLA,BMDLA \
                                      FROM Gobelins \
                                      INNER JOIN Gobelins2 on Gobelins.Id = Gobelins2.Id \
                                      WHERE Gobelins.Id = $gob_id \
                                      ORDER BY Gobelins.Id" );
        $req_gob->execute();

        my @row = $req_gob->fetchrow_array;
        $req_gob->finish();

        my $position = $row[4].', '.$row[5].', '.$row[6];

        my %meute       = %GLB::variables::meute;
        my $nom_meute   = '';
        my $id_meute    = '';
        if ( $meute{$gob_id}{'Id'}  ) { $id_meute  = '('.$meute{$gob_id}{'Id'}.')' }
        if ( $meute{$gob_id}{'Nom'} ) { $nom_meute = $meute{$gob_id}{'Nom'} }

        my $pad;
        if ( $row[7] > 0 )
        {
            $pad = ' class="PADispo"';
        } else { $pad = ' ' }

        my $color   = GLB::functions::GetColor($row[8],$row[9]);
        my $percent = ($row[8] / $row[9]) * 100;
        my $lifebar = '<br><div class="vieContainer"><div style="background-color:'.$color.'; width: '.$percent.'%">&nbsp;</div></div>';

        $ct_total += $row[10];

        my $duree_s   = $row[12] + $row[13] + $row[14];
        my $pdla      = GLB::functions::GetpDLA($row[11], $duree_s);

        print $fh ' ' x10, '<tr>'."\n";
        print $fh ' ' x12, '<td>'."\n";
        print $fh ' ' x14, '<a href="http://games.gobland.fr/Profil.php?IdPJ='.$gob_id.'" target="_blank">'.$row[2].'</a>'."\n";
        print $fh ' ' x12, '</td>'."\n";
        print $fh ' ' x12, '<td>'.$gob_id.'</td>'."\n";
        print $fh ' ' x12, '<td>'.$row[1].'</td>'."\n";
        print $fh ' ' x12, '<td>'.$row[3].'</td>'."\n";
        print $fh ' ' x12, '<td>'.$position.'</td>'."\n";
        print $fh ' ' x12, '<td>'.$nom_meute.' '.$id_meute.'</td>'."\n";
        print $fh ' ' x12, '<td>'.$row[8].' / '.$row[9].$lifebar.'</td>'."\n";
        print $fh ' ' x12, '<td'.$pad.'>'.$row[7].'</td>'."\n";
        print $fh ' ' x12, '<td><span class="DLA"> DLA : '.$row[11].'</span><br><span class="pDLA">pDLA : '.$pdla.'</span></td>'."\n";
        print $fh ' ' x12, '<td>'."\n";
        print $fh ' ' x14, '<a href="/gobelins/'.$gob_id.'.html" title="Votre profil">PROFIL</a>'."\n";
        print $fh ' ' x14, '<a href="/vue/'.$gob_id.'.html" title="Votre vue">VUE</a>'."\n";
        print $fh ' ' x12, '</td>'."\n";
        print $fh ' ' x10, '</tr>'."\n";
    }

    print $fh ' ' x 8, '</table>'."\n";

    print $fh ' ' x 8, '<div>'."\n";
    print $fh ' ' x10, '<h3>Fortune : '.$ct_total.' CT (gobelins)</h3>'."\n";
    print $fh ' ' x 8, '</div>'."\n";

    my $t_elapsed = sprintf ("%0.3f", tv_interval($t_start));
    print $fh ' ' x 8, '<div class="footer">[HTML generated in '.$t_elapsed.' sec.] - [Updated @'.localtime.']</div>'."\n";

    print $fh $GLB::variables::end;
    close $fh;
    print "]\n";
}

1;
