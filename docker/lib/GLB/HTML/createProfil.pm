package GLB::HTML::createProfil;
use strict;
use warnings;

use Time::HiRes qw[gettimeofday tv_interval];

use lib '/home/gobland-bot/lib/';
use GLB::functions;
use GLB::variables;

my $gobs_ref    = $GLB::variables::gobs;
my %gobs        = %{$gobs_ref};
my $gobs2_ref   = $GLB::variables::gobs2;
my %gobs2       = %{$gobs2_ref};
my $stuff_ref   = $GLB::variables::stuff;
my %stuff       = %{$stuff_ref};
my $skill_ref   = $GLB::variables::skill;
my %skill       = %{$skill_ref};
my $cafards_ref = $GLB::variables::cafards;
my %cafards     = %{$cafards_ref};

my $yaml       = '/home/gobland-bot/gl-config.yaml';

sub main
{
    for my $gob_id ( sort keys %gobs )
    {
        my $t_start  = [gettimeofday()];
        my $dir      = '/var/www/localhost/htdocs/gobelins/';
        my $filename = $dir.$gob_id.'.html';
        unless ( -d $dir ) { mkdir $dir }
        open(my $fh, '>', $filename) or die "Could not open file '$filename' $!";
        binmode($fh, ":utf8");
        print $fh $GLB::variables::begin;

        print $fh ' ' x 6, '<div id="content">'."\n";

        my $position = $gobs{$gob_id}{'X'}.', '.$gobs{$gob_id}{'Y'}.', '.$gobs{$gob_id}{'N'};
        my $duree_b  = GLB::functions::GetDureeDLA($gobs2{$gob_id}{'DLA'});
        my $duree_p  = GLB::functions::GetDureeDLA($gobs2{$gob_id}{'BPDLA'});
        my $duree_bm = GLB::functions::GetDureeDLA($gobs2{$gob_id}{'BMDLA'});
        my $duree_s  = $gobs2{$gob_id}{'DLA'} + $gobs2{$gob_id}{'BMDLA'} + $gobs2{$gob_id}{'BPDLA'};
        my $duree_t  = GLB::functions::GetDureeDLA($duree_s);
        my $faim_png  = '<img src="/images/stuff/icon_74.png">';
        my $ct_png    = '<img src="/images/stuff/icon_111.png">';

        print $fh ' ' x 8, '<h1>Profil de '.$gobs{$gob_id}{'Nom'}.'</h1>'."\n";
        print $fh ' ' x 8, '<div id="profilInfos">'."\n";
        print $fh ' ' x10, '<fieldset>'."\n";
        print $fh ' ' x12, '<legend>Caracteristiques</legend>'."\n";
        print $fh ' ' x12, '<strong>Tribu</strong> : '.$gobs{$gob_id}{'Tribu'}.'<br/>'."\n";
        print $fh ' ' x12, '<strong>Niveau</strong> : '.$gobs{$gob_id}{'Niveau'}.'<br/>'."\n";
        print $fh ' ' x12, '<strong>Date Limite d\'Action</strong> : '.$gobs{$gob_id}{'DLA'}.'<br/>'."\n";
        print $fh ' ' x12, '<strong>Position</strong> : '.$position.'<br/>'."\n";
        print $fh ' ' x12, '<br>'."\n";
        print $fh ' ' x12, '<strong>ATT</strong> : '.$gobs2{$gob_id}{'ATT'}.'D '.sprintf("%+d",$gobs2{$gob_id}{'BPATT'}).' '.sprintf("%+d",$gobs2{$gob_id}{'BMATT'}).'<br/>'."\n";
        print $fh ' ' x12, '<strong>ESQ</strong> : '.$gobs2{$gob_id}{'ESQ'}.'D '.sprintf("%+d",$gobs2{$gob_id}{'BPESQ'}).' '.sprintf("%+d",$gobs2{$gob_id}{'BMESQ'}).'<br/>'."\n";
        print $fh ' ' x12, '<strong>DEG</strong> : '.$gobs2{$gob_id}{'DEG'}.'D '.sprintf("%+d",$gobs2{$gob_id}{'BPDEG'}).' '.sprintf("%+d",$gobs2{$gob_id}{'BMDEG'}).'<br/>'."\n";
        print $fh ' ' x12, '<strong>REG</strong> : '.$gobs2{$gob_id}{'REG'}.'D '.sprintf("%+d",$gobs2{$gob_id}{'BPREG'}).' '.sprintf("%+d",$gobs2{$gob_id}{'BMREG'}).'<br/>'."\n";
        print $fh ' ' x12, '<strong>PER</strong> : '.$gobs2{$gob_id}{'PER'}.' '. sprintf("%+d",$gobs2{$gob_id}{'BPPER'}).' '.sprintf("%+d",$gobs2{$gob_id}{'BMPER'}).'<br/>'."\n";
        print $fh ' ' x12, '<strong>ARM</strong> : '.                             $gobs2{$gob_id}{'BPArm'}.' '.sprintf("%+d",$gobs2{$gob_id}{'BMArm'}).'<br/>'."\n";
        print $fh ' ' x12, '<strong>PVs</strong> : '.$gobs{$gob_id}{'PV'}.' / '.$gobs2{$gob_id}{'PVMax'}.'<br/>'."\n";
        print $fh ' ' x12, '<br>'."\n";
        print $fh ' ' x12, '<strong>'.$faim_png.'Faim</strong> : '.$gobs2{$gob_id}{'Faim'}.'<br/>'."\n";
        print $fh ' ' x12, '<br>'."\n";
        print $fh ' ' x12, '<strong>Duree normale du tour</strong> : '.$duree_b.'<br/>'."\n";
        print $fh ' ' x12, '<strong>Bonus / Malus de duree</strong> : '.$duree_bm.'<br/>'."\n";
        print $fh ' ' x12, '<strong>Augmentation due aux blessures</strong> : [A CODER]</span><br/>'."\n";
        print $fh ' ' x12, '<strong>Poids des possessions</strong> : '.$duree_p.'</span><br/>'."\n";
        print $fh ' ' x12, '<strong>Duree totale du tour</strong> : '.$duree_t.'</span><br/>'."\n";
        print $fh ' ' x12, '<strong>Prochaine DLA</strong> : [A CODER]</span><br/>'."\n";
        print $fh ' ' x12, '<br>'."\n";
        print $fh ' ' x12, '<strong>'.$ct_png.'Canines de Trolls</strong> : '.$gobs{$gob_id}{'CT'}.' CT<br/>'."\n";
        print $fh ' ' x10, '</fieldset>'."\n";
        print $fh ' ' x10, '<fieldset>'."\n";
        print $fh ' ' x12, '<legend>'.Encode::decode_utf8('Affinités').'</legend>'."\n";
        my @ecoles    = ('M','T','R','S','C','P');
        my @rms       = ('M','R');
        print $fh ' ' x12, '<table style="border: 0px;float: left;margin: 0px;font-family: courier;font-size: 12px;">'."\n";
        foreach my $ecole (@ecoles)
        {
            print $fh ' ' x12, '<tr>'."\n";
            foreach my $rm (@rms)
            {
                my $affinite = $rm.$ecole;
                my $sum = $gobs2{$gob_id}{$affinite}{$affinite} + $gobs2{$gob_id}{$affinite}{'B'};
                my $aff = $gobs2{$gob_id}{$affinite}{$affinite};
                my $bon = sprintf("%+d",$gobs2{$gob_id}{$affinite}{'B'});
                print $fh ' ' x12, '<td style="border: 0px;text-align: left;padding: 1px;font-size: 12px;">'."\n";
                print $fh ' ' x14, '<strong>'.$affinite.'</strong> : '.$sum.' ('.$aff.$bon.')'."\n";
                print $fh ' ' x12, '</td>'."\n";
            }
            print $fh ' ' x12, '</tr>'."\n";
        }
        print $fh ' ' x12, '</table>'."\n";
        print $fh ' ' x10, '</fieldset>'."\n";
        print $fh ' ' x10, '<fieldset>'."\n";
        print $fh ' ' x12, '<legend>Cafards</legend>'."\n";

        foreach my $c_id ( sort keys %{$cafards{$gob_id}} )
        {
            my $nom     = $cafards{$gob_id}{$c_id}{'Nom'};
            my $type    = $cafards{$gob_id}{$c_id}{'Type'};
            my $effet   = $cafards{$gob_id}{$c_id}{'Effet'};
            my $c_png   = $cafards{$gob_id}{$c_id}{'PNG'};

            print $fh ' ' x12, '<li>'.$c_png.' ['.$c_id.'] '.$type.' ('.$effet.')</li>'."\n";
        }

        print $fh ' ' x10, '</fieldset>'."\n";
        print $fh ' ' x10, '<fieldset>'."\n";
        print $fh ' ' x12, '<legend>Meute</legend>'."\n";

        my $meute_ref   = GLB::GLAPI::getMeuteMembres($yaml,$gob_id);
        my %meute       = %{$meute_ref};

        if ( %meute )
        {
            foreach my $m_id ( sort keys %{$meute{$gob_id}} )
            {
                my $nom     = $meute{$gob_id}{$m_id}{'Nom'};
                my $tribu   = $meute{$gob_id}{$m_id}{'Tribu'};
                my $niveau  = $meute{$gob_id}{$m_id}{'Niveau'};

                print $fh ' ' x12, '<li>'.$nom.' ('.$m_id.') ['.$tribu.'] (lvl '.$niveau.')'."\n";
            }
        }
        else
        {
            print $fh ' ' x12, '<li>No DATA available'."\n";
        }

        print $fh ' ' x10, '</fieldset>'."\n";
        print $fh ' ' x10, '<fieldset>'."\n";
        print $fh ' ' x12, '<legend>Talents</legend>'."\n";
        print $fh ' ' x12, '<strong>Techniques</strong> :<br/>'."\n";
        print $fh ' ' x12, '<ul>'."\n";

        foreach my $t_id ( sort keys %{$skill{$gob_id}{'Talents'}{'T'}} )
        {
            my $nom     = Encode::decode_utf8($skill{$gob_id}{'Talents'}{'T'}{$t_id}{'Nom'});
            my $percent = $skill{$gob_id}{'Talents'}{'T'}{$t_id}{'Connaissance'};
            my $niveau  = $skill{$gob_id}{'Talents'}{'T'}{$t_id}{'Niveau'};
            print $fh ' ' x14, '<li>'.$nom.' ('.$percent.' %) [Niv. '.$niveau.']</li>'."\n";
        }

        print $fh ' ' x12, '</ul>'."\n";
        print $fh ' ' x12, '<strong>Competences</strong> :<br/>'."\n";
        print $fh ' ' x12, '<ul>'."\n";

        foreach my $t_id ( sort keys %{$skill{$gob_id}{'Talents'}{'C'}} )
        {
            my $nom     = Encode::decode_utf8($skill{$gob_id}{'Talents'}{'C'}{$t_id}{'Nom'});
            my $percent = $skill{$gob_id}{'Talents'}{'C'}{$t_id}{'Connaissance'};
            my $niveau  = $skill{$gob_id}{'Talents'}{'C'}{$t_id}{'Niveau'};

            if ( $skill_tt{$gob_id}{'C'}{$t_id}{'tt'} )
            {
                my $tt = $skill_tt{$gob_id}{'C'}{$t_id}{'tt'};
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

        print $fh ' ' x12, '</ul>'."\n";
        print $fh ' ' x10, '</fieldset>'."\n";

        print $fh ' ' x10, '<fieldset>'."\n";
        print $fh ' ' x12, '<legend>'.Encode::decode_utf8('Equipement Equipé').'</legend>'."\n";
        foreach my $e ( sort keys %{$stuff{$gob_id}} )
        {
            if ( $e eq 'Equipe' )
            {
                for my $item_id ( sort keys %{$stuff{$gob_id}{$e}} )
                {
                    my $item_txt = GLB::functions::GetStuff($stuff_ref,$gob_id,$e,$item_id,'short');
                    my $item_png = GLB::functions::GetStuffIcon($stuff_ref,$gob_id,$e,$item_id);

                    print $fh ' ' x14, $item_png.$item_txt."\n";
                }
            }
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
