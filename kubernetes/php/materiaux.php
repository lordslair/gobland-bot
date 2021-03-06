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
        <link href="/style/tt_r.css"  rel="stylesheet" type="text/css"  />
        <link href="/style/equipement.css"  rel="stylesheet" type="text/css"  />
        <h1>Possessions</h1>
        <h2 class="expanded">Matériaux Gobelins</h2>
        <table cellspacing="0" id="profilInfos">
<?php
    include 'inc.db.php';
    include 'inc.var.php';
    include 'functions.php';

    foreach ($arr_gob_ids as $gob_id)
    {
        $req_materiaux_c   = "SELECT COUNT(*) FROM ItemsGobelins WHERE ( Type = 'Matériau' OR Type = 'Roche' OR Type = 'Minerai' OR Type = 'Pierre Précieuse' ) AND Gobelin = '$gob_id'";
        $materiaux_count   = $db->query($req_materiaux_c)->fetch_row()[0];

        $req_gob_nom       = "SELECT Gobelin FROM Gobelins WHERE Id = '$gob_id'";
        $gob_nom           = $db->query($req_gob_nom)->fetch_row()[0];

        if ( $materiaux_count > 0 )
        {
            print('<tr class="expanded">'."\n");
            print('<th>['.$materiaux_count.'] Matériaux de '.$gob_nom.' ('.$gob_id.')</th>'."\n");
            print('</tr>'."\n");
            print('</tr>'."\n");
            print('<tr>'."\n");
            print('<td>'."\n");
            print('<ul class="membreEquipementList">'."\n");

            $req_materiaux   = "SELECT * FROM ItemsGobelins
                                WHERE ( Type = 'Matériau' OR Type = 'Roche' OR Type = 'Minerai' )
                                AND Gobelin = '$gob_id'
                                ORDER BY Type,Nom";
            $query_materiaux = $db->query($req_materiaux);

            while ($row = $query_materiaux->fetch_array())
            {
                $item_id = $row[0];
                $type    = $row[2];
                $nom     = $row[4];
                $desc    = $row[6];
                $min     = sprintf("%.1f",$row[7]/60);
                $nbr     = $row[8];
                $qualite = $row[9];

                $desc    = GetQualite($type,$qualite);
                $m_png   = GetMateriauIcon($nom);
                $carats  = GetCarats($qualite,$nbr);

                print('                <li class="equipementNonEquipe">'."\n");
                print('                  <div class="tt_r">'."\n");
                print('                    '.$m_png.'['.$item_id.'] '.$nom.' de taille '.$nbr.' ('.$desc.'), '.$min.' min'."\n");
                print('                    <span class="tt_r_text">'.$carats.' Carats</span>'."\n");
                print('                  </div>'."\n");
                print('                </li>'."\n");
            }

            print('              </ul>'."\n");
            print('            </td>'."\n");
            print('          </tr>'."\n");
        }
    }
    $db->close;
?>
        </table>
      </div> <!-- content -->
    </div> <!-- page -->
  </body>
</html>
