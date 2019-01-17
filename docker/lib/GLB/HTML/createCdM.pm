package GLB::HTML::createCdM;
use strict;
use warnings;

use Time::HiRes qw[gettimeofday tv_interval];
use List::Util qw[min max];

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

    print "GLB::HTML::createCdM\n";

    my $t_start  = [gettimeofday()];
    my $filename = '/var/www/localhost/htdocs/CdM.html';
    open(my $fh, '>', $filename) or die "Could not open file '$filename' $!";
    binmode($fh, ":utf8");
    print $fh $GLB::variables::begin;

    print $fh ' ' x 6, '<div id="content">'."\n";
    print $fh ' ' x 6, '<link href="/style/tt_r.css"  rel="stylesheet" type="text/css"  />'."\n";
    print $fh ' ' x 6, '<link href="/style/equipement.css"  rel="stylesheet" type="text/css"  />'."\n";
    print $fh ' ' x 8, '<h1></h1>'."\n";

    print $fh ' ' x 8, '<h2 class="expanded">Historique des CdM du Clan</h2>'."\n";
    print $fh ' ' x 8, '<table cellspacing="0" id="profilInfos">'."\n";

    my $req_cdm_ids = $dbh->prepare( "SELECT DISTINCT IdMob,Name FROM CdM ORDER BY Date DESC;" );
       $req_cdm_ids->execute();

    while (my @cdm_ids = $req_cdm_ids->fetchrow_array)
    {

        my $mob_id   = $cdm_ids[0];
        my $mob_date;
        my $mob_name = Encode::decode_utf8($cdm_ids[1]);
        my $mob_niv;
        my $mob_pv_min = 0;
        my $mob_pv_max = 999;
        my $mob_bless;
        my $mob_att_min =  1;
        my $mob_att_max = 99;
        my $mob_esq_min =  1;
        my $mob_esq_max = 99;
        my $mob_deg_min =  1;
        my $mob_deg_max = 99;
        my $mob_reg_min =  1;
        my $mob_reg_max = 99;
        my $mob_arm_min =  1;
        my $mob_arm_max = 99;
        my $mob_per_min =  1;
        my $mob_per_max = 99;

        print $fh ' ' x10, '<tr class="trigger">'."\n";
        print $fh ' ' x12, '<th>['.$mob_id.'] '.$mob_name.'</th>'."\n";
        print $fh ' ' x10, '</tr>'."\n";

        my $req_cdm = $dbh->prepare( "SELECT * FROM CdM WHERE IdMob = '$cdm_ids[0]' ORDER BY Date ASC;" );
           $req_cdm->execute();

        my $update = 0;
        while (my @cdm = $req_cdm->fetchrow_array)
        {
            $mob_niv   = $cdm[4];
            $mob_bless = $cdm[7];
            $mob_date  = $cdm[1];

            $mob_pv_min  = max($mob_pv_min ,$cdm[5]);
            $mob_pv_max  = min($mob_pv_max ,$cdm[6]);
            $mob_att_min = max($mob_att_min,$cdm[8]);
            $mob_att_max = min($mob_att_max,$cdm[9]);
            $mob_esq_min = max($mob_esq_min,$cdm[10]);
            $mob_esq_max = min($mob_esq_max,$cdm[11]);
            $mob_deg_min = max($mob_deg_min,$cdm[10]);
            $mob_deg_max = min($mob_deg_max,$cdm[11]);
            $mob_reg_min = max($mob_reg_min,$cdm[10]);
            $mob_reg_max = min($mob_reg_max,$cdm[11]);
            $mob_arm_min = max($mob_arm_min,$cdm[10]);
            $mob_arm_max = min($mob_arm_max,$cdm[11]);
            $mob_per_min = max($mob_per_min,$cdm[10]);
            $mob_per_max = min($mob_per_max,$cdm[11]);

            $update++
        }

        print $fh ' ' x10, '<tr>'."\n";
        print $fh ' ' x12, '<td>'."\n";

            print $fh ' ' x14, '<ul class="membreEquipementList">'."\n";
            print $fh ' ' x16, '<li class="equipementNonEquipe">'."\n";
            print $fh ' ' x18, 'Niveau : '.$mob_niv."\n";
            print $fh ' ' x16, '</li>'."\n";
            print $fh ' ' x16, '<li class="equipementNonEquipe">'."\n";
            print $fh ' ' x18, 'Blessure : '.$mob_bless.'%'."\n";
            print $fh ' ' x16, '</li>'."\n";
            print $fh ' ' x16, '<li class="equipementNonEquipe">'."\n";
            print $fh ' ' x18, 'Points de Vie : '.$mob_pv_min.'-'.$mob_pv_max."\n";
            print $fh ' ' x16, '</li>'."\n";
            print $fh ' ' x16, '<li class="equipementNonEquipe">'."\n";
            print $fh ' ' x18, 'Attaque : '.$mob_att_min.'-'.$mob_att_max."\n";
            print $fh ' ' x16, '</li>'."\n";
            print $fh ' ' x16, '<li class="equipementNonEquipe">'."\n";
            print $fh ' ' x18, 'Esquive : '.$mob_esq_min.'-'.$mob_esq_max."\n";
            print $fh ' ' x16, '</li>'."\n";
            print $fh ' ' x16, '<li class="equipementNonEquipe">'."\n";
            print $fh ' ' x18, 'Degats : '.$mob_deg_min.'-'.$mob_deg_max."\n";
            print $fh ' ' x16, '</li>'."\n";
            print $fh ' ' x16, '<li class="equipementNonEquipe">'."\n";
            print $fh ' ' x18, 'Regeneration : '.$mob_reg_min.'-'.$mob_reg_max."\n";
            print $fh ' ' x16, '</li>'."\n";
            print $fh ' ' x16, '<li class="equipementNonEquipe">'."\n";
            print $fh ' ' x18, 'Armure : '.$mob_arm_min.'-'.$mob_arm_max."\n";
            print $fh ' ' x16, '</li>'."\n";
            print $fh ' ' x16, '<li class="equipementNonEquipe">'."\n";
            print $fh ' ' x18, 'Perception : '.$mob_per_min.'-'.$mob_per_max."\n";
            print $fh ' ' x16, '</li>'."\n";
            print $fh ' ' x16, '<li class="equipementNonEquipe">'."\n";
            print $fh ' ' x18, 'Update ('.$update.') : '.$mob_date."\n";
            print $fh ' ' x16, '</li>'."\n";
            print $fh ' ' x14, '</ul>'."\n";

        print $fh ' ' x12, '</td>'."\n";
        print $fh ' ' x10, '</tr>'."\n";
    }

    print $fh ' ' x 8, '</table>'."\n";

    my $t_elapsed = sprintf ("%0.3f", tv_interval($t_start));
    print $fh ' ' x 8, '<div class="footer">[HTML generated in '.$t_elapsed.' sec.] - [Updated @'.localtime.']</div>'."\n";

    print $fh $GLB::variables::vuescript;
    print $fh $GLB::variables::end;
    close $fh;
}

1;
