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
        <link href="/style/tt_r.css"  rel="stylesheet" type="text/css"  />
        <link href="/style/equipement.css"  rel="stylesheet" type="text/css"  />
        <h1>Possessions</h1>
        <h2 class="expanded">Composants Gobelins</h2>
        <table cellspacing="0" id="profilInfos">
<?php
    include 'queries.php';

    foreach ($arr_gob_ids as $gob_id)
    {

        $db_file = '/db/'.$_ENV["DBNAME"];
        $db      = new SQLite3($db_file);
        if(!$db) { echo $db->lastErrorMsg(); }

        $req_composant_c   = "SELECT COUNT (*) FROM ItemsGobelins WHERE Type = 'Composant' AND Gobelin = $gob_id";
        $composant_count   = $db->querySingle($req_composant_c);

        $req_gob_nom       = "SELECT Gobelin FROM Gobelins WHERE Id = $gob_id";
        $gob_nom           = $db->querySingle($req_gob_nom);

        if ( $composant_count > 0 )
        {
            print('<tr class="expanded">'."\n");
            print('<th>['.$composant_count.'] Composants de '.$gob_nom.' ('.$gob_id.')</th>'."\n");
            print('</tr>'."\n");
            print('</tr>'."\n");
            print('<tr>'."\n");
            print('<td>'."\n");
            print('<ul class="membreEquipementList">'."\n");

            $req_composant   = "SELECT * FROM ItemsGobelins WHERE Type = 'Composant' AND Gobelin = '$gob_id'";
            $query_composant = $db->query($req_composant);

            while ($row = $query_composant->fetchArray())
            {
                $item_id = $row[0];
                $min     = sprintf("%.1f",$row[7]/60);
                $nom     = $row[4];
                $desc    = $row[6];

                print('                <li class="equipementNonEquipe">'.'['.$item_id.'] '.$nom.' ('.$desc.'), '.$min.' min</li>'."\n");
            }
            $db->close;

            print('              </ul>'."\n");
            print('            </td>'."\n");
            print('          </tr>'."\n");
        }
    }
?>
        </table>
      </div> <!-- content -->
    </div> <!-- page -->
  </body>
</html>
