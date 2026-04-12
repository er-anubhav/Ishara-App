<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateUsersTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('users', function (Blueprint $table) {
            $table->id();
            $table->string('name', 100)->nullable();
            $table->string('email', 100)->unique()->nullable();
            $table->string('phone', 60)->unique()->nullable();
            $table->timestamp('email_verified_at')->nullable();
            $table->string('password', 191)->nullable();
            $table->rememberToken();
            $table->longText('location')->nullable();
            $table->enum('is_active', ['Yes', 'No'])->default('Yes');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('users');
    }
}
