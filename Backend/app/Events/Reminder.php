<?php

namespace App\Events;

use Illuminate\Broadcasting\InteractsWithSockets;
use Illuminate\Foundation\Events\Dispatchable;
use Illuminate\Queue\SerializesModels;
use App\Models\Reminder as ReminderModal;
use App\Models\ReminderActivity;
use DatePeriod;
use DateInterval;
use DateTime;

class Reminder
{
    use Dispatchable, InteractsWithSockets, SerializesModels;

    /**
     * Create a new event instance.
     *
     * @return void
     */
    public function __construct()
    {
        $this->reminders = $this->leatest();
    }

    public function leatest()
    {
        $data = [];
        $today = date('d-m-Y');
        $todayWeek = date('l'); 
        $time = date('H:i');

        $reminders = ReminderModal::join('user_profiles as up', 'up.id', 'reminders.profile_id')->where('up.device_token', '!=', NULL)
                                            ->where('reminders.status', true)->where('reminders.time', $time)
                                            ->select('reminders.id', 'reminders.name', 'reminders.event_type', 'reminders.event_at', 'reminders.time', 'reminders.snooze', 'reminders.snooze_interval as interval', 'reminders.snooze_repeat as repeat','up.device_token')->get();
        try {
            
            foreach ($reminders as $key => $value) {
                
                if($value->event_type == 'Daily'){

                    array_push($data, $value);
                }
                elseif ($value->event_type == 'Once') {
                        
                    if (in_array($today, $value->event_at)) {
                        array_push($data, $value);
                    }
                }
                elseif($value->event_type == 'Weekly'){

                    if (in_array($todayWeek, $value->event_at)) {
                        array_push($data, $value);
                    }
                }
                elseif($value->event_type == 'Date Range'){

                    if (in_array($today, $this->date_range($value->event_at))) {
                        array_push($data, $value);
                    }
                }
            }
        } catch (\Exception $e) {
            \Log::info($e->getMessage());
            return 'Execution failed!!';
        } catch (\Error $e) {
            \Log::info($e->getMessage());
            return 'Execution failed!!';
        }

        return $data;
    }

    private function date_range($event_at, $format = 'd-m-Y')
    {
        $dates = [];
        $periods = new DatePeriod( new DateTime($event_at[0]), new DateInterval('P1D'), new DateTime($event_at[1]) );

        foreach ($periods as $period) {
            array_push($dates, $period->format($format));       
        }
        array_push($dates, $event_at[1]);

        return $dates;
    }
}
