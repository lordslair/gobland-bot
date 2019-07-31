#!/usr/bin/perl
use strict;
use warnings;
    
use DBI;
use Encode;

my $logging   = 1;

my @db_list   = split(',', $ENV{'DBLIST'});
my $db_driver = 'mysql';
my $db_host   = 'gobland-it-mariadb';
my $db_port   = '3306';
my $db_pass   = $ENV{'MARIADB_ROOT_PASSWORD'};
my $dsn       = "DBI:$db_driver:host=$db_host;port=$db_port";
my $dbh       = DBI->connect($dsn, 'root', $db_pass, { RaiseError => 1 }) or die $DBI::errstr;

foreach my $db (@db_list)
{
    $dbh->do("USE `$db`");
    logEntry("[setCompTT] DB: $db");

    my %CREDENTIALS;
    my $sql = "SELECT Id,Hash FROM Credentials WHERE Type = 'clan';";
    my $sth = $dbh->prepare( "$sql" );
    $sth->execute();

    while (my @row = $sth->fetchrow_array) { $CREDENTIALS{$row[0]} = $row[1] }
    $sth->finish();

    foreach my $gob_id ( sort keys %CREDENTIALS )
    {
        # Request for IdSkill info
        my $req_id_skill_c = $dbh->prepare( "SELECT IdSkill,Niveau FROM Skills \
                                             WHERE Type = 'C' AND IdGob = '$gob_id' \
                                             ORDER BY IdSkill" );
        $req_id_skill_c->execute();

        while (my @row = $req_id_skill_c->fetchrow_array)
        {
            my $c_id   = $row[0];
            my $niveau = $row[1];
            my $tt     = '';

            my $sth  = $dbh->prepare( "SELECT PER,BMPER,BPPER FROM Gobelins2 WHERE Id = '$gob_id'" );
            $sth->execute();
            my @per = $sth->fetchrow_array;
            $sth->finish;
            my $vue = $per[0] + $per[1] + $per[2];

            if ( $c_id == 1 )
            {
                $tt = Encode::decode_utf8('Portée').' : '.$vue.' Case(s)';
            }
            elsif ( $c_id == 2 )
            {
                my $proba;
                if    ( $niveau == 1 ) { $proba = 10 }
                elsif ( $niveau == 2 ) { $proba = 12 }
                elsif ( $niveau == 3 ) { $proba = 14 }
                elsif ( $niveau == 4 ) { $proba = 16 }
                $tt = 'Proba. : '.$proba.'%';
            }
            elsif ( $c_id == 9 )
            {
                my $portee  = ($vue, $niveau)[$vue > $niveau];
                $tt = Encode::decode_utf8('Portée').' : '.$portee.' Case(s)';
            }
            elsif ( $c_id == 18 or $c_id == 21 )
            {
                my $coeff;
                if    ( $niveau == 1 ) { $coeff = 1.5 }
                elsif ( $niveau == 2 ) { $coeff = 2   }
                elsif ( $niveau == 3 ) { $coeff = 2.5 }
                elsif ( $niveau == 4 ) { $coeff = 3   }
                my $portee  = sprintf("%d",$coeff * $vue);
                $tt = Encode::decode_utf8('Portée').' : '.$portee.' Case(s)';
            }

            if ( $tt ne '' )
            {
                my $sth  = $dbh->prepare( "UPDATE Skills \
                                           SET Tooltip = '$tt' \
                                           WHERE IdGob = '$gob_id' AND Type = 'C' AND IdSkill = '$c_id'" );
                $sth->execute();
                $sth->finish();
            }
        }
        $req_id_skill_c->finish();

        # Request for IdSkill info
        my $req_id_skill_t = $dbh->prepare( "SELECT IdSkill,Niveau FROM Skills \
                                             WHERE Type = 'T' AND IdGob = '$gob_id' \
                                             ORDER BY IdSkill" );
        $req_id_skill_t->execute();

        while (my @row = $req_id_skill_t->fetchrow_array)
        {
            my $t_id   = $row[0];
            my $niveau = $row[1];
            my $tt     = '';

            my $sth = $dbh->prepare( "SELECT DEG,BMDEG,BPDEG,REG,BMREG,BPREG,PER,BMPER,BPPER,ATT,BMATT,BPATT, \
                                             MM,BMM \
                                      FROM Gobelins2 WHERE Id = '$gob_id'" );
            $sth->execute();
            my @attr = $sth->fetchrow_array;
            $sth->finish;

            if ( $t_id == 2 )
            {
                my $coeff;
                my $coeff_b;
                my $coeff_r;
                my $malus;
                my $malus_r;
                if    ( $niveau == 1 ) { $coeff = 1; $coeff_b = 1; $coeff_r = 0.3; $malus = 0  ; $malus_r = 0   }
                elsif ( $niveau == 2 ) { $coeff = 1; $coeff_b = 1; $coeff_r = 0.4; $malus = 0.5; $malus_r = 0   }
                elsif ( $niveau == 3 ) { $coeff = 1; $coeff_b = 1; $coeff_r = 0.5; $malus = 1  ; $malus_r = 0.5 }
                elsif ( $niveau == 4 ) { $coeff = 1; $coeff_b = 1; $coeff_r = 0.6; $malus = 2  ; $malus_r = 1   }

                my $reg      = $attr[3];
                my $deg      = $attr[0];
                my $deg_bmm  = $attr[1];

                my $deg_full = $coeff*$deg + $coeff_b*$deg_bmm;
                my $deg_r    = sprintf("%d",$coeff_r*$deg);
                my $reg_full = sprintf("%d",$malus*$reg);
                my $reg_r    = sprintf("%d",$malus_r*$reg);

                $tt  = 'Si full'.'<br>';
                $tt .= 'DEG : '.$deg_full.'<br>';
                $tt .= 'Malus : REG -'.$reg_full.'<br>';
                $tt .= '<br>';
                $tt .= Encode::decode_utf8('Si resisté').'<br>';
                $tt .= 'DEG : '.$deg_r.'<br>';
                $tt .= 'Malus : REG -'.$reg_r.'<br>';
            }
            elsif ( $t_id == 7 )
            {
                my $coeff;
                if    ( $niveau == 1 ) { $coeff = 5 }
                elsif ( $niveau == 2 ) { $coeff = 4 }
                elsif ( $niveau == 3 ) { $coeff = 3 }
                elsif ( $niveau == 4 ) { $coeff = 2 }

                $tt = 'Bonus : +1 / '.$coeff.'PVs';
            }
            elsif ( $t_id == 9 )
            {
                my $coeff;
                my $mod;
                if    ( $niveau == 1 ) { $coeff = 4; $mod = 0 }
                elsif ( $niveau == 2 ) { $coeff = 4; $mod = 1 }
                elsif ( $niveau == 3 ) { $coeff = 5; $mod = 0 }
                elsif ( $niveau == 4 ) { $coeff = 5; $mod = 1 }

                my $per        = $attr[6];
                my $per_bmm    = $attr[7];
                my $att        = $attr[9];
                my $att_bmm    = $attr[10];

                my $vue    = $attr[6] + $attr[7] + $attr[8];
                my $portee;
                if    ( $vue <=  4 ) { $portee = 1 }
                elsif ( $vue <=  9 ) { $portee = 2 }
                elsif ( $vue <= 15 ) { $portee = 3 }
                elsif ( $vue <= 22 ) { $portee = 4 }
                elsif ( $vue <= 30 ) { $portee = 5 }
                elsif ( $vue <= 39 ) { $portee = 6 }
                my $po_deg     = ( $att + $per ) /2;
                my $po_deg_bmm = ( $att_bmm + $per_bmm ) /2;
                my $po_att     = (($per+$att)/2);
                my $po_att_bmm = ( $att_bmm + $per_bmm ) /2;

                $tt  = Encode::decode_utf8('Portée').' : '.$portee.' Case(s)'.'<br>';
                $tt .= '<br>';
                $tt .= 'Si cible < '.$coeff.' Cases'.'<br>';
                $tt .= 'ATT : '.$po_att.' D6 + '.$po_att_bmm.'<br>';
                $tt .= 'DEG : '.$po_deg.' D3 + '.$po_deg_bmm;
                $tt .= '<br>';
                $tt .= 'Si cible > '.$coeff.' Cases'.'<br>';
                $tt .= 'ATT : '.($po_att -1).' D6 + '.$po_att_bmm.'<br>';
                $tt .= 'DEG : '.($po_deg -1).' D3 + '.$po_deg_bmm;
            }
            elsif ( $t_id == 10 )
            {
                my $coeff;
                my $coeff_r;
                if    ( $niveau == 1 ) { $coeff = 4; $coeff_r = 8 }
                elsif ( $niveau == 2 ) { $coeff = 4; $coeff_r = 6 }
                elsif ( $niveau == 3 ) { $coeff = 3; $coeff_r = 5 }
                elsif ( $niveau == 4 ) { $coeff = 3; $coeff_r = 4 }
                my $deg   = ( $attr[6] + $attr[0] ) / $coeff;
                   $deg   = sprintf("%d",$deg);
                my $deg_r = ( $attr[6] + $attr[0] ) / $coeff_r;
                   $deg_r = sprintf("%d",$deg_r);

                $tt = 'Full : '.$deg.'D3'."<br>".'Res. : '.$deg_r.'D3';
            }
            elsif ( $t_id == 11 )
            {
                my $coeff    =  6 - $niveau;
                my $coeff_r  = 12 - $niveau * 2;
                my $malus    = (1 + $niveau) * 10;
                my $malus_r  = $malus / 2;
                my $portee   = $niveau;
                my $per      = $attr[6];
                my $reg      = $attr[3];
                my $esq      = 1 + ( $per + $reg )/$coeff;
                   $esq      = sprintf("%d",$esq);
                my $esq_r    = 1 + ( $per + $reg )/$coeff_r;
                   $esq_r    = sprintf("%d",$esq_r);

                $tt  = Encode::decode_utf8('Portée').' : '.$portee.' Case(s)'.'<br>';
                $tt .= '<br>';
                $tt .= 'Si full'.'<br>';
                $tt .= 'ESQ -'.$esq.'D'.'<br>';
                $tt .= 'RS -'.$malus.'%'.'<br>';
                $tt .= '<br>';
                $tt .= Encode::decode_utf8('Si resisté').'<br>';
                $tt .= 'ESQ -'.$esq_r.'D'.'<br>';
                $tt .= 'RS -'.$malus_r.'%'.'<br>';
            }
            elsif ( $t_id == 12 )
            {
                my $coeff  = $niveau;
                my $reg    = $attr[3];
                my $reg_bm = $attr[4];
                my $soin   = $coeff * $reg + $reg_bm;

                $tt = 'Soin : '.$soin.' PV(s)';
            }
            # Ténèbres
            elsif ( $t_id == 15 )
            {
                my $cases_h;
                my $cases_v;
                if    ( $niveau == 1 ) { $cases_h = 3 ; $cases_v = 3 }
                elsif ( $niveau == 2 ) { $cases_h = 7 ; $cases_v = 3 }
                elsif ( $niveau == 3 ) { $cases_h = 7 ; $cases_v = 7 }
                elsif ( $niveau == 4 ) { $cases_h = 11; $cases_v = 7 }

                $tt  = 'Zone<br>';
                $tt .= 'H : '.$cases_h.' Cases<br>';
                $tt .= 'V : '.$cases_v.' Cases';
            }
            elsif ( $t_id == 17 )
            {
                my $coeff;
                if    ( $niveau == 1 ) { $coeff = 1   }
                elsif ( $niveau == 2 ) { $coeff = 1.1 }
                elsif ( $niveau == 3 ) { $coeff = 1.2 }
                elsif ( $niveau == 4 ) { $coeff = 1.3 }

                my $vue    = $attr[6] + $attr[7] + $attr[8];
                my $mm_total = $attr[12] + $attr[13];
                my $db = int((sqrt( 19 + 18 * (($mm_total * $coeff)/5 + 3)) - 7)/ 2);
                my $portee_h = $db + 20 + $vue;
                my $portee_v = int($db /3) + 3;
                $tt  = Encode::decode_utf8('Portée H').' : '.$portee_h.'<br>';
                $tt .= Encode::decode_utf8('Portée V').' : '.$portee_v;
            }
            # Image-Miroir
            elsif ( $t_id == 18 )
            {
                my $nbr;
                my $duree;
                if    ( $niveau == 1 ) { $nbr = 5 ; $duree = 12 }
                elsif ( $niveau == 2 ) { $nbr = 6 ; $duree = 12 }
                elsif ( $niveau == 3 ) { $nbr = 7 ; $duree = 24 }
                elsif ( $niveau == 4 ) { $nbr = 8 ; $duree = 24 }

                $tt  = Encode::decode_utf8('Durée').' : '.$duree.'H<br>';
                $tt .= 'Images : '.$nbr;
            }
            # Eclair
            elsif ( $t_id == 33 )
            {
                my $coeff;
                my $coeff_r;
                if    ( $niveau == 1 ) { $coeff = 3 ; $coeff_r = 1 }
                elsif ( $niveau == 2 ) { $coeff = 6 ; $coeff_r = 3 }
                elsif ( $niveau == 3 ) { $coeff = 9 ; $coeff_r = 4 }
                elsif ( $niveau == 4 ) { $coeff = 12; $coeff_r = 6 }

                my $range  = int(($attr[6] + $attr[7] + $attr[9])/2);
                my $portee;
                if    ( $range <  3 )   { $portee = 1 }
                elsif ( $range < 11 )   { $portee = 2 }
                elsif ( $range < 20 )   { $portee = 3 }
                elsif ( $range < 30 )   { $portee = 4 }
                elsif ( $range < 41 )   { $portee = 5 }
                elsif ( $range > 42 )   { $portee = 6 }

                $tt  = Encode::decode_utf8('Portée').' : '.$portee.'<br>';
                $tt .= '<br>';
                $tt .= 'Full : '.$coeff.'D3<br>';
                $tt .= 'Res. : '.$coeff_r.'D3<br>';
            }
            elsif ( $t_id == 40 )
            {
                my $coeff;
                if    ( $niveau == 1 ) { $coeff = 5   }
                elsif ( $niveau == 2 ) { $coeff = 4.5 }
                elsif ( $niveau == 3 ) { $coeff = 4   }
                elsif ( $niveau == 4 ) { $coeff = 3.5 }

                my $x = int( ($attr[9] + $attr[14]) / $coeff );
                my $m_con = 0;
                my $m_esq = 0;

                if    ( $niveau == 1 ) {                               }
                elsif ( $niveau == 2 ) { $m_esq = int($x/2)            }
                elsif ( $niveau == 3 ) { $m_esq = $x                   }
                elsif ( $niveau == 4 ) { $m_esq = $x ; $m_con = $x * 5 }

                $tt  = 'Malus<br>';
                $tt .= 'ATT -'.$x.'D3<br>';
                $tt .= 'ESQ -'.$m_esq.'D3<br>';
                $tt .= 'Con -'.$m_con.'%<br>';
            }
            elsif ( $t_id == 42 )
            {
                my $coeff;
                my $coeff_r;
                if    ( $niveau == 1 ) { $coeff = $niveau; $coeff_r = 0 }
                elsif ( $niveau == 2 ) { $coeff = $niveau; $coeff_r = 1 }
                elsif ( $niveau == 3 ) { $coeff = $niveau; $coeff_r = 1 }
                elsif ( $niveau == 4 ) { $coeff = $niveau; $coeff_r = 2 }

                $tt  = 'Durée : <br>';
                $tt .= $coeff.'/'.$coeff_r.' Tours';
            }
            # Barrière Psionique
            elsif ( $t_id == 43 )
            {
                my $coeff;
                if    ( $niveau == 1 ) { $coeff =  70 }
                elsif ( $niveau == 2 ) { $coeff =  80 }
                elsif ( $niveau == 3 ) { $coeff =  90 }
                elsif ( $niveau == 4 ) { $coeff = 100 }
                my $coeff_r = $coeff - 25;

                $tt  = 'Absorpsion<br>';
                $tt .= '<br>';
                $tt .= 'Full : '.$coeff.'%<br>';
                $tt .= 'Res. : '.$coeff_r.'%<br>';
            }
            # Feinte
            elsif ( $t_id == 45 )
            {
                my $coeff  = $niveau * 2;
                my $x      = $niveau * 4;
                my $coefa  = 0.60 + ( $niveau * 0.05 );
                my $coefb  = 0.40 + ( $niveau * 0.05 );

                my $att    = int(($attr[9]  * $coefa));
                my $att_bm = int(($attr[10] * $coefa));
                my $deg    = int(($attr[0]  * $coefb));
                my $deg_bm = int(($attr[1]  * $coefb));

                $tt  = 'Gobelin<br>';
                $tt .= 'ESQ : +'.$coeff.'<br>';
                $tt .= 'Jet ATT: '.$att.'D6 + '.$att_bm.'<br>';
                $tt .= 'Jet DEG: '.$deg.'D6 + '.$deg_bm.'<br>';
                $tt .= '<br>';
                $tt .= 'Monstre<br>';
                $tt .= 'Con -'.$x.'%<br>';
            }
            # Symphonie Intestinale
            elsif ( $t_id == 46 )
            {
                my $coeff   = 35 - (  5 * $niveau );
                my $coeff_r = 70 - ( 10 * $niveau );
                my $pv      = $pvs[0];

                my $malus   = int($pv/$coeff);
                my $malus_r = int($pv/$coeff_r);

                $tt  = 'Malus<br>';
                $tt .= '<br>';
                $tt .= 'ATT : - '.$malus.'<br>';
                $tt .= 'ESQ : - '.$malus.'<br>';
                $tt .= 'PER : - '.$malus.'<br>';
            }
            # Foudre
            elsif ( $t_id == 68 )
            {
                my $coeff     = 7 - $niveau;
                my $malus_pv  = int($attr[9] / $coeff);
                my $range     = $attr[6] + $attr[7] + $attr[8];
                my $malus_per = int($attr[9] / 2 / $coeff);

                my $portee;
                if    ( $range <  4 )   { $portee = 1 }
                elsif ( $range <  9 )   { $portee = 2 }
                elsif ( $range < 15 )   { $portee = 3 }
                elsif ( $range < 22 )   { $portee = 4 }
                elsif ( $range < 30 )   { $portee = 5 }
                elsif ( $range < 39 )   { $portee = 6 }

                $tt  = 'Malus<br>';
                $tt .= '<br>';
                $tt .= 'PV - '.$malus_pv.'D3<br>';
                $tt .= 'PER - '.$malus_per.'D3<br>';
                $tt .= '<br>';
                $tt .= Encode::decode_utf8('Portée H').' : '.$portee.'<br>';
            }

            if ( $tt ne '' )
            {
                my $sth  = $dbh->prepare( "UPDATE Skills \
                                           SET Tooltip = '$tt' \
                                           WHERE IdGob = '$gob_id' AND Type = 'T' AND IdSkill = '$t_id'" );
                $sth->execute();
                $sth->finish();
            }
        }
        $req_id_skill_t->finish();
    }
}

# add a line to the log file
sub logEntry {
    my ($logText) = @_;
    my ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) = localtime(time);
    my $dateTime = sprintf "%4d-%02d-%02d %02d:%02d:%02d", $year + 1900, $mon + 1, $mday, $hour, $min, $sec;
    if ($logging) {
        binmode(STDERR, ":utf8");
        print STDERR "$dateTime $logText\n";
    }
}
