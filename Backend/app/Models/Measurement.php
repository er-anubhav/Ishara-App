<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use App\Casts\MeasurementFile;
use App\Casts\JsonMeasurement;
use DateTimeInterface;

class Measurement extends Model
{
    use HasFactory, SoftDeletes;

    /**
     * Indicates if the model should be timestamped.
     *
     * @var bool
     */
    public $timestamps = false;

    protected $fillable = [
        'id',
        'profile_id',
        'category ',
        'datas',
        'attachment',
        'comment',
        'date',
        'time',
        'deleted_at',
    ];
    
    /**
     * The attributes that should be hidden for arrays.
     *
     * @var array
     */
    protected $hidden = [
        //
    ];

    protected $casts = [
        'date' => 'datetime:d M, Y',
        'time' => 'datetime:h:iA',
        'datas' => JsonMeasurement::class,
        'attachment' => MeasurementFile::class,
    ];

    public function scopeProfile($query, $profile_id = 0)
    {
        return $query->where('profile_id', $profile_id);
    }

    //Prepare a date for array / JSON serialization.
    protected function serializeDate(DateTimeInterface $date)
    {
        return $date->format('d-m-Y h:iA');
    }

}
