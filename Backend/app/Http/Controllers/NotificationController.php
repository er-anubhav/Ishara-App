<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Notification;
use App\Library\Structure;
use App\Library\PushNotification;
use App\Models\UserProfile;
use App\Models\Admin;
use Validator;

class NotificationController extends Controller
{
    use Structure;
    
    /**
     * Display a listing of the resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function index()
    {
        return view('notifications');
    }

    public function data(Request $request){

        $table = Notification::where('type', 'manual');

        if($request->notify_to && $request->notify_to != 'all')
        {  
            $table = $table->where('user_type', ucfirst($request->notify_to));
        }
        $data = $table->orderBy('id', 'desc')->get();

        return datatables()->of($data)->addColumn('action', function ($data) {
            if ($data->is_active == 'Yes') {
                $button = '<a href="javascript:void()" name="disable" data-value="'.$data->id.'" class="status-btn"><i class="bx bx-block text-danger"></i></a>';
            }else{
                $button = '<a href="javascript:void()" name="enable" data-value="'.$data->id.'" class="status-btn"><i class="bx bx-check text-success"></i></a>';
            }
            return $button;
        })->addColumn('message', function ($data) {
            if ($data->message!=null && $data->message!='') {
                return "<p>$data->message</p>";
            }
            return "-";
        })->addColumn('notify_to', function ($data) {
            return $data->user_type ? ucwords(str_replace('_', ' ', $data->user_type)) : 'All' ;
        })->rawColumns(['action', 'message', 'notify_to'])->make(true);
    }

    /**
     * Store a newly created resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\Response
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'title' => 'required|string|max:255',
            'message' => 'nullable|string|max:255',
        ]);
        if ($validator->fails()) {
            return response()->json($this->structure(false, $validator->errors()->first()), 200);
        }

        $data = [];
        $notifyTo = $request->notify_to;
        $title = ucfirst($request->title);
        $message = ucfirst($request->message);

        if (in_array("all", $notifyTo))
        {
            $data = ['title' => $title, 'message' => $message, 'type' => 'manual'];
            $this->sendPushNotification($title, $message);
        }
        else
        {
            foreach ($notifyTo as $user_type) {
                if ($user_type!='all') {
                    $data = ['user_type' => strtolower($user_type), 'title' => $title, 'message' => $message, 'type' => 'manual'];
                    $this->sendPushNotification($title, $message, strtolower($user_type));
                }
            }
        }
        
        $data['created_at'] = date('Y-m-d H:i:s');
        $responce = Notification::insert($data);

        if ($responce) {
            return response()->json($this->structure(true, "Sent successfully."));
        }
        return response()->json($this->structure(false, "Something Went Wrong!"));
    }

    public function sendPushNotification($title, $message, $user_type = 'all')
    {
        $pushNotification = NULL;
        $data = ['title' => $title, 'message' => $message, 'type' => 'normal'];

        if ($user_type == 'all')
        {
            $userToken = UserProfile::whereNotNull('device_token')->pluck('device_token')->all();
            $firebaseToken = json_decode(json_encode($userToken , true), true);

            $pushNotification = new PushNotification($firebaseToken, $data);

        }
        elseif($user_type == 'user')
        {
            $firebaseToken = UserProfile::whereNotNull('device_token')->pluck('device_token')->all();
            $firebaseToken = json_decode(json_encode($firebaseToken , true), true);

            $pushNotification = new PushNotification($firebaseToken, $data);
        }
        elseif($user_type == 'sub_admin')
        {
            //
        }
        
        return ($pushNotification == NULL) ? false : json_decode($pushNotification->send(), true) ;
    }
   
}
