<?php
    $db_file = 'global';
    $db_host = 'gobland-it-mariadb';
    $db_port = '3306';
    $db_user = 'root';
    $db_pass = $_ENV["MARIADB_ROOT_PASSWORD"];

    $db = new mysqli($db_host, $db_user, $db_pass, $db_file);
    if(!$db) {
        echo $db->lastErrorMsg();
    }

    $db->set_charset("utf8");
?>
