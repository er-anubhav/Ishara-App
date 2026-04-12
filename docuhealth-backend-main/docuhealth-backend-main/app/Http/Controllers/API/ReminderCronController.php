<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use App\Library\Structure;
use App\Library\ExecutionTime;
use App\Events\Reminder;

class ReminderCronController extends Controller
{
    // Structure of response API.
    use Structure;

    public function reminders(Request $request)
    {
        Reminder::dispatch();
        return response()->json($this->structure(true, 'Reminder event running...'), 200);
    }

} //Class End Tag.
