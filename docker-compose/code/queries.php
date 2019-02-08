<?php
    $db_file = '/db/'.$_ENV["DBNAME"];

    $db = new SQLite3($db_file);
    if(!$db) {
        echo $db->lastErrorMsg();
    }

    $arr_gob_ids   = [];
    $req_gob_ids   = "SELECT Id FROM Gobelins;";
    $query_gob_ids = $db->query($req_gob_ids);
    while ($row = $query_gob_ids->fetchArray())
    {
        array_push($arr_gob_ids, $row['Id']);
    }

    $db->close();
?>
