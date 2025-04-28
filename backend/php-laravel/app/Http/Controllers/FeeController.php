<?php

namespace App\Http\Controllers;

use App\Models\Fee;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class FeeController extends Controller
{
    // For the admin interface
    public function index()
    {
        $fees = Fee::select(
            'fees.id as no',
            'fees.admissionNumber',
            DB::raw("CONCAT(learners.firstName, ' ', learners.lastName) as name"),
            'fees.paid_amount',
            'fees.pending_amount',
            'fees.approved'
        )
            ->join('learners', 'fees.admissionNumber', '=', 'learners.admissionNumber')
            ->get();

        // Convert approved status to boolean
        $fees->transform(function ($fee) {
            $fee->approved = (bool)$fee->approved;
            return $fee;
        });

        error_log('Fetched fees data: ' . count($fees) . ' records');
        // error_log($fees);

        return response()->json(['status' => 'success', 'data' => $fees]);
    }

    public function reset(Request $request)
    {
        Fee::query()->update([
            'paid_amount' => 0,
            'pending_amount' => env('DEFAULT_FEES', 1500),
            'approved' => false
        ]);
        return response()->json(['status' => 'success', 'message' => 'Fees reset']);
    }

    public function save(Request $request)
    {
        $request->validate(['students' => 'required|array']);
        error_log('Saving fees for ' . count($request->students) . ' students');

        foreach ($request->students as $student) {
            Fee::updateOrCreate(
                ['admissionNumber' => $student['admissionNumber']],
                $student
            );
        }
        return response()->json(['status' => 'success', 'message' => 'Fees saved']);
    }
    // For the learner portal to see
    public function learnerFees(Request $request)
    {
        $learner = $request->user();
        $fees = Fee::where('admissionNumber', $learner->admissionNumber)->first();

        $data = $fees ?? [
            'paid_amount' => 0,
            'pending_amount' => 0
        ];

        // Add total_amount to the response
        $data['total_amount'] = env('DEFAULT_FEES', 1500);

        return response()->json([
            'status' => 'success',
            'data' => $data
        ]);
    }

    public function payFees(Request $request)
    {
        $request->validate(['amount' => 'required|numeric|min:100']);

        $admissionNumber = $request->user()->admissionNumber;

        // Attempt to find an existing fee record
        $fee = Fee::where('admissionNumber', $admissionNumber)->first();

        if ($fee) {
            // If a record exists, update the pending amount
            $fee->pending_amount += $request->amount;
            $fee->save();
        } else {
            // If no record exists, create a new one
            Fee::create([
                'admissionNumber' => $admissionNumber,
                'paid_amount' => 0,
                'pending_amount' => $request->amount,
            ]);
        }

        return response()->json([
            'status' => 'success',
            'message' => 'Payment pending approval'
        ]);
    }
}
