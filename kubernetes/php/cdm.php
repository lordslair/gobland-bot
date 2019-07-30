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
        <h1>Historique des CdM du Clan</h1>
        <h3>(30 derniers monstres affichés)</h3>
        <table cellspacing="0" id="cdm">
        <thread>
          <tr>
            <th style="cursor: pointer;" data-sort-method='number'>ID</th>
            <th style="cursor: pointer;" data-sort-method='default'>Nom</th>
            <th style="cursor: pointer;" data-sort-method='number'>Niv.</th>
            <th style="cursor: pointer;" data-sort-method='number'>Bless.</th>
            <th style="cursor: pointer;" data-sort-method='number'>PV</th>
            <th style="cursor: pointer;" data-sort-method='number'>ATT</th>
            <th style="cursor: pointer;" data-sort-method='number'>ESQ</th>
            <th style="cursor: pointer;" data-sort-method='number'>DEG</th>
            <th style="cursor: pointer;" data-sort-method='number'>REG</th>
            <th style="cursor: pointer;" data-sort-method='number'>Arm</th>
            <th style="cursor: pointer;" data-sort-method='number'>PER</th>
            <th style="cursor: pointer;" data-sort-method='date'>Update</th>
            <th style="cursor: pointer;" data-sort-method='date'>Action</th>
          </tr>
        </thread>
        <tbody id="cdm">
<?php
    include 'functions.php';
    include 'inc.db.php';

    if ( $_GET['kill'] && (preg_match('/^\d*$/', $_GET['kill'])) )
    {
        $mob_id      = $_GET['kill'];
        $req_mp_id   = "SELECT Id FROM CdM WHERE IdMob = '$mob_id' ORDER BY Date DESC LIMIT 1;";
        $mp_id       = $db->query($req_mp_id)->fetch_row()[0];
        $mp_kill_id  = $mp_id + 1;

        $req_check_kill_id = "SELECT COUNT(*) FROM `Kills` WHERE Id = '$mp_kill_id'";
        $check_kill_id = $db->query($req_check_kill_id)->fetch_row()[0];
        if ( $check_kill_id > 0 ) { $mp_kill_id++; }

        $req_mp_kill = "INSERT IGNORE INTO `Kills`
                        VALUES ('$mp_kill_id', '', '$mob_id', '', '000', 'Gobland-IT', 'Gobland-IT ($mob_id)', 'débarrassé');";
        $res_mp_kill = $db->query($req_mp_kill); 
    }

    $req_cdm_ids    = "SELECT IdMob,Name
                       FROM CdM 
                       GROUP BY IdMob
                       ORDER BY MAX(Date) 
                       DESC LIMIT 50;";
    $query_cdm_ids = $db->query($req_cdm_ids);

    while ($cdm_ids = $query_cdm_ids->fetch_array())
    {
        $mob_id     = $cdm_ids[0];
        $mob_date;
        $mob_name   = $cdm_ids[1];
        $mob_niv;
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

        $req_cdm    = "SELECT * FROM CdM WHERE IdMob = '$cdm_ids[0]' ORDER BY Date ASC;";
        $query_cdm  = $db->query($req_cdm);

        $update     = 0; # To count how many CdM we have of each IdMonstre
        while ($cdm = $query_cdm->fetch_array())
        {
            $mob_date  = $cdm[1];
            $mob_type  = $cdm[4];
            $mob_niv   = $cdm[5];
            $mob_bless = $cdm[8];

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

            $update++;
        }

        $color       = GetColor(100-$mob_bless,100);
        $lifebar     = '<br><div class="vieContainer"><div style="background-color:'.$color.'; width: '.(100-$mob_bless).'%"></div></div>';
        $bless       = $mob_bless.'%'.$lifebar;
        $baratin_png = '';

        $req_kill    = "SELECT COUNT(*)
                        FROM `Kills`
                        WHERE ( PMSubject LIKE '%$mob_id%' AND PMText LIKE '%débarrassé%' )
                        OR ( PMSubject = 'Résultat Potion' AND PMText LIKE '%$mob_id%Son cadavre%')";
        $kill        = $db->query($req_kill)->fetch_row()[0];

        if ( $kill >= 1 )
        {
            # The mob is dead, print a skull emoji
            $req_kill_id   = "SELECT IdGob,NomGob,Date
                              FROM `Kills`
                              WHERE ( PMSubject LIKE '%$mob_id%' AND PMText LIKE '%débarrassé%' )
                              OR ( PMSubject = 'Résultat Potion' AND PMText LIKE '%$mob_id%Son cadavre%')
                              LIMIT 1";
            $kill_id       = $db->query($req_kill_id, true)->fetch_row();
            $kill_title    = 'Tueur: '.$kill_id['1'].' ('.$kill_id['0'].') Date: '.$kill_id['2'];
            $bless         = '<font size="3,5" title="'.$kill_title.'">☠️</font>';
        }
        else
        {
            # If the mob not dead, let's look if he has some Malus
            $today = date('Y-m-d');
            # Date restriction, to work only on fresh mobs
            if ( preg_match("/^$today/",$mob_date) )
            {
                # Check if a Baratin is still active
                $req_baratin    = "SELECT IdGob,PMSubject,PMDate,PMText
                                   FROM `MPBot`
                                   WHERE PMSubject = \"Résultat Baratin - $mob_name ($mob_id)\"
                                   AND   PMDate LIKE '$today%'
                                   LIMIT 1;";
                $arr_baratin    = $db->query($req_baratin, true)->fetch_row()[0];
                if ( $arr_baratin )
                {
                    $baratin_gob  = $arr_baratin['IdGob'];

                    $req_gob_name = "SELECT Gobelin FROM Gobelins WHERE Id = '$baratin_gob'";
                    $baratin_name = $db->query($req_gob_name)->fetch_row()[0];

                    $baratin_date = $arr_baratin['PMDate'];
                    $png_title    = 'Baratineur: '.$baratin_name.' ('.$baratin_gob.') Date: '.$baratin_date;
                    $baratin_png  = '<font size="3,5" title="'.$png_title.'">🌀</font>';

                    # Here we check if the mob played AFTER the Baratin, making it useless
                    $baratin_time     = strtotime(date($baratin_date));
                    $baratin_time_max = $baratin_time + ( 2 * 60 * 60 );
                    $now              = time();
                    if ( $now > $baratin_time_max ) { $baratin_png = ''; }
                }
            }
            else { $baratin_png = ''; }
        }

        print('          <tr>'."\n");
        print('            <td>'.$cdm_ids[0].'</td>'."\n");
        print('            <td>'.$mob_name.$baratin_png.'</td>'."\n");
        print('            <td>'.$mob_niv.'</td>'."\n");
        print('            <td style="height: 25px">'.$bless.'</td>'."\n");
        print('            <td>'.$mob_pv_min.'-'.$mob_pv_max.'</td>'."\n");
        print('            <td>'.$mob_att_min.'-'.$mob_att_max.'</td>'."\n");
        print('            <td>'.$mob_esq_min.'-'.$mob_esq_max.'</td>'."\n");
        print('            <td>'.$mob_deg_min.'-'.$mob_deg_max.'</td>'."\n");
        print('            <td>'.$mob_reg_min.'-'.$mob_reg_max.'</td>'."\n");
        print('            <td>'.$mob_arm_min.'-'.$mob_arm_max.'</td>'."\n");
        print('            <td>'.$mob_per_min.'-'.$mob_per_max.'</td>'."\n");
        print('            <td>'.$mob_date.' (<b>'.$update.'</b>)</td>'."\n");
        print('            <td><a href="/cdm.php?kill='.$cdm_ids[0].'" title="Kill monstre">[🚫]</a></td>'."\n");
        print('          </tr>'."\n");
    }

    print('      </tbody>'."\n");
    print('        </table>'."\n");

    $db->close;
?>
        <script type="text/javascript" src="/js/tristen-tablesort.js"></script>
        <script type="text/javascript" src="/js/tristen-tablesort.number.js"></script>
        <script>new Tablesort(document.getElementById('cdm'));</script>
      </div> <!-- content -->
    </div> <!-- page -->
  </body>
</html>
