<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateBannersTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('banners', function (Blueprint $table) {
            $table->id();
            $table->string('image', 191)->nullable();
            $table->string('type', 10)->comment('e.g. Normal, Slider')->default('Normal');
            $table->integer('position')->nullable();
            $table->longText('url')->nullable();
            $table->enum('url_type', ['slug', 'link'])->default('slug');
            $table->string('remarks')->nullable();
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
        Schema::dropIfExists('banners');
    }
}
