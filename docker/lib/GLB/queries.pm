package GLB::queries;

use warnings;
use strict;

    use DBI;

    my $dbh = DBI->connect(
        "dbi:SQLite:dbname=/home/gobland-bot/gobland.db",
        "",
        "",
        { RaiseError => 1 },
    ) or die $DBI::errstr;

sub MP2CdM
{
    my $req_mps = $dbh->prepare( "SELECT Id,IdGob,PMDate,PMSubject,PMText \
                                  FROM MPBot \
                                  WHERE PMSubject LIKE 'Résultat CdM%' \
                                  ORDER BY PMDate;" );
        $req_mps->execute();

    while (my @row = $req_mps->fetchrow_array)
    {
        my $mp_id      = $row[0];
        my $gob_id     = $row[1];
        my $mp_date    = $row[2];
        my $mp_subject = $row[3];
        my $mp_text    = $row[4];

        my $mob_id;
        my $mob_name;
        if ( $mp_subject =~ /\[(\d*)\] (.*)/ )
        {
            $mob_id   = $1;
            $mob_name = $2;
        }

        my $mob_niv;
        if ( $mp_text =~ /Niveau : (\d*)</ ) { $mob_niv = $1}

        my $mob_pv_min;
        my $mob_pv_max;
        if ( $mp_text =~ /Points de Vie : inférieur ou égal à (\d*)</  ) { $mob_pv_min = 10;$mob_pv_max = $1  }
        if ( $mp_text =~ /Points de Vie : supérieur ou égal à (\d*)</  ) { $mob_pv_min = $1;$mob_pv_max = 400 }
        if ( $mp_text =~ /Points de Vie : entre (\d*) et (\d*)</          ) { $mob_pv_min = $1;$mob_pv_max = $2  }

        my $mob_bless;
        if ( $mp_text =~ /Blessure : (\d*)%</  ) { $mob_bless = $1 }

        my $mob_att_min;
        my $mob_att_max;
        if ( $mp_text =~ /Attaque : inférieur ou égal à (\d*)</  ) { $mob_att_min = 1 ;$mob_att_max = $1 }
        if ( $mp_text =~ /Attaque : supérieur ou égal à (\d*)</  ) { $mob_att_min = $1;$mob_att_max = 20 }
        if ( $mp_text =~ /Attaque : entre (\d*) et (\d*)</          ) { $mob_att_min = $1;$mob_att_max = $2 }

        my $mob_esq_min;
        my $mob_esq_max;
        if ( $mp_text =~ /Esquive : inférieur ou égal à (\d*)</  ) { $mob_esq_min = 1 ;$mob_esq_max = $1 }
        if ( $mp_text =~ /Esquive : supérieur ou égal à (\d*)</  ) { $mob_esq_min = $1;$mob_esq_max = 20 }
        if ( $mp_text =~ /Esquive : entre (\d*) et (\d*)</          ) { $mob_esq_min = $1;$mob_esq_max = $2 }

        my $mob_deg_min;
        my $mob_deg_max;
        if ( $mp_text =~ /Dégât : inférieur ou égal à (\d*)</  ) { $mob_deg_min = 1 ;$mob_deg_max = $1 }
        if ( $mp_text =~ /Dégât : supérieur ou égal à (\d*)</  ) { $mob_deg_min = $1;$mob_deg_max = 20 }
        if ( $mp_text =~ /Dégât : entre (\d*) et (\d*)</          ) { $mob_deg_min = $1;$mob_deg_max = $2 }

        my $mob_reg_min;
        my $mob_reg_max;
        if ( $mp_text =~ /Régénération : inférieur ou égal à (\d*)</  ) { $mob_reg_min = 1 ;$mob_reg_max = $1 }
        if ( $mp_text =~ /Régénération : supérieur ou égal à (\d*)</  ) { $mob_reg_min = $1;$mob_reg_max = 20 }
        if ( $mp_text =~ /Régénération : entre (\d*) et (\d*)</          ) { $mob_reg_min = $1;$mob_reg_max = $2 }

        my $mob_arm_min;
        my $mob_arm_max;
        if ( $mp_text =~ /Physique : inférieur ou égal à (\d*)</  ) { $mob_arm_min = 1 ;$mob_arm_max = $1 }
        if ( $mp_text =~ /Physique : supérieur ou égal à (\d*)</  ) { $mob_arm_min = $1;$mob_arm_max = 20 }
        if ( $mp_text =~ /Physique : entre (\d*) et (\d*)</          ) { $mob_arm_min = $1;$mob_arm_max = $2 }

        my $mob_per_min;
        my $mob_per_max;
        if ( $mp_text =~ /Perception : inférieur ou égal à (\d*)</  ) { $mob_per_min = 1 ;$mob_per_max = $1 }
        if ( $mp_text =~ /Perception : supérieur ou égal à (\d*)</  ) { $mob_per_min = $1;$mob_per_max = 20 }
        if ( $mp_text =~ /Perception : entre (\d*) et (\d*)</          ) { $mob_per_min = $1;$mob_per_max = $2 }

        #print STDERR "$mob_id:$mob_name:$mob_niv:$mob_pv_min-$mob_pv_max:$mob_bless:$mob_att_min-$mob_att_max:$mob_esq_min-$mob_esq_max$mob_deg_min-$mob_deg_max:$mob_deg_min-$mob_deg_max:$mob_reg_min-$mob_reg_max:$mob_arm_min-$mob_arm_max:$mob_per_min-$mob_per_max\n";

        my $sth  = $dbh->prepare( "INSERT OR IGNORE INTO CdM VALUES( '$mp_id'      , \
                                                                     '$mp_date'    , \
                                                                     '$mob_id'     , \
                                                                     '$mob_name'   , \
                                                                     '$mob_niv'    , \
                                                                     '$mob_pv_min' , \
                                                                     '$mob_pv_max' , \
                                                                     '$mob_bless'  , \
                                                                     '$mob_att_min', \
                                                                     '$mob_att_max', \
                                                                     '$mob_esq_min', \
                                                                     '$mob_esq_max', \
                                                                     '$mob_deg_min', \
                                                                     '$mob_deg_max', \
                                                                     '$mob_reg_min', \
                                                                     '$mob_reg_max', \
                                                                     '$mob_arm_min', \
                                                                     '$mob_arm_max', \
                                                                     '$mob_per_min', \
                                                                     '$mob_per_max'  )" );

        $sth->execute();
        $sth->finish();
    }
}

MP2CdM();

1;