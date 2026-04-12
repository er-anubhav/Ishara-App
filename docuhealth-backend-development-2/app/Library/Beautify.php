<?php

namespace App\Library;

use App\Models\User;
use App\Library\DisplayPath;
use DB;

class Beautify
{

    public function userOBJ($data){

        $data->registered_at = date('d-m-y, H:i A', strtotime($data->created_at));

        if ($data->location) {
            $data->location = json_decode($data->location, true);
        }
        //remove all the unnecessary data.
        unset($data->is_active, $data->email_verified_at, $data->created_at, $data->updated_at, $data->profile, $data->profiles);

        return $data;
    }

    public function profileOBJ($value){
            
        if ($value->icon === NULL) {
            $value->icon = DisplayPath::user_profile_default_icon();
        }else{
            $value->icon = DisplayPath::user_profile_icon($value->icon);
        }

        return $value;
    }

    public function userProfiles($data){

        $profiles = [];

        foreach ($data as $key => $value) {
            
            if ($value->icon === NULL) {
                $value->icon = DisplayPath::user_profile_default_icon();
            }else{
                $value->icon = DisplayPath::user_profile_icon($value->icon);
            }
            array_push($profiles, $value);
        }

        return $profiles;
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

}   

