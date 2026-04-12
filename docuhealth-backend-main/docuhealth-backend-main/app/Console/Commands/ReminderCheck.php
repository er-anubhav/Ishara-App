<?php
   
namespace App\Console\Commands;
   
use Illuminate\Console\Command;
use App\Events\Reminder;
   
class ReminderCheck extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'reminder:check';
    
    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'This command is use for run cron for reminders';
    
    /**
     * Create a new command instance.
     *
     * @return void
     */
    public function __construct()
    {
        parent::__construct();
    }
    
    /**
     * Execute the console command.
     *
     * @return mixed
     */
    public function handle()
    {
        \Log::info("Finding Reminders...");

        Reminder::dispatch();
    }
}