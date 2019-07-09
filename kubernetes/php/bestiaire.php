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
        <h1>Bestiaire du Clan</h1>
        <h3></h3>
        <center>
          <a href="/bestiaire.php?filter=A" title="Filtre A">[<b>A</b>]</a>
          <a href="/bestiaire.php?filter=B" title="Filtre B">[<b>B</b>]</a>
          <a href="/bestiaire.php?filter=C" title="Filtre C">[<b>C</b>]</a>
          <a href="/bestiaire.php?filter=D" title="Filtre D">[<b>D</b>]</a>
          <a href="/bestiaire.php?filter=E" title="Filtre E">[<b>E</b>]</a>
          <a href="/bestiaire.php?filter=F" title="Filtre F">[<b>F</b>]</a>
          <a href="/bestiaire.php?filter=G" title="Filtre G">[<b>G</b>]</a>
          <a href="/bestiaire.php?filter=H" title="Filtre H">[<b>H</b>]</a>
          <a href="/bestiaire.php?filter=I" title="Filtre I">[<b>I</b>]</a>
          <a href="/bestiaire.php?filter=J" title="Filtre J">[<b>J</b>]</a>
          <a href="/bestiaire.php?filter=K" title="Filtre K">[<b>K</b>]</a>
          <a href="/bestiaire.php?filter=L" title="Filtre L">[<b>L</b>]</a>
          <a href="/bestiaire.php?filter=M" title="Filtre M">[<b>M</b>]</a>
          <a href="/bestiaire.php?filter=N" title="Filtre N">[<b>N</b>]</a>
          <a href="/bestiaire.php?filter=O" title="Filtre O">[<b>O</b>]</a>
          <a href="/bestiaire.php?filter=P" title="Filtre P">[<b>P</b>]</a>
          <a href="/bestiaire.php?filter=Q" title="Filtre Q">[<b>Q</b>]</a>
          <a href="/bestiaire.php?filter=R" title="Filtre R">[<b>R</b>]</a>
          <a href="/bestiaire.php?filter=S" title="Filtre S">[<b>S</b>]</a>
          <a href="/bestiaire.php?filter=T" title="Filtre T">[<b>T</b>]</a>
          <a href="/bestiaire.php?filter=U" title="Filtre U">[<b>U</b>]</a>
          <a href="/bestiaire.php?filter=V" title="Filtre V">[<b>V</b>]</a>
          <a href="/bestiaire.php?filter=W" title="Filtre W">[<b>W</b>]</a>
          <a href="/bestiaire.php?filter=X" title="Filtre X">[<b>X</b>]</a>
          <a href="/bestiaire.php?filter=Y" title="Filtre Y">[<b>Y</b>]</a>
          <a href="/bestiaire.php?filter=Z" title="Filtre Z">[<b>Z</b>]</a>
          <a href="/bestiaire.php"          title="NoFiltre">[<b>ALL</b>]</a>
        </center>
        <br>
        <table cellspacing="0" id="cdm">
        <thread>
          <tr>
            <th style="cursor: pointer;" data-sort-method='default'>Nom</th>
            <th style="cursor: pointer;" data-sort-method='default'>Type</th>
            <th style="cursor: pointer;" data-sort-method='number'>Niv.</th>
            <th style="cursor: pointer;" data-sort-method='number'>PV</th>
            <th style="cursor: pointer;" data-sort-method='number'>ATT</th>
            <th style="cursor: pointer;" data-sort-method='number'>ESQ</th>
            <th style="cursor: pointer;" data-sort-method='number'>DEG</th>
            <th style="cursor: pointer;" data-sort-method='number'>REG</th>
            <th style="cursor: pointer;" data-sort-method='number'>Arm</th>
            <th style="cursor: pointer;" data-sort-method='number'>PER</th>
            <th style="cursor: pointer;" data-sort-method='default'>Infos</th>
            <th style="cursor: pointer;" data-sort-method='number'>#</th>
          </tr>
        </thread>
        <tbody id="cdm">
        <div id="tooltip" display="none" style="position: absolute; display: none;"></div>
<?php
    include 'inc.db.php';

    $req_cdm_ids    = "SELECT DISTINCT Name,Niveau FROM CdM ORDER BY Name;";

    if ( preg_match('/^\w$/', $_GET['filter']) )
    {
        $filter      = $_GET['filter'];
        $req_cdm_ids = "SELECT DISTINCT Name,Niveau FROM CdM WHERE Name LIKE '$filter%';";
    }

    $query_cdm_ids = $db->query($req_cdm_ids);

    while ($cdm_ids = $query_cdm_ids->fetch_array())
    {
        $mob_id;
        $mob_date;
        $mob_name   = $cdm_ids[0];
        $mob_name   = preg_replace('/\'/', '\'\'', $mob_name);
        $mob_niv    = $cdm_ids[1];
        $mob_pv_min = 0;
        $mob_pv_max = 999;
        $mob_bless;
        $mob_att_min =  1;
        $mob_att_max = 99;
        $mob_esq_min =  1;
        $mob_esq_max = 99;
        $mob_deg_min =  1;
        $mob_deg_max = 99;
        $mob_reg_min =  1;
        $mob_reg_max = 99;
        $mob_arm_min =  1;
        $mob_arm_max = 99;
        $mob_per_min =  1;
        $mob_per_max = 99;

        $pouvoir_png = '<img src="/images/stuff/icon_127.png">';

        $distance_png = '<img src="/images/stuff/icon_67.png" title="Attaque: Distance">';
        $contact_png  = '<img src="/images/stuff/icon_35.png" title="Attaque: Corps à Corps">';

        $req_cdm    = "SELECT * FROM CdM WHERE Name = '$mob_name' AND Niveau = '$mob_niv'";
        $query_cdm  = $db->query($req_cdm);

        $update     = 0; # To count how many CdM we have of each IdMonstre
        while ($cdm = $query_cdm->fetch_array())
        {
            $mob_date    = $cdm[1];
            $mob_type    = $cdm[4];
            $mob_niv     = $cdm[5];
            $mob_bless   = $cdm[8];
            $mob_pouvoir = '';

            $mob_pv_min  = max($mob_pv_min ,$cdm[6]);
            $mob_pv_max  = min($mob_pv_max ,$cdm[7]);
            $mob_att_min = max($mob_att_min,$cdm[9]);
            $mob_att_max = min($mob_att_max,$cdm[10]);
            $mob_esq_min = max($mob_esq_min,$cdm[11]);
            $mob_esq_max = min($mob_esq_max,$cdm[12]);
            $mob_deg_min = max($mob_deg_min,$cdm[13]);
            $mob_deg_max = min($mob_deg_max,$cdm[14]);
            $mob_reg_min = max($mob_reg_min,$cdm[15]);
            $mob_reg_max = min($mob_reg_max,$cdm[16]);
            $mob_arm_min = max($mob_arm_min,$cdm[17]);
            $mob_arm_max = min($mob_arm_max,$cdm[18]);
            $mob_per_min = max($mob_per_min,$cdm[19]);
            $mob_per_max = min($mob_per_max,$cdm[20]);

            $tt_style = 'width: 15em;background: cornsilk;color: black;border: 1px solid black;';
            $tt = '<div class="tt_r">'.$pouvoir_png.'<span class="tt_r_text" style="'.$tt_style.'">'.$cdm[22].'</span></div>';
            if ( $cdm[22] != '' ) { $mob_pouvoir = $tt; }

            $mob_distance = '';
            if ( $cdm[23] == 'Oui' ) { $mob_distance = $distance_png; }
            if ( $cdm[23] == 'Non' ) { $mob_distance = $contact_png; }

            $update++;
        }

        print('          <tr>'."\n");
        print('            <td>'.$mob_name.'</td>'."\n");
        print('            <td>'.$mob_type.'</td>'."\n");
        print('            <td>'.$mob_niv.'</td>'."\n");
        print('            <td>'.$mob_pv_min.'-'.$mob_pv_max.'</td>'."\n");
        print('            <td>'.$mob_att_min.'-'.$mob_att_max.'</td>'."\n");
        print('            <td>'.$mob_esq_min.'-'.$mob_esq_max.'</td>'."\n");
        print('            <td>'.$mob_deg_min.'-'.$mob_deg_max.'</td>'."\n");
        print('            <td>'.$mob_reg_min.'-'.$mob_reg_max.'</td>'."\n");
        print('            <td>'.$mob_arm_min.'-'.$mob_arm_max.'</td>'."\n");
        print('            <td>'.$mob_per_min.'-'.$mob_per_max.'</td>'."\n");
        print('            <td>'.$mob_pouvoir.' '.$mob_distance.'</td>'."\n");
        print('            <td><b>'.$update.'</b></td>'."\n");
        print('          </tr>'."\n");
    }
    $db->close;

    print('      </tbody>'."\n");
    print('        </table>'."\n");
?>
        <script type="text/javascript" src="/js/tristen-tablesort.js"></script>
        <script type="text/javascript" src="/js/tristen-tablesort.number.js"></script>
        <script>new Tablesort(document.getElementById('cdm'));</script>
      </div> <!-- content -->
    </div> <!-- page -->
  </body>
</html>
