<?php

namespace App\Library;

trait MakeReminder{

	public function make_reminders($data = [], $date = '')
	{
		$reminders = [];
		$currentDate = $date ? $date : date('d-m-Y') ;
		$todayWeekName = date('l'); 

		foreach ($data as $value) {

			if($value->event_type == 'Daily'){

				array_push($reminders, $value);
			}

			elseif ($value->event_type == 'Once') {
					
				if (in_array($currentDate, $value->event_at)) {
					array_push($reminders, $value);
				}
			}

			elseif($value->event_type == 'Weekly'){

				if (in_array($todayWeekName, $value->event_at)) {
					array_push($reminders, $value);
				}
			}

			elseif($value->event_type == 'Date Range'){

				if (in_array($currentDate, $value->event_at)) {
					array_push($reminders, $value);
				}
			}
		}
		return $reminders;
	}

	public function beutify_reminder($reminder = [])
	{
		return $reminder;
	}

}