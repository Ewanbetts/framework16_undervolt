#!/bin/bash
set -eu

RYZEN_UV_DIR="$HOME/.local/share/ryzen_uv"

status=$(<"$RYZEN_UV_DIR/statusadj.txt")
allow=$(<"$RYZEN_UV_DIR/allowadj.txt")
experimental=$(<"$RYZEN_UV_DIR/experimentaladj.txt")

# https://github.com/NGnius/PowerTools/issues/84#issuecomment-1482736698
# https://www.amd.com/system/files/documents/faq-curve-optimizer.pdf
# Expect your UV to be 3-5x your set curve value. IE: -5 = -15mv to -25mv

if [[ $allow = "1" ]]
then
    if [[ $experimental = "1" ]]
    then
        echo "0" > "$HOME"/.local/share/ryzen_uv/experimentaladj.txt

        # EXPERIMENTAL SECTION
        # Put experimental settings here - these
        # will never be restored at next startup

        # CPU
        # 0x100000 - 15 (Range: -30, 30)
        ryzenadj --set-coall=0xFFFF0

        # GPU (Currently not working!)
        # 0x100000 - 15 (Range: -30, 30)
        # ryzenadj --set-cogfx=0xFFFF0

        echo "Experimental on" > "$HOME"/.local/share/ryzen_uv/statusadj.txt
    else
        # Fail safe to avoid repeated crashes at startup
        if [[ $status = "Applying undervolt" ]]
        then
            echo "WARNING: Last apply failed or still in progress - skipping"
        else
            echo "Applying undervolt" > "$HOME"/.local/share/ryzen_uv/statusadj.txt

            # UNDERVOLT-ON SECTION
            # Put verified settings here.
            # WARNING: when service is enabled these will be restored
            # at next startup and can make your device unaccessible until you
            # repair/reimage your deck!

            # CPU
            # 0x100000 - 5 (Range: -30, 30)
            ryzenadj --set-coall=0xFFFFB

            # GPU (Currently not working!)
            # 0x100000 - 5 (Range: -30, 30)
            # ryzenadj --set-cogfx=0xFFFFB

            # Wait 10 seconds before declaring the undervolt a success
            sleep 10

            # Only update status if still applying...
            status=$(<"$HOME"/.local/share/ryzen_uv/statusadj.txt)
            if [[ $status = "Applying undervolt" ]]
            then
                echo "Undervolt on" > "$HOME"/.local/share/ryzen_uv/statusadj.txt
            fi
        fi
    fi
else
    # UNDERVOLT-OFF SECTION
    # Put default values here so the off.sh script can disable your tweaks.
    # If you have experimental settings you forget to restore here a restart
    # of your deck will also put the values back to default

    # CPU
    # 0x100000 - 0
    ryzenadj --set-coall=0x100000

    # GPU (Currently not working!)
    # 0x100000 - 0
    # ryzenadj --set-cogfx=0x100000

    echo "Undervolt off" > "$HOME"/.local/share/ryzen_uv/statusadj.txt
fi
