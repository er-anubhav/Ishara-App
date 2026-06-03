<?php

namespace App\Library;

use Illuminate\Support\Facades\Storage;
use File;
use Auth;

class StorageHelper {

    // Determine if S3 is configured as default disk
    public static function isS3()
    {
        return (config('filesystems.default') === 's3') && config('filesystems.disks.s3.bucket');
    }

    /**
     * Store uploaded file with USER ISOLATION
     * Files stored under: user_{userId}/{category}/{fileName}
     * Returns file_id from database for later retrieval
     */
    public static function storeUploadedFile($file, $localTargetDir, $fileName, $fileCategory = 'other')
    {
        $userId = Auth::id() ?? 1; // Default to 1 if not authenticated (admin uploads)
        
        if (self::isS3()) {
            // Derive category from localTargetDir
            $public = public_path();
            $s3KeyBase = rtrim(ltrim(str_replace($public, '', $localTargetDir), '/'), '/');
            
            // Build S3 path with user isolation: user_{userId}/category/filename
            $s3Path = "user_" . $userId . "/" . $s3KeyBase . "/" . $fileName;

            // Upload to S3 as PRIVATE (no public access)
            Storage::disk('s3')->putFileAs('', $file, $s3Path, 'private');

            // Determine file type from extension
            $ext = strtolower(pathinfo($fileName, PATHINFO_EXTENSION));
            $fileType = self::getFileType($ext);

            // Store metadata in database
            $fileModel = \App\Library\FileAuthService::storeFileMetadata(
                $userId,
                $s3Path,
                $fileType,
                $fileCategory,
                $file->getClientOriginalName()
            );

            // Return file_id (not the filename — user retrieves via secure endpoint)
            return $fileModel->id;
        } else {
            // Local fallback (development)
            if (!(File::isDirectory($localTargetDir))) {
                File::makeDirectory($localTargetDir, 0777, true, true);
            }
            $file->move($localTargetDir, $fileName);
            return $fileName;
        }
    }

    /**
     * Determine file type from extension
     */
    private static function getFileType($ext)
    {
        $imageExts = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'];
        $docExts = ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'txt'];
        $videoExts = ['mp4', 'avi', 'mov', 'mkv'];

        if (in_array($ext, $imageExts)) return 'image';
        if (in_array($ext, $docExts)) return 'document';
        if (in_array($ext, $videoExts)) return 'video';
        if ($ext === 'pdf') return 'pdf';

        return 'document';
    }

}

?>
