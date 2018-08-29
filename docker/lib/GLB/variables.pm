package GLB::variables;

use warnings;
use strict;

use YAML::Tiny;
my  $yaml      = '/home/gobland-bot/gl-config.yaml';
my  $glyaml    = YAML::Tiny->read( $yaml );
our $clan_name = $glyaml->[0]{gl_clan_name};

our $begin = <<"START_LOOP";
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
  <head>
    <title>#CLAN_NAME#</title>
    <link rel="stylesheet" type="text/css" href="/style/common.css" />
    <link rel="stylesheet" type="text/css" href="/style/menu.css" />
    <link rel="stylesheet" type="text/css" href="/style/equipement.css" />
    <link rel="stylesheet" type="text/css" href="/style/gps.css" />
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
              </ul>
            </li>
            <li><a href="" title="">Outils</a>
              <ul>
                <li><a href="/pxbank.html" title="PX Bank du Clan">PX Bank</a></li>
                <li><a href="/GPS.html" title="GPS">GPS</a></li>
              </ul>
            </li>
            <li><a href="" title="">Liens</a></li>
          </ul>
        </div>
      </div>
START_LOOP

$begin =~ s/#CLAN_NAME#/$clan_name/;

our $end   = <<"END_LOOP";
      </div>
    </div>
  </body>
</html>
END_LOOP

our $sortscript = <<SORT_SCRIPT;
<script>
function sortTable(n) {
  var table, rows, switching, i, x, y, shouldSwitch, dir, switchcount = 0;
  table = document.getElementById("trollsList");
  switching = true;
  //Set the sorting direction to ascending:
  dir = "asc";
  /*Make a loop that will continue until
  no switching has been done:*/
  while (switching) {
    //start by saying: no switching is done:
    switching = false;
    rows = table.rows;
    /*Loop through all table rows (except the
    first, which contains table headers):*/
    for (i = 1; i < (rows.length - 1); i++) {
      //start by saying there should be no switching:
      shouldSwitch = false;
      /*Get the two elements you want to compare,
      one from current row and one from the next:*/
      x = rows[i].getElementsByTagName("TD")[n];
      y = rows[i + 1].getElementsByTagName("TD")[n];
      /*check if the two rows should switch place,
      based on the direction, asc or desc:*/
      if (dir == "asc") {
        if (Number(x.innerHTML) > Number(y.innerHTML)) {
          shouldSwitch = true;
          break;
        }
      } else if (dir == "desc") {
        if (Number(x.innerHTML) < Number(y.innerHTML)) {
          shouldSwitch = true;
          break;
        }
      }
    }
    if (shouldSwitch) {
      /*If a switch has been marked, make the switch
      and mark that a switch has been done:*/
      rows[i].parentNode.insertBefore(rows[i + 1], rows[i]);
      switching = true;
      //Each time a switch is done, increase this count by 1:
      switchcount ++;
    } else {
      /*If no switching has been done AND the direction is "asc",
      set the direction to "desc" and run the while loop again.*/
      if (switchcount == 0 && dir == "asc") {
        dir = "desc";
        switching = true;
      }
    }
  }
}
</script>
SORT_SCRIPT

our $vuescript = '      <script type="text/javascript" src="/js/tt-gps.js"></script>'."\n";

1;
