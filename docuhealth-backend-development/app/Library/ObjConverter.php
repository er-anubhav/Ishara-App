<?php

namespace App\Library;


class ObjConverter

{

    //Conver the obj.
    public function convert($array) {

        $object = new \stdClass();

        foreach ($array as $key => $value) {
            if (is_array($value)) {
                $value = $this->convert($value);
            }
            $object->$key = $value;
        }
        
        return $object;
    }

}

