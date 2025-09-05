#!/bin/bash
set -e

echo "🔧 Installing required packages..."
sudo apt update
sudo apt install -y cmake g++ git libboost-dev libevdev-dev libyaml-cpp-dev pkg-config make

echo "📁 Cloning interception-tools..."
TMP_DIR="/tmp/interception-tools"
if [ -d "$TMP_DIR" ]; then
    sudo rm -rf "$TMP_DIR"
fi
git clone https://gitlab.com/interception/linux/tools.git "$TMP_DIR"

echo "🛠️ Building interception-tools and caps2esc..."
cd "$TMP_DIR"
mkdir build && cd build
cmake ..
make

echo "🚚 Installing binaries..."
sudo make install

echo "📁 Building and installing caps2esc plugin..."
cd "$TMP_DIR/plugins/caps2esc"
mkdir build && cd build
cmake ..
make
sudo make install

echo "🧰 Creating udevmon config..."
sudo mkdir -p /etc/interception
cat <<EOF | sudo tee /etc/interception/udevmon.yaml > /dev/null
- JOB: "intercept -g \$DEVNODE | caps2esc | uinput -d \$DEVNODE"
  DEVICE:
    EVENTS:
      EV_KEY: [KEY_CAPSLOCK, KEY_ESC, KEY_LEFTCTRL]
EOF

echo "📝 Setting udev rules for keyboard..."
cat <<EOF | sudo tee /etc/udev/rules.d/90-input-group.rules > /dev/null
KERNEL=="event*", ATTRS{name}=="AT Translated Set 2 keyboard", GROUP="input", MODE="660"
EOF

echo "📝 Setting udev rules for uinput..."
cat <<EOF | sudo tee /etc/udev/rules.d/99-uinput.rules > /dev/null
KERNEL=="uinput", MODE="0666"
EOF

echo "🔄 Reloading udev rules..."
sudo udevadm control --reload-rules
sudo udevadm trigger

echo "👥 Adding user '$USER' to input group..."
sudo usermod -aG input $USER

echo "🔌 Loading uinput module..."
sudo modprobe uinput

echo "🔁 Enabling and starting udevmon service..."
sudo systemctl enable udevmon.service
sudo systemctl restart udevmon.service

echo "✅ All done! Please log out and log back in to apply group changes."

