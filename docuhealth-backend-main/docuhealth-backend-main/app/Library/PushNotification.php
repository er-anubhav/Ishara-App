<?php

namespace App\Library;

class PushNotification
{

    private $fields;

    public function __construct(Array $tokens, Array $data)
    {

        $this->fields = [
            "registration_ids" => $tokens,
            "notification" => [
                "mutable_content" => true,
                "content_available" => true,
                "priority" => "high"
            ],
            "data" => $data
        ];
    }

    public function send()
    {
        $SERVER_API_KEY = "AAAArUCPiK8:APA91bF2XNI56bVuKLAozsc9hHCXk4jTLQAiGVlqm1V36BYsicSJ2uFyIYUQU2VxgU5wBThDuNXTZFeA0GV_rQtqjzJusou3XbAL-PfB-E7w4m2Z2ofyTUlnP4XrKr7ZJ9u7xmpzdEqF";
        
        $data = json_encode($this->fields);
        
        $headers = [
            'Authorization: key=' . $SERVER_API_KEY,
            'Content-Type: application/json',
        ];
    
        $ch = curl_init();
      
        curl_setopt($ch, CURLOPT_URL, 'https://fcm.googleapis.com/fcm/send');
        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
        curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_POSTFIELDS, $data);
               
        return curl_exec($ch);
    }

}

