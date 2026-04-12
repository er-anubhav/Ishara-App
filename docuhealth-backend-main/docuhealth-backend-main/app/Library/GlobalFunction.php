<?php

namespace App\Library;

use File;
use DateTime;

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

    //2000000 bytes = 2MB
    public function image_validation($file='', $size = '2000000')
    {
        $allowedExtension = ["gif", "jpeg", "jpg", "png"];
        $file_type = pathinfo($file->getClientOriginalName(), PATHINFO_EXTENSION);

        // return (!in_array($file_type, $allowedExtension) || filesize($file) > $size) ? false : true ;
        return (!in_array($file_type, $allowedExtension)) ? false : true ;
    }

    public function format_file_size($size) {
      $sizes = array(" Bytes", " KB", " MB", " GB", " TB", " PB", " EB", " ZB", " YB");
      if ($size == 0) { return('0 Bytes'); } else {
      return (round($size/pow(1024, ($i = floor(log($size, 1024)))), 2) . $sizes[$i]); }
    }

    public function encrypt_decrypt($action, $string) {
        if ($string == '') { return 0; }
        $output = false;
        $encrypt_method = "AES-256-CBC";
        //add Your secret key here.
        $secret_key = 'DCH6514897CS';
        //add Your secret iv here.
        $secret_iv = 'DCH14897VCSs';
        // hash
        $key = hash('sha256', $secret_key);

        // iv - encrypt method AES-256-CBC expects 16 bytes - else you will get a warning
        $iv = substr(hash('sha256', $secret_iv), 0, 16);
        if ( $action == 'encrypt' ) {
            $output = openssl_encrypt($string, $encrypt_method, $key, 0, $iv);
            $output = base64_encode($output);
        } 
        else if( $action == 'decrypt' ) {
            $output = openssl_decrypt(base64_decode($string), $encrypt_method, $key, 0, $iv);
        }
        return $output;
    }

    public function folder_Size($set_dir)
    {   
        if (!(File::isDirectory($set_dir))) {
            File::makeDirectory($set_dir, 0777, true, true);
        }
        $set_total_size = 0;
        $set_count = 0;
        $set_dir_array = scandir($set_dir);
        foreach($set_dir_array as $key=>$set_filename)
        {
            if($set_filename!=".." && $set_filename!=".")
            {
                if(is_dir($set_dir."/".$set_filename))
                {
                    $new_foldersize = $this->folder_Size($set_dir."/".$set_filename);
                    $set_total_size = $set_total_size+ $new_foldersize;
                }
                else if(is_file($set_dir."/".$set_filename))
                {
                    $set_total_size = $set_total_size + filesize($set_dir."/".$set_filename);
                    $set_count++;
                }
            }
        }
        return $set_total_size;
    }

    public function validateDate($date, $format = 'Y-m-d')
    {
        $d = DateTime::createFromFormat($format, $date);
        // The Y ( 4 digits year ) returns TRUE for any integer with any number of digits so changing the comparison from == to === fixes the issue.
        return $d && $d->format($format) === $date;
    }
}

?>