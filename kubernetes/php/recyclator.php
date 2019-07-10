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
        <h1>Recyclator</h1>
        <h3>(Liste des matériaux issus de Recycler)</h3>
        <table cellspacing="0" id="recyclage">
        <thread>
          <tr>
            <th style="cursor: pointer;" data-sort-method='default'>Niveau</th>
            <th style="cursor: pointer;" data-sort-method='default'>Objet</th>
            <th style="cursor: pointer;" data-sort-method='default'>Matériau</th>
            <th style="cursor: pointer;" data-sort-method='number'>Carats</th>
            <th style="cursor: pointer;" data-sort-method='number'>#</th>
          </tr>
        </thread>
        <tbody id="recyclage">
<?php
    include 'inc.db.php';
    include 'functions.php';

    $arr_niv = ['Apprenti','Compagnon','Maître', 'Grand Maître'];
    $hash    = [];

    foreach ( $arr_niv as $niv )
    {
        $req_rec_ids    = "SELECT Id,PMText 
                           FROM   MPBot
                           WHERE  PMSubject = 'Résultat Recyclage'
                           AND    PMText LIKE '%AVEZ RÉUSSI%que $niv%recyclé%'";
        $query_rec_ids = $db->query($req_rec_ids);

        while ($rec_ids = $query_rec_ids->fetch_array())
        {
            $mp_id      = $rec_ids[0];
            $mp_text    = $rec_ids[1];
            $carats     = 0;

            preg_match('/A partir de( de)? cet objet \(([\'\w\s-]*)\),/u', $mp_text, $matches);
            $item = $matches[2];
            $item = preg_replace('/ $/', '', $item);

            preg_match('/(un morceau d[\'e]|un[e]?)?<B>(\w*)</', $mp_text, $arr_materiau);
            preg_match('/de taille <B>(\d*)</', $mp_text, $arr_taille);
            preg_match('/de qualité <B>([\w\s]*)</u', $mp_text, $arr_qualite);

            if ( $arr_qualite[1] )
            {
                $carats = GetCarats($arr_qualite[1],$arr_taille[1]);
            }
            else
            {
                $carats = $arr_taille[1];
            }

            $hash[$niv][$item]['count']++;
            $hash[$niv][$item]['ids'][] = $mp_id;
            $hash[$niv][$item]['ressource'] = $arr_materiau[2];
            $hash[$niv][$item]['max'] = max($hash[$niv][$item]['max'],$carats);

            if ( ! $hash[$niv][$item]['min'] ) { $hash[$niv][$item]['min'] = 999; }
            $hash[$niv][$item]['min'] = min($hash[$niv][$item]['min'],$carats);
        }
    }

    foreach ( $arr_niv as $niv )
    {
        foreach ( $hash[$niv] as $item => $value)
        {
            if ( $hash[$niv][$item]['min'] < $hash[$niv][$item]['max'] )
            {
                $carats = $hash[$niv][$item]['min'].'-'.$hash[$niv][$item]['max'];
            }
            else
            {
                $carats = $hash[$niv][$item]['min'];
            }

            print('          <tr>'."\n");
            print('            <td>'.$niv.'</td>'."\n");
            print('            <td>'.$item.'</td>'."\n");
            print('            <td>'.$hash[$niv][$item]['ressource'].'</td>'."\n");
            print('            <td>'.$carats.'</td>'."\n");
            print('            <td>'.$hash[$niv][$item]['count'].'</td>'."\n");
            print('          </tr>'."\n");
        }
    }

    print('      </tbody>'."\n");
    print('        </table>'."\n");

    $db->close;
?>
        <script type="text/javascript" src="/js/tristen-tablesort.js"></script>
        <script type="text/javascript" src="/js/tristen-tablesort.number.js"></script>
        <script>new Tablesort(document.getElementById('recyclage'));</script>
      </div> <!-- content -->
    </div> <!-- page -->
  </body>
</html>
