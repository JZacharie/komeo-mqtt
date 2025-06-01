use std::env;
use std::net::TcpStream;
use std::io::{Write, Read};

use serde_json::Value;
use paho_mqtt as mqtt;
use dotenvy::dotenv;
use anyhow::{Context, Result};

fn main() -> Result<()> {
    dotenv().ok(); // Load .env file

    let mqtt_user = env::var("MQTT_USER").unwrap_or_else(|_| "joseph".to_string());
    let mqtt_pass = env::var("MQTT_PASS").context("MQTT_PASS not set")?;
    let mqtt_ip = env::var("MQTT_IP").unwrap_or_else(|_| "192.168.0.115".to_string());
    let mqtt_port = env::var("MQTT_PORT").unwrap_or_else(|_| "1883".to_string());
    let komeo_ip = env::var("KOMEO_IP").unwrap_or_else(|_| "192.168.0.15".to_string());

    // Connect to TCP socket
    let mut stream = TcpStream::connect(format!("{}:23", komeo_ip))
        .context("Failed to connect to Komeo device")?;

    let message = b"{"1234567": { "msgId": 5, "read": ["status", "wear", "pressure", "waterFlow", "flow", "consumption", "about"]}}";
    stream.write_all(message)?;

    let mut buffer = vec![0; 2048];
    let size = stream.read(&mut buffer)?;
    let json: Value = serde_json::from_slice(&buffer[..size])?;

    let data = &json["1234567"]["read"];

    let create_msg = |topic: &str, val: &Value| {
        mqtt::Message::new(topic, val.to_string(), mqtt::QOS_1)
    };

    let cli = mqtt::Client::new(format!("tcp://{}:{}", mqtt_ip, mqtt_port))
        .context("Error creating MQTT client")?;

    let conn_opts = mqtt::ConnectOptionsBuilder::new()
        .user_name(mqtt_user)
        .password(mqtt_pass)
        .finalize();

    cli.connect(conn_opts)?;

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

    for (topic, val) in topics {
        let msg = create_msg(topic, val);
        cli.publish(msg)?;
    }

    cli.disconnect(None)?;
    Ok(())
}
