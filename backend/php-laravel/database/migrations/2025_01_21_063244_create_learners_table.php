<?php

use App\Models\Learner;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateLearnersTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('learners', function (Blueprint $table) {
            $table->id(); // Primary key
            $table->string('admissionNumber')->unique(); // System-generated
            $table->string('firstName');
            $table->string('lastName');
            $table->integer('age');
            $table->string('gender');
            $table->string('parentName');
            $table->string('parentEmail')->unique();
            $table->string('parentPhone');
            $table->string('password');
            $table->boolean('admitted')->default(false)->nullable(false);
            $table->timestamps(); // Created_at, updated_at
        });

    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('learners');
    }
}
