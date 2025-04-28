<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('attendance_records', function (Blueprint $table) {
            $table->id();
            $table->string('admissionNumber');
            $table->tinyInteger('week_number');
            $table->tinyInteger('day_of_week'); // 1-5 for Monday-Friday
            $table->boolean('present')->default(false);
            $table->timestamps();

            $table->unique(['admissionNumber', 'week_number', 'day_of_week'], 'uniq_att_rec_adm_wk_day'); // Shorter index name
            $table->foreign('admissionNumber')->references('admissionNumber')->on('learners')->onDelete('cascade');
        });
    }

    public function down()
    {
        Schema::dropIfExists('attendance_records');
    }
};