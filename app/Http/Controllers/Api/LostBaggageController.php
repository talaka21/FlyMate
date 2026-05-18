<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreBaggageReportRequest;
use App\Http\Requests\UploadReportImagesRequest;
use App\Models\LostBaggageReport;
use App\Models\ReportImage;
use App\Models\ReportStatusHistory;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\Log;
use App\Http\Requests\UpdateBaggageStatusRequest;
use App\Services\FcmService;


class LostBaggageController extends Controller
{
    /**
     * إنشاء بلاغ جديد عن حقيبة مفقودة
     */
    public function store(StoreBaggageReportRequest $request)
    {
        // نستخدم DB Transaction لضمان حفظ البلاغ والسجل معاً بأمان
        return DB::transaction(function () use ($request) {

            // 1. توليد رقم مرجعي فريد (e.g., FML-1234567)
            do {
                $referenceNumber = 'FML-' . rand(1000000, 9999999);
            } while (LostBaggageReport::where('reference_number', $referenceNumber)->exists());

            // 2. تجهيز البيانات وحفظ البلاغ بربطه بالمسافر الحالي
            $validatedData = $request->validated();
            $validatedData['reference_number'] = $referenceNumber;
            $validatedData['user_id'] = $request->user()->id; // جلب الـ ID تلقائياً من الـ Token
            $validatedData['status'] = 'pending_review'; // الحالة الافتراضية للبلاغ الجديد

            $report = LostBaggageReport::create($validatedData);

            // 3. توثيق هذه الخطوة في جدول تتبع وحفظ سجل الحالات (History)
            ReportStatusHistory::create([
                'lost_baggage_report_id' => $report->id,
                'changed_by'             => $request->user()->id,
                'status'                 => 'pending_review',
                'comment'                => 'تم تقديم بلاغ الحقيبة المفقودة بنجاح وهو قيد المراجعة حالياً.',
            ]);

            // 4. إرجاع الاستجابة بنجاح حسب الـ Format المتفق عليه مع الفلاتر
            return response()->json([
                'success' => true,
                'message' => 'تم تسجيل بلاغ الحقيبة المفقودة بنجاح.',
                'data'    => [
                    'id'               => $report->id,
                    'reference_number' => $report->reference_number,
                    'status'           => $report->status,
                    'created_at'       => $report->created_at->toIso8601String(),
                ]
            ], 201); // 201 Created
        });
    }
    /**
 * 1. جلب قائمة البلاغات الخاصة بالمسافر الحالي فقط
 */
public function index(Request $request)
{
    // جلب البلاغات المرتبطة بالـ user_id الحالي مع ترتيبها من الأحدث للأقدم
    $reports = LostBaggageReport::where('user_id', $request->user()->id)
        ->select(['id', 'reference_number', 'flight_number', 'status', 'created_at'])
        ->orderBy('created_at', 'desc')
        ->get();

    return response()->json([
        'success' => true,
        'data'    => $reports
    ], 200);
}

/**
 * 2. جلب تفاصيل بلاغ معين بالكامل مع الصور والخط الزمني (Status History)
 */
public function show(Request $request, $id)
{
    // جلب البلاغ مع علاقة الصور وعلاقة السجل التاريخي ومستخدم السجل بشكل كامل وآمن
    $report = LostBaggageReport::with(['images', 'statusHistory.user'])
        ->where('user_id', $request->user()->id)
        ->find($id);

    if (!$report) {
        return response()->json([
            'success' => false,
            'error' => [
                'code'    => 'NOT_FOUND',
                'message' => 'عذراً، بلاغ الحقيبة المفقودة غير موجود أو لا تملك صلاحية للوصول إليه.'
            ]
        ], 404);
    }

    return response()->json([
        'success' => true,
        'data'    => $report
    ], 200);
}
/**
 * رفع صورة تابعة لبلاغ معين (حقيبة أو تاغ)
 */
public function uploadImage(UploadReportImagesRequest $request, $id)
{
    // 1. التأكد من وجود البلاغ وأنه يخص المستخدم الحالي
    $report = LostBaggageReport::where('user_id', $request->user()->id)->find($id);

    if (!$report) {
        return response()->json([
            'success' => false,
            'error'   => ['code' => 'NOT_FOUND', 'message' => 'البلاغ غير موجود أو لا تملك صلاحية للوصول إليه.']
        ], 404);
    }

    // 2. التحقق من عدم تجاوز الحد الأقصى للصور (5 صور كحد أقصى حسب الـ Contract)
    if ($report->images()->count() >= 5) {
        return response()->json([
            'success' => false,
            'error'   => ['code' => 'LIMIT_EXCEEDED', 'message' => 'لا يمكنك رفع أكثر من 5 صور للبلاغ الواحد.']
        ], 422);
    }

    // 3. تخزين الصورة في السيرفر (مجلد local كمرحلة أولى، أو S3 لاحقاً)
    if ($request->hasFile('image')) {
        $file = $request->file('image');

        // تخزين الملف في مجلد storage/app/public/baggage_images
        $storagePath = $file->store('public/baggage_images');

        // توليد الـ URL العام المقروء للموبايل
        $publicUrl = asset(str_replace('public/', 'storage/', $storagePath));

        // 4. حفظ بيانات الصورة في جدول الـ report_images
        $image = ReportImage::create([
            'lost_baggage_report_id' => $report->id,
            'uploaded_by'            => $request->user()->id,
            'image_type'             => $request->input('image_type'),
            'url'                    => $publicUrl,
            'storage_key'            => $storagePath,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'تم رفع الصورة وحفظها بنجاح.',
            'data'    => [
                'id'         => $image->id,
                'image_type' => $image->image_type,
                'url'        => $image->url
            ]
        ], 201);
    }

    return response()->json([
        'success' => false,
        'error'   => ['code' => 'BAD_REQUEST', 'message' => 'لم يتم إرسال أي ملف.']
    ], 400);
}
public function updateStatus(UpdateBaggageStatusRequest $request, $id)
{
    return DB::transaction(function () use ($request, $id) {

        // 1. جلب البلاغ مع بيانات المسافر (للحصول على الـ FCM Token)
        $report = LostBaggageReport::with('user')->find($id);

        if (!$report) {
            return response()->json([
                'success' => false,
                'error'   => ['code' => 'NOT_FOUND', 'message' => 'بلاغ الحقيبة المفقودة غير موجود.']
            ], 404);
        }

        $oldStatus = $report->status;
        $newStatus = $request->input('status');
        // تعديل المسمى إلى note ليطابق الـ Contract
        $note = $request->input('note') ?? "تم تحديث حالة بلاغكم إلى: " . $newStatus;

        // 2. تحديث حالة البلاغ الرئيسي
        $report->update([
            'status'      => $newStatus,
            'assigned_to' => $request->user()->id // الموظف الذي باشر التحديث
        ]);

        // 3. إضافة سطر في جدول السجل الزمني (History)
        ReportStatusHistory::create([
            'lost_baggage_report_id' => $report->id,
            'changed_by'             => $request->user()->id,
            'status'                 => $newStatus,
            'note'                   => $note, // تعديل الاسم هنا أيضاً لـ note
        ]);

        // 4. 🔥 إرسال إشعار الـ FCM الفوري للمسافر (تم تصحيح القوس هنا ليصبح بداخل الـ Transaction)
        if ($report->user && $report->user->fcm_token) {
            try {
                app(FcmService::class)->sendPushNotification(
                    $report->user->fcm_token,
                    "تحديث بشأن حقيبتك المفقودة 🧳",
                    "البلاغ رقم {$report->reference_number}: حالته الآن أصبحت ({$newStatus}).",
                    [
                        'type'             => 'status_changed',
                        'report_id'        => (string)$report->id,
                        'report_reference' => $report->reference_number, // مطابقة الـ Contract
                        'new_status'       => $newStatus,                 // مطابقة الـ Contract
                        'click_action'     => 'FLUTTER_NOTIFICATION_CLICK'
                    ]
                );
            } catch (\Exception $e) {
                \Log::error("FCM Failed for report {$report->id}: " . $e->getMessage());
            }
        }

        return response()->json([
            'success' => true,
            'message' => 'Status updated. User has been notified.', // مطابقة رسالة الـ Contract
            'data'    => [
                'id'               => $report->id,
                'reference_number' => $report->reference_number,
                'status'           => $report->status,
                'updated_at'       => $report->updated_at->toIso8601String()
            ]
        ], 200);

    }); // إغلاق القوس الخاص بالـ Transaction هنا بالصحيح تماماً!
}
}
