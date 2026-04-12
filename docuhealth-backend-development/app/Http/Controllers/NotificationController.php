<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Notification;
use App\Library\Structure;
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
            return ($data->user_type!=null && $data->user_type!='') ? ucfirst($data->user_type) : 'All' ;
        })->rawColumns(['action', 'message', 'notify_to'])->make(true);
    }

    /**
     * Show the form for creating a new resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function create()
    {
        //
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

        $this->data = [];
        $notifyTo = $request->notify_to;
        $title = ucfirst($request->title);
        $message = ucfirst($request->message);

        if (in_array("all", $notifyTo))
        {
            $this->data = ['title' => $title, 'message' => $message, 'type' => 'manual'];
            // $firebaseToken = $this->firebaseToken();
            // $this->sendPushNotification($firebaseToken);
        }
        else
        {
            foreach ($notifyTo as $user_type) {
                if ($user_type!='all') {
                    $this->data = ['user_type' => ucfirst($user_type), 'title' => $title, 'message' => $message, 'type' => 'manual'];
                    // $firebaseToken = $this->firebaseToken(ucfirst($user_type));
                    // $this->sendPushNotification($firebaseToken);
                }
            }
        }
        
        $this->data['created_at'] = date('Y-m-d H:i:s');
        $responce = Notification::insert($this->data);

        if ($responce) {
            return response()->json($this->structure(true, "Sent successfully."));
        }
        return response()->json($this->structure(false, "Something Went Wrong!"));
    }

    /**
     * Display the specified resource.
     *
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function show($id)
    {
        //
    }

    /**
     * Show the form for editing the specified resource.
     *
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function edit($id)
    {
        //
    }

    /**
     * Update the specified resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function update(Request $request, $id)
    {
        //
    }

    /**
     * Remove the specified resource from storage.
     *
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function destroy($id)
    {
        //
    }
}
