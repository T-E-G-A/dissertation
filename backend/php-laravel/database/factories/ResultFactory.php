<?php

namespace Database\Factories;

use App\Models\Learner;
use App\Models\Result;
use Illuminate\Database\Eloquent\Factories\Factory;

class ResultFactory extends Factory
{
    protected $model = Result::class;
    /**
     * Define the model's default state.
     *
     * @return array
     */
    public function definition()
    {
        $learners = Learner::pluck('admissionNumber')->toArray();

        return [
            'admissionNumber' => $this->faker->randomElement($learners),
            'maths' => $this->faker->numberBetween(30, 90),
            'english' => $this->faker->numberBetween(40, 80),
            'science' => $this->faker->numberBetween(50, 80),
        ];
    }
}
