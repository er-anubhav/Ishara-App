<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

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
        'icon',
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
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    protected $columns = ['id','parent_id', 'user_id', 'name','type', 'gender', 'dob', 'relation', 'icon', 'deleted_at', 'created_at',
        'updated_at'];

    public function scopeExclude($query, $value = []) 
    {
        return $query->select(array_diff($this->columns, (array) $value));
    }
}
