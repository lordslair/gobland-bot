package GLB::variables;

use warnings;
use strict;

use YAML::Tiny;
our $yaml      = '/home/gobland-bot/gl-config.yaml';
our $glyaml    = YAML::Tiny->read( $yaml );
our $clan_name = $glyaml->[0]{gl_clan_name};

use lib '/home/gobland-bot/lib/';
use GLB::functions;

use DBI;
my $dbh = DBI->connect(
    "dbi:SQLite:dbname=/home/gobland-bot/gobland.db",
    "",
    "",
    { RaiseError => 1 },
) or die $DBI::errstr;

our @gob_ids;
my $req_gobelin_id = $dbh->prepare( "SELECT Id FROM Gobelins;" );
   $req_gobelin_id->execute();
   while (my $lastline = $req_gobelin_id->fetchrow_array) { push @gob_ids, $lastline }
   $req_gobelin_id->finish();

our %id2gob;
my $req_id2gob = $dbh->prepare( "SELECT Id,Gobelin FROM 'Gobelins' ORDER BY Id" );
   $req_id2gob->execute();
   while (my @row = $req_id2gob->fetchrow_array) { $id2gob{$row[0]} = $row[1] }
   $req_id2gob->finish();

our %meute;
my $req_meute = $dbh->prepare( "SELECT Id,IdMeute,NomMeute FROM 'Meutes' ORDER BY Id" );
   $req_meute->execute();
   while (my @row = $req_meute->fetchrow_array)
   {
       $meute{$row[0]}{'Id'}  = $row[1];
       $meute{$row[0]}{'Nom'} = $row[2];
   }
   $req_meute->finish();

#GLB::GLAPI::GetClanMembres($yaml);
#GLB::GLAPI::GetClanMembres2($yaml);
#GLB::GLAPI::getClanSkills($yaml);
#GLB::GLAPI::GetClanEquipement($yaml);
#GLB::GLAPI::getClanCavernes($yaml);
#GLB::GLAPI::getClanCafards($yaml);
#GLB::GLAPI::getMeuteMembres($yaml);
#GLB::GLAPI::getMPBot($yaml);
#GLB::GLAPI::getVue($yaml);

#GLB::functions::GetCompsTT();

our $begin = <<"START_LOOP";
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
  <head>
    <title>#CLAN_NAME#</title>
    <link rel="stylesheet" type="text/css" href="/style/common.css" />
    <link rel="stylesheet" type="text/css" href="/style/menu.css" />
    <script type="text/javascript" src="/js/common.js"></script>
    <script type="text/javascript" src="/js/domcollapse.js"></script>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
  </head>
  <body>
    <div id="page">
      <div id="header">
        <br><br><br><br><br><br><br><br>
        <div id="nav">
          <ul id="menu">
            <li><a href="/index.html" title="Page d'accueil">Accueil</a></li>
            <li><a href="#">Consulter</a>
              <ul>
                <li><a href="/equipement.html" title="Equipement des Gob' du Clan">Equipement du Clan</a></li>
                <li><a href="/materiaux.html" title="Materiaux des Gob' du Clan">Materiaux du Clan</a></li>
                <li><a href="/composants.html" title="Composants des Gob' du Clan">Composants du Clan</a></li>
                <li><a href="/cavernes.html" title="Cavernes du Clan">Cavernes du Clan</a></li>
              </ul>
            </li>
            <li><a href="" title="">Outils</a>
              <ul>
                <li><a href="/pxbank.html" title="PX Bank du Clan">PX Bank</a></li>
                <li><a href="/GPS.html" title="GPS">GPS</a></li>
                <li><a href="/CdM.html" title="CdM">CdM Collector</a></li>
              </ul>
            </li>
            <li><a href="" title="">Liens</a></li>
          </ul>
        </div>
      </div>
START_LOOP

$begin =~ s/#CLAN_NAME#/$clan_name/;

our $end   = <<"END_LOOP";
      </div> <!-- content -->
    </div> <!-- page -->
  </body>
</html>
END_LOOP

our $sortscript = '      <script type="text/javascript" src="/js/sort-px.js"></script>'."\n";
our $vuescript  = '      <script type="text/javascript" src="/js/tt-gps.js"></script>'."\n";

1;
