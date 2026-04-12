<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class CMS extends Model
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
        'content',
        'tags',
        'is_active',
        'created_at',
        'updated_at',
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
        'updated_at' => 'datetime:d M, Y H:i a',
        'created_at' => 'datetime:d M, Y H:i a',
    ];


    public function scopeExclude($query, $value = []) 
    {
        return $query->select(array_diff($this->fillable, (array) $value));
    }

    public function scopeActive($query) 
    {
        return $query->where('is_active', 'Yes');
    }
}
