<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use DateTimeInterface;
use App\Casts\Json;
use App\Casts\Time;
use App\Casts\Boolean;
use App\Models\ReminderActivity;

class Reminder extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'id',
        'profile_id',
        'name',
        'time',
        'event_type',
        'event_at',
        'snooze',
        'snooze_interval',
        'snooze_repeat',
        'status',
        'created_at',
        'updated_at',
        'deleted_at',
    ];
    
    /**
     * The attributes that should be hidden for arrays.
     *
     * @var array
     */
    protected $hidden = [
        'created_at',
        'deleted_at'
    ];

    protected $casts = [
        'created_at' => 'datetime:d M, Y h:iA',
        'updated_at' => 'datetime:d M, Y h:iA',
        'event_at' => Json::class,
        'time' => Time::class,
        'status' => Boolean::class,
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

    public function scopeExclude($query, $value = []) 
    {
        return $query->select(array_diff($this->fillable, (array) $value));
    }

    public function activities()
    {
        return $this->hasMany(ReminderActivity::class);
    }
}
