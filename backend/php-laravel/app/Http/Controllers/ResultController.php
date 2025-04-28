<?php

namespace App\Http\Controllers;

use App\Models\Learner;
use App\Models\Result;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class ResultController extends Controller
{
    public function index()
    {
        $results = Learner::select(
            'learners.id as no',
            'learners.admissionNumber',
            DB::raw("CONCAT(learners.firstName, ' ', learners.lastName) as name"),
            DB::raw('COALESCE(results.maths, 0) as maths'),
            DB::raw('COALESCE(results.english, 0) as english'),
            DB::raw('COALESCE(results.science, 0) as science')
        )
            ->leftJoin('results', 'learners.admissionNumber', '=', 'results.admissionNumber')
            ->get();

        return response()->json(['status' => 'success', 'data' => $results]);
    }

    public function reset()
    {
        Result::query()->update([
            'maths' => 0,
            'english' => 0,
            'science' => 0
        ]);
        return response()->json(['status' => 'success', 'message' => 'Results reset']);
    }

    public function save(Request $request)
    {
        $request->validate(['students' => 'required|array']);

        foreach ($request->students as $student) {
            // Check if all marks are zero
            if ($student['maths'] == 0 && $student['english'] == 0 && $student['science'] == 0) {
                continue; // Skip saving this record
            }

            Result::updateOrCreate(
                ['admissionNumber' => $student['admissionNumber']],
                $student
            );
        }
        return response()->json(['status' => 'success', 'message' => 'Results saved']);
    }

    public function learnerResults(Request $request)
    {
        $admissionNumberArray = $request->only('admissionNumber');
        $admissionNumber = $admissionNumberArray['admissionNumber'];
        error_log('Fetching results for ' . $admissionNumber);

        $results = Result::select(
            'results.admissionNumber',
            DB::raw("CONCAT(learners.firstName, ' ', learners.lastName) as name"),
            'results.maths',
            'results.english',
            'results.science',
            )
            ->join('learners', 'results.admissionNumber', '=', 'learners.admissionNumber')
            ->where('results.admissionNumber', $admissionNumber)
            ->firstOrFail();

        error_log(json_encode($results));

        return response()->json([
            'status' => 'success',
            'data' => $results
        ]);
    }
}
