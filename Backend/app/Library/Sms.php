<?php

namespace App\Library;


use DB;

class Sms

{

    var $number, $msg;
    public function __construct($number, $msg)
    {
        $this->number = $number;
        $this->msg = $msg;
    }


    public function send()
    {
        
        // $url = "http://sms.programmics.tech/api?userid=chandra.pro&password=chandra@2020&mobno=".$this->number."&msg=".urlencode($this->msg)."&senderid=PRGMCS&route=4&template_id=1707160465079587546&unicode=0";
        // $ch = curl_init();

        // curl_setopt($ch, CURLOPT_URL, $url);

        // curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);

        // curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

        // curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true);

        // curl_setopt($ch, CURLOPT_ENCODING, "gzip,deflate");

        // $response = curl_exec($ch);

        // DB::table('sms_api_logs')->insert(['data'=>$response]);

        // return json_decode($response, true);
        
        $msg = $this->msg;
        $apiKey = 'MzgzNDc5NTk0YjMwNjU2Yzc5NGYzOTYxMzMzMjYyMzU=';
        $numbers = array('91'.$this->number);
        $sender = urlencode('OPANAP');
        $message = rawurlencode($msg);
        $numbers = implode(',', $numbers);
        $data = array('apikey' => $apiKey, 'numbers' => $numbers, 'sender' => $sender, 'message' => $message);
        $ch = curl_init('https://api.textlocal.in/send/');
        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch, CURLOPT_POSTFIELDS, $data);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        $response = curl_exec($ch);
        // SmsApiLog::create(['data'=>$response]);
        curl_close($ch);
        
        return json_decode($response,true);
    }

}

