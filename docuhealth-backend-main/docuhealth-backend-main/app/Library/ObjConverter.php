<?php

namespace App\Library;


trait ObjConverter

{

    //Conver the obj.
    public function objConvert($array) {

        $object = new \stdClass();

        foreach ($array as $key => $value) {
            if (is_array($value)) {
                $value = $this->objConvert($value);
            }
            $object->$key = $value;
        }
        
        return $object;
    }

}

