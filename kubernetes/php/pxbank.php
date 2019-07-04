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
        <h1>Banque PI/PX</h1>
        <h3>(Alias: Qui a la plus grosse ...)</h3>
        <table cellspacing="0" id="px">
        <thread>
          <tr>
            <th style="cursor: pointer;" data-sort-method='default'>Pseudo</th>
            <th style="cursor: pointer;" data-sort-method='number'>Num</th>
            <th style="cursor: pointer;" data-sort-method='number'>Niv.</th>
            <th style="cursor: pointer;" data-sort-method='number'>PX Perso</th>
            <th style="cursor: pointer;" data-sort-method='number'>PX</th>
            <th style="cursor: pointer;" data-sort-method='number'>PI</th>
            <th style="cursor: pointer;" data-sort-method='number'>PI Totaux</th>
            <th style="cursor: pointer;" data-sort-method='number'>PX+PI Totaux</th>
          </tr>
        </thread>
        <tbody>
<?php
        $db_file = '/db/'.$_ENV["DBNAME"];
        $db      = new SQLite3($db_file);
        if(!$db) { echo $db->lastErrorMsg(); }

        $req_pxbank    = "SELECT Gobelins.Id,PX,PXPerso,PI,Gobelin,Niveau,PITotal
                          FROM Gobelins
                          INNER JOIN Gobelins2 on Gobelins.Id = Gobelins2.Id
                          ORDER BY Gobelins.Id";
        $query_pxbank = $db->query($req_pxbank);

        while ($row = $query_pxbank->fetchArray())
        {
            $total = $row[1] + $row[2] + $row[6];

            print('          <tr>'."\n");
            print('            <td>'.$row[4].'</td>'."\n");
            print('            <td>'.$row[0].'</td>'."\n");
            print('            <td>'.$row[5].'</td>'."\n");
            print('            <td>'.$row[2].'</td>'."\n");
            print('            <td>'.$row[1].'</td>'."\n");
            print('            <td>'.$row[3].'</td>'."\n");
            print('            <td>'.$row[6].'</td>'."\n");
            print('            <td>'.$total.'</td>'."\n");
            print('          </tr>'."\n");
        }
        $db->close;
?>
        </tbody>
        </table>
        <script type="text/javascript" src="/js/tristen-tablesort.js"></script>
        <script type="text/javascript" src="/js/tristen-tablesort.number.js"></script>
        <script>new Tablesort(document.getElementById('px'));</script>
      </div> <!-- content -->
    </div> <!-- page -->
  </body>
</html>
