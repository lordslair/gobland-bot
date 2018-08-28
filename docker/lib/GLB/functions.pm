package GLB::functions;

use warnings;
use strict;

use YAML::Tiny;
my  $yaml      = '/home/gobland-bot/gl-config.yaml';
my  $glyaml    = YAML::Tiny->read( $yaml );
our $clan_name = $glyaml->[0]{gl_clan_name};

our $begin = <<"START_LOOP";
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
    <head>
        <title>#CLAN_NAME#</title>
        <link rel="stylesheet" type="text/css" href="/style/common.css" />
        <link rel="stylesheet" type="text/css" href="/style/menu.css" />
        <link rel="stylesheet" type="text/css" href="/style/equipement.css" />
        <link rel="stylesheet" type="text/css" href="/style/gps.css" />
        <script type="text/javascript" src="/js/common.js"></script>
        <script type="text/javascript" src="/js/domcollapse.js"></script>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
    </head>
    <body>
        <div id="page">
            <div id="header">
                <br><br><br><br><br><br><br><br>
                <div id="nav">
                    <ul id="menu">
                        <li><a href="/index.html" title="Page d'accueil">Accueil</a></li>
                        <li><a href="#">Consulter</a>
                            <ul>
                                <li><a href="/equipement.html" title="Equipement des Gob' du Clan">Equipement du Clan</a></li>
                                <li><a href="/materiaux.html" title="Materiaux des Gob' du Clan">Materiaux du Clan</a></li>
                                <li><a href="/composants.html" title="Composants des Gob' du Clan">Composants du Clan</a></li>
                            </ul>
                       </li>
                        <li><a href="" title="">Outils</a>
                            <ul>
                                <li><a href="/pxbank.html" title="PX Bank du Clan">PX Bank</a></li>
                                <li><a href="/GPS.html" title="GPS">GPS</a></li>
                            </ul>
                        </li>
                        <li><a href="" title="">Liens</a></li>
                    </ul>
                </div>
            </div>
START_LOOP

$begin =~ s/#CLAN_NAME#/$clan_name/;

our $end   = <<"END_LOOP";
            </div>
        </div>
    </body>
</html>
END_LOOP

our $sortscript = <<SORT_SCRIPT;
<script>
function sortTable(n) {
  var table, rows, switching, i, x, y, shouldSwitch, dir, switchcount = 0;
  table = document.getElementById("trollsList");
  switching = true;
  //Set the sorting direction to ascending:
  dir = "asc";
  /*Make a loop that will continue until
  no switching has been done:*/
  while (switching) {
    //start by saying: no switching is done:
    switching = false;
    rows = table.rows;
    /*Loop through all table rows (except the
    first, which contains table headers):*/
    for (i = 1; i < (rows.length - 1); i++) {
      //start by saying there should be no switching:
      shouldSwitch = false;
      /*Get the two elements you want to compare,
      one from current row and one from the next:*/
      x = rows[i].getElementsByTagName("TD")[n];
      y = rows[i + 1].getElementsByTagName("TD")[n];
      /*check if the two rows should switch place,
      based on the direction, asc or desc:*/
      if (dir == "asc") {
        if (Number(x.innerHTML) > Number(y.innerHTML)) {
          shouldSwitch = true;
          break;
        }
      } else if (dir == "desc") {
        if (Number(x.innerHTML) < Number(y.innerHTML)) {
          shouldSwitch = true;
          break;
        }
      }
    }
    if (shouldSwitch) {
      /*If a switch has been marked, make the switch
      and mark that a switch has been done:*/
      rows[i].parentNode.insertBefore(rows[i + 1], rows[i]);
      switching = true;
      //Each time a switch is done, increase this count by 1:
      switchcount ++;
    } else {
      /*If no switching has been done AND the direction is "asc",
      set the direction to "desc" and run the while loop again.*/
      if (switchcount == 0 && dir == "asc") {
        dir = "desc";
        switching = true;
      }
    }
  }
}
</script>
SORT_SCRIPT

sub GetComps
{
    my %SKILLS;
    my $skills_csv = '/home/gobland-bot/data/FP_Skill.csv';
    open (my $fh, '<:encoding(Latin1)', $skills_csv) or die "Could not open file '$skills_csv' $!";
        while (my $row = <$fh>)
        {
            $row =~ s/"//g;
            my @row = split /;/, $row;
            $SKILLS{$row[0]}{'Nom'} = Encode::encode_utf8($row[1]);
        }
    close($fh);
    return \%SKILLS;
}

sub GetTechs
{
    my %TECHS;
    my $techs_csv = '/home/gobland-bot/data/FP_Tech.csv';
    open (my $hf, '<:encoding(UTF-8)', $techs_csv) or die "Could not open file '$techs_csv' $!";
        while (my $row = <$hf>)
        {
            $row =~ s/"//g;
            my @row = split /;/, $row;
            $TECHS{$row[0]}{'Nom'} = Encode::encode_utf8($row[1]);
        }
    close($hf);
    return \%TECHS;
}

sub GetColor
{
    my $pv_now = shift;
    my $pv_max = shift;

    my $green  = '#77EE77';
    my $jaune  = '#EEEE77';
    my $orange = '#EEAA77';
    my $red    = '#B22222';

    my $color  = '#FFFFFF';
    my $percent = 100 * ($pv_now / $pv_max);

    if    ( $percent > 75 )
    {
        $color = $green;
    }
    elsif ( $percent > 50 )
    {
        $color = $jaune;
    }
    elsif ( $percent > 25 )
    {
        $color = $orange;
    }
    else
    {
        $color = $red;
    }
}

sub GetStuffIcon
{
    my $type = shift;
    my $nom  = shift;
    my $png;

    if    ( $type eq 'Armure' )                           { $png = 'icon_04.png' }
    elsif ( $type eq 'Casque' )                           { $png = 'icon_14.png' }
    elsif ( $type eq 'Bottes' )                           { $png = 'icon_24.png' }
    elsif ( $type eq 'Arme 1 Main' and $nom =~ /Hache/ )  { $png = 'icon_52.png' }
    elsif ( $type eq 'Arme 1 Main' )                      { $png = 'icon_47.png' }
    elsif ( $type eq 'Arme 2 mains' and $nom =~ /Hache/ ) { $png = 'icon_56.png' }
    elsif ( $type eq 'Arme 2 mains' )                     { $png = 'icon_45.png' }
    elsif ( $type eq 'Talisman' )                         { $png = 'icon_18.png' }
    elsif ( $type eq 'Anneau' )                           { $png = 'icon_29.png' }
    elsif ( $type eq 'Bouclier' )                         { $png = 'icon_09.png' }
    elsif ( $type eq 'Baguette' )                         { $png = 'icon_61.png' }
    elsif ( $type eq 'Bijou' )                            { $png = 'icon_108.png' }
    else  { $png = '' }

    return $png;
}

sub GetMateriauIcon
{
    my $nom  = shift;
    my $png  = '';

    if    ( $nom eq 'Rondin'         ) { $png = '<img src="/images/stuff/icon_109.png">'  }
    elsif ( $nom eq 'Minerai de Fer' ) { $png = '<img src="/images/stuff/icon_104.png">'  }
    elsif ( $nom eq 'Cuir'           ) { $png = '<img src="/images/stuff/icon_98.png">'   }
    elsif ( $nom eq 'Tissu'          ) { $png = '<img src="/images/stuff/icon_103.png">'  }
    elsif ( $nom eq 'Pierre'         ) { $png = '<img src="/images/stuff/icon_1142.png">' }

    return $png;
}

sub GetDureeDLA
{
    my $sec = shift;
    my @DLA = (($sec/(60*60))%24,($sec/60)%60,$sec%60);
    my $DLA;

    if ( $sec == abs($sec) )
    {
        $DLA = sprintf("%02d",$DLA[0]).'h'.sprintf("%02d",$DLA[1]);
    }
    else
    {
        $DLA = '-'.sprintf("%02d",$DLA[0]).'h'.sprintf("%02d",$DLA[1]);
    }
    return $DLA;
}

sub GetQualite
{
    my $type      = shift;
    my $quali_id  = shift;
    my $quali_str = '';

    my %M_QUALITY;
    $M_QUALITY{'0'} = '';
    $M_QUALITY{'1'} = Encode::decode_utf8('Médiocre');
    $M_QUALITY{'2'} = 'Moyenne';
    $M_QUALITY{'3'} = 'Normale';
    $M_QUALITY{'4'} = 'Bonne';
    $M_QUALITY{'5'} = '<b>Exceptionnelle</b>';

    if ( $type eq 'Matériau' or $type eq 'Minerai' )
    {
        $quali_str = $M_QUALITY{$quali_id};
    }
    return $quali_str;
}

our $vuescript = <<VUE_SCRIPT;
<script>
function showTooltip(evt, text) {
          let tooltip = document.getElementById("tooltip");
          tooltip.innerHTML = text;
          tooltip.style.display = "block";
          tooltip.style.left = evt.pageX + 10 + 'px';
          tooltip.style.top = evt.pageY + 10 + 'px';
}

function hideTooltip() {
          var tooltip = document.getElementById("tooltip");
          tooltip.style.display = "none";
}
</script>
VUE_SCRIPT

1;
