package GLB::GLAPI;

use LWP;
use YAML::Tiny;

sub GetClanEquipement
{
    my $glfile = shift;
    my $glyaml = YAML::Tiny->read( $glfile );

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
            if ( $line =~ /^"(\d*)";"(\d*)";"([^"]*)";"(\w*)";"([^"]*)";"(\w*)";"([^"]*)";"(\d*)";"(\d*)";"(\d*)";"(\w*)";"(\w*)"/ )
            {
                if ( $11 eq 'FAUX' ) { $equipe = 'NonEquipe' } else { $equipe = 'Equipe'}
                $INVENTAIRE{$1}{$equipe}{$2}{'Type'}      = $3;
                $INVENTAIRE{$1}{$equipe}{$2}{'Identifie'} = $4;
                $INVENTAIRE{$1}{$equipe}{$2}{'Nom'}       = Encode::decode_utf8($5);
                $INVENTAIRE{$1}{$equipe}{$2}{'Magie'}     = $6;
                $INVENTAIRE{$1}{$equipe}{$2}{'Desc'}      = $7;
                $INVENTAIRE{$1}{$equipe}{$2}{'Poids'}     = $8;
                $INVENTAIRE{$1}{$equipe}{$2}{'Taille'}    = $9;
                $INVENTAIRE{$1}{$equipe}{$2}{'Qualite'}   = $10;
                $INVENTAIRE{$1}{$equipe}{$2}{'Utilise'}   = $11;
                $INVENTAIRE{$1}{$equipe}{$2}{'Matiere'}   = $12;
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
            if ( $line =~ /^"(\d*)";"([^"]*)";"(\w*)";"([^"]*)";"([^"]*)";"([^"]*)";"([^"]*)";"([^"]*)";"([^"]*)";"([^"]*)";"([^"]*)";"([^"]*)";"([^"]*)";"([^"]*)";"([^"]*)";"([^"]*)";"([^"]*)"/ )
            {
                $MEMBRES{$1}{'Nom'}   = Encode::decode_utf8($2);
                $MEMBRES{$1}{'Race'}  = $3;
                $MEMBRES{$1}{'Tribu'} = $4;
                $MEMBRES{$1}{'Niveau'} = $5;
                $MEMBRES{$1}{'X'} = $6;
                $MEMBRES{$1}{'Y'} = $7;
                $MEMBRES{$1}{'N'} = $8;
                $MEMBRES{$1}{'Z'} = $9;
                $MEMBRES{$1}{'DLA'} = $10;
                $MEMBRES{$1}{'Etat'} = $11;
                $MEMBRES{$1}{'PA'} = $12;
                $MEMBRES{$1}{'PV'} = $13;
                $MEMBRES{$1}{'CT'} = $17;
            }
        }
        return \%MEMBRES;
    }
}

1;
