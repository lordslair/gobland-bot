#!/usr/bin/perl
use strict;
use warnings;

use LWP;
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

    my %CREDENTIALS;
    my $sql = "SELECT Id,Hash FROM Credentials WHERE Type = 'clan';";
    my $sth = $dbh->prepare( "$sql" );
    $sth->execute();

    while (my @row = $sth->fetchrow_array) { $CREDENTIALS{$row[0]} = $row[1] }
    $sth->finish();

    if (%CREDENTIALS)
    {
        my @CREDENTIALS = keys %CREDENTIALS;               # Picking only a random Gobelin in the list to avoid
        my $gob_rand    = $CREDENTIALS[rand @CREDENTIALS]; # using same ID, or requsting from every Gobelin the same data
        logEntry("[getIE_ClanMembres2] DB: $db | Gob: $gob_rand");

        my $browser = new LWP::UserAgent;
        my $request = new HTTP::Request( GET => "http://ie.gobland.fr/IE_ClanMembres2?id=$gob_rand&passwd=$CREDENTIALS{$gob_rand}" );
        my $headers = $request->headers();
           $headers->header( 'User-Agent','Mozilla/5.0 (compatible; Konqueror/3.4; Linux) KHTML/3.4.2 (like Gecko)');
           $headers->header( 'Accept', 'text/html, image/jpeg, image/png, text/*, image/*, */*');
           $headers->header( 'Accept-Encoding','x-gzip, x-deflate, gzip, deflate');
           $headers->header( 'Accept-Charset', 'iso-8859-15, utf-8;q=0.5, *;q=0.5');
           $headers->header( 'Accept-Language', 'fr, en');
           $headers->header( 'Referer', 'http://ie.gobland.fr');
        my $response = $browser->request($request);

        if ($response->is_success)
        {
            foreach my $line (split(/\n/,$response->content))
            {
                chomp ($line);
                #"Id";"Nom";"DLA";"BPDLA";"BMDLA";"PVMax";"BPPVMax";"BMPVMax";"ATT";"BPATT";"BMATT";"ESQ";"BPESQ";"BMESQ";"DEG";"BPDEG";"BMDEG";
                #           "REG";"BPREG";"BMREG";"PER";"BPPER";"BMPER";"BPArm";"BMArm";"PITotal";
                #"Faim";
                #"MM";"BMM";"BPMM";"BMMM";"RM";"BRM";"BPRM";"BMRM";
                #"MT";"BMT";"BPMT";"BMMT";"RT";"BRT";"BPRT";"BMRT";
                #"MR";"BMR";"BPMR";"BMMR";"RR";"BRR";"BPRR";"BMRR";
                #"MS";"BMS";"BPMS";"BMMS";"RS";"BRS";"BPRS";"BMRS";
                #"MC";"BMC";"BPMC";"BMMC";"RC";"BRC";"BPRC";"BMRC";
                #"MP";"BMP";"BPMP";"BMMP";"RP";"BRP";"BPRP";"BMRP"
                $line =~ s/"//g;
                my @line = split /;/, $line;
                if ( $line !~ /^#/ )
                {
                    my $sth  = $dbh->prepare( "REPLACE INTO Gobelins2 VALUES( '$line[0]',  \
                                                                              '$line[1]',  \
                                                                              '$line[2]',  \
                                                                              '$line[3]',  \
                                                                              '$line[4]',  \
                                                                              '$line[5]',  \
                                                                              '$line[6]',  \
                                                                              '$line[7]',  \
                                                                              '$line[8]',  \
                                                                              '$line[9]',  \
                                                                              '$line[10]', \
                                                                              '$line[11]', \
                                                                              '$line[12]', \
                                                                              '$line[13]', \
                                                                              '$line[14]', \
                                                                              '$line[15]', \
                                                                              '$line[16]', \
                                                                              '$line[17]', \
                                                                              '$line[18]', \
                                                                              '$line[19]', \
                                                                              '$line[20]', \
                                                                              '$line[21]', \
                                                                              '$line[22]', \
                                                                              '$line[23]', \
                                                                              '$line[24]', \
                                                                              '$line[25]', \
                                                                              '$line[26]', \
                                                                              '$line[27]', \
                                                                              '$line[28]', \
                                                                              '$line[29]', \
                                                                              '$line[30]', \
                                                                              '$line[31]', \
                                                                              '$line[32]', \
                                                                              '$line[33]', \
                                                                              '$line[34]', \
                                                                              '$line[35]', \
                                                                              '$line[36]', \
                                                                              '$line[37]', \
                                                                              '$line[38]', \
                                                                              '$line[39]', \
                                                                              '$line[40]', \
                                                                              '$line[41]', \
                                                                              '$line[42]', \
                                                                              '$line[43]', \
                                                                              '$line[44]', \
                                                                              '$line[45]', \
                                                                              '$line[46]', \
                                                                              '$line[47]', \
                                                                              '$line[48]', \
                                                                              '$line[49]', \
                                                                              '$line[50]', \
                                                                              '$line[51]', \
                                                                              '$line[52]', \
                                                                              '$line[53]', \
                                                                              '$line[54]', \
                                                                              '$line[55]', \
                                                                              '$line[56]', \
                                                                              '$line[57]', \
                                                                              '$line[58]', \
                                                                              '$line[59]', \
                                                                              '$line[60]', \
                                                                              '$line[61]', \
                                                                              '$line[62]', \
                                                                              '$line[63]', \
                                                                              '$line[64]', \
                                                                              '$line[65]', \
                                                                              '$line[66]', \
                                                                              '$line[67]', \
                                                                              '$line[68]', \
                                                                              '$line[69]', \
                                                                              '$line[70]', \
                                                                              '$line[71]', \
                                                                              '$line[72]', \
                                                                              '$line[73]', \
                                                                              '$line[74]'  ) ");

                    $sth->execute();
                    $sth->finish();
                }
            }
        }
    }
    else
    {
        logEntry("[getIE_ClanMembres2] DB: $db | No credentials found");
    }
}
$dbh->disconnect();

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
