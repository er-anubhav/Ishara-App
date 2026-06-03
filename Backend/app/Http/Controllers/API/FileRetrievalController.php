<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Library\FileAuthService;
use App\Library\Structure;
use Auth;

class FileRetrievalController extends Controller
{
    use Structure;

    /**
     * Get authorized temporary download URL for a file
     * GET /api/files/{fileId}/download-url
     * 
     * Response: { "url": "https://...", "expires_at": "..." }
     */
    public function getDownloadUrl(Request $request, $fileId)
    {
        try {
            $userId = Auth::id();
            
            // Get authorized signed URL (will throw if user doesn't own file)
            $urlData = FileAuthService::getAuthorizedUrl($fileId, $userId, 24);

            return response()->json($this->structure(true, 'File URL generated', $urlData), 200);

        } catch (\Illuminate\Database\Eloquent\ModelNotFoundException $e) {
            // File not found OR user doesn't own it
            return response()->json($this->structure(false, 'File not found or unauthorized'), 403);
        } catch (\Exception $e) {
            return response()->json($this->structure(false, 'Error: ' . $e->getMessage()), 500);
        }
    }

    /**
     * List all files owned by authenticated user
     * GET /api/my-files
     */
    public function listMyFiles(Request $request)
    {
        $userId = Auth::id();

        $files = \App\Models\FileModel::where('user_id', $userId)
                                     ->select(['id', 'original_name', 'file_type', 'file_category', 'created_at'])
                                     ->latest()
                                     ->paginate(20);

        return response()->json($this->structure(true, 'Files retrieved', $files), 200);
    }

}

?>
