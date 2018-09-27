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
                $MEMBRES{$line[0]}{'PX'}     = $line[13];
                $MEMBRES{$line[0]}{'PXPerso'}= $line[14];
                $MEMBRES{$line[0]}{'PI'}     = $line[15];
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
            #"MM";"BMM";"BPMM";"BMMM";"RM";"BRM";"BPRM";"BMRM";
            #"MT";"BMT";"BPMT";"BMMT";"RT";"BRT";"BPRT";"BMRT";
            #"MR";"BMR";"BPMR";"BMMR";"RR";"BRR";"BPRR";"BMRR";
            #"MS";"BMS";"BPMS";"BMMS";"RS";"BRS";"BPRS";"BMRS";
            #"MC";"BMC";"BPMC";"BMMC";"RC";"BRC";"BPRC";"BMRC";
            #"MP";"BMP";"BPMP";"BMMP";"RP";"BRP";"BPRP";"BMRP"
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

                $MEMBRES{$line[0]}{'MM'}{'MM'}= $line[27];
                $MEMBRES{$line[0]}{'MM'}{'B'} = $line[28];
                $MEMBRES{$line[0]}{'MM'}{'BP'}= $line[29];
                $MEMBRES{$line[0]}{'MM'}{'BM'}= $line[30];
                $MEMBRES{$line[0]}{'RM'}{'RM'}= $line[31];
                $MEMBRES{$line[0]}{'RM'}{'B'} = $line[32];
                $MEMBRES{$line[0]}{'RM'}{'BP'}= $line[33];
                $MEMBRES{$line[0]}{'RM'}{'BM'}= $line[34];

                $MEMBRES{$line[0]}{'MT'}{'MT'}= $line[35];
                $MEMBRES{$line[0]}{'MT'}{'B'} = $line[36];
                $MEMBRES{$line[0]}{'MT'}{'BP'}= $line[37];
                $MEMBRES{$line[0]}{'MT'}{'BM'}= $line[38];
                $MEMBRES{$line[0]}{'RT'}{'RT'}= $line[39];
                $MEMBRES{$line[0]}{'RT'}{'B'} = $line[40];
                $MEMBRES{$line[0]}{'RT'}{'BP'}= $line[41];
                $MEMBRES{$line[0]}{'RT'}{'BM'}= $line[42];

                $MEMBRES{$line[0]}{'MR'}{'MR'}= $line[43];
                $MEMBRES{$line[0]}{'MR'}{'B'} = $line[44];
                $MEMBRES{$line[0]}{'MR'}{'BP'}= $line[45];
                $MEMBRES{$line[0]}{'MR'}{'BM'}= $line[46];
                $MEMBRES{$line[0]}{'RR'}{'RR'}= $line[47];
                $MEMBRES{$line[0]}{'RR'}{'B'} = $line[48];
                $MEMBRES{$line[0]}{'RR'}{'BP'}= $line[49];
                $MEMBRES{$line[0]}{'RR'}{'BM'}= $line[50];

                $MEMBRES{$line[0]}{'MS'}{'MS'}= $line[51];
                $MEMBRES{$line[0]}{'MS'}{'B'} = $line[52];
                $MEMBRES{$line[0]}{'MS'}{'BP'}= $line[53];
                $MEMBRES{$line[0]}{'MS'}{'BM'}= $line[54];
                $MEMBRES{$line[0]}{'RS'}{'RS'}= $line[55];
                $MEMBRES{$line[0]}{'RS'}{'B'} = $line[56];
                $MEMBRES{$line[0]}{'RS'}{'BP'}= $line[57];
                $MEMBRES{$line[0]}{'RS'}{'BM'}= $line[58];

                $MEMBRES{$line[0]}{'MC'}{'MC'}= $line[59];
                $MEMBRES{$line[0]}{'MC'}{'B'} = $line[60];
                $MEMBRES{$line[0]}{'MC'}{'BP'}= $line[61];
                $MEMBRES{$line[0]}{'MC'}{'BM'}= $line[62];
                $MEMBRES{$line[0]}{'RC'}{'RC'}= $line[63];
                $MEMBRES{$line[0]}{'RC'}{'B'} = $line[64];
                $MEMBRES{$line[0]}{'RC'}{'BP'}= $line[65];
                $MEMBRES{$line[0]}{'RC'}{'BM'}= $line[66];

                $MEMBRES{$line[0]}{'MP'}{'MP'}= $line[67];
                $MEMBRES{$line[0]}{'MP'}{'B'} = $line[68];
                $MEMBRES{$line[0]}{'MP'}{'BP'}= $line[69];
                $MEMBRES{$line[0]}{'MP'}{'BM'}= $line[70];
                $MEMBRES{$line[0]}{'RP'}{'RP'}= $line[71];
                $MEMBRES{$line[0]}{'RP'}{'B'} = $line[72];
                $MEMBRES{$line[0]}{'RP'}{'BP'}= $line[73];
                $MEMBRES{$line[0]}{'RP'}{'BM'}= $line[74];
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

sub getVue
{
    my $glfile = shift;
    my $gob_id = shift;
    my $glyaml = YAML::Tiny->read( $glfile );
    my %VUE;

    my $browser = new LWP::UserAgent;
    my $request = new HTTP::Request( GET => "http://ie.gobland.fr/IE_Vue.php?id=$gob_id&passwd=$glyaml->[0]->{clan}{$gob_id}" );
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
            #"Categorie";"Dist";"Id";"Nom";"Niveau";"Type";"Clan";"X";"Y";"N";"Z"
            $line =~ s/"//g;
            my @line = split /;/, $line;
            if ( $line !~ /^#/)
            {
                if ( ($line[0] eq 'C') and ($line[5] =~ /Musculeux|Nodef|Trad|Yonnair|Zozo|Mentalo|Gobelin/) )
                {
                    $VUE{'G'}{$line[2]}{'Dist'}   = $line[1];
                    $VUE{'G'}{$line[2]}{'Nom'}    = $line[3];
                    $VUE{'G'}{$line[2]}{'Niveau'} = $line[4];
                    $VUE{'G'}{$line[2]}{'Type'}   = $line[5];
                    $VUE{'G'}{$line[2]}{'Clan'}   = $line[6];
                    $VUE{'G'}{$line[2]}{'X'}      = $line[7];
                    $VUE{'G'}{$line[2]}{'Y'}      = $line[8];
                    $VUE{'G'}{$line[2]}{'N'}      = $line[9];
                    $VUE{'G'}{$line[2]}{'Z'}      = $line[10];
                }
                else
                {
                    $VUE{$line[0]}{$line[2]}{'Dist'}   = $line[1];
                    $VUE{$line[0]}{$line[2]}{'Nom'}    = $line[3];
                    $VUE{$line[0]}{$line[2]}{'Niveau'} = $line[4];
                    $VUE{$line[0]}{$line[2]}{'Type'}   = $line[5];
                    $VUE{$line[0]}{$line[2]}{'Clan'}   = $line[6];
                    $VUE{$line[0]}{$line[2]}{'X'}      = $line[7];
                    $VUE{$line[0]}{$line[2]}{'Y'}      = $line[8];
                    $VUE{$line[0]}{$line[2]}{'N'}      = $line[9];
                    $VUE{$line[0]}{$line[2]}{'Z'}      = $line[10];
                }
            }
        }
        return \%VUE;
    }
}

sub getClanCafards
{
    my $glfile = shift;
    my $glyaml = YAML::Tiny->read( $glfile );
    my %CAFARDS;

    my $browser = new LWP::UserAgent;
    my $request = new HTTP::Request( GET => "http://ie.gobland.fr/IE_ClanCafards?id=$glyaml->[0]{gl_user}&passwd=$glyaml->[0]{gl_api_key}" );
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
            #"IdGob";"IdCafard";"Nom";"Effet";"Type";"Apparition";"Etat"
            $line =~ s/"//g;
            my @line = split /;/, $line;
            if ( $line !~ /^#/ )
            {
                $CAFARDS{$line[0]}{$line[1]}{'Nom'}        = Encode::decode_utf8($line[2]);
                $CAFARDS{$line[0]}{$line[1]}{'Effet'}      = $line[3];
                $CAFARDS{$line[0]}{$line[1]}{'Type'}       = Encode::decode_utf8($line[4]);
                $CAFARDS{$line[0]}{$line[1]}{'Apparition'} = $line[5];
                $CAFARDS{$line[0]}{$line[1]}{'Etat'}       = $line[6];
                if ( $line[6] eq 'Actif' )
                {
                    $CAFARDS{$line[0]}{$line[1]}{'PNG'}    = '<img src="/images/bug/bug-icon.png">';
                } else
                {
                    $CAFARDS{$line[0]}{$line[1]}{'PNG'}    = '<img src="/images/bug/bug-error-icon.png">';
                }
            }
        }
        return \%CAFARDS;
    }
}

sub getMeuteMembres
{
    my $glfile = shift;
    my $gob_id = shift;
    my $glyaml = YAML::Tiny->read( $glfile );
    my %MEUTE;

    if ( $glyaml->[0]->{meute}{$gob_id} )
    {
        my $browser = new LWP::UserAgent;
        my $request = new HTTP::Request( GET => "http://ie.gobland.fr/IE_MeuteMembres.php?id=$gob_id&passwd=$glyaml->[0]->{meute}{$gob_id}" );
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
                #"IdMeute";"NomMeute";"Id";"Nom";"Race";"Tribu";"Niveau";"X";"Y";"N";"Z";"DLA";"Etat";"PA";"PV";"PX";"PXPerso";"PI";"CT";"CARAC"
                $line =~ s/"//g;
                my @line = split /;/, $line;
                if ( $line !~ /^#/)
                {
                    $MEUTE{$gob_id}{'IdMeute'}                              = $line[0];
                    $MEUTE{$gob_id}{'NomMeute'}                             = $line[1];
                    $MEUTE{$gob_id}{'MembersMeute'}{$line[2]}{'Nom'}        = Encode::decode_utf8($line[3]);
                    $MEUTE{$gob_id}{'MembersMeute'}{$line[2]}{'Tribu'}      = $line[5];
                    $MEUTE{$gob_id}{'MembersMeute'}{$line[2]}{'Niveau'}     = $line[6];
                }
            }
        }
    }
    return \%MEUTE;
}

sub getClanCavernes
{
    my $glfile = shift;
    my $glyaml = YAML::Tiny->read( $glfile );
    my %INVENTAIRE;

    my $browser = new LWP::UserAgent;
    my $request = new HTTP::Request( GET => "http://ie.gobland.fr/IE_ClanCavernes?id=$glyaml->[0]{gl_user}&passwd=$glyaml->[0]{gl_api_key}" );
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
            #"Id";"Type";"Identifie";"Nom";"Magie";"Desc";"Poids";"Taille";"Qualite";"Localisation";"Prix";"Reservation";"Matiere"
            $line =~ s/"//g;
            my @line = split /;/, $line;
            if ( $line !~ /^#/ )
            {
                my $equipe = 'NonEquipe';
                my $caverne = Encode::decode_utf8($line[9]);
                my $desc   = Encode::decode_utf8('<b>Non identifi..</b>');
                if ( $line[2] eq 'VRAI' )  { $desc = Encode::decode_utf8($line[5]) }
                $INVENTAIRE{$caverne}{$equipe}{$line[1]}{$line[0]}{'Id'}           = $line[0];
                $INVENTAIRE{$caverne}{$equipe}{$line[1]}{$line[0]}{'Type'}         = Encode::decode_utf8($line[1]);
                $INVENTAIRE{$caverne}{$equipe}{$line[1]}{$line[0]}{'Identifie'}    = $line[2];
                $INVENTAIRE{$caverne}{$equipe}{$line[1]}{$line[0]}{'Nom'}          = Encode::decode_utf8($line[3]);
                $INVENTAIRE{$caverne}{$equipe}{$line[1]}{$line[0]}{'Magie'}        = $line[4];
                $INVENTAIRE{$caverne}{$equipe}{$line[1]}{$line[0]}{'Desc'}         = $desc;
                $INVENTAIRE{$caverne}{$equipe}{$line[1]}{$line[0]}{'Poids'}        = $line[6];
                $INVENTAIRE{$caverne}{$equipe}{$line[1]}{$line[0]}{'Taille'}       = $line[7];
                $INVENTAIRE{$caverne}{$equipe}{$line[1]}{$line[0]}{'Qualite'}      = $line[8];
                $INVENTAIRE{$caverne}{$equipe}{$line[1]}{$line[0]}{'Localisation'} = $caverne;
                $INVENTAIRE{$caverne}{$equipe}{$line[1]}{$line[0]}{'Utilise'}      = 'FAUX';
                $INVENTAIRE{$caverne}{$equipe}{$line[1]}{$line[0]}{'Prix'}         = $line[10];
                $INVENTAIRE{$caverne}{$equipe}{$line[1]}{$line[0]}{'Reservation'}  = $line[11];
                $INVENTAIRE{$caverne}{$equipe}{$line[1]}{$line[0]}{'Matiere'}      = $line[12];
            }
        }
        return \%INVENTAIRE;
    }
}

1;
