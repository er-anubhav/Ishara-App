<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;
use App\Models\ReminderActivity;
use App\Models\Reminder;
use App\Library\Structure;
use App\Library\Beautify;
use App\Library\MakeReminder;
use App\Library\ExecutionTime;

class ReminderController extends Controller
{
    // Structure of response API.
    use Structure, MakeReminder;

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), 
            [ 
              'name' => 'required|String|max:255',
              'time' => 'required',
              'event_type' => 'required',
              'event_at' => 'nullable',
              'snooze' => 'required',
              'repeat' => 'nullable|numeric|min:1',
            ]);

        if ($validator->fails()) {
            return response()->json($this->structure(false, $validator->errors()->first()), 200);
        }

        $profile_id = $request->profile->id;
        if (isset($profile_id)) {

            $event_type = ucfirst($request->event_type);
            $event_at = is_array($request->event_at) ? $request->event_at : json_decode(str_replace("'", '"', $request->event_at), true);

            try {
                
                Reminder::firstOrCreate(
                    [
                        'profile_id' => $profile_id, 
                        'name' => $request->name, 
                        'time' => $request->time, 
                        'event_type' => $event_type, 
                        'event_at' => $event_at,
                        'snooze' => ($request->snooze === 'true'? true: false),
                        'snooze_interval' => ($request->snooze === 'true'? $request->interval : null),
                        'snooze_repeat' => ($request->snooze === 'true'? $request->repeat : null),
                    ]
                );
                return response()->json($this->structure(true, 'Reminder Created.'), 200);
            } catch (\Exception $e) {
                return response()->json($this->structure(false, 'Internal server error!'), 200);
            } catch (\Error $e) {
                return response()->json($this->structure(false, 'Internal server error!'), 200);
            }
        }
        return response()->json($this->structure(false, "Profile not found!"), 200);
    }

    public function get(Request $request)
    {   
        $profile_id = $request->profile->id;
        if (isset($profile_id)) {

            $table = Reminder::profile($profile_id);

            //Page Calculations.
            $data_records['pagination'] = true;
            $data_records['page'] = request('page') ? intval(request('page')) : 1 ;
            $data_records['limit'] = request('limit') ? request('limit') : 6 ;
            $data_records['start'] = $data_records['page'] == 1 ? 0 : ($data_records['page'] -1 ) * $data_records['limit'] ;

            //count the total lead data.
            $data_records['total_records'] = $table->count();

            $reminders = $table->skip($data_records['start'])->take($data_records['limit'])
                                        ->orderBy('time', 'asc')->orderBy('updated_at', 'desc')->get();

            if ($request->date) {

                try {
                   if (strtotime(date('Y-m-d')) <= strtotime($request->date)) {
                        $date = date('d-m-Y', strtotime($request->date));
                        $reminders = $this->make_reminders($reminders, $date);
                    }else{
                        $data_records['total_records'] = 0;
                        $reminders = []; 
                    }
                } catch (\Exception $e) {
                    return response()->json($this->structure(false, 'Incorrect date format!'), 200);
                } catch (\Error $e) {
                    return response()->json($this->structure(false, 'Incorrect date format!'), 200);
                }
            }
            $data['data'] = $reminders;
            $data['data_records'] = $data_records;
            return response()->json($this->structure(true, 'Reminder', $data), 200);
        }
        return response()->json($this->structure(false, "Profile not found!"), 200);
    }

    public function update(Request $request)
    {
        $validator = Validator::make($request->all(), 
            [ 
              'name' => 'required|String|max:255',
              'time' => 'required',
              'event_type' => 'required',
              'event_at' => 'nullable',
              'snooze' => 'required',
              'repeat' => 'nullable|numeric|min:1',
            ]);

        if ($validator->fails()) {
            return response()->json($this->structure(false, $validator->errors()->first()), 200);
        }

        $profile_id = $request->profile->id;
        if (isset($profile_id)) {

            if ($reminder = Reminder::profile($profile_id)->where('id', $request->id)->first()) {

                $reminder->name = $request->name;
                $reminder->event_type = ucfirst($request->event_type);
                $reminder->event_at = is_array($request->event_at) ? $request->event_at : json_decode(str_replace("'", '"', $request->event_at), true);
                $reminder->name = $request->name;
                $reminder->time = $request->time;
                $reminder->snooze = ($request->snooze === 'true'? true: false);
                $reminder->snooze_interval = ($request->snooze === 'true'? $request->interval : null);
                $reminder->snooze_repeat = ($request->snooze === 'true'? $request->repeat : null);

                try {
                    
                    $reminder->save();
                    return response()->json($this->structure(true, 'Reminder Updated.'), 200);
                } catch (\Exception $e) {
                    return response()->json($this->structure(false, 'Internal server error!'), 200);
                } catch (\Error $e) {
                    return response()->json($this->structure(false, 'Internal server error!'), 200);
                }
            }
            return response()->json($this->structure(false, "Reminder not found!"), 200);
        }
        return response()->json($this->structure(false, "Profile not found!"), 200);
    }

    public function status(Request $request)
    {   
        $profile_id = $request->profile->id;
        if (isset($profile_id)) {

            if ($reminder = Reminder::profile($profile_id)->where('id', $request->id)->first()) {

                try {
                    $reminder->status = $request->status;
                    $reminder->updated_at = date('Y-m-d H:i:s');
                    $reminder->save();
                    return response()->json($this->structure(true, ($request->status ? 'Reminder On' : 'Reminder Off')), 200);
                } catch (\Exception $e) {
                    return response()->json($this->structure(false, 'Internal server error!'), 200);
                } catch (\Error $e) {
                    return response()->json($this->structure(false, 'Internal server error!'), 200);
                }
            }
            return response()->json($this->structure(false, 'Reminder not found!'), 200);
        }
        return response()->json($this->structure(false, "Profile not found!"), 200);
    }

    public function delete(Request $request)
    {   
        $profile_id = $request->profile->id;
        if (isset($profile_id)) {

            if ($reminder = Reminder::profile($profile_id)->where('id', $request->id)->first()) {

                try {
                    $reminder->delete();
                    return response()->json($this->structure(true, 'Reminder deleted' ), 200);
                } catch (\Exception $e) {
                    return response()->json($this->structure(false, 'Internal server error!'), 200);
                } catch (\Error $e) {
                    return response()->json($this->structure(false, 'Internal server error!'), 200);
                }
            }
            return response()->json($this->structure(false, 'Reminder not found!'), 200);
        }
        return response()->json($this->structure(false, "Profile not found!"), 200);
    }

    public function view(Request $request)
    {   
        $profile_id = $request->profile->id;
        if (isset($profile_id)) {

            $reminder = Reminder::profile($profile_id)->where('id', $request->id)->first();
            if ($reminder) {
                $reminder = $this->beutify_reminder($reminder);
                return response()->json($this->structure(true, 'Reminder', $reminder), 200);
            }
            return response()->json($this->structure(false, "Reminder not found!"), 200);
        }
        return response()->json($this->structure(false, "Profile not found!"), 200);
    }

    public function taken(Request $request)
    {   
        $profile_id = $request->profile->id;
        if (isset($profile_id)) {

            if ($activity = ReminderActivity::find($request->id)) {

                try {
                    $activity->status = 'taken';
                    $activity->save();
                    return response()->json($this->structure(true, 'Success!'), 200);
                } catch (\Exception $e) {
                    return response()->json($this->structure(false, 'Internal server error!'), 200);
                } catch (\Error $e) {
                    return response()->json($this->structure(false, 'Internal server error!'), 200);
                }
            }
            return response()->json($this->structure(false, 'Reminder not found!'), 200);
        }
        return response()->json($this->structure(false, "Profile not found!"), 200);
    }

    public function snooze(Request $request)
    {   
        $profile_id = $request->profile->id; 
        if (isset($profile_id)) {

            if ($activity = ReminderActivity::find($request->id)) { 

                try {
                    $reminder = Reminder::findOrFail($activity->reminder_id);
                    $snooze_date_time = explode(' ', date("Y-m-d H:i", strtotime("+$reminder->snooze_interval minutes", strtotime(($activity->date.' '.$activity->time)))));

                    $snoozeActivity = new ReminderActivity();
                    $snoozeActivity->reminder_id = $activity->reminder_id;
                    $snoozeActivity->type = 'snooze';
                    $snoozeActivity->date = $snooze_date_time[0];
                    $snoozeActivity->time = $snooze_date_time[1];
                    $snoozeActivity->save();
                    return response()->json($this->structure(false, 'Success!'), 200);
                } catch (\Exception $e) {
                    return response()->json($this->structure(false, $e->getMessage()), 200);
                } catch (\Error $e) {
                    return response()->json($this->structure(false, $e->getMessage()), 200);
                }
            }
            return response()->json($this->structure(false, 'Reminder not found!'), 200);
        }
        return response()->json($this->structure(false, "Profile not found!"), 200);
    }

    public function suggetions(Request $request)
    {
        $suggetions = Reminder::inRandomOrder()->limit(10)->pluck('name')->unique('name')->toArray();

        return response()->json($this->structure(true, 'Reminder name suggetions', $suggetions), 200);
    }

} //Class End Tag.
