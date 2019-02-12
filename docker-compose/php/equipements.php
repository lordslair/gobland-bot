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
        <h2 class="expanded">Équipements Gobelins</h2>
        <table cellspacing="0" id="profilInfos">
<?php
    include 'queries.php';
    include 'functions.php';

    foreach ($arr_gob_ids as $gob_id)
    {
        $db_file = '/db/'.$_ENV["DBNAME"];
        $db      = new SQLite3($db_file);
        if(!$db) { echo $db->lastErrorMsg(); }

        $req_gob_nom       = "SELECT Gobelin FROM Gobelins WHERE Id = '$gob_id'";
        $gob_nom           = $db->querySingle($req_gob_nom);

        print('<tr class="expanded">'."\n");
        print('<th>Équipements de '.$gob_nom.' ('.$gob_id.')</th>'."\n");
        print('</tr>'."\n");
        print('</tr>'."\n");
        print('<tr>'."\n");
        print('<td>'."\n");
        print('<ul class="membreEquipementList">'."\n");

        $req_equipements   = "SELECT * FROM ItemsGobelins 
                              WHERE Gobelin = '$gob_id'
                              AND Type NOT IN ('Minerai', 'Composant', 'Matériau', 'Roche')
                              ORDER BY Utilise DESC";
        $query_equipements = $db->query($req_equipements);

        $counter = 0;

        while ($row = $query_equipements->fetchArray())
        {
            $item_id  = $row[0];
            $type     = $row[2];
            $nom      = $row[4];
            $template = '';
            $desc     = $row[6];
            $min      = sprintf("%.1f",$row[7]/60);
            $equipe   = '';

            if ( $row[5] )  { $template = '<b>'.$row[5].'</b>'; }
            if ( $row[11] ) { $nom .= ' en '.$row[11]; }
            if ( $row[10] == 'FAUX' ) { $equipe = 'Non'; }

            $luxe     = GetLuxe($type,$nom,$desc);
            $craft    = GetCraft($type,$nom,$desc,$template);

            if ( $counter == 0 and $equipe == 'Non' )
            {
                print('                <br>'."\n");
                $counter++;
            }

            print('                <li class="equipement'.$equipe.'Equipe">'."\n");
            print('                    ['.$item_id.'] '.$type.' : '.$nom.' '.$template.' ('.$desc.'), '.$min.' min'.$luxe.$craft."\n");
            print('                </li>'."\n");
        }
        $db->close;

        print('              </ul>'."\n");
        print('            </td>'."\n");
        print('          </tr>'."\n");
    }
?>
        </table>
      </div> <!-- content -->
    </div> <!-- page -->
  </body>
</html>
