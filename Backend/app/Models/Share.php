<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use App\Models\UserProfile;

class Share extends Model
{
    use SoftDeletes, HasFactory;

    protected $table = 'share';
    /**
     * Indicates if the model should be timestamped.
     *
     * @var bool
     */
    public $timestamps = false;

    protected $fillable = [
        'id',
        'profile_id',
        'shared_by',
        'access_id',
        'access_type',
        'shared_at',
        'deleted_at',
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
        'shared_at' => 'datetime:d M, Y h:i A',
        'deleted_at' => 'datetime:d M, Y h:i A',
    ];

    public function shared_by_profile()
    {
        return $this->hasOne(UserProfile::class, 'id', 'shared_by');
    }

    public function shared_to_profiles()
    {
        return $this->hasMany(UserProfile::class, 'id', 'profile_id');
    }
}
