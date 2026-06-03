<?php

namespace App\Library;

use Illuminate\Support\Facades\Storage;
use App\Models\FileModel;

class FileAuthService {

    /**
     * Store file metadata and return S3 path
     */
    public static function storeFileMetadata($userId, $s3Path, $fileType, $fileCategory, $originalName)
    {
        $file = FileModel::create([
            'user_id' => $userId,
            's3_path' => $s3Path,
            'file_type' => $fileType,
            'file_category' => $fileCategory,
            'original_name' => $originalName,
        ]);

        return $file;
    }

    /**
     * Get authorized temporary URL for file
     * Returns signed URL if user owns file, throws exception otherwise
     */
    public static function getAuthorizedUrl($fileId, $userId, $expiresInHours = 24)
    {
        // Verify file belongs to this user
        $file = FileModel::where('id', $fileId)
                        ->where('user_id', $userId)
                        ->firstOrFail(); // Will throw ModelNotFoundException if not found

        // Generate temporary signed URL (valid for X hours)
        $signedUrl = Storage::disk('s3')
                           ->temporaryUrl($file->s3_path, now()->addHours($expiresInHours));

        return [
            'file_id' => $file->id,
            'url' => $signedUrl,
            'expires_at' => now()->addHours($expiresInHours)->toDateTimeString(),
        ];
    }

    /**
     * Check if user can access file (returns boolean, doesn't throw)
     */
    public static function canAccessFile($fileId, $userId)
    {
        return FileModel::where('id', $fileId)
                       ->where('user_id', $userId)
                       ->exists();
    }

}

?>
