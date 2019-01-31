package GLB::HTML::createProfil;
use strict;
use warnings;

use Time::HiRes qw[gettimeofday tv_interval];

use lib '/home/gobland-bot/lib/';
use GLB::functions;
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
    my @gob_ids = @GLB::variables::gob_ids;

    for my $gob_id ( sort @gob_ids )
    {
        my $t_start  = [gettimeofday()];
        my $dir      = '/var/www/localhost/htdocs/gobelins/';
        my $filename = $dir.$gob_id.'.html';
        unless ( -d $dir ) { mkdir $dir }
        open(my $fh, '>', $filename) or die "Could not open file '$filename' $!";
        binmode($fh, ":utf8");
        print $fh $GLB::variables::begin;

        print $fh ' ' x 6, '<div id="content">'."\n";
        print $fh ' ' x 6, '<link href="/style/tt_r.css"       rel="stylesheet" type="text/css" />'."\n";

        # Caracteristiques
        # Request for Profil info with a JOIN for DLA
        my $req_gob = $dbh->prepare( "SELECT Gobelins.Id,Gobelin,Tribu,Niveau,X,Y,N,PA,PV,PVMax,CT,Gobelins2.DLA,BPDLA,BMDLA,Gobelins.DLA, \
                                             ATT,BPATT,BMATT,  \
                                             ESQ,BPESQ,BMESQ,  \
                                             DEG,BPDEG,BMDEG,  \
                                             REG,BPREG,BMREG,  \
                                             PER,BPPER,BMPER,  \
                                             BPArm,BMArm,      \
                                             PV,PVMax,Faim     \
                                      FROM Gobelins \
                                      INNER JOIN Gobelins2 on Gobelins.Id = Gobelins2.Id \
                                      WHERE Gobelins.Id = $gob_id \
                                      ORDER BY Gobelins.Id" );
        $req_gob->execute();

        my @row = $req_gob->fetchrow_array;
        $req_gob->finish();

        print $fh ' ' x 8, '<h1>Profil de '.$row[1].'</h1>'."\n";
        print $fh ' ' x 8, '<div id="profilInfos">'."\n";

        my $position  = $row[4].', '.$row[5].', '.$row[6];

        my $duree_b   = GLB::functions::GetDureeDLA($row[11]);
        my $duree_p   = GLB::functions::GetDureeDLA($row[12]);
        my $duree_bm  = GLB::functions::GetDureeDLA($row[13]);

        my $duree_s   = $row[11] + $row[12] + $row[13];
        my $duree_t   = GLB::functions::GetDureeDLA($duree_s);

        my $faim_png  = '<img src="/images/stuff/icon_74.png">';
        my $ct_png    = '<img src="/images/stuff/icon_111.png">';

        my $pdla      = GLB::functions::GetpDLA($row[14], $duree_s);

        print $fh ' ' x10, '<fieldset>'."\n";
        print $fh ' ' x12, '<legend>Caracteristiques</legend>'."\n";
        print $fh ' ' x12, '<strong>Tribu</strong> : '.$row[2].'<br/>'."\n";
        print $fh ' ' x12, '<strong>Niveau</strong> : '.$row[4].'<br/>'."\n";
        print $fh ' ' x12, '<strong>Date Limite d\'Action</strong> : '.$row[14].'<br/>'."\n";
        print $fh ' ' x12, '<strong>Position</strong> : '.$position.'<br/>'."\n";
        print $fh ' ' x12, '<br>'."\n";
        print $fh ' ' x12, '<strong>ATT</strong> : '.$row[15].'D '.sprintf("%+d",$row[16]).' '.sprintf("%+d",$row[17]).'<br/>'."\n";
        print $fh ' ' x12, '<strong>ESQ</strong> : '.$row[18].'D '.sprintf("%+d",$row[19]).' '.sprintf("%+d",$row[20]).'<br/>'."\n";
        print $fh ' ' x12, '<strong>DEG</strong> : '.$row[21].'D '.sprintf("%+d",$row[22]).' '.sprintf("%+d",$row[23]).'<br/>'."\n";
        print $fh ' ' x12, '<strong>REG</strong> : '.$row[24].'D '.sprintf("%+d",$row[25]).' '.sprintf("%+d",$row[24]).'<br/>'."\n";
        print $fh ' ' x12, '<strong>PER</strong> : '.$row[27].' ' .sprintf("%+d",$row[28]).' '.sprintf("%+d",$row[29]).'<br/>'."\n";
        print $fh ' ' x12, '<strong>ARM</strong> : '.$row[30].' ' .sprintf("%+d",$row[31]).'<br/>'."\n";
        print $fh ' ' x12, '<strong>PVs</strong> : '.$row[32].' / '.$row[33].'<br/>'."\n";
        print $fh ' ' x12, '<br>'."\n";
        print $fh ' ' x12, '<strong>'.$faim_png.'Faim</strong> : '.$row[34].'<br/>'."\n";
        print $fh ' ' x12, '<br>'."\n";
        print $fh ' ' x12, '<strong>Duree normale du tour</strong> : '.$duree_b.'<br/>'."\n";
        print $fh ' ' x12, '<strong>Bonus / Malus de duree</strong> : '.$duree_bm.'<br/>'."\n";
        print $fh ' ' x12, '<strong>Augmentation due aux blessures</strong> : [A CODER]</span><br/>'."\n";
        print $fh ' ' x12, '<strong>Poids des possessions</strong> : '.$duree_p.'</span><br/>'."\n";
        print $fh ' ' x12, '<strong>Duree totale du tour</strong> : '.$duree_t.'</span><br/>'."\n";
        print $fh ' ' x12, '<strong>Prochaine DLA</strong> : '.$pdla.'</span><br/>'."\n";
        print $fh ' ' x12, '<br>'."\n";
        print $fh ' ' x12, '<strong>'.$ct_png.'Canines de Trolls</strong> : '.$row[10].' CT<br/>'."\n";
        print $fh ' ' x10, '</fieldset>'."\n";

        # Affinites
        # Request for Affinites info with a JOIN for DLA
        my $req_aff = $dbh->prepare( "SELECT MM,BMM, \
                                             RM,BRM, \
                                             MT,BMT, \
                                             RT,BRT, \
                                             MR,BMR, \
                                             RR,BRR, \
                                             MS,BMS, \
                                             RS,BRS, \
                                             MC,BMC, \
                                             RC,BRC, \
                                             MP,BMP, \
                                             RP,BRP  \
                                      FROM Gobelins2 \
                                      WHERE Id = $gob_id" );
        $req_aff->execute();

        my @row_aff = $req_aff->fetchrow_array;
        $req_aff->finish();

        my $style = 'style="border: 0px;float: left;margin: 0px;font-family: courier;font-size: 12px;"';

        print $fh ' ' x10, '<fieldset>'."\n";
        print $fh ' ' x12, '<legend>'.Encode::decode_utf8('Affinités').'</legend>'."\n";
        print $fh ' ' x12, '<table '.$style.'>'."\n";

        my @ecoles    = ('M','T','R','S','C','P');
        my @rms       = ('M','R');
        my $aff_count = 0;

        foreach my $ecole (@ecoles)
        {
            print $fh ' ' x12, '<tr>'."\n";
            foreach my $rm (@rms)
            {
                my $affinite = $rm.$ecole;
                my $sum = $row_aff[$aff_count]+$row_aff[$aff_count+1];
                my $aff = $row_aff[$aff_count];
                my $bon = sprintf("%+d",$row_aff[$aff_count+1]);
                print $fh ' ' x12, '<td style="border: 0px;text-align: left;padding: 1px;font-size: 12px;">'."\n";
                print $fh ' ' x14, '<strong>'.$affinite.'</strong> : '.$sum.' ('.$aff.$bon.')'."\n";
                print $fh ' ' x12, '</td>'."\n";
                $aff_count = $aff_count + 2;
            }
            print $fh ' ' x12, '</tr>'."\n";
        }

        print $fh ' ' x12, '</table>'."\n";
        print $fh ' ' x10, '</fieldset>'."\n";

        # Suivants
        print $fh ' ' x10, '<fieldset>'."\n";
        print $fh ' ' x12, '<legend>Suivants</legend>'."\n";

        my $req_suivants = $dbh->prepare( "SELECT Suivants.Id,Vue.Nom,Vue.Niveau,Vue.X,Vue.Y,Vue.N \
                                           FROM Suivants \
                                           INNER JOIN Vue on Suivants.Id = Vue.Id \
                                           WHERE Suivants.IdGob = '$gob_id' \
                                           ORDER BY Suivants.Id" );
        $req_suivants->execute();
        while (my @row = $req_suivants->fetchrow_array)
        {
            my $suivant_id  = $row[0];
            my $suivant_nom = $row[1];
            my $suivant_niv = $row[2];
            my $X           = $row[3];
            my $Y           = $row[4];
            my $N           = $row[5];
            my $title       = '[ X='.$X.' | Y= '.$Y.' | N= '.$N.' ] '.$suivant_nom;
            my $link        = '<a href="/vue/'.$suivant_id.'.html" title="'.$title.'">'.$suivant_nom.'</a>';

            print $fh ' ' x12, '<li>['.$suivant_id.'] '.$link.' (Niv. '.$suivant_niv.')</li>'."\n";
        }
        $req_suivants->finish();

        print $fh ' ' x10, '</fieldset>'."\n";

        # Cafards
        print $fh ' ' x10, '<fieldset>'."\n";
        print $fh ' ' x12, '<legend>Cafards</legend>'."\n";

        my $req_cafards = $dbh->prepare( "SELECT Id,Type,Effet,PNG \
                                          FROM Cafards \
                                          WHERE Id = '$gob_id'" );
        $req_cafards->execute();
        while (my @row = $req_cafards->fetchrow_array)
        {
            my $c_id    = $row[0];
            my $type    = Encode::decode_utf8($row[1]);
            my $effet   = $row[2];
            my $c_png   = $row[3];

            print $fh ' ' x12, '<li><img src="'.$c_png.'"> ['.$c_id.'] '.$type.' ('.$effet.')</li>'."\n";
        }
        $req_cafards->finish();

        print $fh ' ' x10, '</fieldset>'."\n";

        # Meute
        my %meute       = %GLB::variables::meute;
        my $nom_meute   = '';
        my $id_meute    = '';
        if ( $meute{$gob_id}{'Id'} )
        {
            $id_meute  = $meute{$gob_id}{'Id'};
            $nom_meute = $meute{$gob_id}{'Nom'};

            print $fh ' ' x10, '<fieldset>'."\n";
            print $fh ' ' x12, '<legend>Meute : '.$nom_meute.' ('.$id_meute.')</legend>'."\n";

            my $req_meute_compo = $dbh->prepare( "SELECT Id,Nom,Tribu,Niveau \
                                                  FROM Meutes \
                                                  WHERE IdMeute = '$id_meute'" );

               $req_meute_compo->execute();
            while (my @row = $req_meute_compo->fetchrow_array)
            {
                print $fh ' ' x12, '<li>'.$row[1].' ('.$row[0].') ['.$row[2].'] (lvl '.$row[3].')'."\n";
            }
            $req_meute_compo->finish();
            print $fh ' ' x10, '</fieldset>'."\n";
        }

        # Talents
        print $fh ' ' x10, '<fieldset>'."\n";
        print $fh ' ' x12, '<legend>Talents</legend>'."\n";
        print $fh ' ' x12, '<strong>Competences</strong> :<br/>'."\n";
        print $fh ' ' x12, '<ul>'."\n";

        my $req_skill_c = $dbh->prepare( "SELECT IdGob,Skills.IdSkill,Niveau,Connaissance,NomSkill,Tooltip \
                                          FROM Skills \
                                          INNER JOIN FP_C on Skills.IdSkill = FP_C.IdSkill \
                                          WHERE Skills.Type = 'C' AND Skills.IdGob = '$gob_id'" );
           $req_skill_c->execute();

        while (my @row = $req_skill_c->fetchrow_array)
        {
            my $niveau  = $row[2];
            my $percent = $row[3];
            my $nom     = Encode::decode_utf8($row[4]);
            my $tt      = $row[5];

            if ( $tt )
            {
                $tt = Encode::decode_utf8($tt);
                print $fh ' ' x14, '<li>'."\n";
                print $fh ' ' x16, '<div class="tt_r">'."\n";
                print $fh ' ' x18, $nom.' ('.$percent.' %) [Niv. '.$niveau.']'."\n";
                print $fh ' ' x18, '<span class="tt_r_text">'.$tt.'</span>'."\n";
                print $fh ' ' x16, '</div>'."\n";
                print $fh ' ' x14, '</li>'."\n";
            }
            else
            {
                print $fh ' ' x14, '<li>'.$nom.' ('.$percent.' %) [Niv. '.$niveau.']</li>'."\n";
            }
        }
        $req_skill_c->finish();

        print $fh ' ' x12, '</ul>'."\n";
        print $fh ' ' x12, '<strong>Techniques</strong> :<br/>'."\n";
        print $fh ' ' x12, '<ul>'."\n";

        my $req_skill_t = $dbh->prepare( "SELECT IdGob,Skills.IdSkill,Niveau,Connaissance,NomSkill,Tooltip \
                                          FROM Skills \
                                          INNER JOIN FP_T on Skills.IdSkill = FP_T.IdSkill \
                                          WHERE Skills.Type = 'T' AND Skills.IdGob = '$gob_id'" );
           $req_skill_t->execute();

        while (my @row = $req_skill_t->fetchrow_array)
        {
            my $niveau  = $row[2];
            my $percent = $row[3];
            my $nom     = Encode::decode_utf8($row[4]);
            my $tt      = $row[5];

            if ( $tt )
            {
                $tt = Encode::decode_utf8($tt);
                print $fh ' ' x14, '<li>'."\n";
                print $fh ' ' x16, '<div class="tt_r">'."\n";
                print $fh ' ' x18, $nom.' ('.$percent.' %) [Niv. '.$niveau.']'."\n";
                print $fh ' ' x18, '<span class="tt_r_text">'.$tt.'</span>'."\n";
                print $fh ' ' x16, '</div>'."\n";
                print $fh ' ' x14, '</li>'."\n";
            }
            else
            {
                print $fh ' ' x14, '<li>'.$nom.' ('.$percent.' %) [Niv. '.$niveau.']</li>'."\n";
            }
        }
        $req_skill_t->finish();

        print $fh ' ' x12, '</ul>'."\n";
        print $fh ' ' x10, '</fieldset>'."\n";

        # Equipement
        print $fh ' ' x10, '<fieldset>'."\n";
        print $fh ' ' x12, '<legend>'.Encode::decode_utf8('Equipement Equipé').'</legend>'."\n";

        my $req_stuff_equipe = $dbh->prepare( "SELECT Id,Type,Nom,Magie,Desc,Matiere \
                                               FROM ItemsGobelins \
                                               WHERE Utilise = 'VRAI' AND Gobelin = '$gob_id'" );
           $req_stuff_equipe->execute();
        while (my @row = $req_stuff_equipe->fetchrow_array)
        {
                my $type     = Encode::decode_utf8($row[1]);
                my $nom      = Encode::decode_utf8($row[2]);
                my $item_png = GLB::functions::GetStuffIcon($type, $nom);
                my $desc     = Encode::decode_utf8($row[4]);
                my $template = '';
                   $template = '<b>'.Encode::decode_utf8($row[3]).'</b>' if ( $row[3] );
                my $luxe     = GLB::functions::GetLuxe($type,$nom,$desc);
                my $craft    = GLB::functions::GetCraft($type,$nom,$desc,$template);

                if ( $row[5] ) { $nom .= ' en '.$row[5] } # Fix for 'en Pierre' equipements

                my $item_txt = '['.$row[0].'] '.$type.' : '.$nom.' '.$template.' ('.$desc.')'.$luxe.$craft.'<br>';

                print $fh ' ' x14, $item_png.$item_txt."\n";
        }
        print $fh ' ' x10, '</fieldset>'."\n";

        print $fh ' ' x 8, '</div>'."\n";

        my $t_elapsed = sprintf ("%0.3f", tv_interval($t_start));
        print $fh ' ' x 8, '<div class="footer">[HTML generated in '.$t_elapsed.' sec.] - [Updated @'.localtime.']</div>'."\n";

        print $fh $GLB::variables::end;
        close $fh;
    }
}

1;
