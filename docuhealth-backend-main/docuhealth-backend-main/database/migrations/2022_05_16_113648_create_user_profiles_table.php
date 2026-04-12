<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateUserProfilesTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('user_profiles', function (Blueprint $table) {
            $table->id();
            $table->integer('parent_id')->nullable();
            $table->integer('user_id')->nullable();
            $table->string('name', 100);
            $table->enum('type', ['Self', 'Add-On'])->default('Self');
            $table->enum('gender', ['Male', 'Female', 'Other'])->default('Other');
            $table->date('dob')->nullable();
            $table->string('relation', 50)->nullable();
            $table->string('icon', 100)->nullable();
            $table->softDeletes();
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
        Schema::dropIfExists('user_profiles');
    }
}
