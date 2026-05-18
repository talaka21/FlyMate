<?php

namespace App\Services;

use App\Models\LostBaggageReport;
use App\Models\ReportImage;
use App\Models\ReportStatusHistory;
use App\Services\FcmService;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class BaggageService
{
    public function createReport(array $data, $userId)
    {
        return DB::transaction(function () use ($data, $userId) {
            do {
                $referenceNumber = 'FML-' . rand(1000000, 9999999);
            } while (LostBaggageReport::where('reference_number', $referenceNumber)->exists());

            $data['reference_number'] = $referenceNumber;
            $data['user_id'] = $userId;
            $data['status'] = 'pending_review';

            $report = LostBaggageReport::create($data);

            ReportStatusHistory::create([
                'lost_baggage_report_id' => $report->id,
                'changed_by'             => $userId,
                'status'                 => 'pending_review',
                'comment'                => 'Baggage report submitted successfully and is currently under review.',
            ]);

            return $report;
       });
    }

    public function uploadReportImage($file, $imageType, LostBaggageReport $report, $userId)
    {
        $storagePath = $file->store('public/baggage_images');
        $publicUrl = asset(str_replace('public/', 'storage/', $storagePath));

        return ReportImage::create([
            'lost_baggage_report_id' => $report->id,
            'uploaded_by'            => $userId,
            'image_type'             => $imageType,
            'url'                    => $publicUrl,
            'storage_key'            => $storagePath,
        ]);
    }

    public function updateReportStatus(LostBaggageReport $report, $newStatus, $note, $userId)
    {
        return DB::transaction(function () use ($report, $newStatus, $note, $userId) {
            $report->update([
                'status'      => $newStatus,
                'assigned_to' => $userId
            ]);

            ReportStatusHistory::create([
                'lost_baggage_report_id' => $report->id,
                'changed_by'             => $userId,
                'status'                 => $newStatus,
                'note'                   => $note,
            ]);

            if ($report->user && $report->user->fcm_token) {
                try {
                    app(FcmService::class)->sendPushNotification(
                        $report->user->fcm_token,
                        "Update on your lost baggage 🧳",
                        "Report #{$report->reference_number}: Status changed to ({$newStatus}).",
                        [
                            'type'             => 'status_changed',
                            'report_id'        => (string)$report->id,
                            'report_reference' => (string)$report->reference_number,
                            'new_status'       => (string)$newStatus, // تحويل صريح لنص لضمان الاستقرار مع Flutter
                            'click_action'     => 'FLUTTER_NOTIFICATION_CLICK'
                        ]
                    );
                } catch (\Exception $e) {
                    Log::error("FCM Failed for report {$report->id}: " . $e->getMessage());
                }
            }

            return $report;
        });
    }
}
