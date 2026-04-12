<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Models\DeviceVital;

/**
 * MQTT Subscriber Command
 * 
 * This command subscribes to the MQTT broker and listens for incoming
 * vital data from hardware devices.
 * 
 * Usage:
 *   php artisan mqtt:subscribe
 * 
 * Requirements:
 *   composer require php-mqtt/client
 * 
 * Configuration (add to .env):
 *   MQTT_HOST=31.97.60.61
 *   MQTT_PORT=1883
 *   MQTT_CLIENT_ID=docuhealth-backend
 *   MQTT_USERNAME=your_username
 *   MQTT_PASSWORD=your_password
 *   MQTT_TOPIC=v1/gateway/telemetry
 */
class MqttSubscriber extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'mqtt:subscribe 
                            {--host= : MQTT broker host}
                            {--port= : MQTT broker port}
                            {--topic= : Topic to subscribe to}';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Subscribe to MQTT broker and store incoming vital readings';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        // Check if php-mqtt/client is installed
        if (!class_exists('\PhpMqtt\Client\MqttClient')) {
            $this->error('php-mqtt/client is not installed.');
            $this->info('Run: composer require php-mqtt/client');
            return 1;
        }

        $host = $this->option('host') ?? env('MQTT_HOST', '31.97.60.61');
        $port = (int) ($this->option('port') ?? env('MQTT_PORT', 1883));
        $clientId = env('MQTT_CLIENT_ID', 'docuhealth-backend-' . uniqid());
        $username = env('MQTT_USERNAME');
        $password = env('MQTT_PASSWORD');
        $topic = $this->option('topic') ?? env('MQTT_TOPIC', 'v1/gateway/telemetry');

        $this->info("Connecting to MQTT broker: $host:$port");
        $this->info("Topic: $topic");
        $this->info("Client ID: $clientId");

        try {
            $mqtt = new \PhpMqtt\Client\MqttClient($host, $port, $clientId);
            
            $connectionSettings = (new \PhpMqtt\Client\ConnectionSettings())
                ->setKeepAliveInterval(60)
                ->setConnectTimeout(10);

            if ($username) {
                $connectionSettings->setUsername($username);
            }
            if ($password) {
                $connectionSettings->setPassword($password);
            }

            $mqtt->connect($connectionSettings, true);
            $this->info("Connected to MQTT broker successfully!");

            // Subscribe to the topic
            $mqtt->subscribe($topic, function (string $topic, string $message) {
                $this->processMessage($topic, $message);
            }, 1);

            $this->info("Subscribed to topic: $topic");
            $this->info("Listening for messages... Press Ctrl+C to stop.");
            $this->newLine();

            // Loop and listen for messages
            $mqtt->loop(true);

        } catch (\PhpMqtt\Client\Exceptions\MqttClientException $e) {
            $this->error("MQTT Error: " . $e->getMessage());
            return 1;
        } catch (\Exception $e) {
            $this->error("Error: " . $e->getMessage());
            return 1;
        }

        return 0;
    }

    /**
     * Process incoming MQTT message and store vital readings
     */
    protected function processMessage(string $topic, string $message): void
    {
        $timestamp = now()->format('Y-m-d H:i:s');
        $this->line("[$timestamp] Received on '$topic':");
        $this->line("  Payload: $message");

        try {
            $created = DeviceVital::createFromMqttPayload($message);

            if (empty($created)) {
                $this->warn("  No valid vitals in payload");
                return;
            }

            foreach ($created as $vital) {
                $this->info("  Saved: {$vital->device_name} - {$vital->vital_type}: {$vital->value} {$vital->unit}");
            }

        } catch (\Exception $e) {
            $this->error("  Failed to save: " . $e->getMessage());
            \Log::error('MQTT message processing failed', [
                'topic' => $topic,
                'message' => $message,
                'error' => $e->getMessage(),
            ]);
        }

        $this->newLine();
    }
}
