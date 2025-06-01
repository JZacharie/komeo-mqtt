
# 🧠 Komeo MQTT Exporter

![Build](https://img.shields.io/github/actions/workflow/status/your-org/komeo-mqtt/docker.yml?branch=main&label=build)
![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Rust](https://img.shields.io/badge/rust-stable-brightgreen.svg)

> ⚙️ A minimal Rust binary to read JSON data from a TCP socket, parse it, and publish key metrics to an MQTT broker.

---

## 🚀 Features

- 🪶 **Ultra-light**: Built with minimal Rust dependencies (`serde`, `rumqttc`, `dotenvy`)
- 🔐 **Secure**: Credentials managed via environment variables
- 🌐 **MQTT-ready**: Publishes Komeo metrics directly to your MQTT broker
- 🧪 **CI/CD**: GitHub Actions workflow included for Docker builds
- 📦 **Static binary**: Cross-compilable for Alpine, ARM, x86_64
- 🛠️ **Customizable**: Easy to add new sensors or message types

---

## 🧰 Requirements

- Rust (1.70+ recommended)
- An MQTT broker (like Mosquitto)
- A TCP JSON-speaking device (Komeo)
- `dotenv` CLI (optional for local dev)

---

## 🛠️ Usage

### 1. Clone & Build

```bash
git clone https://github.com/your-org/komeo-mqtt.git
cd komeo-mqtt
cargo build --release
```

Or using Docker:

```bash
docker build -t komeo-mqtt .
```

---

### 2. Configure Environment

Create a `.env` file or set variables manually:

```env
MQTT_USER=joseph
MQTT_PASS=supersecure
MQTT_IP=192.168.0.115
MQTT_PORT=1883
KOMEO_IP=192.168.0.15
KOMEO_PORT=23
```

---

### 3. Run the Binary

```bash
./target/release/komeo-mqtt
```

Or in a container:

```bash
docker run --env-file .env komeo-mqtt
```

---

## 📦 Output Topics (MQTT)

| Topic                      | Description             |
|---------------------------|-------------------------|
| `komeo/wear/filt1`        | Filter 1 wear level     |
| `komeo/pressure/inst`     | Instant pressure        |
| `komeo/consumption/month` | Monthly consumption     |
| ...                       | And many more!          |

---

## 📂 Project Structure

```text
komeo-mqtt/
├── .env                      # Sample environment variables
├── Dockerfile                # Minimal static image
├── src/
│   └── main.rs               # Rust source code
├── Cargo.toml                # Project metadata and dependencies
└── .github/
    └── workflows/
        └── docker.yml        # CI workflow
```

---

## 👷 GitHub Actions (CI/CD)

✅ Automatically builds Docker image on push  
🧪 Future improvement: Add MQTT + Komeo simulation tests

---

## 📃 License

This project is licensed under the MIT License.  
Feel free to use, contribute, and improve!

---

## 💡 Tips

- Use [`mosquitto_sub`](https://mosquitto.org/) to view live data:

```bash
mosquitto_sub -h $MQTT_IP -t "komeo/#" -u $MQTT_USER -P $MQTT_PASS
```

---

## 🙋‍♂️ Contribute

Pull requests are welcome! Feel free to open issues or suggest enhancements.
