use std::env;
use std::net::TcpStream;
use std::io::{Read, Write};

use serde_json::Value;
use paho_mqtt as mqtt;
use dotenvy::dotenv;
use anyhow::{Context, Result};

fn main() -> Result<()> {
    // Load environment variables from a `.env` file if available
    dotenv().ok();

    // Load MQTT credentials and configuration, with sensible defaults where possible
    let mqtt_user = env::var("MQTT_USER").unwrap_or_else(|_| "joseph".to_string());
    let mqtt_pass = env::var("MQTT_PASS").context("MQTT_PASS not set")?;
    let mqtt_ip = env::var("MQTT_IP").unwrap_or_else(|_| "192.168.0.115".to_string());
    let mqtt_port = env::var("MQTT_PORT").unwrap_or_else(|_| "1883".to_string());
    let komeo_ip = env::var("KOMEO_IP").unwrap_or_else(|_| "192.168.0.15".to_string());

    // Connect to the Komeo device over TCP port 23 (commonly Telnet)
    let mut stream = TcpStream::connect(format!("{}:23", komeo_ip))
        .context("Failed to connect to Komeo device")?;

    // Prepare the message to request sensor data
    let message = br#"{
        "1234567": {
            "msgId": 5,
            "read": [
                "status", "wear", "pressure", "waterFlow",
                "flow", "consumption", "about"
            ]
        }
    }"#;

    // Send the request to the Komeo device
    stream.write_all(message).context("Failed to send request")?;

    // Read the response into a buffer
    let mut buffer = vec![0; 2048];
    let size = stream.read(&mut buffer).context("Failed to read response")?;

    // Parse the JSON response
    let json: Value = serde_json::from_slice(&buffer[..size])
        .context("Failed to parse JSON response")?;

    let data = &json["1234567"]["read"];

    // Helper function to create MQTT messages
    let create_msg = |topic: &str, val: &Value| {
        mqtt::Message::new(topic, val.to_string(), mqtt::QOS_1)
    };

    // Initialize MQTT client
    let cli = mqtt::Client::new(format!("tcp://{}:{}", mqtt_ip, mqtt_port))
        .context("Error creating MQTT client")?;

    // Setup connection options with authentication
    let conn_opts = mqtt::ConnectOptionsBuilder::new()
        .user_name(mqtt_user)
        .password(mqtt_pass)
        .finalize();

    // Connect to the MQTT broker
    cli.connect(conn_opts).context("Failed to connect to MQTT broker")?;

    // List of topics and associated data to publish
    let topics = vec![
        ("komeo/wear/filt1", &data["wear"]["filt1"]),
        ("komeo/wear/filt2", &data["wear"]["filt2"]),
        ("komeo/wear/prefilt", &data["wear"]["prefilt"]),
        ("komeo/wear/lamp", &data["wear"]["lamp"]),
        ("komeo/wear/bat", &data["wear"]["bat"]),
        ("komeo/pressure/max", &data["pressure"]["max"]),
        ("komeo/pressure/min", &data["pressure"]["min"]),
        ("komeo/pressure/avge", &data["pressure"]["avge"]),
        ("komeo/pressure/inst", &data["pressure"]["inst"]),
        ("komeo/consumption/week", &data["consumption"]["week"]),
        ("komeo/consumption/month", &data["consumption"]["month"]),
        ("komeo/consumption/day", &data["consumption"]["day"]),
        ("komeo/flow/max", &data["flow"]["max"]),
        ("komeo/flow/avge", &data["flow"]["avge"]),
        ("komeo/flow/inst", &data["flow"]["inst"]),
        ("komeo/status/defect", &data["status"]["defect"]),
        ("komeo/status/warning", &data["status"]["warning"]),
        ("komeo/status/mode", &data["status"]["mode"]),
        ("komeo/status/uvc", &data["status"]["uvc"]),
    ];

    // Publish each topic with its corresponding value
    for (topic, val) in topics {
        let msg = create_msg(topic, val);
        cli.publish(msg).context(format!("Failed to publish topic: {}", topic))?;
    }

    // Disconnect gracefully from the MQTT broker
    cli.disconnect(None).context("Failed to disconnect from MQTT broker")?;

    Ok(())
}
