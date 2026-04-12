<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ReminderActivity extends Model
{
    use HasFactory;

    public $timestamps = false;

    protected $fillable = [
        'id',
        'reminder_id',
        'date',
        'time',
        'status',
        'type',
        'created_at',
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
        'created_at' => 'datetime:d M, Y h:i A',
    ];

}
