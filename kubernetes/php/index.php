<?php include 'inc.session.php'; ?>
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
      <div id="content">
<?php
    print ('<br><h1>'.$_SESSION["gob_clan_name"].'</h1><br>');
?>
        <table cellspacing="0" id="trollsList">
          <tr>
            <th>Pseudo</th>
            <th>Num</th>
            <th>Race</th>
            <th>Niv.</th>
            <th>Position</th>
            <th>Meute</th>
            <th>PV</th>
            <th>Faim</th>
            <th>État</th>
            <th>PA</th>
            <th>Dates</th>
            <th>Action</th>
          </tr>
<?php
    include 'inc.db.php';
    include 'inc.var.php';
    include 'functions.php';

    $ct_total   = 0;

    foreach ($arr_gob_ids as $gob_id)
    {

        $req_profile   = "SELECT Gobelins.Id,Tribu,Gobelin,Niveau,X,Y,N,PA,PV,PVMax,CT,
                                 Gobelins.DLA,Gobelins2.DLA,BPDLA,BMDLA,Gobelins.Etat,Faim
                          FROM Gobelins
                          INNER JOIN Gobelins2 on Gobelins.Id = Gobelins2.Id
                          WHERE Gobelins.Id = $gob_id
                          ORDER BY Gobelins.Id";
        $query_profile = $db->query($req_profile);

        while ($row = $query_profile->fetch_array())
        {
            $dla = new \DateTime($row[11]);
            $now = new \DateTime();
            if($dla->diff($now)->days > 30) { continue; } // In order to hide inactive gobelins

            $position    = $row[4].', '.$row[5].', '.$row[6];

            $req_meute_id    = "SELECT IdMeute  FROM Meutes WHERE Id = $gob_id";
            $meute_id  = $db->query($req_meute_id)->fetch_row()[0];
            if ( $meute_id ) { $meute_id = '('.$meute_id.')'; }

            $req_meute_nom   = "SELECT NomMeute FROM Meutes WHERE Id = $gob_id";
            $meute_nom = $db->query($req_meute_nom)->fetch_row()[0];

            $pad = ' ';
            if ( $row[7] > 0 )
            {
                $pad = ' class="PADispo"';
            }

            $color   = GetColor($row[8],$row[9]);
            $percent = ($row[8] / $row[9]) * 100;
            $lifebar = '<br><div class="vieContainer"><div style="background-color:'.$color.'; width: '.$percent.'%">&nbsp;</div></div>';

            $faimcolor = GetColorFaim($row[16]);
            $faimbar   = '<br><div class="faimContainer"><div style="background-color:'.$faimcolor.'; width: 100%">&nbsp;</div></div>';

            $ct_total += $row[10];

            $duree_s   = $row[12] + $row[13] + $row[14];
            $pdla      = GetpDLA($row[11], $duree_s);
 
            $etat      = '';
            if ( $row[15] == 'Camouflé' ) { $etat = '👻'; }

            print('          <tr>'."\n");
            print('            <td>'."\n");
            print('              <a href="http://games.gobland.fr/Profil.php?IdPJ='.$gob_id.'" target="_blank">'.$row[2].'</a>'."\n");
            print('            </td>'."\n");
            print('            <td>'.$gob_id.'</td>'."\n");
            print('            <td>'.$row[1].'</td>'."\n");
            print('            <td>'.$row[3].'</td>'."\n");
            print('            <td>'.$position.'</td>'."\n");
            print('            <td>'.$meute_nom.' '.$meute_id.'</td>'."\n");
            print('            <td>'.$row[8].' / '.$row[9].$lifebar.'</td>'."\n");
            print('            <td>'.$row[16].$faimbar.'</td>'."\n");
            print('            <td><font size="4">'.$etat.'</font></td>'."\n");
            print('            <td'.$pad.'>'.$row[7].'</td>'."\n");
            print('            <td><span class="DLA"> DLA : '.$row[11].'</span><br><span class="pDLA">pDLA : '.$pdla.'</span></td>'."\n");
            print('            <td>'."\n");
            print('            <a href="/gobelins.php?id='.$gob_id.'" title="Votre profil">PROFIL</a>'."\n");
            print('            <a href="/vue.php?id='.$gob_id.'" title="Votre vue">VUE</a>'."\n");
            print('            </td>'."\n");
            print('            </tr>'."\n");
        }
    }

    print('        </table>'."\n");

    print('        <div>'."\n");
    print('          <h3>Fortune : '.$ct_total.' CT (gobelins)</h3>'."\n");
    print('        </div>'."\n");

    $db->close;
?>
<?php include 'inc.footer.php'; ?>
      </div> <!-- content -->
    </div> <!-- page -->
  </body>
</html>
