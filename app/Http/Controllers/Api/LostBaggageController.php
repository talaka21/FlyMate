<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreBaggageReportRequest;
use App\Http\Requests\UploadReportImagesRequest;
use App\Http\Requests\UpdateBaggageStatusRequest;
use App\Models\LostBaggageReport;
use App\Services\BaggageService;
use Illuminate\Http\Request;

class LostBaggageController extends Controller
{
    protected $baggageService;

    public function __construct(BaggageService $baggageService)
    {
        $this->baggageService = $baggageService;
    }

    public function store(StoreBaggageReportRequest $request)
    {
        $report = $this->baggageService->createReport($request->validated(), $request->user()->id);

        return response()->json([
            'success' => true,
            'message' => 'Baggage report registered successfully.',
            'data'    => [
                'id'               => $report->id,
                'reference_number' => $report->reference_number,
                'status'           => $report->status,
                'created_at'       => $report->created_at->toIso8601String(),
            ],
            'error'   => null
        ], 201);
    }

    public function index(Request $request)
    {
        $reports = LostBaggageReport::where('user_id', $request->user()->id)
            ->select(['id', 'reference_number', 'flight_number', 'status', 'created_at'])
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'message' => 'Baggage reports retrieved successfully.',
            'data'    => $reports,
            'error'   => null
        ], 200);
    }

    public function show(Request $request, $id)
    {
        $report = LostBaggageReport::with(['images', 'statusHistory.user'])
            ->where('user_id', $request->user()->id)
            ->find($id);

        if (!$report) {
            return response()->json([
                'success' => false,
                'message' => 'Resource not found.',
                'data'    => null,
                'error'   => [
                    'code'    => 'NOT_FOUND',
                    'message' => 'Sorry, the baggage report does not exist or you do not have permission to access it.'
                ]
            ], 404);
        }

        return response()->json([
            'success' => true,
            'message' => 'Baggage report details retrieved successfully.',
            'data'    => $report,
            'error'   => null
        ], 200);
    }

    public function uploadImage(UploadReportImagesRequest $request, $id)
    {
        $report = LostBaggageReport::where('user_id', $request->user()->id)->find($id);

        if (!$report) {
            return response()->json([
                'success' => false,
                'message' => 'Resource not found.',
                'data'    => null,
                'error'   => ['code' => 'NOT_FOUND', 'message' => 'The baggage report does not exist or you do not have permission to access it.']
            ], 404);
        }

        if ($report->images()->count() >= 5) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed.',
                'data'    => null,
                'error'   => ['code' => 'LIMIT_EXCEEDED', 'message' => 'You cannot upload more than 5 images per report.']
            ], 422);
        }

        if ($request->hasFile('image')) {
            $image = $this->baggageService->uploadReportImage(
                $request->file('image'),
                $request->input('image_type'),
                $report,
                $request->user()->id
            );

            return response()->json([
                'success' => true,
                'message' => 'Image uploaded and saved successfully.',
                'data'    => [
                    'id'         => $image->id,
                    'image_type' => $image->image_type,
                    'url'        => $image->url
                ],
                'error'   => null
            ], 201);
        }

        return response()->json([
            'success' => false,
            'message' => 'Bad request.',
            'data'    => null,
            'error'   => ['code' => 'BAD_REQUEST', 'message' => 'No image file was provided.']
        ], 400);
    }

    public function updateStatus(UpdateBaggageStatusRequest $request, $id)
    {
        $report = LostBaggageReport::with('user')->find($id);

        if (!$report) {
            return response()->json([
                'success' => false,
                'message' => 'Resource not found.',
                'data'    => null,
                'error'   => ['code' => 'NOT_FOUND', 'message' => 'The baggage report does not exist.']
            ], 404);
        }

        $newStatus = $request->input('status');
        $note = $request->input('note') ?? "Your baggage report status has been updated to: " . $newStatus;

        $updatedReport = $this->baggageService->updateReportStatus($report, $newStatus, $note, $request->user()->id);

        return response()->json([
            'success' => true,
            'message' => 'Status updated. User has been notified.',
            'data'    => [
                'id'               => $updatedReport->id,
                'reference_number' => $updatedReport->reference_number,
                'status'           => $updatedReport->status,
                'updated_at'       => $updatedReport->updated_at->toIso8601String()
            ],
            'error'   => null
        ], 200);
    }
}
