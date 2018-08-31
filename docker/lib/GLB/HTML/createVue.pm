package GLB::HTML::createVue;
use strict;
use warnings;

use Time::HiRes qw[gettimeofday tv_interval];

use lib '/home/gobland-bot/lib/';
use GLB::variables;

my $gobs_ref   = $GLB::variables::gobs;
my %gobs       = %{$gobs_ref};
my $gobs2_ref  = $GLB::variables::gobs2;
my %gobs2      = %{$gobs2_ref};

my $yaml       = '/home/gobland-bot/gl-config.yaml';

sub main
{
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
            print $fh $GLB::variables::begin;

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

            print $fh ' ' x 6, '<div id="content">'."\n";

            print $fh ' ' x 6, '<h1>Vue de '.$gobs{$gob_id}{'Nom'}.' ('.$cases.' cases)'.'</h1>'."\n";
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
}

1;
