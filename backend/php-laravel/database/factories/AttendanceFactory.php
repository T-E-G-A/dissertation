<?php

namespace Database\Factories;

use App\Models\Attendance;
use App\Models\Learner;
use Illuminate\Database\Eloquent\Factories\Factory;

class AttendanceFactory extends Factory
{
    protected $model = Attendance::class;
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
            'week' => 'Week ' . $this->faker->numberBetween(1, 4), // Generate a random week (e.g., "Week 1", "Week 2", etc.)
            'attendance' => array_map(function () {
                return $this->faker->boolean(); // Generate random true/false values for attendance
            }, range(0, 4)), // Create an array of 5 boolean values
        ];
    }
}
