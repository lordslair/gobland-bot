<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
  <head>
<?php
    print ('<title>Gobland-IT ('.$_ENV["CLANID"].') '.$_ENV["CLANNAME"].'</title>');
?>
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
            <li><a href="/index.php" title="Page d'accueil">Accueil</a></li>
            <li><a href="#">Consulter</a>
              <ul>
                <li><a href="/equipements.php" title="Équipement des Gob' du Clan">Équipement du Clan</a></li>
                <li><a href="/materiaux.php" title="Matériaux des Gob' du Clan">Matériaux du Clan</a></li>
                <li><a href="/composants.php" title="Composants des Gob' du Clan">Composants du Clan</a></li>
                <li><a href="/cavernes.php" title="Cavernes du Clan">Cavernes du Clan</a></li>
              </ul>
            </li>
            <li><a href="" title="">Outils</a>
              <ul>
                <li><a href="/pxbank.php" title="PX Bank du Clan">PX Bank</a></li>
                <li><a href="/gps.php" title="GPS">GPS</a></li>
                <li><a href="/radar.php" title="Radar">Radar</a></li>
                <li><a href="/cdm.php" title="CdM">CdM Collector</a></li>
              </ul>
            </li>
            <li><a href="" title="">Liens</a>
              <ul>
                <li><a href="/admin.php" title="Admin">Admin</a></li>
                <li><a href="/locator.php" title="Locator">Locator</a></li>
              </ul>
            </li>
          </ul>
        </div>
      </div>
      <div id="content" style="text-align:center;">
      <link href="/style/gps.css"  rel="stylesheet" type="text/css"  />
        <h1>GPS des Lieux</h1>
        <h3>Passez la souris sur un point pour afficher l'infobulle</h3>
        <div id="tooltip" display="none" style="position: absolute; display: none;"></div>
        <svg version="1.2" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" class="graph" role="img">
          <g class="grid x-grid" id="xGrid"><line x1="300" x2="300" y1="000" y2="600"></line></g>
          <g class="grid y-grid" id="yGrid"><line x1="000" x2="600" y1="300" y2="300"></line></g>
          <g class="grid r-grid" id="rGrid"><line x1="600" x2="600" y1="000" y2="600"></line></g>
          <g class="grid t-grid" id="tGrid"><line x1="000" x2="600" y1="000" y2="000"></line></g>
          <g class="grid b-grid" id="bGrid"><line x1="000" x2="600" y1="600" y2="600"></line></g>
          <g class="grid l-grid" id="lGrid"><line x1="000" x2="000" y1="000" y2="600"></line></g>

<?php
        $db_file = '/db/'.$_ENV["DBNAME"];
        $db      = new SQLite3($db_file);
        if(!$db) { echo $db->lastErrorMsg(); }

        $req_gps    = "SELECT * FROM FP_Lieu";
        $query_gps = $db->query($req_gps);

        while ($row = $query_gps->fetchArray())
        {
            if ( ! $row[6] ) { continue; } # If coordinates not present in DB, we skip the display

            $position = "<b>X</b> = $row[6] | <b>Y</b> = $row[7] | <b>N</b> = $row[8]";
            $cx       = ($row[6] + 200) * 1.5;
            $cy       = (200 - $row[7]) * 1.5;
            $tt       = '\''.$row[1].' ('.$position.')\'';
            $dv       = $row[4];
            $dv       = preg_replace('/é/','e',$dv);
            $dv       = preg_replace('/è/','e',$dv);
            $dv       = preg_replace('/â/','a',$dv);

            print('          <g class="'.$dv.'">'."\n");
            print('            <circle cx="'.$cx.'" cy="'.$cy.'" r="2" onmousemove="showTooltip(evt, '.$tt.')";" onmouseout="hideTooltip();"></circle>'."\n");
            print('          </g>'."\n");
        }
        $db->close;
?>

        </svg>
      </div> <!-- content -->
      <br>
      <div style="text-align:center;">
        <svg version="1.2" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" class="leg" role="img">
          <g class="grid r-grid" id="rGrid"><line x1="400" x2="400" y1="000" y2="050"></line></g>
          <g class="grid t-grid" id="tGrid"><line x1="000" x2="400" y1="000" y2="000"></line></g>
          <g class="grid b-grid" id="bGrid"><line x1="000" x2="400" y1="050" y2="050"></line></g>
          <g class="grid l-grid" id="lGrid"><line x1="000" x2="000" y1="000" y2="050"></line></g>

          <g class="Tour">        <circle cx="010" cy="10" r="5"</circle></g><text x="20"  y="15">Tour</text>
          <g class="Laboratoire"> <circle cx="080" cy="10" r="5"</circle></g><text x="90"  y="15">Laboratoire</text>
          <g class="Cercle">      <circle cx="160" cy="10" r="5"</circle></g><text x="170" y="15">Cercle</text>
          <g class="Caverne">     <circle cx="240" cy="10" r="5"</circle></g><text x="250" y="15">Caverne</text>
          <g class="Cabane">      <circle cx="320" cy="10" r="5"</circle></g><text x="330" y="15">Cabane</text>

          <g class="Monastere">   <circle cx="010" cy="40" r="5"</circle></g><text x="020" y="45">Monastere</text>
          <g class="Fosse">       <circle cx="080" cy="40" r="5"</circle></g><text x="090" y="45">Fosse</text>
          <g class="Amphitheatre"><circle cx="160" cy="40" r="5"</circle></g><text x="170" y="45">Amphi.</text>
          <g class="Hemicycle">   <circle cx="240" cy="40" r="5"</circle></g><text x="250" y="45">Hemicycle</text>
        </svg>
      </div>
      <script type="text/javascript" src="/js/tt-gps.js"></script>
    </div> <!-- page -->
  </body>
</html>
