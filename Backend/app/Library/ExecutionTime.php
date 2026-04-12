<?php

namespace App\Library;

class ExecutionTime
{
    private $execution_start = 0;

    public function start()
    {
        $this->execution_start = microtime(true);
        return $this->execution_start;
    }

    public function end()
    {
        $execution_end = microtime(true) - $this->execution_start;
        return round($execution_end*1000). ' ms | It might be 2 to 5 ms less than this time.';
    }
}

