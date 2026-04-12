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

    public static function banner($path = '')
    {
        return url('app/banners')."/$path";
    }

    public static function category_icon()
    {
        return url('public/app/category-icon').'/';
    }

    public static function specialization_icon()
    {
        return url('public/app/specialization-icon').'/';
    }

    public static function user_profile_default_icon()
    {
        return url('public/app-assets/images/icon/user.png');
    }

    public static function user_profile_icon($path = '')
    {
        if ($path !== '') {
            return url('public/app/images/icon').'/'.$path;
        }
        return url('public/app/images/icon');
    }

    public static function common_storage($path = '')
    {
        if ($path !== '') {
            return url('public/app').'/'.$path;
        }
        return url('public/app');
    }

    public static function blog_post($path = '')
    {
        if ($path !== '') {
            return url('public/app/images/blog').'/'.$path;
        }
        return url('public/app/images/blog');
    }

    public static function no_image()
    {
        return url('public/app-assets/images/icon/no-image-icon.png');
    }
}

?>