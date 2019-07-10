<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
  <head>
<?php include 'inc.head.php'; ?>
  </head>
  <body>
    <div id="page">
      <div id="header">
<?php include 'inc.header.php'; ?>
      </div>
      <div id="content" style="text-align:center;">
      <link href="/style/gps.css"  rel="stylesheet" type="text/css"  />
        <h1>Radar de zone</h1>
        <h3>Passez la souris sur un point pour afficher l'infobulle</h3>
        <div id="tooltip" display="none" style="position: absolute; display: none;"></div>
        <svg version="1.2" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" class="graph" role="img">
          <g class="grid x-grid" id="xGrid"><line x1="300" x2="300" y1="000" y2="600"></line></g>
          <g class="grid y-grid" id="yGrid"><line x1="000" x2="600" y1="300" y2="300"></line></g>
          <g class="grid r-grid" id="rGrid"><line x1="600" x2="600" y1="000" y2="600"></line></g>
          <g class="grid t-grid" id="tGrid"><line x1="000" x2="600" y1="000" y2="000"></line></g>
          <g class="grid b-grid" id="bGrid"><line x1="000" x2="600" y1="600" y2="600"></line></g>
          <g class="grid l-grid" id="lGrid"><line x1="000" x2="000" y1="000" y2="600"></line></g>

          <text x="000" y="308" font-family="sans-serif" font-size="10px" fill="black">-200</text>
          <text x="582" y="299" font-family="sans-serif" font-size="10px" fill="black"> 200</text>
          <text x="279" y="599" font-family="sans-serif" font-size="10px" fill="black">-200</text>
          <text x="301" y="009" font-family="sans-serif" font-size="10px" fill="black"> 200</text>

<?php
    include 'inc.db.php';

    $arr_colors = ["AliceBlue","AntiqueWhite","Aqua","Aquamarine","Azure",
                   "Beige","Bisque","Black","BlanchedAlmond","Blue",
                   "BlueViolet","Brown","BurlyWood","CadetBlue","Chartreuse",
                   "Chocolate","Coral","CornflowerBlue","Cornsilk","Crimson"];

    $req_radar_g    = "SELECT Gobelins.Id,Gobelins.Gobelin,X,Y,N,PER,BMPER,BPPER,
                       (PER+BMPER+BPPER) AS CASES 
                       FROM Gobelins
                       INNER JOIN Gobelins2 on Gobelins.Id = Gobelins2.Id
                       ORDER BY CASES DESC";
    $query_radar_g = $db->query($req_radar_g);

    while ($row = $query_radar_g->fetch_array())
    {
        $gob_id   = $row[0];
        $X        = $row[2];
        $Y        = $row[3];
        $N        = $row[4];
        $cases    = 1 + $row[5] + $row[6] + $row[7];
        $position = "<b>X</b> = $X | <b>Y</b> = $Y | <b>N</b> = $N";
        $tt       = '\''.'['.$gob_id.'] '.$row[1].' ('.$position.')\'';

        $cx       = ($X + 200) * 1.5;
        $cy       = (200 - $Y) * 1.5;

        $color    = $arr_colors[array_rand($arr_colors, 1)];

        print('          <g fill="'.$color.'">'."\n");
        print('            <circle cx="'.$cx.'" cy="'.$cy.'" r="'.$cases.'" onmousemove="showTooltip(evt, '.$tt.')";" onmouseout="hideTooltip();"></circle>'."\n");
        print('          </g>'."\n");

        print('          <g stroke="black" fill="none">'."\n");
        print('            <circle fill="none"  cx="'.$cx.'" cy="'.$cy.'" r="'.$cases.'"></circle>'."\n");
        print('          </g>'."\n");
    }

    $req_radar_s    = "SELECT Suivants.Id,Vue.Nom,Vue.X,Vue.Y,Vue.N
                       FROM Suivants
                       INNER JOIN Vue on Suivants.Id = Vue.Id
                       ORDER BY Suivants.Id";
    $query_radar_s = $db->query($req_radar_s);

    while ($row = $query_radar_s->fetch_array())
    {
        $X        = $row[2];
        $Y        = $row[3];
        $N        = $row[4];
        $cases    = 2;      # Hardcoded for now
        $position = "<b>X</b> = $X | <b>Y</b> = $Y | <b>N</b> = $N";
        $tt       = '\''.'['.$row[0].'] '.$row[1].' ('.$position.')\'';

        $cx       = ($X + 200) * 1.5;
        $cy       = (200 - $Y) * 1.5;

        $color    = $arr_colors[array_rand($arr_colors, 1)];

        print('          <g fill="'.$color.'">'."\n");
        print('            <circle cx="'.$cx.'" cy="'.$cy.'" r="'.$cases.'" onmousemove="showTooltip(evt, '.$tt.')";" onmouseout="hideTooltip();"></circle>'."\n");
        print('          </g>'."\n");

        print('          <g stroke="black" fill="none">'."\n");
        print('            <circle fill="none"  cx="'.$cx.'" cy="'.$cy.'" r="'.$cases.'"></circle>'."\n");
        print('          </g>'."\n");
    }

    $db->close;
?>

        </svg>
      </div> <!-- content -->
      <script type="text/javascript" src="/js/tt-gps.js"></script>
    </div> <!-- page -->
  </body>
</html>
