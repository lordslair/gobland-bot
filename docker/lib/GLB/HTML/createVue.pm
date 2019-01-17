package GLB::HTML::createVue;
use strict;
use warnings;

use Time::HiRes qw[gettimeofday tv_interval];
use DBI;

use lib '/home/gobland-bot/lib/';
use GLB::variables;

my $dbh = DBI->connect(
       "dbi:SQLite:dbname=/home/gobland-bot/gobland.db",
       "",
       "",
       { RaiseError => 1 },
    ) or die $DBI::errstr;

my $yaml   = $GLB::variables::glyaml;
my $glyaml = YAML::Tiny->read( $yaml );

sub main
{
    print "GLB::HTML::createVue[";
    my @gob_ids = @GLB::variables::gob_ids;

    for my $gob_id ( sort @gob_ids )
    {
        print '.';
        if ( $glyaml->[0]->{clan}{$gob_id} )
        {
            my $t_start  = [gettimeofday()];
            my $dir      = '/var/www/localhost/htdocs/vue/';
            my $filename = $dir.$gob_id.'.html';
            unless ( -d $dir ) { mkdir $dir }
            open(my $fh, '>', $filename) or die "Could not open file '$filename' $!";
            binmode($fh, ":utf8");
            print $fh $GLB::variables::begin;

            my %ITEMS;

            # Request for PX info with a JOIN for PITotal
            my $req_data = $dbh->prepare( "SELECT PER,BMPER,BPPER,X,Y,N,Nom FROM Gobelins \
                                           INNER JOIN Gobelins2 on Gobelins.Id = Gobelins2.Id \
                                           WHERE Gobelins.Id = $gob_id" );
            $req_data->execute();

            my @gob = $req_data->fetchrow_array;
            $req_data->finish();

            my $cases   = $gob[0] + $gob[1] + $gob[2];
            my $X       = $gob[3];
            my $Y       = $gob[4];
            my $N       = $gob[5];
            my $nom_gob = $gob[6];

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

            my $x_min = $X - $cases;
            my $x_max = $X + $cases;
            my $y_min = $Y - $cases;
            my $y_max = $Y + $cases;
            my $n_max = sprintf("%d",$N + ($cases / 2));
            my $n_min = sprintf("%d",$N - ($cases / 2));

            # Request for elements in the Gob sight
            my $req_vue = $dbh->prepare( "SELECT Id,Categorie,Nom,Niveau,Type,Clan,X,Y,N,Z \
                                          FROM Vue \
                                          WHERE X BETWEEN '$x_min' AND '$x_max' \
                                          AND Y BETWEEN '$y_min' AND '$y_max' \
                                          AND N BETWEEN '$n_min' AND '$n_max'" );

            $req_vue->execute();
            while (my @row = $req_vue->fetchrow_array)
            {
                my $id   = $row[0];
                my $cat  = $row[1];
                my $nom  = $row[2];
                my $niv  = $row[3];

                if    ( $cat eq 'T'                  ) { $T_count++ }
                elsif ( $cat eq 'C'                  ) { $C_count++ }
                elsif ( $cat eq 'G'                  ) { $G_count++ }
                elsif ( $cat eq 'L' && $nom ne 'Mur' && $nom ne 'Arbre' ) { $L_count++ }

                my $x = $row[6];
                my $y = $row[7];
                my $n = $row[8];

                if (! $ITEMS{$x}{$y})
                {
                    $ITEMS{$x}{$y}{'td'} = '';
                    $ITEMS{$x}{$y}{'tt'} = "<center>&nbsp;&nbsp;X = $x | Y = $y<br><br></center>";
                }

                if ( $cat eq 'T' && $ITEMS{$x}{$y}{'td'} !~ /1f4b0/ )
                {
                    $ITEMS{$x}{$y}{'td'} .= $T_emoji;
                }
                elsif ( $cat eq 'L' && $ITEMS{$x}{$y}{'td'} !~ /1f3e0/ && $nom !~ /Mur|Arbre/)
                {
                    $ITEMS{$x}{$y}{'td'} .= $L_emoji;
                }
                elsif ( $cat eq 'L' && $nom eq 'Mur')
                {
                    $ITEMS{$x}{$y}{'td'} .= $W_emoji;
                }
                elsif ( $cat eq 'L' && $nom eq 'Arbre')
                {
                    $ITEMS{$x}{$y}{'td'} .= $A_emoji;
                }
                elsif ( $cat eq 'C' && $ITEMS{$x}{$y}{'td'} !~ /1f47f/ )
                {
                    $ITEMS{$x}{$y}{'td'} .= $C_emoji;
                }
                elsif ( $cat eq 'G' && $ITEMS{$x}{$y}{'td'} !~ /1f60e/ )
                {
                    $ITEMS{$x}{$y}{'td'} .= $G_emoji;
                }

                if ( $ITEMS{$x}{$y}{'tt'} !~ /N = $n/ )
                {
                    $ITEMS{$x}{$y}{'tt'} .= "&nbsp;&nbsp;<b>N = $n</b><br>";
                }

                my $tt_text_c = 'black';
                if ($cat eq 'G') { $tt_text_c = 'cyan'};
                if ($cat eq 'C') { $tt_text_c = 'grey'};

                if ($cat eq 'G' || $cat eq 'C')
                {
                    $ITEMS{$x}{$y}{'tt'} .= "&nbsp;&nbsp;[$id] <span style='color:$tt_text_c'>".Encode::decode_utf8($nom).' (Niv. '.$niv.')'.'</span><br>';
                }
                else
                {
                    $ITEMS{$x}{$y}{'tt'} .= "&nbsp;&nbsp;[$id] <span style='color:$tt_text_c'>".Encode::decode_utf8($nom).'</span><br>';
                }
            }

            print $fh ' ' x 6, '<div id="content">'."\n";

            print $fh ' ' x 6, '<h1>Vue de '.$nom_gob.' ('.$cases.' cases)'.'</h1>'."\n";
            print $fh ' ' x 8, '<table cellspacing="0" id="GobVue">'."\n";
            print $fh ' ' x10, '<caption>'."\n";
            print $fh ' ' x12, '<br>'.$T_emoji.'Tresors ('.$T_count.') | '.$G_emoji.'Gobelins ('.$G_count.') | '.$L_emoji.' Lieux ('.$L_count.')'."\n";
            print $fh ' ' x12, '<br>'.$C_emoji.'Monstres ('.$C_count.')<br>'."\n";
            print $fh ' ' x10, '<caption>'."\n";
            print $fh ' ' x10, '<tbody>'."\n";
            print $fh ' ' x12, '<tr>'."\n";
            print $fh ' ' x14, '<td class="blank"></td>'."\n";

            if ( $cases > 0 )
            {
                for (my $td = $X - $cases; $td <= $X + $cases; $td++) {print $fh ' ' x14, '<th>'.$td.'</th>'."\n" }
                print $fh ' ' x12, '</tr>'."\n";

                for (my $tr = $Y + $cases; $tr >= $Y - $cases; $tr--)
                {
                    print $fh ' ' x12, '<tr>'."\n";
                    print $fh ' ' x14, '<th>'.$tr.'</th>'."\n";
                    for (my $td = $X - $cases; $td <= $X + $cases; $td++)
                    {
                        my $tdcolor = '';
                        if ( $td == $X and $tr == $Y ) { $tdcolor = 'style="background-color: white"' }
                        if ( defined $ITEMS{$td}{$tr}{'td'} )
                        {
                            print $fh ' ' x14, '<td '.$tdcolor.'>'."\n";
                            print $fh ' ' x16, '<div class="tt">'."\n";
                            print $fh ' ' x18, $ITEMS{$td}{$tr}{'td'}."\n";
                            print $fh ' ' x18, '<span class="tt_text">'.$ITEMS{$td}{$tr}{'tt'}.'</span>'."\n";
                            print $fh ' ' x16, '</div>'."\n";
                            print $fh ' ' x14, '</td>'."\n";
                        }
                        else
                        {
                            print $fh ' ' x14, '<td '.$tdcolor.'></td>'."\n";
                        }
                    }
                    print $fh ' ' x12, '</tr>'."\n";
                }
            }
            else
            {
                my $tdcolor = 'style="background-color: white"';
                print $fh ' ' x14, '<th>'.$X.'</th>'."\n";
                print $fh ' ' x12, '</tr>'."\n";
                print $fh ' ' x12, '<tr>'."\n";
                print $fh ' ' x14, '<th>'.$Y.'</th>'."\n";
                print $fh ' ' x14, '<td '.$tdcolor.'>'."\n";
                print $fh ' ' x16, '<div class="tt">'."\n";
                print $fh ' ' x18, $ITEMS{$X}{$Y}{'td'}."\n";
                print $fh ' ' x18, '<span class="tt_text">'.$ITEMS{$X}{$Y}{'tt'}.'</span>'."\n";
                print $fh ' ' x16, '</div>'."\n";
                print $fh ' ' x14, '</td>'."\n";
                print $fh ' ' x12, '</tr>'."\n";
            }

            print $fh ' ' x10, '</tbody>'."\n";
            print $fh ' ' x 8, '</table>'."\n";

            my $t_elapsed = sprintf ("%0.3f", tv_interval($t_start));
            print $fh ' ' x 8, '<div class="footer">[HTML generated in '.$t_elapsed.' sec.] - [Updated @'.localtime.']</div>'."\n";

            print $fh $GLB::variables::end;
            close $fh;
        }
    }
    print "]\n";
}

1;
