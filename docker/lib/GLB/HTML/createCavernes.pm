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

    my @equipements = ('Arme 1 Main', 'Arme 2 mains', 'Anneau', 'Armure', 'Baguette', 'Bijou', 'Bottes', 'Bouclier', 'Casque', 'Nourriture', 'Outil', 'Potion', 'Talisman');
    my %count_equipements;

    foreach my $equipement ( sort @equipements )
    {
        print '.';
        my $sth = $dbh->prepare( "SELECT Id,Type,Identifie,Nom,Magie,Desc,Poids,Taille,Qualite,Localisation,Utilise,Prix,Reservation,Matiere \
                                  FROM   ItemsCavernes \
                                  WHERE  Type = '$equipement' \
                                  ORDER  BY Type,Nom;" );
        $sth->execute();

        my $png_done = 'DOING';
        while (my @row = $sth->fetchrow_array)
        {
            my $item_id   = $row[0];
            my $item_type = $row[1];
            my $nom       = Encode::decode_utf8($row[3]);
            my $min       = ', '.sprintf("%.1f", $row[6]/60) . ' min';
            my $desc      = Encode::decode_utf8($row[5]);
            my $template  = '<b>'.$row[4].'</b>';
            my $luxe      = GLB::functions::GetLuxe($item_type,$nom,$desc);

            if ( $row[13] ) { $nom .= ' en '.$row[13] } # Fix for 'en Pierre' equipements

            $count_equipements{$equipement}++;

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

    # Block with count of pieces of equipement
    print $fh ' ' x10, '<tr>'."\n";
    print $fh ' ' x12, '<td>'."\n";
    foreach my $equipement ( sort @equipements )
    {
        $equipement =~ s/''/\'/g;
        if ( $count_equipements{$equipement} )
        {
            my $item_png = GLB::functions::GetStuffIcon($equipement, );
            print $fh ' ' x14, $item_png.' ('.$count_equipements{$equipement}.') '."\n";
        }
    }
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

    my @composants = ('Composant', 'Fleur', 'Racine', 'Champignon');
    my %count_composants;

    foreach my $composant ( sort @composants )
    {
        if ( ! $count_composants{$composant} ) { $count_composants{$composant} = 0 }
        my $sth = $dbh->prepare( "SELECT Id,Type,Identifie,Nom,Magie,Desc,Poids,Taille,Qualite,Localisation,Utilise,Prix,Reservation,Matiere \
                                  FROM   ItemsCavernes \
                                  WHERE  Type = '$composant' \
                                  ORDER  BY Nom;" );
        $sth->execute();

        my $item_png = GLB::functions::GetMateriauIcon($composant);

        print $fh ' ' x 16,'<div style="text-align:center;">'."\n";
        print $fh ' ' x 18, '<br>'.$item_png.'<br>'."\n";
        print $fh ' ' x 16,'</div>'."\n";

        while (my @row = $sth->fetchrow_array)
        {
            my $item_id  = $row[0];
            my $nom      = Encode::decode_utf8($row[3]);
            my $min      = ', '.sprintf("%.1f", $row[6]/60) . ' min';
            my $desc     = GLB::functions::GetQualite('Composant', $row[8]);

            $count_composants{$composant}++;

            my $item_txt = '['.$item_id.'] '.$nom.' ('.$desc.')'.$min."\n";

            print $fh ' ' x 16, '<li class="equipementNonEquipe">'."\n";
            print $fh ' ' x 18, $item_txt."\n";
            print $fh ' ' x 16, '</li>'."\n";
        }
        $sth->finish();
    }

    print $fh ' ' x14, '</ul>'."\n";
    print $fh ' ' x12, '</td>'."\n";
    print $fh ' ' x10, '</tr>'."\n";

    # Block with count of Composants
    print $fh ' ' x10, '<tr>'."\n";
    print $fh ' ' x12, '<td>'."\n";
    foreach my $composant ( sort @composants )
    {
        $composant =~ s/''/\'/g;
        if ( $count_composants{$composant} )
        {
            my $item_png = GLB::functions::GetMateriauIcon($composant);
            print $fh ' ' x14, $item_png.' ('.$count_composants{$composant}.') '."\n";
        }
    }
    print $fh ' ' x12, '</td>'."\n";
    print $fh ' ' x10, '</tr>'."\n";

    # Matériaux
    print $fh ' ' x10, '<tr class="expanded">'."\n";
    print $fh ' ' x12, '<th>'.Encode::decode_utf8('Matériaux').'</th>'."\n";
    print $fh ' ' x10, '</tr>'."\n";
    print $fh ' ' x10, '<tr>'."\n";
    print $fh ' ' x12, '<td>'."\n";
    print $fh ' ' x14, '<ul class="membreEquipementList">'."\n";

    my @minerais  = ('Sable', "Minerai d''Or", 'Minerai de Cuivre', "Minerai d''Argent", "Minerai d''Etain", 'Minerai de Mithril', "Minerai d''Adamantium", 'Minerai de Fer');
    my @materiaux = ('Cuir', 'Tissu', 'Rondin');
    my @roches    = ('Pierre');
    my @items     = (@minerais, @materiaux, @roches);
    my %count;

    foreach my $item ( sort @items )
    {
        print '.';
        my $sth = $dbh->prepare( "SELECT Id,Type,Identifie,Nom,Magie,Desc,Poids,Taille,Qualite,Localisation,Utilise,Prix,Reservation,Matiere \
                                  FROM   ItemsCavernes \
                                  WHERE  Nom = '$item' \
                                  ORDER  BY Nom;" );
        $sth->execute();

        my $png_done = 'DOING';
        while (my @row = $sth->fetchrow_array)
        {
            my $item_id   = $row[0];
            my $item_type = $row[1];
            my $nom       = Encode::decode_utf8($row[3]);
            my $min       = ', '.sprintf("%.1f", $row[6]/60) . ' min';
            my $desc      = GLB::functions::GetQualite($item_type, $row[8]);
            my $nbr       = $row[7];
            my $carats    = GLB::functions::GetCarats($row[8],$nbr);;

            if ( ! $count{$item_type}{$nom} ) { $count{$item_type}{$nom} = 0 }

            if ( $item eq 'Rondin' )
            {
                $count{$item_type}{$nom} = $count{$item_type}{$nom} + $nbr;
            }
            else
            {
                $count{$item_type}{$nom} = $count{$item_type}{$nom} + $carats;
            }

            if ( $png_done ne 'DONE' )
            {
                $png_done    = 'DONE';
                my $item_png = GLB::functions::GetMateriauIcon($nom);
                print $fh ' ' x 16,'<div style="text-align:center; type="'.$nom.'">'."\n";
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

    # Block with count of Carats / materiau
    print $fh ' ' x10, '<tr>'."\n";
    print $fh ' ' x12, '<td>'."\n";

    foreach my $minerai ( sort @minerais )
    {
        $minerai =~ s/''/\'/g;
        if ( $count{'Minerai'}{$minerai} )
        {
            my $item_png = GLB::functions::GetMateriauIcon($minerai);
            print $fh ' ' x14, $item_png.' ('.$count{'Minerai'}{$minerai}.') '."\n";
        }
    }
    print $fh ' ' x14, '<br>'."\n";
    foreach my $materiau ( sort @materiaux )
    {
        if ( $count{'Matériau'}{$materiau} )
        {
            my $item_png = GLB::functions::GetMateriauIcon($materiau);
            print $fh ' ' x14, $item_png.' ('.$count{'Matériau'}{$materiau}.') '."\n";
        }
    }
    print $fh ' ' x14, '<br>'."\n";
    foreach my $roche ( sort @roches )
    {
        if ( $count{'Roche'}{$roche} )
        {
            my $item_png = GLB::functions::GetMateriauIcon($roche);
            print $fh ' ' x14, $item_png.' ('.$count{'Roche'}{$roche}.') '."\n";
        }
    }

    print $fh ' ' x 8, '</table>'."\n";

    my $t_elapsed = sprintf ("%0.3f", tv_interval($t_start));
    print $fh ' ' x 8, '<div class="footer">[HTML generated in '.$t_elapsed.' sec.] - [Updated @'.localtime.']</div>'."\n";

    print $fh $GLB::variables::vuescript;
    print $fh $GLB::variables::end;
    close $fh;
    print "]\n";
}

1;
