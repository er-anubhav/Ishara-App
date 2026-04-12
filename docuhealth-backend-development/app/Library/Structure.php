<?php

namespace App\Library;

trait Structure

{

    // Structure of response API.
    public function structure($result, $msg , $data=[]){
        return ['success' => $result, 'message' => $msg , 'data' => $data];
    }

}

