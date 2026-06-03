<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('user_files', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('user_id');
            $table->string('s3_path'); // e.g., "user_123/banners/file.jpg"
            $table->enum('file_type', ['image', 'document', 'video', 'pdf']);
            $table->enum('file_category', ['banner', 'profile_icon', 'measurement', 'document', 'blog_post', 'other']);
            $table->string('original_name');
            $table->timestamps();

            $table->foreign('user_id')->references('id')->on('users')->onDelete('cascade');
            $table->index('user_id');
        });
    }

    public function down()
    {
        Schema::dropIfExists('user_files');
    }
};
