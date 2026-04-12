<?php

namespace App\Models;

use Tymon\JWTAuth\Contracts\JWTSubject;
use Illuminate\Contracts\Auth\MustVerifyEmail;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;
use App\Models\UserProfile;
use DateTimeInterface;

class User extends Authenticatable implements JWTSubject
{
    use HasApiTokens, HasFactory, Notifiable;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'name',
        'phone',
        'email',
        'password',
        'is_active',
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var array<int, string>
     */
    protected $hidden = [
        'password',
        'remember_token',
    ];

    /**
     * The attributes that should be cast.
     *
     * @var array<string, string>
     */
    protected $casts = [
        'email_verified_at' => 'datetime:d M,Y h:i A',
    ];

    //Prepare a date for array / JSON serialization.
    protected function serializeDate(DateTimeInterface $date)
    {
        return $date->format('d M,Y h:iA');
    }

    /**
     * Get the identifier that will be stored in the subject claim of the JWT.
     *
     * @return mixed
     */
    public function getJWTIdentifier()
    {
        return $this->getKey();
    }

    /**
     * Return a key value array, containing any custom claims to be added to the JWT.
     *
     * @return array
     */
    public function getJWTCustomClaims()
    {
        return [];
    }

    public function profile()
    {
        return $this->hasOne(UserProfile::class);
    }

    public function addOnProfiles()
    {
        return $this->hasMany(UserProfile::class, 'parent_id');
    }

    public function scopeProfiles()
    {
        return UserProfile::where('parent_id', $this->id)->orWhere('user_id', $this->id)->orderBy('id', 'asc')->get();
    }

    public function scopeProfilesID()
    {
        return UserProfile::where('parent_id', $this->id)->orWhere('user_id', $this->id)->pluck('id')->toArray();
    }
}
