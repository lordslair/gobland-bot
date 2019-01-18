package GLB::variables;

use warnings;
use strict;

use YAML::Tiny;

use lib '/home/gobland-bot/lib/';
use GLB::queries;

our $yaml      = '/home/gobland-bot/gl-config.yaml';
our $glyaml    = YAML::Tiny->read( $yaml );
our $clan_name = $glyaml->[0]{gl_clan_name};

our @gob_ids   = GLB::queries::req_gobelin_id();
our %id2gob    = GLB::queries::req_id2gob();
our %meute     = GLB::queries::req_meute();

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
