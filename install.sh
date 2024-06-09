#!/bin/sh
set -eu

cp_file() {
    cp "${1}${3}" "${2}${3}"
}

# Check if sudo is available
if ! command -v sudo >/dev/null 2>&1; then
    echo "sudo is required but it's not installed. Please install sudo and try again."
    exit 1
fi

# Install files in the user's home directory
echo "Installing files in the user's home directory..."
fromPath="home/"
toPath="$HOME/.local/bin/"
mkdir -p "$toPath"
cp_file $fromPath "$toPath" "allowadj.txt"
cp_file $fromPath "$toPath" "experimental.sh"
cp_file $fromPath "$toPath" "experimentaladj.txt"
cp_file $fromPath "$toPath" "off.sh"
cp_file $fromPath "$toPath" "on.sh"
cp_file $fromPath "$toPath" "set-ryzenadj-tweaks.sh"
cp_file $fromPath "$toPath" "statusadj.txt"

# Function to run cp_file with sudo
sudo_cp_file() {
    sudo sh -c "$(declare -f cp_file); cp_file $1 $2 $3"
}

# Install system files with sudo
echo "Installing system files with root privileges..."
fromPath="./etc/systemd/system/"
toPath="/etc/systemd/system/"
sudo_cp_file $fromPath $toPath "ac.target"
sudo_cp_file $fromPath $toPath "battery.target"
sudo_cp_file $fromPath $toPath "set-ryzenadj-tweaks.path"
sudo_cp_file $fromPath $toPath "set-ryzenadj-tweaks.service"

fromPath="./etc/udev/rules.d/"
toPath="/etc/udev/rules.d/"
sudo_cp_file $fromPath $toPath "99-powertargets.rules"

# Set permissions on files
echo "Set permissions on files..."
chmod 666 "$toPath""allowadj.txt"
chmod 666 "$toPath""experimentaladj.txt"
chmod 755 "$toPath""experimental.sh"
chmod 755 "$toPath""on.sh"
chmod 755 "$toPath""off.sh"

# Ensure undervolt is off
echo "Ensuring undervolt is off..."
bash "$toPath""off.sh"

# Enable new powertarget rules with sudo
echo "Enable new powertarget rules..."
sudo udevadm control --reload-rules

# Enable path listener with sudo
echo "Enable path listener..."
sudo systemctl enable --now set-ryzenadj-tweaks.path

# Enable set-ryzenadj-tweaks service with sudo
echo "Enabling set-ryzenadj-tweaks service..."
sudo systemctl enable set-ryzenadj-tweaks.service

echo "Installation done."
echo ""
echo "Toggle with on.sh, off.sh and experimental.sh"
echo "First try the on.sh script. It does a small -5 curve"
echo "offset. If it works fine you can try the experimental.sh"
echo "script. It does a much more ambitious -15 curve offset."
echo ""
echo "NOTE: It might cause a hard crash or a hang but you can"
echo "just restart."
echo ""
echo "If the experimental setting also works fine you can edit"
echo "the undervolt settings in the 'experimental' and"
echo "'undervolt-on' sections of"
echo "$HOME/.local/bin/set-ryzenadj-tweaks.sh"
echo "script moving the -15 curve offset to the 'undervolt-on'"
echo "section and making a more ambitious setting for the"
echo "'experimental' section, e.g., a -20 curve offset."
echo "If the experimental setting doesn't work you should go for"
echo "a less ambitious setting in the 'experimental' section,"
echo "eg., a -10 curve."
echo "In any case you can go and test your new"
echo "experimental setting. Repeat until you find the best stable"
echo "setting and put that on the 'undervolt-on' section."
echo ""
echo "If something goes wrong and the deck hangs while applying"
echo "undervolt then all further undervolting attempts are"
echo "disabled. The file '$HOME/.local/bin/statusadj.txt'"
echo "acts as a fail safe. It will contain the text"
echo "'Applying undervolt' after a failed restart. Make a less"
echo "ambitious undervolt setting and clear the contents of the"
echo "file to reactivate undervolting."
