<?php

namespace App\Listeners;

use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Queue\InteractsWithQueue;
use App\Library\PushNotification;
use App\Library\DisplayPath;
use App\Models\ReminderActivity;
use App\Events\Reminder;

class PushReminder
{
    /**
     * Handle the event.
     *
     * @param  \App\Events\Reminder  $event
     * @return void
     */
    public function handle(Reminder $event)
    {
        $icon = DisplayPath::reminder_notification();
        $reminders = $event->reminders;

        foreach ($reminders as $reminder) {

            $activity = ReminderActivity::create([
                    'reminder_id' => $reminder->id,
                    'date' => date('Y-m-d'),
                    'time' => date('H:i', strtotime($reminder->time)),
            ]);

            $data = [
                    "target_id" => $activity->id,
                    "notification_type" => 'reminder',
                    "redirect_to" => 'reminders',
                    "datetime" => date("d-m-Y h:i A"),
                    "content" => [
                        "title" => $reminder->name,
                        "body" => $reminder->time,
                        "image_url" => $icon,
                        "image_show" => true,
                        "autoDismissible" => true,
                    ],
            ];

            if ($activity->snooze) {
                
                $data["actionButtons"] = [
                    [
                        "key" => "SNOOZE",
                        "label" => "SNOOZE",
                        "autoDismissible" => true,
                        "isDangerousOption" => true
                    ],
                    [
                        "key" => "ACCEPT",
                        "label" => "ACCEPT",
                        "autoDismissible" => true,
                        "buttonType" =>  "Default"
                    ],
                ];
            }else{
                $data["actionButtons"] = [
                    [
                        "key" => "ACCEPT",
                        "label" => "ACCEPT",
                        "autoDismissible" => true,
                        "buttonType" =>  "Default"
                    ],
                ];
            }
            
            $device_token = json_decode(json_encode([$reminder->device_token], true), true);
            $pushNotification = new PushNotification($device_token, $data);
            $pushNotification->send();
        }
    }

    
}
