# Framework 16 Undervolt

This repository offers an easy way to undervolt a Framework 16 as safely as possible and without entering the BIOS (Smokeless UMAF) using [RyzenAdj](https://github.com/FlyGoat/RyzenAdj) and systemd targets based on [Chris Down's guide](https://chrisdown.name/2017/10/29/adding-power-related-targets-to-systemd.html).

RyzenADJ must be installed already.

## Warning

As with any undervolt, exercise caution. While this project greatly reduces the risk of making your system unbootable, it does not in any way guarantee you won't damage your hardware. Use at your own risk.

## Installation

1. Clone this repository
2. Navigate to the repository root folder
3. Make the script `install.sh` executable: `chmod +x install.sh`
4. Run it with root privileges: `sudo ./install.sh`

The script will:
- Install a new service `set-ryzenadj-tweaks.service`
- Create additional service activation rules
- Copy necessary files to the `$HOME/.local/share/ryzen_uv/` folder

Undervolt amount can be changed by editing `$HOME/.local/share/ryzen_uv/set-ryzenadj-tweaks.sh`

By default, a `-5` [curve optimization](https://www.amd.com/system/files/documents/faq-curve-optimizer.pdf) is applied (via `-set-coall`) in the 'undervolt-on' section, which should be stable on most hardware.

A much more ambitious `-15` curve optimization is applied in the `experimental` section. This setting might be stable but it might also cause a crash/hang if applied.

## Activation

By default, no undervolt is applied until you run either the `on.sh` or the `experimental.sh` scripts.

### The on, off, and experimental scripts

Add `on.sh`, `off.sh`, and `experimental.sh` from the `~/.local/share/ryzen_uv/` folder as non-steam apps and run them from game mode to control undervolt status.

* `on.sh`: Enables undervolt in the `undervolt-on` section. This setting will be restored if you restart your system unless you have run the `off.sh` script before restart.
* `experimental.sh`: Enables undervolt in the `experimental` section. The experimental setting is applied only once and is not restored if you restart your system.
* `off.sh`: Disables undervolt.

## Uninstall

If you don't want to undervolt anymore, you can uninstall the service, remove the additional service activation rules, and delete the files from `~/.local/share/ryzen_uv/` via the uninstall.sh script.

1. Navigate to the repository root folder
2. Make the script `uninstall.sh` executable: `chmod +x uninstall.sh`
3. Run it with root privileges: `sudo ./uninstall.sh`

## Troubleshooting

If something goes wrong and the system hangs while applying undervolt, all further undervolting attempts are disabled. The file `$HOME/.local/share/ryzen_uv/statusadj.txt` acts as a fail-safe. It will contain the text "Applying undervolt" after a failed restart. 

To reactivate undervolting:
1. Make a less ambitious undervolt setting in the `set-ryzenadj-tweaks.sh` script
2. Clear the contents of the `statusadj.txt` file

Always exercise caution when adjusting undervolt settings.