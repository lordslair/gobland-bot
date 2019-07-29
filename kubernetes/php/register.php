<?php
// Include config file
require_once 'inc.db-global.php';

// Define variables and initialize with empty values
$username = $password = $confirm_password = $clan = "";
$username_err = $password_err = $confirm_password_err = $clan_err = "";

// Processing form data when form is submitted
if($_SERVER["REQUEST_METHOD"] == "POST"){

    // Validate username
    if(empty(trim($_POST["username"]))){
        $username_err = "Entrez le nom de votre Gobelin";
    } else{
        // Prepare a select statement
        $sql = "SELECT account_id FROM users WHERE account_name = ?";

        if($stmt = $db->prepare($sql)){
            // Bind variables to the prepared statement as parameters
            $stmt->bind_param("s", $param_username);

            // Set parameters
            $param_username = trim($_POST["username"]);

            // Attempt to execute the prepared statement
            if($stmt->execute()){
                // store result
                $stmt->store_result();

                if($stmt->num_rows == 1){
                    $username_err = "Ce Gobelin existe déjà. dans une IT";
                } else{
                    $username = trim($_POST["username"]);
                }
            } else{
                echo "Oops! Something went wrong. Please try again later.";
            }
        }

        // Close statement
        $stmt->close();
    }

    // Validate clan
    if(empty(trim($_POST["clan"]))){
        $clan_err = "Merci de préciser le Clan ID";
    } elseif(!is_numeric($_POST["clan"])){
        $clan_err = "Le Clan ID doit être un nombre <br> (et pas '".trim($_POST["clan"])."')";
    } else{
        $clan = trim($_POST["clan"]);
    }

    // Validate password
    if(empty(trim($_POST["password"]))){
        $password_err = "Please enter a password.";
    } elseif(strlen(trim($_POST["password"])) < 6){
        $password_err = "Le mot de passe doit être >6 caractères";
    } else{
        $password = trim($_POST["password"]);
    }

    // Validate confirm password
    if(empty(trim($_POST["confirm_password"]))){
        $confirm_password_err = "Confirmez le mot de passe";
    } else{
        $confirm_password = trim($_POST["confirm_password"]);
        if(empty($password_err) && ($password != $confirm_password)){
            $confirm_password_err = "Mots de passe non-identiques";
        }
    }

    // Check input errors before inserting in database
    if(empty($username_err) && empty($password_err) && empty($confirm_password_err) && empty($clan_err)){

        // Prepare an insert statement
        $sql = "INSERT INTO global.users (account_name, account_password, account_clan, account_enabled) VALUES (?, ?, ?, FALSE)";

        if($stmt = $db->prepare($sql)){
            // Bind variables to the prepared statement as parameters
            $stmt->bind_param("sss", $param_username, $param_password, $param_clan);

            // Set parameters
            $param_username = $username;
            $param_password = password_hash($password, PASSWORD_DEFAULT); // Creates a password hash
            $param_clan     = $clan;

            // Attempt to execute the prepared statement
            if($stmt->execute()){
                // Redirect to login page
                header("location: login.php");
            } else{
                echo "Something went wrong. Please try again later.";
            }
        }

        // Close statement
        $stmt->close();
    }

    // Close connection
    $db->close();
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Inscription Gobland-IT</title>
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.css">
    <style type="text/css">
        /* Works for smartphones */
        @media (min-width: 640px) {
            body { font: 32px sans-serif; }
            .wrapper{ width: 100%; padding: 20px;margin: auto; }
        }
        /* Works for laptops */
        @media (min-width: 1024px) {
            body { font: 16px sans-serif; }
            .wrapper{ width: 350px; padding: 20px;margin: auto; }
        }
    </style>
</head>
<body>
    <div class="wrapper">
        <h2>Inscription</h2>
        <p>Merci de remplir le nom de votre Gobelin, et un mot de passe (différent de Gobland)</p>
        <form action="<?php echo htmlspecialchars($_SERVER["PHP_SELF"]); ?>" method="post">
            <div class="form-group <?php echo (!empty($username_err)) ? 'has-error' : ''; ?>">
                <label>Gobelin</label>
                <input type="text" name="username" class="form-control" value="<?php echo $username; ?>">
                <span class="help-block"><?php echo $username_err; ?></span>
            </div>
            <div class="form-group <?php echo (!empty($clan_err)) ? 'has-error' : ''; ?>">
                <label>Clan ID</label>
                <input type="text" name="clan" class="form-control" value="<?php echo $clan; ?>">
                <span class="help-block"><?php echo $clan_err; ?></span>
            </div>
            <div class="form-group <?php echo (!empty($password_err)) ? 'has-error' : ''; ?>">
                <label>Password</label>
                <input type="password" name="password" class="form-control" value="<?php echo $password; ?>">
                <span class="help-block"><?php echo $password_err; ?></span>
            </div>
            <div class="form-group <?php echo (!empty($confirm_password_err)) ? 'has-error' : ''; ?>">
                <label>Confiration Password</label>
                <input type="password" name="confirm_password" class="form-control" value="<?php echo $confirm_password; ?>">
                <span class="help-block"><?php echo $confirm_password_err; ?></span>
            </div>
            <div class="form-group">
                <input type="submit" class="btn btn-primary" value="Inscription">
                <input type="reset" class="btn btn-default" value="Annuler">
            </div>
            <p>Déjà enregistré ? <a href="login.php">Connexion</a>.</p>
            <p>/!\ L'administrateur validera votre compte.<br>
               Votre accès sera effectif sous 24/48h /!\</p>
        </form>
    </div>
</body>
</html>
