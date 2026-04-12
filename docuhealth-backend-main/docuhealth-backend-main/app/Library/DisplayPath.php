<?php

namespace App\Library;

class DisplayPath {

    public static function user_display_image()
    {
        return url('app/users/display-picture').'/';
    }

    public static function subadmin_display_image()
    {
        return url('app/subadmin/display-picture').'/';
    }

    public static function banner($path = '')
    {
        return url('app/banners')."/$path";
    }

    public static function category_icon($path = '')
    {
        return url('app/category-icon')."/$path";
    }

    public static function specialization_icon($path = '')
    {
        return url('app/specialization-icon')."/$path";
    }

    public static function user_profile_default_icon()
    {
        return url('app-assets/images/icon/user.png');
    }

    public static function doctor_default_icon()
    {
        return url('app-assets/images/icon/doctor.png');
    }

    public static function lab_default_icon()
    {
        return url('app-assets/images/icon/diagnosis.png');
    }

    public static function hospital_default_icon()
    {
        return url('app-assets/images/icon/hospital.png');
    }

    public static function user_profile_icon($path = '')
    {
        if ($path !== '') {
            return url('app/images/icon').'/'.$path;
        }
        return url('app/images/icon');
    }

    public static function measurement_attachment($path = '')
    {
        if ($path !== '') {
            return url('app')."/$path/measurement-attachment";
        }
        return url('app/measurement-attachment');
    }

    public static function common_storage($path = '')
    {
        if ($path !== '') {
            return url('app').'/'.$path;
        }
        return url('app');
    }

    public static function blog_post($path = '')
    {
        if ($path !== '') {
            return url('app/images/blog').'/'.$path;
        }
        return url('app/images/blog');
    }

    public static function no_image()
    {
        return url('app-assets/images/icon/no-image-icon.png');
    }

    public static function reminder_notification()
    {
        return url('app-assets/images/icon/reminder.png');
    }

    public static function pdf_icon()
    {
        return url('app-assets/images/icon/pdf.png');
    }
}

?>