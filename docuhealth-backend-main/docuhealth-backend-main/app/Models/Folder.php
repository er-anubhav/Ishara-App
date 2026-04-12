<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use App\Models\Bookmark;
use App\Models\File;
use DateTimeInterface;

class Folder extends Model
{
    use HasFactory, SoftDeletes;

    /**
     * The attributes that are mass assignable.
     *
     * @var array
     */
    protected $fillable = [
        'id',
        'profile_id',
        'name',
        'belongs_to',
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
        // 'updated_at' => 'datetime:d M, Y h:iA',
        // 'created_at' => 'datetime:d M, Y h:iA',
    ];

    //Prepare a date for array / JSON serialization.
    protected function serializeDate(DateTimeInterface $date)
    {
        return $date->format('d M, Y h:iA');
    }
    
    public function files()
    {
        return $this->hasMany(File::class, 'folder_id', 'id');
    }
}
