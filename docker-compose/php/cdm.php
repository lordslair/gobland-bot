<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
  <head>
<?php
    print ('<title>Gobland-IT ('.$_ENV["CLANID"].') '.$_ENV["CLANNAME"].'</title>');
?>
    <link rel="stylesheet" type="text/css" href="/style/common.css" />
    <link rel="stylesheet" type="text/css" href="/style/menu.css" />
    <script type="text/javascript" src="/js/common.js"></script>
    <script type="text/javascript" src="/js/domcollapse.js"></script>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
  </head>
  <body>
    <div id="page">
      <div id="header">
        <br><br><br><br><br><br><br><br>
        <div id="nav">
          <ul id="menu">
            <li><a href="/index.php" title="Page d'accueil">Accueil</a></li>
            <li><a href="#">Consulter</a>
              <ul>
                <li><a href="/equipements.php" title="Équipement des Gob' du Clan">Équipement du Clan</a></li>
                <li><a href="/materiaux.php" title="Matériaux des Gob' du Clan">Matériaux du Clan</a></li>
                <li><a href="/composants.php" title="Composants des Gob' du Clan">Composants du Clan</a></li>
                <li><a href="/cavernes.php" title="Cavernes du Clan">Cavernes du Clan</a></li>
              </ul>
            </li>
            <li><a href="" title="">Outils</a>
              <ul>
                <li><a href="/pxbank.php" title="PX Bank du Clan">PX Bank</a></li>
                <li><a href="/gps.php" title="GPS">GPS</a></li>
                <li><a href="/radar.php" title="Radar">Radar</a></li>
                <li><a href="/cdm.php" title="CdM">CdM Collector</a></li>
              </ul>
            </li>
            <li><a href="" title="">Liens</a>
              <ul>
                <li><a href="/admin.php" title="Admin">Admin</a></li>
                <li><a href="/locator.php" title="Locator">Locator</a></li>
              </ul>
            </li>
          </ul>
        </div>
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
          </tr>
        </thread>
        <tbody id="cdm">
<?php
    include 'functions.php';

        $db_file = '/db/'.$_ENV["DBNAME"];
        $db      = new SQLite3($db_file);
        if(!$db) { echo $db->lastErrorMsg(); }

        $req_cdm_ids    = "SELECT DISTINCT IdMob,Name FROM CdM ORDER BY Date DESC LIMIT 30;";
        $query_cdm_ids = $db->query($req_cdm_ids);

        while ($cdm_ids = $query_cdm_ids->fetchArray())
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
            while ($cdm = $query_cdm->fetchArray())
            {
                $mob_niv   = $cdm[4];
                $mob_bless = $cdm[7];
                $mob_date  = $cdm[1];

                $mob_pv_min  = max($mob_pv_min ,$cdm[5]);
                $mob_pv_max  = min($mob_pv_max ,$cdm[6]);
                $mob_att_min = max($mob_att_min,$cdm[8]);
                $mob_att_max = min($mob_att_max,$cdm[9]);
                $mob_esq_min = max($mob_esq_min,$cdm[10]);
                $mob_esq_max = min($mob_esq_max,$cdm[11]);
                $mob_deg_min = max($mob_deg_min,$cdm[10]);
                $mob_deg_max = min($mob_deg_max,$cdm[11]);
                $mob_reg_min = max($mob_reg_min,$cdm[10]);
                $mob_reg_max = min($mob_reg_max,$cdm[11]);
                $mob_arm_min = max($mob_arm_min,$cdm[10]);
                $mob_arm_max = min($mob_arm_max,$cdm[11]);
                $mob_per_min = max($mob_per_min,$cdm[10]);
                $mob_per_max = min($mob_per_max,$cdm[11]);

                $update++;
            }

            $color   = GetColor(100-$mob_bless,100);
            $lifebar = '<br><div class="vieContainer"><div style="background-color:'.$color.'; width: '.(100-$mob_bless).'%"></div></div>';

            print('          <tr>'."\n");
            print('            <td>'.$cdm_ids[0].'</td>'."\n");
            print('            <td>'.$mob_name.'</td>'."\n");
            print('            <td>'.$mob_niv.'</td>'."\n");
            print('            <td style="height: 25px">'.$mob_bless.'%'.$lifebar.'</td>'."\n");
            print('            <td>'.$mob_pv_min.'-'.$mob_pv_max.'</td>'."\n");
            print('            <td>'.$mob_att_min.'-'.$mob_att_max.'</td>'."\n");
            print('            <td>'.$mob_esq_min.'-'.$mob_esq_max.'</td>'."\n");
            print('            <td>'.$mob_deg_min.'-'.$mob_deg_max.'</td>'."\n");
            print('            <td>'.$mob_reg_min.'-'.$mob_reg_max.'</td>'."\n");
            print('            <td>'.$mob_arm_min.'-'.$mob_arm_max.'</td>'."\n");
            print('            <td>'.$mob_per_min.'-'.$mob_per_max.'</td>'."\n");
            print('            <td>'.$mob_date.' (<b>'.$update.'</b>)</td>'."\n");
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
