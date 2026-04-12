<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use DateTimeInterface;
use App\Casts\ProfileIcon;
use App\Casts\Json;

class UserProfile extends Model
{
    use HasFactory;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'id',
        'parent_id',
        'user_id',
        'name',
        'type',
        'gender',
        'dob',
        'relation',
        'location',
        'icon',
        'device_token',
        'deleted_at',
        'created_at',
        'updated_at',
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var array<int, string>
     */
    protected $hidden = [
        'deleted_at',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected $casts = [
        'created_at' => 'datetime:d M,Y h:i A',
        'updated_at' => 'datetime:d M,Y h:i A',
        'location' => Json::class,
        'icon' => ProfileIcon::class,
    ];

    //Prepare a date for array / JSON serialization.
    protected function serializeDate(DateTimeInterface $date)
    {
        return $date->format('d-m-Y h:iA');
    }

    public function scopeExclude($query, $value = []) 
    {
        return $query->select(array_diff($this->fillable, (array) $value));
    }
}
