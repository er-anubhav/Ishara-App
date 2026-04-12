<?php

namespace App\Library;

use App\Models\User;
use App\Models\UserInfo;
use App\Models\Address;
use DB;

class Beautify
{

    public function userOBJ($data){

        
        $data->phone_code = NULL;
        $data->phone = NULL;
        $data->dob = NULL;
        $data->player_email = NULL;
        $data->day_phone = NULL;
        $data->addr1 = NULL;
        $data->addr2 = NULL;
        $data->country = NULL;
        $data->city = NULL;
        $data->zip_code = NULL;
        $data->registered_at = date('d-m-y, H:i A', strtotime($data->created_at));

        if ($info = UserInfo::where('user_id', $data->id)->first()) {
            
            $data->phone_code = $info->phone_code;
            $data->phone = $info->phone;
            $data->dob = $info->dob;
            $data->player_email = $info->player_email;
            $data->day_phone = $info->day_phone;
        }
        if ($address = Address::where('user_id', $data->id)->first()) {
            
            $data->address_type = $address->address_type;
            $data->addr1 = $address->line1;
            $data->addr2 = $address->line2;
            $data->country = $address->country;
            $data->city = $address->city;
            $data->zip_code = $address->zip_code;
        }

        //remove all the unnecessary data.
        unset($data->is_active, $data->email_verified_at, $data->created_at, $data->updated_at, $data->info, $data->address);

        return $data;
    }

    public function market_timing_date($timing){
        
        $dates = [];

        if ($timing->day_type == 'Repeat') {

            $bet_close_time = strtotime($timing->bet_close_time);
            $current_time   =   strtotime(date('H:i:s'));

            if ($bet_close_time > $current_time) {
                
                array_push($dates, date('d-m-Y'));

                for ($i=1; $i < 10; $i++) {
                    $NewDate = Date('d-m-Y', strtotime("+$i days"));
                    array_push($dates, $NewDate);
                }
            }else{

                for ($i=1; $i < 11; $i++) {
                    $NewDate = Date('d-m-Y', strtotime("+$i days"));
                    array_push($dates, $NewDate);
                }
            }
        }
        if ($timing->day_type == 'Specific') {

            $open_days = json_decode($timing->open_days, true);

            for ($i=0; $i < sizeof($open_days); $i++) { 
                
                if (strtotime(date('Y-m-d')) == strtotime($open_days[$i])) {
                    
                    $bet_close_time = strtotime($timing->bet_close_time);
                    $current_time   =   strtotime(date('H:i:s'));

                    if ($bet_close_time > $current_time) {
                
                        array_push($dates, $open_days[$i]);
                    }
                }else{
                    array_push($dates, $open_days[$i]);
                }
            }
        }
        if ($timing->day_type == 'Weekly') {

            $open_days = json_decode($timing->open_days, true);
            $today = date('l');

            for ($i=0; $i < 11; $i++) {

                $newDate = Date('d-m-Y', strtotime("+$i days"));
                $newDay = date('l', strtotime($newDate));

                for ($j=0; $j < sizeof($open_days); $j++) {
                
                    if ($newDay == $open_days[$j]) {
                        
                        array_push($dates, $newDate);
                    }
                }
            }
        }

        return $dates;
    }
}

