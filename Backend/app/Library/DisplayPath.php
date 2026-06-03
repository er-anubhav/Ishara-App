<?php

namespace App\Library;

use Illuminate\Support\Facades\Storage;

class DisplayPath {

    public static function user_display_image()
    {
        if (config('filesystems.default') === 's3' && config('filesystems.disks.s3.bucket')) {
            return rtrim(Storage::disk('s3')->url('app/users/display-picture'), '/') . '/';
        }
        return url('app/users/display-picture').'/';
    }

    public static function subadmin_display_image()
    {
        return url('app/subadmin/display-picture').'/';
    }

    public static function banner($path = '')
    {
        if (config('filesystems.default') === 's3' && config('filesystems.disks.s3.bucket')) {
            $key = trim("app/banners/" . $path, '/');
            return Storage::disk('s3')->url($key);
        }
        return url('app/banners')."/$path";
    }

    public static function category_icon($path = '')
    {
        if (config('filesystems.default') === 's3' && config('filesystems.disks.s3.bucket')) {
            $key = trim("app/category-icon/" . $path, '/');
            return Storage::disk('s3')->url($key);
        }
        return url('app/category-icon')."/$path";
    }

    public static function specialization_icon($path = '')
    {
        if (config('filesystems.default') === 's3' && config('filesystems.disks.s3.bucket')) {
            $key = trim("app/specialization-icon/" . $path, '/');
            return Storage::disk('s3')->url($key);
        }
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
        if (config('filesystems.default') === 's3' && config('filesystems.disks.s3.bucket')) {
            if ($path !== '') {
                $key = trim("app/images/icon/" . $path, '/');
                return Storage::disk('s3')->url($key);
            }
            return rtrim(Storage::disk('s3')->url('app/images/icon'), '/');
        }
        if ($path !== '') {
            return url('app/images/icon').'/'.$path;
        }
        return url('app/images/icon');
    }

    public static function measurement_attachment($path = '')
    {
        if (config('filesystems.default') === 's3' && config('filesystems.disks.s3.bucket')) {
            if ($path !== '') {
                $key = trim($path . "/measurement-attachment", '/');
                return Storage::disk('s3')->url($key);
            }
            return rtrim(Storage::disk('s3')->url('app/measurement-attachment'), '/');
        }
        if ($path !== '') {
            return url('app')."/$path/measurement-attachment";
        }
        return url('app/measurement-attachment');
    }

    public static function common_storage($path = '')
    {
        if (config('filesystems.default') === 's3' && config('filesystems.disks.s3.bucket')) {
            if ($path !== '') {
                $key = trim("app/" . $path, '/');
                return Storage::disk('s3')->url($key);
            }
            return rtrim(Storage::disk('s3')->url('app'), '/');
        }
        if ($path !== '') {
            return url('app').'/'.$path;
        }
        return url('app');
    }

    public static function blog_post($path = '')
    {
        if (config('filesystems.default') === 's3' && config('filesystems.disks.s3.bucket')) {
            if ($path !== '') {
                $key = trim("app/images/blog/" . $path, '/');
                return Storage::disk('s3')->url($key);
            }
            return rtrim(Storage::disk('s3')->url('app/images/blog'), '/');
        }
        if ($path !== '') {
            return url('app/images/blog').'/'.$path;
        }
        return url('app/images/blog');
    }

    public static function secure_file($fileId)
    {
        return url('api/v1/file/'.$fileId.'/download');
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