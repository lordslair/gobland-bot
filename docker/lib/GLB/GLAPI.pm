package GLB::GLAPI;
use strict;
use warnings;

use LWP;
use DBI;

my $dbh = DBI->connect(
    "dbi:SQLite:dbname=/home/gobland-bot/gobland.db",
    "",
    "",
    { RaiseError => 1 },
) or die $DBI::errstr;

my $glfile  = $GLB::variables::glfile;
my $glyaml  = $GLB::variables::glyaml;
my @gob_ids = @GLB::variables::gob_ids;

sub GetClanEquipement
{
    print "GLB::GLAPI::GetClanEquipement[";
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
        my @item_ids_live;
        my @item_ids_db;
        my %count;

        foreach my $line (split(/\n/,$response->content))
        {
            chomp ($line);
            #"IdGob";"Id";"Type";"Identifie";"Nom";"Magie";"Desc";"Poids";"Taille";"Qualite";"Utilise";"Matiere"
            $line =~ s/"//g;
            my @line = split /;/, $line;
            if ( $line !~ /^#/ )
            {
                my $description   = Encode::decode_utf8('<b>Non identifié</b>');
                if ( $line[3] eq 'VRAI' ) { $description = $line[6] }
                if ( $line[4] =~ /'/    ) { $line[4]     =~ s/\'/\'\'/g}
                if ( $line[5] =~ /'/    ) { $line[5]     =~ s/\'/\'\'/g}
                if ( $line[8] eq ""     ) { $line[8]     = 1  } # Patch for Empty Baguette size
                if ( $line[9] eq ""     ) { $line[9]     = 0  } # Patch for Empty Baguette quality
                if ( !$line[11]         ) { $line[11]    = '' } # Patch for Empty Matiere

                my $sth  = $dbh->prepare( "INSERT OR REPLACE INTO ItemsGobelins VALUES( '$line[1]',  \
                                                                                        '$line[0]',      \
                                                                                        '$line[2]',  \
                                                                                        '$line[3]',  \
                                                                                        '$line[4]',  \
                                                                                        '$line[5]',  \
                                                                                        '$description',  \
                                                                                        '$line[7]',  \
                                                                                        '$line[8]',  \
                                                                                        '$line[9]',  \
                                                                                        '$line[10]', \
                                                                                        '$line[11]'  ) ");
                $sth->execute();
                $sth->finish();
                push @item_ids_live, $line[1];
            }
        }

        # Find items stored in DB
        my $req_item_ids = $dbh->prepare( "SELECT Id FROM ItemsGobelins;" );
        $req_item_ids->execute();

        while (my $lastline = $req_item_ids->fetchrow_array)
        {
            push @item_ids_db, $lastline;
        }
        $req_item_ids->finish();

        # Find items stored in DB which are no more into live inventory
        for my $item_id (@item_ids_db, @item_ids_live) { $count{$item_id}++ }
        for my $item_id (keys %count)
        {
            if ( $count{$item_id} == 1 )
            {
                print "ItemsGobelinsCleaner:$item_id:$count{$item_id}\n";
                my $sth  = $dbh->prepare( "DELETE FROM ItemsGobelins WHERE Id IS '$item_id'" );
                   $sth->execute();
                   $sth->finish();
            }
        }
    }
    print "]\n";
}

sub GetClanMembres
{
    print "GLB::GLAPI::GetClanMembres[";
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
                my $nom  = Encode::decode_utf8($line[1]);
                my $sth  = $dbh->prepare( "INSERT OR REPLACE INTO Gobelins VALUES( '$line[0]',  \
                                                                                   '$nom',      \
                                                                                   '$line[2]',  \
                                                                                   '$line[3]',  \
                                                                                   '$line[4]',  \
                                                                                   '$line[5]',  \
                                                                                   '$line[6]',  \
                                                                                   '$line[7]',  \
                                                                                   '$line[8]',  \
                                                                                   '$line[9]',  \
                                                                                   '$line[10]', \
                                                                                   '$line[11]', \
                                                                                   '$line[12]', \
                                                                                   '$line[13]', \
                                                                                   '$line[14]', \
                                                                                   '$line[15]', \
                                                                                   '$line[16]'  ) ");
                $sth->execute();
                $sth->finish();
            }
        }
    }
    print "]\n";
}

sub GetClanMembres2
{
    print "GLB::GLAPI::GetClanMembres2[";
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
                my $sth  = $dbh->prepare( "INSERT OR REPLACE INTO Gobelins2 VALUES( '$line[0]',  \
                                                                                    '$line[1]',  \
                                                                                    '$line[2]',  \
                                                                                    '$line[3]',  \
                                                                                    '$line[4]',  \
                                                                                    '$line[5]',  \
                                                                                    '$line[6]',  \
                                                                                    '$line[7]',  \
                                                                                    '$line[8]',  \
                                                                                    '$line[9]',  \
                                                                                    '$line[10]', \
                                                                                    '$line[11]', \
                                                                                    '$line[12]', \
                                                                                    '$line[13]', \
                                                                                    '$line[14]', \
                                                                                    '$line[15]', \
                                                                                    '$line[16]', \
                                                                                    '$line[17]', \
                                                                                    '$line[18]', \
                                                                                    '$line[19]', \
                                                                                    '$line[20]', \
                                                                                    '$line[21]', \
                                                                                    '$line[22]', \
                                                                                    '$line[23]', \
                                                                                    '$line[24]', \
                                                                                    '$line[25]', \
                                                                                    '$line[26]', \
                                                                                    '$line[27]', \
                                                                                    '$line[28]', \
                                                                                    '$line[29]', \
                                                                                    '$line[30]', \
                                                                                    '$line[31]', \
                                                                                    '$line[32]', \
                                                                                    '$line[33]', \
                                                                                    '$line[34]', \
                                                                                    '$line[35]', \
                                                                                    '$line[36]', \
                                                                                    '$line[37]', \
                                                                                    '$line[38]', \
                                                                                    '$line[39]', \
                                                                                    '$line[40]', \
                                                                                    '$line[41]', \
                                                                                    '$line[42]', \
                                                                                    '$line[43]', \
                                                                                    '$line[44]', \
                                                                                    '$line[45]', \
                                                                                    '$line[46]', \
                                                                                    '$line[47]', \
                                                                                    '$line[48]', \
                                                                                    '$line[49]', \
                                                                                    '$line[50]', \
                                                                                    '$line[51]', \
                                                                                    '$line[52]', \
                                                                                    '$line[53]', \
                                                                                    '$line[54]', \
                                                                                    '$line[55]', \
                                                                                    '$line[56]', \
                                                                                    '$line[57]', \
                                                                                    '$line[58]', \
                                                                                    '$line[59]', \
                                                                                    '$line[60]', \
                                                                                    '$line[61]', \
                                                                                    '$line[62]', \
                                                                                    '$line[63]', \
                                                                                    '$line[64]', \
                                                                                    '$line[65]', \
                                                                                    '$line[66]', \
                                                                                    '$line[67]', \
                                                                                    '$line[68]', \
                                                                                    '$line[69]', \
                                                                                    '$line[70]', \
                                                                                    '$line[71]', \
                                                                                    '$line[72]', \
                                                                                    '$line[73]', \
                                                                                    '$line[74]'  ) ");

                $sth->execute();
                $sth->finish();
            }
        }
    }
    print "]\n";
}

sub getClanSkills
{
    print "GLB::GLAPI::GetClanSkills[";
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
                my $sth  = $dbh->prepare( "INSERT OR REPLACE INTO Skills VALUES( '$line[0]-$line[1]-$line[2]', \
                                                                                 '$line[0]', \
                                                                                 '$line[1]', \
                                                                                 '$line[2]', \
                                                                                 '$line[3]', \
                                                                                 '$line[4]',
                                                                                 ''  ) ");
                $sth->execute();
                $sth->finish();
            }
        }
    }
    print "]\n";
}

sub getVue
{
    print "GLB::GLAPI::GetVue[";
    my @vue_ids_db;
    my @vue_ids_live;
    my %count;

    for my $gob_id ( @gob_ids )
    {
        if ( ! $glyaml->[0]->{clan}{$gob_id} ) { next } # If passwd not set for a gob, GOTO next gob

        print '.';
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
                    $line[3]      =~ s/\'/\'\'/g;
                    $line[5]      =~ s/\'/\'\'/g;
                    if ( $line[5] =~ /Musculeux|Nodef|Trad|Yonnair|Zozo|Mentalo|Gobelin/ ) { $line[0] = 'G' }

                    my $sth       = $dbh->prepare( "INSERT OR REPLACE INTO Vue VALUES( '$line[2]', \
                                                                                       '$line[0]', \
                                                                                       '$line[3]', \
                                                                                       '$line[4]', \
                                                                                       '$line[5]', \
                                                                                       '$line[6]', \
                                                                                       '$line[7]', \
                                                                                       '$line[8]', \
                                                                                       '$line[9]', \
                                                                                       '$line[10]'  ) ");
                    $sth->execute();
                    $sth->finish();
                    push @vue_ids_live, $line[2];
                }
            }
        }
    }

    # Find vue ids stored in DB
    my $req_vue_ids = $dbh->prepare( "SELECT Id FROM Vue" );
    $req_vue_ids->execute();

    while (my $lastline = $req_vue_ids->fetchrow_array)
    {
        push @vue_ids_db, $lastline;
    }
    $req_vue_ids->finish();

    # Find items stored in db which are no more into live inventory
    for my $vue_id (@vue_ids_db, @vue_ids_live) { $count{$vue_id}++ }
    for my $vue_id (keys %count)
    {
        if ( $count{$vue_id} == 1 )
        {
            print "VueCleaner:$vue_id:$count{$vue_id}\n";
            my $sth  = $dbh->prepare( "DELETE FROM Vue WHERE Id IS '$vue_id'" );
               $sth->execute();
               $sth->finish();
        }
    }
    print "]\n";
}

sub getClanCafards
{
    print "GLB::GLAPI::GetClanCafards[";
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
                if ( $line[2] =~ /'/    ) { $line[2]     =~ s/\'/\'\'/g}

                my $png = '/images/bug/bug-error-icon.png';
                if ( $line[6] eq 'Actif' ) { $png    = '/images/bug/bug-icon.png' }

                my $sth  = $dbh->prepare( "INSERT OR IGNORE INTO Cafards VALUES( '$line[1]', \
                                                                                 '$line[0]', \
                                                                                 '$line[2]', \
                                                                                 '$line[3]', \
                                                                                 '$line[4]', \
                                                                                 '$line[5]', \
                                                                                 '$line[6]', \
                                                                                 '$png'  )" );

                $sth->execute();
                $sth->finish();
            }
        }
    }
    print "]\n";
}

sub getMeuteMembres
{
    print "GLB::GLAPI::GetMeuteMembres[";
    foreach my $gob_id (@gob_ids)
    {
        print '.';
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
                        my $meute = Encode::decode_utf8($line[1]);
                        my $sth   = $dbh->prepare( "INSERT OR REPLACE INTO Meutes VALUES( '$line[2]', \
                                                                                          '$line[3]', \
                                                                                          '$line[0]', \
                                                                                          '$meute'  )" );
                        $sth->execute();
                        $sth->finish();
                    }
                }
            }
        }
    }
    print "]\n";
}

sub getClanCavernes
{
    print "GLB::GLAPI::GetClanCavernes[";
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
        my @item_ids_db;
        my @item_ids_live;
        my %count;

        foreach my $line (split(/\n/,$response->content))
        {
            chomp ($line);
            #"Id";"Type";"Identifie";"Nom";"Magie";"Desc";"Poids";"Taille";"Qualite";"Localisation";"Prix";"Reservation";"Matiere"
            $line =~ s/"//g;
            my @line = split /;/, $line;
            if ( $line !~ /^#/ )
            {
                my $description   = Encode::decode_utf8('<b>Non identifié</b>');
                if ( $line[2] eq 'VRAI' ) { $description = $line[5] }
                if ( $line[3] =~ /'/    ) { $line[3]     =~ s/\'/\'\'/g}
                if ( $line[4] =~ /'/    ) { $line[4]     =~ s/\'/\'\'/g}
                if ( $line[7] eq ""     ) { $line[7]     = 1  } # Patch for Empty Baguette size
                if ( $line[8] eq ""     ) { $line[8]     = 0  } # Patch for Empty Baguette quality
                if ( $line[9] =~ /'/    ) { $line[9]     =~ s/\'/\'\'/g}
                if ( !$line[12]         ) { $line[12]    = '' } # Patch for Empty Matiere

                my $sth  = $dbh->prepare( "INSERT OR IGNORE INTO ItemsCavernes VALUES( '$line[0]',     \ 
                                                                                       '$line[1]',     \
                                                                                       '$line[2]',     \
                                                                                       '$line[3]',     \
                                                                                       '$line[4]',     \
                                                                                       '$description', \
                                                                                       '$line[6]',     \
                                                                                       '$line[7]',     \
                                                                                       '$line[8]',     \
                                                                                       '$line[9]',     \
                                                                                       'FAUX',         \
                                                                                       '$line[10]',    \
                                                                                       '$line[11]',    \
                                                                                       '$line[12]')"   );
                $sth->execute();
                $sth->finish();
                push @item_ids_live, $line[0];
            }
        }

        # Find items stored in DB
        my $req_item_ids = $dbh->prepare( "SELECT Id FROM ItemsCavernes" );
        $req_item_ids->execute();

        while (my $lastline = $req_item_ids->fetchrow_array)
        {
            push @item_ids_db, $lastline;
        }
        $req_item_ids->finish();

        # Find items stored in db which are no more into live inventory
        for my $item_id (@item_ids_db, @item_ids_live) { $count{$item_id}++ }
        for my $item_id (keys %count)
        {
            if ( $count{$item_id} == 1 )
            {
                print "ItemsCavernesCleaner:$item_id:$count{$item_id}\n";
                my $sth  = $dbh->prepare( "DELETE FROM ItemsCavernes WHERE Id IS '$item_id'" );
                   $sth->execute();
                   $sth->finish();
            }
        }
    }
    print "]\n";
}

sub getMPBot
{
    print "GLB::GLAPI::GetMPBot[";
    foreach my $gob_id (@gob_ids)
    {
        if ( ! $glyaml->[0]->{clan}{$gob_id} ) { next } # If passwd not set for a gob, GOTO next gob

        print '.';
        my $browser = new LWP::UserAgent;
        my $request = new HTTP::Request( GET => "http://ie.gobland.fr/IE_BotMessages.php?id=$gob_id&passwd=$glyaml->[0]->{clan}{$gob_id}" );
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
                #IdPM;PMSubject;PMDate;PMStatus;PMExp;PMText
                $line =~ s/"//g;
                my @line = split /;/, $line;
                if ( $line !~ /^#/)
                {
                    if ( $line[1] =~ /'/    ) { $line[1]     =~ s/\'/\'\'/g};
                    if ( $line[5] =~ /'/    ) { $line[5]     =~ s/\'/\'\'/g}

                    my $sth  = $dbh->prepare( "INSERT OR IGNORE INTO MPBot VALUES( '$line[0]', \
                                                                                   '$gob_id' , \
                                                                                   '$line[1]', \
                                                                                   '$line[2]', \
                                                                                   '$line[3]', \
                                                                                   '$line[4]', \
                                                                                   '$line[5]'  )" );

                    $sth->execute();
                    $sth->finish();
                }
            }
        }
    }  
    print "]\n";
}

1;
