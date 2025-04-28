<?php

use App\Models\Admin;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateAdminsTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('admins', function (Blueprint $table) {
            $table->id(); // Primary key
            $table->string('staffNumber')->unique(); // System-generated
            $table->string('username')->unique(); // Username field
            $table->string('email')->unique();    // Email field
            $table->string('password');          // Password field
            $table->string('role')->default('admin')->nullable(false); // Role (e.g., admin, superadmin)
            $table->timestamps();                // Created_at, updated_at
        });

    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('admins');
    }
}
