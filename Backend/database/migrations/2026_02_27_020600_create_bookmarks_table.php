<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        if (!Schema::hasTable('bookmarks')) {
            Schema::create('bookmarks', function (Blueprint $table) {
                $table->id();
                $table->integer('profile_id')->nullable();
                $table->integer('asset_id')->nullable();
                $table->string('asset_type', 20);
                $table->softDeletes();
                $table->timestamp('created_at')->nullable();

                $table->index(['profile_id', 'asset_type', 'asset_id'], 'bookmarks_profile_asset_index');
            });
        }
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        if (Schema::hasTable('bookmarks')) {
            Schema::dropIfExists('bookmarks');
        }
    }
};
