<?php

namespace Database\Factories;

use App\Models\Fee;
use App\Models\Learner;
use Illuminate\Database\Eloquent\Factories\Factory;

class FeeFactory extends Factory
{
    protected $model = Fee::class;
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        $learners = Learner::pluck('admissionNumber')->toArray();

        return [
            'admissionNumber' => $this->faker->randomElement($learners),        
            'paid_amount' => $this->faker->randomFloat(2, 0, 1000), 
            'pending_amount' => $this->faker->randomFloat(2, 0, 500), 
            'approved' => $this->faker->boolean(), 
        ];
    }
}
