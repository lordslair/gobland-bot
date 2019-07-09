<?php
    $db_file = $_ENV["CLANID"];
    $db_host = 'gobland-it-mariadb';
    $db_port = '3306';
    $db_user = 'root';
    $db_pass = $_ENV["MARIADB_ROOT_PASSWORD"];

    $db = new mysqli($db_host, $db_user, $db_pass, $db_file);
    if(!$db) {
        echo $db->lastErrorMsg();
    }

    $db->set_charset("utf8");

    $arr_gob_ids   = [];
    $req_gob_ids   = "SELECT Id FROM Gobelins;";
    $query_gob_ids = $db->query($req_gob_ids);

    while ($row = $query_gob_ids->fetch_array())
    {
        array_push($arr_gob_ids, $row['Id']);
    }

function GetSuivantsActions($gob_id,$suivant_id)
{
    $suivant_actions  = '<div class="tt_r">';
    $suivant_actions .= '<img src="/images/stuff/note.png" width="10" height="10">';

    $tt = '<center><b>Actions recentes</b></center><br>';

    $req_actions = "SELECT Id,PMDate, PMSubject
                    FROM MPBot
                    WHERE IdGob = '$gob_id' AND PMSubject LIKE '%$suivant_id%'
                    ORDER BY Id DESC
                    LIMIT 5;";
    $query_actions = $db->query($req_actions);

    while ($row = $query_actions->fetch_array())
    {
        $row[2] = preg_replace('/Infos Suivant - /','',$row[2]);
        $row[2] = preg_replace('/Résultat /','',$row[2]);
        $row[1] = preg_replace('/:\d\d$/','',$row[1]);

        $tt .= '&nbsp;'.'['.$row[1].'] '.$row[2].'<br>';
    }

    $suivant_actions .= '<span class="tt_r_text_suivant">'.$tt.'</span>';
    $suivant_actions .= '</div>';

    return $suivant_actions;
}

function GetSuivantsAmelios($gob_id,$suivant_id)
{
    $arr_amelios      = [];
    $suivant_amelios  = '<div class="tt_r">';
    $suivant_amelios .= '<img src="/images/stuff/up.png" width="10" height="10">';

    $tt = '<center><b>Coût des Amélios (actuelles)</b></center><br>';

    $req_amelios = "SELECT PMDate,PMText
                    FROM MPBot
                    WHERE PMSubject LIKE '%$suivant_id%Entrainement%'
                    ORDER BY PMDate";
    $query_amelios = $db->query($req_amelios);

    while ($row = $query_amelios->fetch_array())
    {
        if ( preg_match('/(\w*) (\d*) PI$/', $row[1], $arr_matches ) )
        {
            $arr_amelios[$arr_matches[1]] = $arr_matches[2];
        }
    }

    ksort($arr_amelios);
    foreach ( $arr_amelios as $carac => $pi )
    {
        $tt .= $carac.' : '.$pi.'PI'.'<br>';
    }

    $suivant_amelios .= '<span class="tt_r_text_suivant">'.$tt.'</span>';
    $suivant_amelios .= '</div>';

    return $suivant_amelios;
}

?>
