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
        <h1>Kiki-meter</h1>
        <h3>(Alias: Qui a la plus grosse ...)</h3>
        <table cellspacing="0" id="px">
        <thread>
          <tr>
            <th style="cursor: pointer;" data-sort-method='default'>Pseudo</th>
            <th style="cursor: pointer;" data-sort-method='number'>Num</th>
            <th style="cursor: pointer;" data-sort-method='dice'>ATT</th>
            <th style="cursor: pointer;" data-sort-method='dice'>DEG</th>
            <th style="cursor: pointer;" data-sort-method='dice'>ESQ</th>
            <th style="cursor: pointer;" data-sort-method='dice'>REG</th>
            <th style="cursor: pointer;" data-sort-method='number'>PER</th>
            <th style="cursor: pointer;" data-sort-method='number'>PV</th>
            <th style="cursor: pointer;" data-sort-method='number'>Arm P</th>
            <th style="cursor: pointer;" data-sort-method='number'>Arm M</th>
            <th style="cursor: pointer;" data-sort-method='number'>DLA</th>
            <th style="cursor: pointer;" data-sort-method='number'>CT</th>
          </tr>
        </thread>
        <tbody>
<?php
    include 'inc.db.php';
    include 'functions.php';
    include 'inc.var.php';

    $req_gob_kiki      = "SELECT Gobelins.Id,Gobelin,CT,
                                 Gobelins2.DLA AS DLA_s,BPDLA,BMDLA,Gobelins.DLA,
                                 ATT,BPATT,BMATT,
                                 ESQ,BPESQ,BMESQ,
                                 DEG,BPDEG,BMDEG,
                                 REG,BPREG,BMREG,
                                 PER,BPPER,BMPER,
                                 BPArm,BMArm,
                                 PVMax
                          FROM Gobelins
                          INNER JOIN Gobelins2 on Gobelins.Id = Gobelins2.Id";
    $query_gob_kiki    = $db->query($req_gob_kiki);

    $req_max_ct   = "SELECT MAX(CT) FROM `Gobelins`";
    $req_max_marm = "SELECT MAX(BMArm) FROM `Gobelins2`";
    $req_max_parm = "SELECT MAX(BPArm) FROM `Gobelins2`";
    $req_max_pv   = "SELECT MAX(PVMax) FROM `Gobelins2`";
    $req_max_dla  = "SELECT MIN(DLA) FROM `Gobelins2`";
    $req_max_att  = "SELECT MAX(`ATT` * 3.5 + `BPATT` + `BMATT`) FROM `Gobelins2`";
    $req_max_deg  = "SELECT MAX(`DEG` * 3.5 + `BPDEG` + `BMDEG`) FROM `Gobelins2`";
    $req_max_esq  = "SELECT MAX(`ESQ` * 3.5 + `BPESQ` + `BMESQ`) FROM `Gobelins2`";
    $req_max_reg  = "SELECT MAX(`REG` * 1.5 + `BPREG` + `BMREG`) FROM `Gobelins2`";
    $req_max_per  = "SELECT MAX(`PER` + `BPPER` + `BMPER`) FROM `Gobelins2`";

    $max_pv       = $db->query($req_max_pv)->fetch_row()[0];
    $max_parm     = $db->query($req_max_parm)->fetch_row()[0];
    $max_marm     = $db->query($req_max_marm)->fetch_row()[0];
    $max_ct       = $db->query($req_max_ct)->fetch_row()[0];
    $max_dla      = $db->query($req_max_dla)->fetch_row()[0];
    $max_att      = $db->query($req_max_att)->fetch_row()[0];
    $max_deg      = $db->query($req_max_deg)->fetch_row()[0];
    $max_esq      = $db->query($req_max_esq)->fetch_row()[0];
    $max_reg      = $db->query($req_max_reg)->fetch_row()[0];
    $max_per      = $db->query($req_max_per)->fetch_row()[0];

    while ($row = $query_gob_kiki->fetch_assoc())
    {
        $duree_b = GetDureeDLA($row['DLA_s']);
        $att_bm  = $row['BPATT'] + $row['BMATT'];
        $deg_bm  = $row['BPDEG'] + $row['BMDEG'];
        $esq_bm  = $row['BPESQ'] + $row['BMESQ'];
        $reg_bm  = $row['BPREG'] + $row['BMREG'];
        $portee  = $row['PER']   + $row['BPPER'] + $row['BMPER'];

        $att_nbr = $row['ATT'] * 3.5 + $att_bm;
        $deg_nbr = $row['DEG'] * 3.5 + $deg_bm;
        $esq_nbr = $row['ESQ'] * 3.5 + $esq_bm;
        $reg_nbr = $row['REG'] * 1.5 + $reg_bm;

        $att_d   = $row['ATT'].'D6 '.sprintf("%+d",$att_bm);
        $deg_d   = $row['DEG'].'D6 '.sprintf("%+d",$deg_bm);
        $esq_d   = $row['ESQ'].'D6 '.sprintf("%+d",$esq_bm);
        $reg_d   = $row['REG'].'D3 '.sprintf("%+d",$reg_bm);

        if ( $row['CT'] == $max_ct ) { $ct = '<b style="color:SpringGreen;">'.$max_ct.'</b>'; } else { $ct = $row['CT']; }
        if ( $row['PVMax'] == $max_pv ) { $pv = '<b style="color:SpringGreen;">'.$max_pv.'</b>'; } else { $pv = $row['PVMax']; }
        if ( $row['BPArm'] == $max_parm ) { $parm = '<b style="color:SpringGreen;">'.$max_parm.'</b>'; } else { $parm = $row['BPArm']; }
        if ( $row['BMArm'] == $max_marm ) { $marm = '<b style="color:SpringGreen;">'.$max_marm.'</b>'; } else { $marm = $row['BMArm']; }
        if ( $row['DLA_s'] == $max_dla ) { $dla = '<b style="color:SpringGreen;">'.$duree_b.'</b>'; } else { $dla = $duree_b; }
        if ( $att_nbr      == $max_att ) { $att = '<b style="color:SpringGreen;">'.$att_d.'</b>'; } else { $att = $att_d; }
        if ( $deg_nbr      == $max_deg ) { $deg = '<b style="color:SpringGreen;">'.$deg_d.'</b>'; } else { $deg = $deg_d; }
        if ( $esq_nbr      == $max_esq ) { $esq = '<b style="color:SpringGreen;">'.$esq_d.'</b>'; } else { $esq = $esq_d; }
        if ( $reg_nbr      == $max_reg ) { $reg = '<b style="color:SpringGreen;">'.$reg_d.'</b>'; } else { $reg = $reg_d; }
        if ( $portee       == $max_per ) { $per = '<b style="color:SpringGreen;">'.$portee.'</b>'; } else { $per = $portee; }

        print('          <tr>'."\n");
        print('            <td>'.$row['Gobelin'].'</td>'."\n");
        print('            <td>'.$row['Id'].'</td>'."\n");
        print('            <td>'.$att.'</td>'."\n");
        print('            <td>'.$deg.'</td>'."\n");
        print('            <td>'.$esq.'</td>'."\n");
        print('            <td>'.$reg.'</td>'."\n");
        print('            <td>'.$per.' Cases</td>'."\n");
        print('            <td>'.$pv.' PV'.'</td>'."\n");
        print('            <td>'.$parm.'</td>'."\n");
        print('            <td>'.$marm.'</td>'."\n");
        print('            <td>'.$dla.'</td>'."\n");
        print('            <td>'.$ct.' CT'.'</td>'."\n");
        print('          </tr>'."\n");
    }

    $db->close;
?>
        </tbody>
        </table>
        <script type="text/javascript" src="/js/tristen-tablesort.js"></script>
        <script type="text/javascript" src="/js/tristen-tablesort.dice.js"></script>
        <script type="text/javascript" src="/js/tristen-tablesort.number.js"></script>
        <script>new Tablesort(document.getElementById('px'));</script>
      </div> <!-- content -->
    </div> <!-- page -->
  </body>
</html>
