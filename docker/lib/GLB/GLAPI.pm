package GLB::GLAPI;
use strict;
use warnings;

use LWP;
use YAML::Tiny;

sub GetClanEquipement
{
    my $glfile = shift;
    my $glyaml = YAML::Tiny->read( $glfile );
    my %INVENTAIRE;

    my $browser = new LWP::UserAgent;
    my $request = new HTTP::Request( GET => "http://ie.gobland.fr/IE_ClanEquipement?id=$glyaml->[0]{gl_user}&passwd=$glyaml->[0]{gl_api_key}" );
    my $headers = $request->headers();
       $headers->header( 'User-Agent','Mozilla/5.0 (compatible; Konqueror/3.4; Linux) KHTML/3.4.2 (like Gecko)');
       $headers->header( 'Accept', 'text/html, image/jpeg, image/png, text/*, image/*, */*');
       $headers->header( 'Accept-Encoding','x-gzip, x-deflate, gzip, deflate');
       $headers->header( 'Accept-Charset', 'iso-8859-15, utf-8;q=0.5, *;q=0.5');
       $headers->header( 'Accept-Language', 'fr, en');
       $headers->header( 'Referer', 'http://ie.gobland.fr');
    my $response = $browser->request($request);

    if ($response->is_success)
    {
        foreach my $line (split(/\n/,$response->content))
        {
            chomp ($line);
            #"IdGob";"Id";"Type";"Identifie";"Nom";"Magie";"Desc";"Poids";"Taille";"Qualite";"Utilise";"Matiere"
            $line =~ s/"//g;
            my @line = split /;/, $line;
            if ( $line !~ /^#/ )
            {
                my $equipe = 'Equipe';
                if ( $line[10] eq 'FAUX' ) { $equipe = 'NonEquipe' }
                $INVENTAIRE{$line[0]}{$equipe}{$line[1]}{'Type'}      = $line[2];
                $INVENTAIRE{$line[0]}{$equipe}{$line[1]}{'Identifie'} = $line[3];
                $INVENTAIRE{$line[0]}{$equipe}{$line[1]}{'Nom'}       = Encode::decode_utf8($line[4]);
                $INVENTAIRE{$line[0]}{$equipe}{$line[1]}{'Magie'}     = $line[5];
                $INVENTAIRE{$line[0]}{$equipe}{$line[1]}{'Desc'}      = $line[6];
                $INVENTAIRE{$line[0]}{$equipe}{$line[1]}{'Poids'}     = $line[7];
                $INVENTAIRE{$line[0]}{$equipe}{$line[1]}{'Taille'}    = $line[8];
                $INVENTAIRE{$line[0]}{$equipe}{$line[1]}{'Qualite'}   = $line[9];
                $INVENTAIRE{$line[0]}{$equipe}{$line[1]}{'Utilise'}   = $line[10];
                $INVENTAIRE{$line[0]}{$equipe}{$line[1]}{'Matiere'}   = $line[11];
            }
        }
        return \%INVENTAIRE;
    }
}

sub GetClanMembres
{
    my $glfile = shift;
    my $glyaml = YAML::Tiny->read( $glfile );
    my %MEMBRES;

    my $browser = new LWP::UserAgent;
    my $request = new HTTP::Request( GET => "http://ie.gobland.fr/IE_ClanMembres?id=$glyaml->[0]{gl_user}&passwd=$glyaml->[0]{gl_api_key}" );
    my $headers = $request->headers();
       $headers->header( 'User-Agent','Mozilla/5.0 (compatible; Konqueror/3.4; Linux) KHTML/3.4.2 (like Gecko)');
       $headers->header( 'Accept', 'text/html, image/jpeg, image/png, text/*, image/*, */*');
       $headers->header( 'Accept-Encoding','x-gzip, x-deflate, gzip, deflate');
       $headers->header( 'Accept-Charset', 'iso-8859-15, utf-8;q=0.5, *;q=0.5');
       $headers->header( 'Accept-Language', 'fr, en');
       $headers->header( 'Referer', 'http://ie.gobland.fr');
    my $response = $browser->request($request);

    if ($response->is_success)
    {
        foreach my $line (split(/\n/,$response->content))
        {
            chomp ($line);
            #"Id";"Nom";"Race";"Tribu";"Niveau";"X";"Y";"N";"Z";"DLA";"Etat";"PA";"PV";"PX";"PXPerso";"PI";"CT";"CARAC"
            $line =~ s/"//g;
            my @line = split /;/, $line;
            if ( $line !~ /^#/ )
            {
                $MEMBRES{$line[0]}{'Nom'}    = Encode::decode_utf8($line[1]);
                $MEMBRES{$line[0]}{'Race'}   = $line[2];
                $MEMBRES{$line[0]}{'Tribu'}  = $line[3];
                $MEMBRES{$line[0]}{'Niveau'} = $line[4];
                $MEMBRES{$line[0]}{'X'}      = $line[5];
                $MEMBRES{$line[0]}{'Y'}      = $line[6];
                $MEMBRES{$line[0]}{'N'}      = $line[7];
                $MEMBRES{$line[0]}{'Z'}      = $line[8];
                $MEMBRES{$line[0]}{'DLA'}    = $line[9];
                $MEMBRES{$line[0]}{'Etat'}   = $line[10];
                $MEMBRES{$line[0]}{'PA'}     = $line[11];
                $MEMBRES{$line[0]}{'PV'}     = $line[12];
                $MEMBRES{$line[0]}{'CT'}     = $line[16];
            }
        }
        return \%MEMBRES;
    }
}

sub GetClanMembres2
{
    my $glfile = shift;
    my $glyaml = YAML::Tiny->read( $glfile );
    my %MEMBRES;

    my $browser = new LWP::UserAgent;
    my $request = new HTTP::Request( GET => "http://ie.gobland.fr/IE_ClanMembres2?id=$glyaml->[0]{gl_user}&passwd=$glyaml->[0]{gl_api_key}" );
    my $headers = $request->headers();
       $headers->header( 'User-Agent','Mozilla/5.0 (compatible; Konqueror/3.4; Linux) KHTML/3.4.2 (like Gecko)');
       $headers->header( 'Accept', 'text/html, image/jpeg, image/png, text/*, image/*, */*');
       $headers->header( 'Accept-Encoding','x-gzip, x-deflate, gzip, deflate');
       $headers->header( 'Accept-Charset', 'iso-8859-15, utf-8;q=0.5, *;q=0.5');
       $headers->header( 'Accept-Language', 'fr, en');
       $headers->header( 'Referer', 'http://ie.gobland.fr');
    my $response = $browser->request($request);

    if ($response->is_success)
    {
        foreach my $line (split(/\n/,$response->content))
        {
            chomp ($line);
            #"Id";"Nom";"DLA";"BPDLA";"BMDLA";"PVMax";"BPPVMax";"BMPVMax";"ATT";"BPATT";"BMATT";"ESQ";"BPESQ";"BMESQ";"DEG";"BPDEG";"BMDEG";
            #           "REG";"BPREG";"BMREG";"PER";"BPPER";"BMPER";"BPArm";"BMArm";"PITotal";
            #"Faim";
            #"MM";"BMM";"BPMM";"BMMM";"RM";"BRM";"BPRM";"BMRM";"MT";"BMT";"BPMT";"BMMT";"RT";"BRT";"BPRT";"BMRT";
            #"MR";"BMR";"BPMR";"BMMR";"RR";"BRR";"BPRR";"BMRR";"MS";"BMS";"BPMS";"BMMS";"RS";"BRS";"BPRS";"BMRS";
            #"MC";"BMC";"BPMC";"BMMC";"RC";"BRC";"BPRC";"BMRC";"MP";"BMP";"BPMP";"BMMP";"RP";"BRP";"BPRP";"BMRP"
            $line =~ s/"//g;
            my @line = split /;/, $line;
            if ( $line !~ /^#/ )
            {
                $MEMBRES{$line[0]}{'DLA'}     = $line[2];
                $MEMBRES{$line[0]}{'BPDLA'}   = $line[3];
                $MEMBRES{$line[0]}{'BMDLA'}   = $line[4];
                $MEMBRES{$line[0]}{'PVMax'}   = $line[5];
                $MEMBRES{$line[0]}{'ATT'}     = $line[8];
                $MEMBRES{$line[0]}{'BPATT'}   = $line[9];
                $MEMBRES{$line[0]}{'BMATT'}   = $line[10];
                $MEMBRES{$line[0]}{'ESQ'}     = $line[11];
                $MEMBRES{$line[0]}{'BPESQ'}   = $line[12];
                $MEMBRES{$line[0]}{'BMESQ'}   = $line[13];
                $MEMBRES{$line[0]}{'DEG'}     = $line[14];
                $MEMBRES{$line[0]}{'BPDEG'}   = $line[15];
                $MEMBRES{$line[0]}{'BMDEG'}   = $line[16];
                $MEMBRES{$line[0]}{'REG'}     = $line[17];
                $MEMBRES{$line[0]}{'BPREG'}   = $line[18];
                $MEMBRES{$line[0]}{'BMREG'}   = $line[19];
                $MEMBRES{$line[0]}{'PER'}     = $line[20];
                $MEMBRES{$line[0]}{'BPPER'}   = $line[21];
                $MEMBRES{$line[0]}{'BMPER'}   = $line[22];
                $MEMBRES{$line[0]}{'BPArm'}   = $line[23];
                $MEMBRES{$line[0]}{'BMArm'}   = $line[24];
                $MEMBRES{$line[0]}{'PITotal'} = Encode::decode_utf8($line[25]);
                $MEMBRES{$line[0]}{'Faim'}    = $line[26];
            }
        }
        return \%MEMBRES;
    }
}

sub getClanSkills
{
    use lib '/home/gobland-bot/lib/';
    use GLB::functions;

    my $COMPS_ref = GLB::functions::GetComps();
    my %COMPS     = %{$COMPS_ref};
    my $TECHS_ref = GLB::functions::GetTechs();
    my %TECHS     = %{$TECHS_ref};

    my $glfile = '/home/gobland-bot/gl-config.yaml';
    my $glyaml = YAML::Tiny->read( $glfile );
    my %MEMBRES;

    my $browser = new LWP::UserAgent;
    my $request = new HTTP::Request( GET => "http://ie.gobland.fr/IE_ClanTalents.php?id=$glyaml->[0]{gl_user}&passwd=$glyaml->[0]{gl_api_key}" );
    my $headers = $request->headers();
       $headers->header( 'User-Agent','Mozilla/5.0 (compatible; Konqueror/3.4; Linux) KHTML/3.4.2 (like Gecko)');
       $headers->header( 'Accept', 'text/html, image/jpeg, image/png, text/*, image/*, */*');
       $headers->header( 'Accept-Encoding','x-gzip, x-deflate, gzip, deflate');
       $headers->header( 'Accept-Charset', 'iso-8859-15, utf-8;q=0.5, *;q=0.5');
       $headers->header( 'Accept-Language', 'fr, en');
       $headers->header( 'Referer', 'http://ie.gobland.fr');
    my $response = $browser->request($request);

    if ($response->is_success)
    {
        foreach my $line (split(/\n/,$response->content))
        {
            chomp ($line);
            #"Id";"Type";"IdTalent";"Niveau";"Connaissance"
            $line =~ s/"//g;
            my @line = split /;/, $line;
            if ( $line !~ /^#/ )
            {
                $MEMBRES{$line[0]}{'Talents'}{$line[1]}{$line[2]}{'Niveau'}       = $line[3];
                $MEMBRES{$line[0]}{'Talents'}{$line[1]}{$line[2]}{'Connaissance'} = $line[4];
                if ( $line[1] eq 'C' )
                {
                    $MEMBRES{$line[0]}{'Talents'}{$line[1]}{$line[2]}{'Nom'}      = $COMPS{$line[2]}{'Nom'};
                }
                elsif ( $line[1] eq 'T' )
                {
                    $MEMBRES{$line[0]}{'Talents'}{$line[1]}{$line[2]}{'Nom'}      = $TECHS{$line[2]}{'Nom'};
                }
            }
        }
        return \%MEMBRES;
    }
}

1;
