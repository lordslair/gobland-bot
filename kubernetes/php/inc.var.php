<?php
    include 'inc.db.php';

    $arr_gob_ids   = [];
    $req_gob_ids   = "SELECT Id FROM Gobelins;";
    $query_gob_ids = $db->query($req_gob_ids);

    while ($row = $query_gob_ids->fetch_array())
    {
        array_push($arr_gob_ids, $row['Id']);
    }

    $db->close;
?>
