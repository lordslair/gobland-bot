package GLB::HTML::createCavernes;
use strict;
use warnings;

use Time::HiRes qw[gettimeofday tv_interval];

use lib '/home/gobland-bot/lib/';
use GLB::variables;

use DBI;

my $dbh = DBI->connect(
       "dbi:SQLite:dbname=/home/gobland-bot/gobland.db",
       "",
       "",
       { RaiseError => 1 },
    ) or die $DBI::errstr;

sub main
{
    print "GLB::HTML::createCavernes[";

    my $t_start  = [gettimeofday()];
    my $filename = '/var/www/localhost/htdocs/cavernes.html';
    open(my $fh, '>', $filename) or die "Could not open file '$filename' $!";
    binmode($fh, ":utf8");
    print $fh $GLB::variables::begin;

    print $fh ' ' x 6, '<div id="content">'."\n";
    print $fh ' ' x 6, '<link href="/style/tt_r.css"  rel="stylesheet" type="text/css"  />'."\n";
    print $fh ' ' x 6, '<link href="/style/equipement.css"  rel="stylesheet" type="text/css"  />'."\n";
    print $fh ' ' x 8, '<h1>Possessions</h1>'."\n";

    print $fh ' ' x 8, '<h2 class="expanded">Equipements Gobelins dans les Cavernes</h2>'."\n";
    print $fh ' ' x 8, '<table cellspacing="0" id="profilInfos">'."\n";

    #Equipements
    print $fh ' ' x10, '<tr class="expanded">'."\n";
    print $fh ' ' x12, '<th>Equipements</th>'."\n";
    print $fh ' ' x10, '</tr>'."\n";
    print $fh ' ' x10, '<tr>'."\n";
    print $fh ' ' x12, '<td>'."\n";
    print $fh ' ' x14, '<ul class="membreEquipementList">'."\n";

    foreach my $item_type ('Arme 1 Main', 'Arme 2 mains', 'Anneau', 'Armure', 'Baguette', 'Bijou', 'Bottes', 'Bouclier', 'Casque', 'Nourriture','Outil', 'Potion', 'Talisman')
    {
        print '.';
        my $sth = $dbh->prepare( "SELECT Id,Type,Identifie,Nom,Magie,Desc,Poids,Taille,Qualite,Localisation,Utilise,Prix,Reservation,Matiere \
                                  FROM   ItemsCavernes \
                                  WHERE  Type = '$item_type' \
                                  ORDER  BY Type,Nom;" );
        $sth->execute();

        my $png_done = 'DOING';
        while (my @row = $sth->fetchrow_array)
        {
            my $item_id  = $row[0];
            my $nom      = Encode::decode_utf8($row[3]);
            my $min      = ', '.sprintf("%.1f", $row[6]/60) . ' min';
            my $desc     = Encode::decode_utf8($row[5]);
            my $template = '<b>'.$row[4].'</b>';
            my $luxe     = GLB::functions::GetLuxe($item_type,$nom,$desc);

            if ( $png_done ne 'DONE' )
            {
                $png_done    = 'DONE';
                my $item_png = GLB::functions::GetStuffIcon($item_type,$nom);
                print $fh ' ' x 16,'<div style="text-align:center; type="'.$item_type.'">'."\n";
                print $fh ' ' x 18, '<br>'.$item_png.'<br>'."\n";
                print $fh ' ' x 16,'</div>'."\n";
            }

            my $item_txt = '['.$item_id.'] '.$item_type.' : '.$nom.' '.$template.' ('.$desc.')'.$min.$luxe.'<br>';

            print $fh ' ' x 16, '<li class="equipementNonEquipe">'."\n";
            print $fh ' ' x 18, $item_txt."\n";
            print $fh ' ' x 16, '</li>'."\n";
        }
        $sth->finish();
    }

    print $fh ' ' x14, '</ul>'."\n";
    print $fh ' ' x12, '</td>'."\n";
    print $fh ' ' x10, '</tr>'."\n";

    # Composants
    print $fh ' ' x10, '<tr class="expanded">'."\n";
    print $fh ' ' x12, '<th>Composants</th>'."\n";
    print $fh ' ' x10, '</tr>'."\n";
    print $fh ' ' x10, '<tr>'."\n";
    print $fh ' ' x12, '<td>'."\n";
    print $fh ' ' x14, '<ul class="membreEquipementList">'."\n";

    print '.';

    my $sth = $dbh->prepare( "SELECT Id,Type,Identifie,Nom,Magie,Desc,Poids,Taille,Qualite,Localisation,Utilise,Prix,Reservation,Matiere \
                              FROM   ItemsCavernes \
                              WHERE  Type = 'Composant' \
                              ORDER  BY Type,Nom;" );
    $sth->execute();

    my $item_png = GLB::functions::GetStuffIcon('Composant', '');
    print $fh ' ' x 16,'<div style="text-align:center;">'."\n";
    print $fh ' ' x 18, '<br>'.$item_png.'<br>'."\n";
    print $fh ' ' x 16,'</div>'."\n";

    while (my @row = $sth->fetchrow_array)
    {
        my $item_id  = $row[0];
        my $nom      = Encode::decode_utf8($row[3]);
        my $min      = ', '.sprintf("%.1f", $row[6]/60) . ' min';
        my $desc     = GLB::functions::GetQualite('Composant', $row[8]);

        my $item_txt = '['.$item_id.'] '.$nom.' ('.$desc.')'.$min."\n";

        print $fh ' ' x 16, '<li class="equipementNonEquipe">'."\n";
        print $fh ' ' x 18, $item_txt."\n";
        print $fh ' ' x 16, '</li>'."\n";
    }
    $sth->finish();

    print $fh ' ' x14, '</ul>'."\n";
    print $fh ' ' x12, '</td>'."\n";
    print $fh ' ' x10, '</tr>'."\n";


    # Matériaux
    print $fh ' ' x10, '<tr class="expanded">'."\n";
    print $fh ' ' x12, '<th>Materiaux</th>'."\n";
    print $fh ' ' x10, '</tr>'."\n";
    print $fh ' ' x10, '<tr>'."\n";
    print $fh ' ' x12, '<td>'."\n";
    print $fh ' ' x14, '<ul class="membreEquipementList">'."\n";

    foreach my $item_type ('Minerai', 'Roche', 'Matériau')
    {
        print '.';
        my $sth = $dbh->prepare( "SELECT Id,Type,Identifie,Nom,Magie,Desc,Poids,Taille,Qualite,Localisation,Utilise,Prix,Reservation,Matiere \
                                  FROM   ItemsCavernes \
                                  WHERE  Type = '$item_type' \
                                  ORDER  BY Type,Nom;" );
        $sth->execute();

        my $png_done = 'DOING';
        while (my @row = $sth->fetchrow_array)
        {
            my $item_id = $row[0];
            my $nom     = Encode::decode_utf8($row[3]);
            my $min     = ', '.sprintf("%.1f", $row[6]/60) . ' min';
            my $desc    = GLB::functions::GetQualite($item_type, $row[8]);
            my $nbr     = $row[7];
            my $carats  = GLB::functions::GetCarats($row[8],$nbr);

            if ( $png_done ne 'DONE' )
            {
                $png_done    = 'DONE';
                my $item_png = GLB::functions::GetMateriauIcon($nom);
                print $fh ' ' x 16,'<div style="text-align:center; type="'.$item_type.'">'."\n";
                print $fh ' ' x 18, '<br>'.$item_png.'<br>'."\n";
                print $fh ' ' x 16,'</div>'."\n";
            }

            my $item_txt  = '<div class="tt_r">'."\n";
               $item_txt .= ' ' x 20 . '['.$item_id.'] '.$nom.' de taille '.$nbr.' ('.$desc.')'.$min."\n";
               $item_txt .= ' ' x 20 . '<span class="tt_r_text">'.$carats.' Carats</span>'."\n";
               $item_txt .= ' ' x 18 . '</div>'."\n";

            print $fh ' ' x 16, '<li class="equipementNonEquipe">'."\n";
            print $fh ' ' x 18, $item_txt."\n";
            print $fh ' ' x 16, '</li>'."\n";
        }
        $sth->finish();
    }

    print $fh ' ' x14, '</ul>'."\n";
    print $fh ' ' x12, '</td>'."\n";
    print $fh ' ' x10, '</tr>'."\n";

    print $fh ' ' x 8, '</table>'."\n";

    my $t_elapsed = sprintf ("%0.3f", tv_interval($t_start));
    print $fh ' ' x 8, '<div class="footer">[HTML generated in '.$t_elapsed.' sec.] - [Updated @'.localtime.']</div>'."\n";

    print $fh $GLB::variables::vuescript;
    print $fh $GLB::variables::end;
    close $fh;
    print "]\n";
}

1;
