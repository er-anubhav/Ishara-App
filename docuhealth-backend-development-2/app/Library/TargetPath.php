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

    public static function common_storage($path = '')
    {
        if ($path !== '') {
            return public_path('app').'/'.$path;
        }
        return public_path('app');
    }

    public static function user_profile_icon($path = '')
    {
        if ($path !== '') {
            return public_path('app/images/icon').'/'.$path;
        }
        return public_path('app/images/icon');
    }

    public static function blog_post($path = '')
    {
        if ($path !== '') {
            return public_path('app/images/blog').'/'.$path;
        }
        return public_path('app/images/blog');
    }
}

?>