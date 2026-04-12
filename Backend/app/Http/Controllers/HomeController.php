<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\User;
use App\Models\Doctor;
use App\Models\Admin;
use DB;

class HomeController extends Controller
{
    /**
     * Create a new controller instance.
     *
     * @return void
     */
    public function __construct()
    {
        $this->middleware('auth');
    }

    /**
     * Show the application dashboard.
     *
     * @return \Illuminate\Contracts\Support\Renderable
     */
    public function index()
    {
        return view('home');
    }

    public function get_basic_analytics(Request $request)
    {
        $total_users = $active_users = $total_sub_admins = 0; $ative_sub_admins = 0; $doctors = $labs = $hospitals = 0;

        $users = User::get();
        foreach ($users as $user) {

            $total_users += 1;
            if ($user->is_active == 'Yes') {
                $active_users += 1;
            }
        }

        $sub_admins = Admin::where('role', 'Sub-Admin')->get();
        foreach ($sub_admins as $sub_admin) {

            $total_sub_admins += 1;
            if ($sub_admin->is_active == 'Yes') {
                $ative_sub_admins += 1;
            }
        }

        $medicos = Doctor::all();
        foreach ($medicos as $medico) {

            if ($medico->role == 'Doctor') {
                $doctors += 1;
            }elseif($medico->role == 'Lab'){
                $labs += 1;
            }elseif($medico->role == 'Hospital'){
                $hospitals += 1;
            }
        }
        return  [
                    'total_users' => $total_users,
                    'active_users' => $active_users,
                    'total_sub_admins' => $total_sub_admins,
                    'ative_sub_admins' => $ative_sub_admins,
                    'doctors' => $doctors,
                    'labs' => $labs,
                    'hospitals' => $hospitals,
                ];
    }

    public function get_user_analytics()
    {
        // $dates = explode(" - ", $request->get('daterange'));
        // $from_time=date("Y-m-d", strtotime($dates[0]));
        // $to_time=date("Y-m-d", strtotime("+1 days", strtotime($dates[1])));

        $from_time = date('Y-m-d');
        $to_time = date("Y-m-d", strtotime("-10 days", strtotime(date('Y-m-d'))));
        $filter_days = $this->dateDiff($to_time, $from_time);

        $table = User::whereBetween('created_at', [$to_time, $from_time])
                ->select('created_at')
                ->orderBy('created_at', 'asc');

        $active_users = $table->where('is_active', 'Yes')->get()
                ->groupBy(function($date) {
                    return date("d-m-Y", strtotime($date->created_at));
                  });
        $all_users = $table->get()
                ->groupBy(function($date) {
                    return date("d-m-Y", strtotime($date->created_at));
                  });

        $dates = $users = $total_users = [];

        for ($i=$filter_days; $i >= 0; $i--) { 
            
            $current_date = Date('d-m-Y', strtotime("-$i days"));
            array_push($dates, $current_date);

            if (isset($active_users[$current_date])) {
                array_push($users, count($active_users[$current_date]));
            }else{
                array_push($users, 0);
            }

            if (isset($all_users[$current_date])) {
                array_push($total_users, count($all_users[$current_date]));
            }else{
                array_push($total_users, 0);
            }
        }

        $user_max = max($users);
        $total_max = max($total_users);

        $min = 0;
        $max = ($user_max > $total_max) ? $user_max : $total_max ;

        return ['active_users' => $users, 'users' => $total_users, 'dates' => $dates, 'min' => $min, 'max' => $max];
    }

    private function dateDiff($date1, $date2)
    {
        $date1_ts = strtotime($date1);
        $date2_ts = strtotime($date2);
        $diff = $date2_ts - $date1_ts;
        return round($diff / 86400);
    }
}
