<?php

namespace App\Library;

class DisplayPath {

    public static function user_display_image()
    {
        return url('public/app/users/display-picture').'/';
    }

    public static function subadmin_display_image()
    {
        return url('public/app/subadmin/display-picture').'/';
    }

    public static function banner()
    {
        return url('public/app/banners').'/';
    }

    public static function category_icon()
    {
        return url('public/app/category-icon').'/';
    }

    public static function specialization_icon()
    {
        return url('public/app/specialization-icon').'/';
    }
}

?>