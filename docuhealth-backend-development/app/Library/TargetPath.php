<?php

namespace App\Library;

class TargetPath {

    public static function user_display_image()
    {
        return public_path('app/users/display-picture/');
    }

    public static function subadmin_display_image()
    {
        return public_path('app/subadmin/display-picture/');
    }

    public static function banner()
    {
        return public_path('app/banners/');
    }

    public static function category_icon()
    {
        return public_path('app/category-icon');
    }

    public static function specialization_icon()
    {
        return public_path('app/specialization-icon');
    }
}

?>