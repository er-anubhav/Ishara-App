<?php
 
namespace App\Casts;
 
use Illuminate\Contracts\Database\Eloquent\CastsAttributes;
use App\Library\DisplayPath;
use App\Library\FileAndFolder;
 
class MeasurementFile implements CastsAttributes
{
    use FileAndFolder;
    /**
     * Cast the given value.
     *
     * @param  \Illuminate\Database\Eloquent\Model  $model
     * @param  string  $key
     * @param  mixed  $value
     * @param  array  $attributes
     * @return array
     */
    public function get($model, $key, $value, $attributes)
    {
        return ($value === NULL) ? null : DisplayPath::measurement_attachment($this->profileFolderName($model->profile_id)).'/'.$value;
    }
 
    /**
     * Prepare the given value for storage.
     *
     * @param  \Illuminate\Database\Eloquent\Model  $model
     * @param  string  $key
     * @param  array  $value
     * @param  array  $attributes
     * @return string
     */
    public function set($model, $key, $value, $attributes)
    {
        return $value;
    }
}