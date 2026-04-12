<?php

namespace App\Library;

trait GlobalFunction {

    public $otpTemplateID = 1707161052986138985;

    public function timeago($date)
    {
        $timestamp = strtotime($date);

        $strTime = array("s", "m", "h", "day", "month", "year");
        $length = array("60", "60", "24", "30", "12", "10");

        $currentTime = time();
        if ($currentTime >= $timestamp) {
            $diff     = time() - $timestamp;
            for ($i = 0; $diff >= $length[$i] && $i < count($length) - 1; $i++) {
                $diff = $diff / $length[$i];
            }

            $diff = round($diff);
            return $diff . $strTime[$i] . " ago ";
        }

        return false;
    }

    public function sendSMS($mobile, $msg ,$temp_id = '1707161052986138985')
    {
        $msg=urlencode($msg);
        $url = "http://sms.programmics.tech/api?userid=Cafyo&password=Cafyo@2020&mobno=".$mobile."&msg=".$msg."&senderid=CAFYOP&route=4&template_id=".$temp_id."&unicode=0";
        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $url);
        curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true );
        curl_setopt($ch, CURLOPT_ENCODING, "gzip,deflate");     
        $response = curl_exec($ch);
        curl_close($ch);
        
        return $response;
    }

    public function format_number_short($n = 0){

        // first strip any formatting;
        $n = (0+str_replace(",", "", $n));
        // is this a number?
        if (!is_numeric($n)) return false;

        if ($n < 0) {
            $n = abs($n);
        }
         // now filter it;
        if ($n > 1000000000000) return round(($n/1000000000000), 2).'T';
        elseif ($n > 1000000000) return round(($n/1000000000), 2).'B';
        elseif ($n > 1000000) return round(($n/1000000), 2).'M';
        elseif ($n > 1000) return round(($n/1000), 2).'K';
 
        return number_format($n);
    }

    public function getURL(){
          if(isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] === 'on') 
                $link = "https"; 
            else
                $link = "http"; 
              
            // Here append the common URL characters. 
            $link .= "://"; 
              
            // Append the host(domain name, ip) to the URL. 
            $link .= $_SERVER['HTTP_HOST']; 
              
            // Append the requested resource location to the URL 
            // $link .= $_SERVER['REQUEST_URI']; 
                  
            // Print the link 
            return $link; 
    }
}

?>