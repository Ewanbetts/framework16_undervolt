#!/usr/bin/env bash
set -eu

cp_file()
{
    cp "${1}${3}" "${2}${3}"
}

# Check for root privileges
if [ "$(id -u)" != "0" ]
then
    echo "This script must be run with root privileges"
    exit 1
fi

# Function to replace home directory placeholder in file
replace_home_in_file() {
    sed "s|__HOME__|$HOME|g" "$1" > "$2"
}

# Function to list available directories in /home and prompt user to choose one
choose_home_directory() {
    echo "Available directories in /home:"
    select dir in /home/*; do
        if [ -n "$dir" ]; then
            echo "You have selected: $dir"
            read -p "Do you want to proceed with this directory as the new HOME? (y/n): " confirm
            case $confirm in
                [Yy]* )
                    export HOME="$dir"
                    break
                    ;;
                [Nn]* )
                    echo "Please select a different directory."
                    ;;
                * )
                    echo "Please answer yes or no."
                    ;;
            esac
        else
            echo "Invalid selection. Please try again."
        fi
    done
}

# Call the function to choose home directory
choose_home_directory
echo "The HOME directory chosen is: $HOME"

# Install files in the user's home directory
echo "Installing files in $HOME..."
fromPath="home/"
toPath="$HOME/.local/share/ryzen_uv/"
mkdir -p "$toPath"

cp_file $fromPath "$toPath" "allowadj.txt"
cp_file $fromPath "$toPath" "experimental.sh"
cp_file $fromPath "$toPath" "experimentaladj.txt"
cp_file $fromPath "$toPath" "off.sh"
cp_file $fromPath "$toPath" "on.sh"
cp_file $fromPath "$toPath" "statusadj.txt"

# Replace home directory in target script and copy
replace_home_in_file "${fromPath}set-ryzenadj-tweaks.sh" "/tmp/set-ryzenadj-tweaks.sh"
cp "/tmp/set-ryzenadj-tweaks.sh" "$HOME/.local/share/ryzen_uv/set-ryzenadj-tweaks.sh"

# Install system files
echo "Installing system files with root privileges..."
fromPath="etc/systemd/system/"
toPath="/etc/systemd/system/"

# Replace home directory in templates and copy
replace_home_in_file "${fromPath}set-ryzenadj-tweaks.path.template" "/tmp/set-ryzenadj-tweaks.path"
replace_home_in_file "${fromPath}set-ryzenadj-tweaks.service.template" "/tmp/set-ryzenadj-tweaks.service"
cp "/tmp/set-ryzenadj-tweaks.path" "${toPath}set-ryzenadj-tweaks.path"
cp "/tmp/set-ryzenadj-tweaks.service" "${toPath}set-ryzenadj-tweaks.service"
cp_file $fromPath $toPath "ac.target"
cp_file $fromPath $toPath "battery.target"

fromPath="etc/udev/rules.d/"
toPath="/etc/udev/rules.d/"
cp_file $fromPath $toPath "99-powertargets.rules"

echo "Set permissions on files..."
toPath="$HOME/.local/bin/"
chmod 666 "$toPath""allowadj.txt"
chmod 666 "$toPath""experimentaladj.txt"
chmod 755 "$toPath""experimental.sh"
chmod 755 "$toPath""on.sh"
chmod 755 "$toPath""off.sh"

echo "Ensuring undervolt is off..."
bash "$toPath""off.sh"

# Enable new powertarget rules with sudo
echo "Enable new powertarget rules..."
udevadm control --reload-rules

# Enable path listener
echo "Enable path listener..."
systemctl enable --now set-ryzenadj-tweaks.path

# Enable set-ryzenadj-tweaks service with sudo
echo "Enabling set-ryzenadj-tweaks service..."
systemctl enable set-ryzenadj-tweaks.service

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
echo "$HOME/.local/share/ryzen_uv/set-ryzenadj-tweaks.sh"
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
echo "disabled. The file '$HOME/.local/share/ryzen_uv/statusadj.txt'"
echo "acts as a fail safe. It will contain the text"
echo "'Applying undervolt' after a failed restart. Make a less"
echo "ambitious undervolt setting and clear the contents of the"
echo "file to reactivate undervolting."
