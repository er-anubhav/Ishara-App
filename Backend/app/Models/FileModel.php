<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class FileModel extends Model
{
    protected $table = 'user_files';
    
    protected $fillable = [
        'user_id',
        's3_path',
        'file_type',
        'original_name',
        'file_category', // 'banner', 'profile', 'measurement', 'document', etc.
    ];

    public function user()
    {
        return $this->belongsTo(User::class, 'user_id');
    }
}

?>
