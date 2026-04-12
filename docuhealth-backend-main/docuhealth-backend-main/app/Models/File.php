<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use App\Models\Bookmark;
use App\Models\Folder;
use DateTimeInterface;

class File extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'id',
        'profile_id',
        'folder_id',
        'category',
        'name',
        'file_type',
        'remarks',
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
        // 'updated_at' => 'datetime:d M, Y h:i A',
        // 'created_at' => 'datetime:d M, Y h:i A',
    ];

    //Prepare a date for array / JSON serialization.
    protected function serializeDate(DateTimeInterface $date)
    {
        return $date->format('d M, Y h:iA');
    }

    public function folder()
    {
        return $this->hasOne(Folder::class, 'id', 'folder_id');
    }

    public function bookmark()
    {
        return $this->hasMany(Folder::class, 'id', 'folder_id');
    }
}
