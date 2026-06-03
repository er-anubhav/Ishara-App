<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;
use App\Library\Structure;
use App\Library\Beautify;
use App\Library\TargetPath;
use App\Library\GlobalFunction;
use App\Library\FileAndFolder;
use App\Library\Measurement as MeasurementData;
use App\Models\Measurement;
use DateInterval;
use DatePeriod;
use DateTime;
use File;
use DB;

class MeasurementController extends Controller
{
    // Structure of response API.
    use Structure, MeasurementData, GlobalFunction, FileAndFolder;

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), 
            [ 
              'date' => 'required',
              'time' => 'required',
              'category' => 'required',
              'datas' => 'nullable',
              'attachment' => 'nullable',
              'comment' => 'nullable|String|max:300',
            ]);

        if ($validator->fails()) {
            return response()->json($this->structure(false, $validator->errors()->first()), 200);
        }

        if ($request->category) {
            if (!in_array($request->category, $this->measurementsCategories())) {
                return response()->json($this->structure(false, "Category to not recognized!"), 200);
            }
        }
        
        $profile_id = $request->profile->id;
        if (isset($profile_id)) {

            $date = date('Y-m-d', strtotime($request->date));
            $time = date('H:i:s', strtotime($request->time));

            $measurements = Measurement::profile($profile_id)->whereDate('date', $date);
            if ($measurements->count() >= 3) {
                return response()->json($this->structure(false, "You can add upto 3 measurements a day."), 200);
            }
            if ($measurements->where('time', $time)->count() > 0) {
                return response()->json($this->structure(false, "Can not add multiple measurement at same time!"), 200);
            }

            $data = [];
            $measurements = is_array($request->datas) ? $request->datas : str_replace("'", '"', $request->datas);
            $measurements = is_array($measurements) ? $measurements : json_decode($measurements, true);

            if (is_array($measurements)) {

                $file_name = null;
                if ($request->file('attachment') != "") {

                    if (!$this->image_validation($request->file('attachment'))) {
                        // return response()->json($this->structure(false, 'File must be image & less than 2 MB.'), 200);
                        return response()->json($this->structure(false, 'File must be image!'), 200);
                    }

                    $folder = $this->profileFolderName($profile_id);

                    $file = $request->file('attachment');
                    $ext = preg_replace('/^.*\.([^.]+)$/D', '$1', $file->getClientOriginalName());
                    //Make directory, If doesn't exist.
                    $targetDir = TargetPath::measurement_attachment($folder);
                    if (!(File::isDirectory($targetDir))) {
                        File::makeDirectory($targetDir, 0777, true, true);
                    }
                    $file_name = strtoupper($request->category).'_MEASUREMENT_'.date('ymdhis').'.'.$ext;
                    \App\Library\StorageHelper::storeUploadedFile($file, $targetDir, $file_name);
                }

                $date = date('Y-m-d', strtotime($request->date));
                $time = date('H:i:s', strtotime($request->time));

                $measurement = new Measurement();
                $measurement->profile_id = $profile_id;
                $measurement->category = $request->category;
                $measurement->datas = $measurements;
                $measurement->attachment = $file_name;
                $measurement->comment = $request->comment;
                $measurement->date = $date;
                $measurement->time = $time;

                try {
                    $measurement->save();
                    return response()->json($this->structure(true, 'Measurement Saved'), 200);
                } catch (\Exception $e) {
                    return response()->json($this->structure(false, 'Something went wrong!'), 200);
                } catch (\Error $e) {
                    return response()->json($this->structure(false, 'Something went wrong!'), 200);
                }
            }
            return response()->json($this->structure(false, 'Measurement Incorrect!'), 200);
        }
        return response()->json($this->structure(false, "Profile not found!"), 200);
    }

    public function get(Request $request)
    {
        $profile_id = $request->profile->id;
        if (isset($profile_id)) {
            
            $date = isset($request->date) ? date('Y-m-d', strtotime($request->date)) : date('Y-m-d') ; 
            $category = $request->category ? $request->category : 'BP' ;

            if (!in_array($category, ['BP', 'Pulse', 'Weight', 'Sugar'])) {
                return response()->json($this->structure(false, "Category not found!"), 200);
            }

            $measurements = Measurement::profile($profile_id)->whereDate('date', $date)->where('category', $category)->get();
            return response()->json($this->structure(true, 'Measurement', $measurements), 200);
        }
        return response()->json($this->structure(false, "Profile not found!"), 200);
    }

    public function delete(Request $request)
    {
        $profile_id = $request->profile->id;
        if (isset($profile_id)) {
            
            $measurement = Measurement::profile($profile_id)->where('id', $request->id)->first();

            try {
                $measurement->delete();
                return response()->json($this->structure(true, 'Measurement Deleted'), 200);
            } catch (\Exception $e) {
                return response()->json($this->structure(false, 'Measurement not found or not deleted!'), 200);
            } catch (\Error $e) {
                return response()->json($this->structure(false, 'Measurement not found or not deleted!'), 200);
            }
        }
        return response()->json($this->structure(false, "Profile not found!"), 200);
    }

    public function analytics(Request $request) 
    {
        $profile_id = $request->profile->id;
        if (isset($profile_id)) {
            
            $data = [];
            $format = 'd-m-Y';
            $from_date = $this->validateDate($request->startDate, $format) ? date('Y-m-d', strtotime($request->startDate)) : date('Y-m-d');
            $to_date = $this->validateDate($request->endDate, $format) ? date('Y-m-d', strtotime($request->endDate)) : date('Y-m-d');
            $periodic = $request->periodic;
            $category = $request->category ? $request->category : 'BP' ;
            
            if (!in_array($category, ['BP', 'Pulse', 'Weight', 'Sugar', 'Temperature', 'SpO2'])) {
                return response()->json($this->structure(false, "Category not found!"), 200);
            }
   
            $query = Measurement::profile($profile_id)->where('category', $category);
            if ($periodic == 'Weekly') {
                
                $to_date = $from_date;
                $from_date = date('Y-m-d', strtotime($to_date. ' - 6 days' ));

                $query = $query->whereDate('date', '>=', $from_date)->whereDate('date', '<=', $to_date);
            }
            elseif($periodic == 'Monthly'){

                $to_date = $from_date;
                $from_date = date('Y-m-d', strtotime($to_date. ' - 29 days' ));

                $query = $query->whereDate('date', '>=', $from_date)->whereDate('date', '<=', $to_date);
            }
            elseif($periodic == 'Custom'){

                $query = $query->whereDate('date', '>=', $from_date)->whereDate('date', '<=', $to_date);
            }
            else{
                $query = $query->whereDate('date', $from_date);
                $to_date = $from_date;
            }
            $measurements = $query->select('id', 'category', 'datas',  DB::raw('DATE_FORMAT(date, "%d %b") as formatted_date'), 'time')->get()->groupBy('formatted_date');
            
            $periods = new DatePeriod( new DateTime($from_date), new DateInterval('P1D'), new DateTime($to_date) );
            foreach ($periods as $period) {

                $date = $period->format('d M');
                if (isset($measurements[$date])) {
                    array_push($data, ['label' => $date, 'values' => $measurements[$date]]);
                }

                // else{

                //     if ($category == 'BP') {
                //         $empty_measurements = ['category' => $category, 'datas' => ['upper_bound'=>'0', 'lower_bound' => '0'], 'formatted_date' => $date, 'time' => date('h:iA')];
                //     }elseif($category == 'Pulse'){
                //         $empty_measurements = ['category' => $category, 'datas' => ['pulse_rate' => '0'], 'formatted_date' => $date, 'time' => date('h:iA')];
                //     }elseif($category == 'Sugar'){
                //         $empty_measurements = ['category' => $category, 'datas' => ['sugar_lavel' => '0'], 'formatted_date' => $date, 'time' => date('h:iA')];
                //     }elseif($category == 'Weight'){
                //         $empty_measurements = ['category' => $category, 'datas' => ['weight' => '0'], 'formatted_date' => $date, 'time' => date('h:iA')];
                //     }
                //     array_push($data, ['label' => $date, 'values' => [$empty_measurements]]);
                // }    
            }

            $date = date('d M', strtotime($to_date));
            if (isset($measurements[$date])) {
                array_push($data, ['label' => $date, 'values' => $measurements[$date]]);
            }
            // else{

            //     if ($category == 'BP') {
            //         $empty_measurements = ['category' => $category, 'datas' => ['upper_bound'=>'0', 'lower_bound' => '0'], 'formatted_date' => $date, 'time' => date('h:iA')];
            //     }elseif($category == 'Pulse'){
            //         $empty_measurements = ['category' => $category, 'datas' => ['pulse_rate' => '0'], 'formatted_date' => $date, 'time' => date('h:iA')];
            //     }elseif($category == 'Sugar'){
            //         $empty_measurements = ['category' => $category, 'datas' => ['sugar_lavel' => '0'], 'formatted_date' => $date, 'time' => date('h:iA')];
            //     }elseif($category == 'Weight'){
            //         $empty_measurements = ['category' => $category, 'datas' => ['weight' => '0'], 'formatted_date' => $date, 'time' => date('h:iA')];
            //     }
            //     array_push($data, ['label' => $date, 'values' => [$empty_measurements]]);
            // }

            return response()->json($this->structure(true, 'Measurement Analytics', $data), 200);
        }
        return response()->json($this->structure(false, "Profile not found!"), 200);
    }


} //Class End Tag.
