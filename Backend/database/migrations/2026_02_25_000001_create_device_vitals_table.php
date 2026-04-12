<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     * 
     * This table stores vital readings received from hardware devices via MQTT.
     * Supports: Body_Temp, SpO2, BP_SYS, BP_DIA
     */
    public function up()
    {
        Schema::create('device_vitals', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('profile_id')->nullable();
            $table->string('device_name', 100);
            $table->string('vital_type', 50); // Body_Temp, SpO2, BP_SYS, BP_DIA
            $table->decimal('value', 10, 2);
            $table->string('unit', 20)->nullable(); // °C, %, mmHg
            $table->timestamp('recorded_at')->useCurrent();
            $table->timestamps();

            $table->index(['profile_id', 'vital_type']);
            $table->index(['device_name', 'recorded_at']);
            $table->index('recorded_at');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down()
    {
        Schema::dropIfExists('device_vitals');
    }
};
