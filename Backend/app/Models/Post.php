<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use App\Models\Category;
use Illuminate\Database\Eloquent\SoftDeletes;

class Post extends Model
{
    use HasFactory, SoftDeletes;

    /**
     * The attributes that are mass assignable.
     *
     * @var array
     */
    protected $fillable = [
        'id',
        'heading',
        'description',
        'image',
        'category',
        'tags',
        'content',
        'status',
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
        'updated_at' => 'datetime:d M, Y H:i a',
        'created_at' => 'datetime:d M, Y H:i a',
    ];

    public function categoryName()
    {
        return $this->hasOne(Category::class, 'id', 'category');
    }
}
