<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;
use App\Library\Structure;
use App\Library\Beautify;
use App\Library\DisplayPath;
use App\Models\Notification;
use App\Models\Banner;

class DataController extends Controller
{
    // Structure of response API.
    use Structure;

    public function notifications(Request $request){

        $user_id = isset(auth('api')->user()->id) ? auth('api')->user()->id : 0;

        $notifications =  Notification::where('user_id', $user_id)->orWhere('user_id', NULL)->where('user_type', 'User')->get();
        return response()->json($this->structure(true, "Notifications", $notifications), 200);
    }

    public function banners(Request $request){

        $banners =  Banner::where('is_active', 'Yes')->get();

        $beautify = new Beautify();
        $banners = $beautify->banners($banners);
        return response()->json($this->structure(true, "Banners", $banners), 200);
    }

    // public function filters(Request $request){

    //     $filters = [];

    //     //Sort by.
    //     $sort_by['name'] = 'Sort by';
    //     $sort_by['filter_var'] = 'sort_by';
    //     $sort_by['data'] = [['name'=>'Date','value'=>'date'], ['name'=>'Salary- High To Low', 'value'=>'high-to-low'], ['name'=>'Salary- Low To High', 'value'=>'low-to-high']];
    //     array_push($filters, $sort_by);

    //     //Job Type.
    //     $job_type['name'] = 'Job Type';
    //     $job_type['filter_var'] = 'job_type';
    //     $job_type['data'] = [['name'=>'Full Time','value'=>'Full-Time'], ['name'=>'Part Time', 'value'=>'Part-Time'], ['name'=>'Trainee/Internship', 'value'=>'Trainee-Internship'], ['name'=>'Remote Or WFH','value'=>'Remote-Or-WFH'], ['name'=>'Freelancing', 'value'=>'Freelancing']];
    //     array_push($filters, $job_type);

    //     //Experience.
    //     $experience['name'] = 'Experience';
    //     $experience['filter_var'] = 'experience';
    //     $experience['data'] = [['name'=>'Fresher','value'=>'Fresher'], ['name'=>'< 1 Year','value'=>'0-1'], ['name'=>'1-3 years','value'=>'1-3'], ['name'=>'3-5 years','value'=>'3-5'], ['name'=>'5-10 years','value'=>'5-10'], ['name'=>'10-15 years','value'=>'10-15'], ['name'=>'15+ years','value'=>'15-gt']];
    //     array_push($filters, $experience);

    //     //Experience.
    //     $salary_range['name'] = 'Salary Range';
    //     $salary_range['filter_var'] = 'salary_range';
    //     $salary_range['data'] = [['name'=>'< 10,000','value'=>'10K-ls'], ['name'=>'10,000 - 20,000','value'=>'10K-20K'], ['name'=>'20,000 - 30,000','value'=>'20K-30K'], ['name'=>'30,000 - 50,000','value'=>'30K-50K'], ['name'=>'50,000 - 100,000','value'=>'50K-100K'], ['name'=>'100,000+','value'=>'100K-gt']];
    //     array_push($filters, $salary_range);

    //     //Education.
    //     $education['name'] = 'Education';
    //     $education['filter_var'] = 'education';
    //     $education['data'] = [['name'=>'Less than 10th','value'=>'ls-10th'], ['name'=>'10th','value'=>'10th'], ['name'=>'12th','value'=>'12th'], ['name'=>'Diploma/ ITI','value'=>'diploma'], ['name'=>'Graduation','value'=>'graduation'], ['name'=>'Post Graduation','value'=>'post-graduation'], ['name'=>'PhD','value'=>'PhD']];
    //     array_push($filters, $education);

    //     //Industries.
    //     $industries['name'] = 'Industry';
    //     $industries['filter_var'] = 'industry';
    //     $industries['data'] = DB::table('industry')->where('is_active', 'Yes')->select('name', 'id as value')->get();
    //     array_push($filters, $industries);

    //     return response()->json($this->structure(true, "", $filters), 200);
    // }

} //Class End Tag.
