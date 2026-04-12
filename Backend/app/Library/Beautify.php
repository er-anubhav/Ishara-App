<?php

namespace App\Library;

use App\Models\User;
use App\Models\Specialization;
use App\Models\Bookmark;
use App\Library\DisplayPath;
use App\Library\FileAndFolder;
use DB;
use Illuminate\Support\Facades\Schema;

class Beautify
{
    use FileAndFolder;

    public function userOBJ($data){

        $data->registered_at = date('d-m-y, H:i A', strtotime($data->created_at));

        //remove all the unnecessary data.
        unset($data->is_active, $data->email_verified_at, $data->created_at, $data->updated_at, $data->profile, $data->profiles);

        return $data;
    }

    public function doctors($data, $type = 'Half'){

        $doctors = [];

        foreach ($data as $key => $value) {
            
            if ($value->role == 'Doctor') {
                $value->icon = DisplayPath::doctor_default_icon();
            }elseif($value->role == 'Lab'){
                $value->icon = DisplayPath::lab_default_icon();
            }else{
                $value->icon = DisplayPath::hospital_default_icon();
            }

            if ($value->degree && $value->degree != 'null') {
                $value->degree = implode(', ', $value->degree);
            }
            if ($value->services && $value->services != 'null') {
                $value->services = implode(', ', $value->services);
            }

            if ($value->specializations && $value->specializations != 'null') {
                $specializations = Specialization::whereIn('id', $value->specializations)->pluck('name')->toArray();
                $value->specializations = implode(', ', $specializations);
            }

            $experience = '0';
            if ($value->experience_years) {
                $experience = $value->experience_years;
            }

            if ($value->experience_months) {
                $experience = $experience.'.'.$value->experience_months;
            }
            $experience =  $value->experience_years > 1 ? $experience.' Years' : $experience.' Year' ;

            $value->experience = $experience;

            if ($type == 'Full') {
                
                if (isset($value->address)) {
                    
                    $addresses = [];
                    $to_day_name = date('l');
                    foreach ($value->address as $address) {
                        
                        if ($address->open_days == 'everyday') {
                            $address->open_days = ['Everyday'];

                            $address->status = strtotime($address->time_to) > strtotime(date('H:i:s')) ? 'Open' : 'Close' ;
                        }else{
                            $open_days = array_map('ucfirst', explode(',', $address->open_days));
                            $address->open_days = $open_days;
                            $address->status = in_array($to_day_name, $open_days) ? (strtotime($address->time_to) > strtotime(date('H:i:s')) ? 'Open' : 'Close') : 'Close' ;
                        }

                        $address->time_from = date('h:iA', strtotime($address->time_from));
                        $address->time_to = date('h:iA', strtotime($address->time_to));
                        
                        unset($address->deleted_at, $address->belongs_to);
                        array_push($addresses, $address);
                    }

                    $value->addresses = $addresses;
                }
            }

            unset($value->experience_years, $value->experience_months, $value->deleted_at, $value->address);
            array_push($doctors, $value);
        }

        return $doctors;
    }

    public function search_medico($data){

        $doctors = [];

        foreach ($data as $key => $value) {
            
            if ($value->role == 'Doctor') {
                $value->icon = DisplayPath::doctor_default_icon();
            }elseif($value->role == 'Lab'){
                $value->icon = DisplayPath::lab_default_icon();
            }else{
                $value->icon = DisplayPath::hospital_default_icon();
            }

            if ($value->specializations && $value->specializations != 'null') {
                $specializations = Specialization::whereIn('id', $value->specializations)->pluck('name')->toArray();
                $value->specializations = implode(', ', $specializations);
            }

            $experience = '0';
            if ($value->experience_years) {
                $experience = $value->experience_years;
            }

            if ($value->experience_months) {
                $experience = $experience.'.'.$value->experience_months;
            }
            $experience =  $value->experience_years > 1 ? $experience.' Years' : $experience.' Year' ;

            $value->experience = $experience;

            unset($value->experience_years, $value->experience_months);
            array_push($doctors, $value);
        }

        return $doctors;
    }

    public function blog_categories($data){

        $categories = [];

        foreach ($data as $key => $value) {
            
            if ($value->icon === NULL) {
                $value->icon = url("/app-assets/images/icon/no-image.png");
            }else{
                $value->icon = DisplayPath::category_icon($value->icon);
            }
            array_push($categories, $value);
        }

        return $categories;
    }
    
    public function categories($data){

        $categories = [];

        foreach ($data as $key => $value) {
            
            if ($value->icon === NULL) {
                $value->icon = url("/app-assets/images/icon/no-image.png");
            }else{
                $value->icon = DisplayPath::specialization_icon($value->icon);
            }
            array_push($categories, $value);
        }

        return $categories;
    }

    public function blogs($data){

        $blogs = [];

        foreach ($data as $key => $value) {
            
            if ($value->image === NULL) {
                $value->image = DisplayPath::no_image();
            }else{
                $value->image = DisplayPath::blog_post($value->image);
            }
            $value->tags = json_decode($value->tags, true);
            unset($value->deleted_at, $value->status);
            array_push($blogs, $value);
        }

        return $blogs;
    }

    public function banners($data){

        $banners = [];

        foreach ($data as $key => $value) {
            
            if ($value->image) {
                $value->image = DisplayPath::banner($value->image);
                array_push($banners, $value);
            }
        }

        return $banners;
    }

    public function files($data, $profile_id, $request = 'Unknown'){

        $files = [];
        $targetDir = DisplayPath::common_storage($this->profileFolderName($profile_id)); 

        $bookmark_ids = [];
        if ($request == 'Unknown') {
            if (Schema::hasTable('bookmarks')) {
                $bookmark_ids = Bookmark::where('profile_id', $profile_id)
                    ->where('asset_type', 'File')
                    ->pluck('asset_id')
                    ->toArray();
            }
        }

        foreach ($data as $key => $value) {

            if ($value->name) {

                $folder = '';
                if (isset($value->folder->name)) {
                    $folder = $value->folder->name.'/';
                }elseif (isset($value->folder_name)) {
                    $folder = $value->folder_name.'/';
                }
               
                $value->file = "$targetDir/$folder".$value->name;

                if ($value->file_type != 'image') {
                    $value->thumbnail_file = DisplayPath::pdf_icon();
                }else{
                    $value->thumbnail_file = "$targetDir/$folder".'thumbnail/'.$value->name;
                }
                

                if ($request == 'Unknown') {
                    $value->bookmark = in_array($value->id, $bookmark_ids) ? 'Yes' : 'No' ;
                }

                unset($value->folder, $value->folder_id);
                array_push($files, $value);
            }
        }

        return $files;
    }

    public function share_files($data){

        $files = [];
        $targetDir = '';
        foreach ($data as $key => $value) {

            $last_shared_by = 0;
            if ($value->name) {

                $folder = '';
                if ($last_shared_by != $value->shared_by) {
                    $targetDir = DisplayPath::common_storage($this->profileFolderName($value->shared_by));
                }

                if (isset($value->folder_name)) {
                    $folder = $value->folder_name.'/';
                }
               
                $value->file = "$targetDir/$folder".$value->name;

                if ($value->file_type != 'image') {
                    $value->thumbnail_file = DisplayPath::pdf_icon();
                }else{
                    $value->thumbnail_file = "$targetDir/$folder".'thumbnail/'.$value->name;
                }

                unset($value->folder_id, $value->shared_by, $value->folder_name, $value->profile_id);
                array_push($files, $value);
            }
        }
        return $files;
    }

    public function folders($data, $profile_id){

        $folders = [];
        $bookmark_ids = [];
        if (Schema::hasTable('bookmarks')) {
            $bookmark_ids = Bookmark::where('profile_id', $profile_id)->where('asset_type', 'Folder')->pluck('asset_id')->toArray();
        }

        foreach ($data as $key => $value) {

            $value->bookmark = in_array($value->id, $bookmark_ids) ? 'Yes' : 'No' ;
            array_push($folders, $value);
        }

        return $folders;
    }
}   
