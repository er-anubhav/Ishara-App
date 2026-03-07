const String baseUrl = String.fromEnvironment(
  'BASE_URL',
  defaultValue: 'http://147.93.96.116:9000/api/v1/',
);

// MQTT Broker Configuration
const String mqttBrokerHost = String.fromEnvironment(
  'MQTT_HOST',
  defaultValue: '31.97.60.61',
);

const int mqttBrokerPort = int.fromEnvironment(
  'MQTT_PORT',
  defaultValue: 1883,
);


const String mqttClientId = String.fromEnvironment(
  'MQTT_CLIENT_ID',
  defaultValue: '8mb6rybljg63kg6ivruu',
);

const String mqttUsername = String.fromEnvironment(
  'MQTT_USERNAME',
  defaultValue: 'jtfdracmu93nnckz69kl',
);

const String mqttPassword = String.fromEnvironment(
  'MQTT_PASSWORD',
  defaultValue: 'xdwvrmmcrlhxhmfqsw0a',
);

const String mqttTelemetryTopic = String.fromEnvironment(
  'MQTT_TOPIC',
  defaultValue: 'v1/gateway/telemetry',
);
