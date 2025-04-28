<?php

namespace App\Http\Controllers;

use App\Models\Timetable;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Storage;

class TimetableController extends Controller
{
    public function index()
    {
        $timetables = Timetable::all()->map(function ($timetable) {
            return [
                'id' => $timetable->id,
                'filename' => $timetable->filename,
                'filepath' => $timetable->filepath,
                'description' => $timetable->description,
                'file_type' => $timetable->file_type,
                'file_size' => $timetable->file_size,
                'download_url' => route('timetable.download', $timetable->id)
            ];
        });
        error_log('Retrieved all timetables: ' . json_encode($timetables));
        return response()->json(['status' => 'success', 'data' => $timetables]);
    }

    // Add new download method
    public function download($id)
    {
        $timetable = Timetable::findOrFail($id);
        $path = str_replace('/storage/', 'public/', $timetable->filepath);

        if (!Storage::exists($path)) {
            return response()->json([
                'status' => 'error',
                'message' => 'File not found'
            ], 404);
        }

        return Storage::download($path, $timetable->filename);
    }

    public function upload(Request $request)
    {
        try {
            $request->validate([
                'file' => 'required|file|mimes:pdf,doc,docx,xls,xlsx,csv|max:10240', // 10MB max
            ]);

            $file = $request->file('file');

            // Generate a unique filename
            $filename = time() . '_' . $file->getClientOriginalName();
            $path = $file->storeAs('public/timetables', $filename);

            if (!$path) {
                throw new \Exception('Failed to store file');
            }

            $timetable = Timetable::create([
                'filename' => $file->getClientOriginalName(),
                'filepath' => Storage::url($path),
                'file_type' => $file->getClientMimeType(),
                'file_size' => round($file->getSize() / 1024, 2),
                'description' => $request->description ?? "Timetable uploaded on " . now()->format('Y-m-d H:i:s')
            ]);
            error_log('Timetable uploaded: ' . json_encode($timetable));

            return response()->json([
                'status' => 'success',
                'message' => 'Timetable uploaded successfully',
                'data' => $timetable
            ]);
        } catch (\Illuminate\Validation\ValidationException $e) {
            error_log('Validation errors: ' . json_encode($e->errors()));
            return response()->json([
                'status' => 'error',
                'message' => 'Validation failed',
                'errors' => $e->errors()
            ], 422);
        } catch (\Exception $e) {
            error_log('Timetable upload error: ' . $e->getMessage());
            return response()->json([
                'status' => 'error',
                'message' => 'Failed to upload timetable: ' . $e->getMessage()
            ], 500);
        }
    }

    public function delete($id)
    {
        Timetable::destroy($id);
        return response()->json(['status' => 'success', 'message' => 'Timetable deleted']);
    }
    public function learnerTimetables()
    {
        $timetables = Timetable::all()->map(function ($timetable) {
            return [
                'id' => $timetable->id,
                'name' => $timetable->filename,
                'file_type' => $timetable->file_type,
                'file_size' => $timetable->file_size,
                'description' => $timetable->description,
                'download_url' => route('timetable.download', $timetable->id)
            ];
        });

        return response()->json([
            'status' => 'success',
            'data' => $timetables
        ]);
    }
}
