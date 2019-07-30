<?php
// Set sessions sava path (for sharing betwwen replicas)
session_save_path('/code/sessions');
// Initialize the session
session_start();

// Unset all of the session variables
$_SESSION = array();

// Destroy the session.
session_destroy();

// Redirect to login page
header("location: login.php");
exit;
?>
