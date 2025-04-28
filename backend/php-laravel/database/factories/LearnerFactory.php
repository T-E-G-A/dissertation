<?php

namespace Database\Factories;

use App\Models\Learner;
use Illuminate\Database\Eloquent\Factories\Factory;

class LearnerFactory extends Factory
{
    protected $model = Learner::class;

    public function definition()
    {
        return [
            'admissionNumber' => 'LNR/' . str_pad($this->faker->unique()->randomNumber(4), 4, '0', STR_PAD_LEFT) . '/' . date('Y'),
            'firstName' => $this->faker->firstName,
            'lastName' => $this->faker->lastName,
            'age' => $this->faker->numberBetween(5, 18),
            'gender' => $this->faker->randomElement(['Male', 'Female']),
            'parentName' => $this->faker->name,
            'parentEmail' => $this->faker->email,
            'parentPhone' => $this->faker->phoneNumber,
            'password' => password_hash('password', PASSWORD_BCRYPT),
            'admitted' => false,
        ];
    }
}
