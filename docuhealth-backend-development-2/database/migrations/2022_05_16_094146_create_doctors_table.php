<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateDoctorsTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('doctors', function (Blueprint $table) {
            $table->id();
            $table->string('name', 191);
            $table->string('specializations', 50)->nullable();
            $table->longText('clinic_address')->nullable();
            $table->smallInteger('experience_years')->default(0);
            $table->smallInteger('experience_months')->default(0);
            $table->time('time_from')->nullable();
            $table->time('time_to')->nullable();
            $table->string('degree', 100)->nullable();
            $table->longText('services')->nullable();
            $table->longText('description')->nullable();
            $table->enum('verified', ['Yes', 'No'])->default('No');
            $table->enum('featured', ['Yes', 'No'])->default('No');
            $table->enum('is_active', ['Yes', 'No'])->default('Yes');
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
        Schema::dropIfExists('doctors');
    }
}
