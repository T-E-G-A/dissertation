<?php

namespace Database\Factories;

use App\Models\Admin;
use Illuminate\Database\Eloquent\Factories\Factory;

class AdminFactory extends Factory
{
    protected $model = Admin::class;

    public function definition()
    {
        return [
            'staffNumber' => 'ADM/' . str_pad($this->faker->unique()->randomNumber(4), 4, '0', STR_PAD_LEFT) . '/' . date('Y'),
            'username' => $this->faker->userName,
            'email' => $this->faker->unique()->safeEmail,
            'password' => password_hash('password', PASSWORD_BCRYPT), // Default password
            'role' => 'admin', // Default role
        ];
    }
}
