<?php

function GetColor($pv_now,$pv_max)
{
    $green  = '#77EE77';
    $jaune  = '#EEEE77';
    $orange = '#EEAA77';
    $red    = '#B22222';

    $color  = '#FFFFFF';
    $percent = 100 * ($pv_now / $pv_max);

    if    ( $percent > 75 )
    {
        $color = $green;
    }
    elseif ( $percent > 50 )
    {
        $color = $jaune;
    }
    elseif ( $percent > 25 )
    {
        $color = $orange;
    }
    else
    {
        $color = $red;
    }
    return $color;
}

function GetpDLA($dla_str,$duree_s)
{
    # $dla_str = 2019-01-30 19:40:16

    $dla  = strtotime(date($dla_str));
    $pdla = date("Y-m-d H:i:s", ($dla + $duree_s));

    return $pdla;
}

?>
