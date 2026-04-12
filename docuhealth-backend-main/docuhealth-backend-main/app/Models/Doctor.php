<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use App\Models\DoctorAddress;
use App\Casts\Json;

class Doctor extends Model
{
    use HasFactory;

    /**
     * The attributes that are mass assignable.
     *
     * @var array
     */
    protected $fillable = [
        'id',
        'name',
        'specializations',
        'latitude',
        'longitude',
        'experience_years',
        'experience_months',
        'time_from',
        'time_to',
        'degree',
        'services',
        'description',
        'verified',
        'featured',
        'is_active',
        'deleted_at',
        'created_at',
        'updated_at',
    ];

    /**
     * The attributes that should be hidden for arrays.
     *
     * @var array
     */
    protected $hidden = [
        'updated_at',
    ];

    protected $casts = [
        'degree' => Json::class,
        'services' => Json::class,
        'specializations' => Json::class,
        'updated_at' => 'datetime:d M, Y H:i a',
        'created_at' => 'datetime:d M, Y H:i a',
    ];

    public function address()
    {
        return $this->hasMany(DoctorAddress::class, 'belongs_to');
    }
}
