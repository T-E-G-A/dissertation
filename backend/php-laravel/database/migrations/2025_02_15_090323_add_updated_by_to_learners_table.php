<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::table('learners', function (Blueprint $table) {
            $table->unsignedBigInteger('updated_by')->nullable()->after('updated_at');
            $table->foreign('updated_by')->references('id')->on('admins');
        });
        Schema::create('activity_logs', function (Blueprint $table) {
            $table->id();
            $table->foreignId('admin_id')->constrained('admins');
            $table->string('action');
            $table->text('description');
            $table->string('old_value')->nullable();
            $table->string('new_value')->nullable();
            $table->timestamps();
        });
    }

    public function down()
    {
        Schema::dropIfExists('activity_logs');
        Schema::table('learners', function (Blueprint $table) {
            $table->dropColumn('updated_by'); 
        });
    }
};