<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreatePostsTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('posts', function (Blueprint $table) {
            $table->id();
            $table->string('heading');
            $table->longText('description')->nullable();
            $table->string('image', 100)->nullable();
            $table->string('category', 100)->nullable();
            $table->longText('tags')->nullable();
            $table->longText('content')->nullable();
            $table->enum('status', ['Active', 'Draft'])->default('Draft');
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
        Schema::dropIfExists('posts');
    }
}
