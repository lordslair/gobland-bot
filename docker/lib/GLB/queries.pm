package GLB::queries;

use warnings;
use strict;

use DBI;

my $sqlite_db = '/home/gobland-bot/gobland.db';
my $driver_db = 'SQLite';
my $dsn       = "DBI:$driver_db:dbname=$sqlite_db";

sub req_gobelin_id
{
    my @gob_ids;

    my $sql = "SELECT Id FROM Gobelins;";
    my $dbh = DBI->connect($dsn, '', '', { RaiseError => 1 }) or die $DBI::errstr;
    my $sth = $dbh->prepare( "$sql" );
    $sth->execute();

    while (my $lastline = $sth->fetchrow_array) { push @gob_ids, $lastline }

    $sth->finish();
    $dbh->disconnect();

    return @gob_ids;
}

sub req_id2gob
{
    my %id2gob;

    my $sql = "SELECT Id,Gobelin FROM 'Gobelins' ORDER BY Id;";
    my $dbh = DBI->connect($dsn, '', '', { RaiseError => 1 }) or die $DBI::errstr;
    my $sth = $dbh->prepare( "$sql" );
    $sth->execute();

    while (my @row = $sth->fetchrow_array) { $id2gob{$row[0]} = $row[1] }

    $sth->finish();
    $dbh->disconnect();

    return %id2gob;
}

sub req_meute
{
    my %meute;

    my $sql = "SELECT Id,IdMeute,NomMeute FROM 'Meutes' ORDER BY Id;";
    my $dbh = DBI->connect($dsn, '', '', { RaiseError => 1 }) or die $DBI::errstr;
    my $sth = $dbh->prepare( "$sql" );
    $sth->execute();

   while (my @row = $sth->fetchrow_array)
   {
       $meute{$row[0]}{'Id'}  = $row[1];
       $meute{$row[0]}{'Nom'} = Encode::decode_utf8($row[2]);
   }

    $sth->finish();
    $dbh->disconnect();

    return %meute;
}

sub MP2CdM
{
    my $dbh = DBI->connect($dsn, '', '', { RaiseError => 1 }) or die $DBI::errstr;

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
            $mob_name =~ s/\'/\'\'/g;
        }

        my $mob_niv;
        if ( $mp_text =~ /Niveau : (\d*)</ )                            { $mob_niv = $1 }

        my $mob_pv_min;
        my $mob_pv_max;
        if ( $mp_text =~ /Points de Vie : inférieur ou égal à (\d*)</ ) { $mob_pv_min = 10;$mob_pv_max = $1  }
        if ( $mp_text =~ /Points de Vie : supérieur ou égal à (\d*)</ ) { $mob_pv_min = $1;$mob_pv_max = 400 }
        if ( $mp_text =~ /Points de Vie : entre (\d*) et (\d*)</ )      { $mob_pv_min = $1;$mob_pv_max = $2  }

        my $mob_bless;
        if ( $mp_text =~ /Blessure : (\d*)%</ )                         { $mob_bless = $1 }

        my $mob_att_min;
        my $mob_att_max;
        if ( $mp_text =~ /Attaque : inférieur ou égal à (\d*)</ )       { $mob_att_min = 1 ;$mob_att_max = $1 }
        if ( $mp_text =~ /Attaque : supérieur ou égal à (\d*)</ )       { $mob_att_min = $1;$mob_att_max = 20 }
        if ( $mp_text =~ /Attaque : entre (\d*) et (\d*)</ )            { $mob_att_min = $1;$mob_att_max = $2 }

        my $mob_esq_min;
        my $mob_esq_max;
        if ( $mp_text =~ /Esquive : inférieur ou égal à (\d*)</ )       { $mob_esq_min = 1 ;$mob_esq_max = $1 }
        if ( $mp_text =~ /Esquive : supérieur ou égal à (\d*)</ )       { $mob_esq_min = $1;$mob_esq_max = 20 }
        if ( $mp_text =~ /Esquive : entre (\d*) et (\d*)</ )            { $mob_esq_min = $1;$mob_esq_max = $2 }

        my $mob_deg_min;
        my $mob_deg_max;
        if ( $mp_text =~ /Dégât : inférieur ou égal à (\d*)</ )         { $mob_deg_min = 1 ;$mob_deg_max = $1 }
        if ( $mp_text =~ /Dégât : supérieur ou égal à (\d*)</ )         { $mob_deg_min = $1;$mob_deg_max = 20 }
        if ( $mp_text =~ /Dégât : entre (\d*) et (\d*)</ )              { $mob_deg_min = $1;$mob_deg_max = $2 }

        my $mob_reg_min;
        my $mob_reg_max;
        if ( $mp_text =~ /Régénération : inférieur ou égal à (\d*)</ )  { $mob_reg_min = 1 ;$mob_reg_max = $1 }
        if ( $mp_text =~ /Régénération : supérieur ou égal à (\d*)</ )  { $mob_reg_min = $1;$mob_reg_max = 20 }
        if ( $mp_text =~ /Régénération : entre (\d*) et (\d*)</ )       { $mob_reg_min = $1;$mob_reg_max = $2 }

        my $mob_arm_min;
        my $mob_arm_max;
        if ( $mp_text =~ /Physique : inférieur ou égal à (\d*)</ )      { $mob_arm_min = 1 ;$mob_arm_max = $1 }
        if ( $mp_text =~ /Physique : supérieur ou égal à (\d*)</ )      { $mob_arm_min = $1;$mob_arm_max = 20 }
        if ( $mp_text =~ /Physique : entre (\d*) et (\d*)</      )      { $mob_arm_min = $1;$mob_arm_max = $2 }

        my $mob_per_min;
        my $mob_per_max;
        if ( $mp_text =~ /Perception : inférieur ou égal à (\d*)</ )    { $mob_per_min = 1 ;$mob_per_max = $1 }
        if ( $mp_text =~ /Perception : supérieur ou égal à (\d*)</ )    { $mob_per_min = $1;$mob_per_max = 20 }
        if ( $mp_text =~ /Perception : entre (\d*) et (\d*)</      )    { $mob_per_min = $1;$mob_per_max = $2 }

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

sub MP2Suivants
{
    use POSIX qw(strftime);

    my $now     = strftime "%Y-%m-%d", localtime;
    my $dbh     = DBI->connect($dsn, '', '', { RaiseError => 1 }) or die $DBI::errstr;
    my $req_mps = $dbh->prepare( "SELECT Id,IdGob,PMDate,PMSubject,PMText \
                                  FROM MPBot \
                                  WHERE PMSubject LIKE 'Infos Suivant%' AND PMDate LIKE '$now%' \
                                  ORDER BY PMDate \
                                  LIMIT 100;" ); # To avoid a slow SELECT as MPBot can be huge
       $req_mps->execute();

    my %suivants;

    while (my @row = $req_mps->fetchrow_array)
    {
        if ( $row[3] =~ /Infos Suivant - (.*) \((\d*)\) - / )
        {
            $suivants{$2}{'Nom'}   = $1;
            $suivants{$2}{'IdGob'} = $row[1];
        }
    }

    foreach my $suivant_id ( sort keys %suivants )
    {
        $suivants{$suivant_id}{'Nom'} =~ s/\'/\'\'/g;
        my $sth  = $dbh->prepare( "INSERT OR IGNORE INTO Suivants VALUES( '$suivant_id', \
                                                                          '$suivants{$suivant_id}{'IdGob'}', \
                                                                          '$suivants{$suivant_id}{'Nom'}' )" );
        $sth->execute();
        $sth->finish();
    }
}

MP2Suivants;

1;
