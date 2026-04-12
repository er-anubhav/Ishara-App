<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class DoctorAddress extends Model
{
    use HasFactory, SoftDeletes;

    protected $table = 'addresses';

    public $timestamps = false;
    
    /**
     * The attributes that are mass assignable.
     *
     * @var array
     */
    protected $fillable = [
        'id',
        'belongs_to',
        'name',
        'addr1',
        'latitude',
        'longitude',
        'time_from',
        'time_to',
        'open_days',
        'deleted_at',
    ];
}
