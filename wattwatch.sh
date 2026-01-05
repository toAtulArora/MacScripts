#!/bin/bash

# Default refresh rate
DEFAULT_REFRESH=1

# If the first argument is empty, use the default
REFRESH_RATE="${1:-$DEFAULT_REFRESH}"

while true; do
    # Read values from ioreg
    current=$(ioreg -rw0 -c AppleSmartBattery | grep -o -e '"ChargingCurrent"=[0-9]*' | sed 's/.*=\([0-9]*\).*/\1/')
    # voltage=$(ioreg -rw0 -c AppleSmartBattery |  grep "AppleRawAdapterDetails" | grep -o -e '"AdapterVoltage"=[0-9]*' | sed 's/.*=\([0-9]*\).*/\1/') 
    voltage=$(ioreg -rw0 -c AppleSmartBattery | grep -o -e '"ChargingVoltage"=[0-9]*' | sed 's/.*=\([0-9]*\).*/\1/')
    power_raw=$(ioreg -rw0 -c AppleSmartBattery | grep -o -e '"WallEnergyEstimate"=[0-9]*' | sed 's/.*=\([0-9]*\).*/\1/')
    syspower_raw=$(ioreg -rw0 -c AppleSmartBattery | grep -o -e '"SystemPowerIn"=[0-9]*' | sed 's/.*=\([0-9]*\).*/\1/')
    # power_w2=$(echo "scale=2; $power_raw / 1000" | bc)
    # power_w2=$(echo "scale=2; 0.0000231368267 * $power_raw" | bc)
    power_w2=$(echo "scale=2; 0.00231368267 * $power_raw" | bc)
    # syspower_w2=$(echo "scale=2; $syspower_raw / 1000000" | bc)        
    syspower_w2=$(echo "scale=2; $syspower_raw / 1000" | bc)        
    # syspower_w2=$(echo "scale=2; 0.00231368267 * $syspower_raw" | bc)
    echo "⚡️🔬 Watt Watch            "
    echo "--------------------------"

    # if [[ -z "$current" || -z "$voltage" ]]; then
    if [[ -z "$current" || -z "$power_w2" ]]; then
        echo "Could not read ChargingCurrent or ChargingVoltage from ioreg."
    else
        # Compute mW = mA * mV
        power_mw=$(( current * voltage ))

        # Convert to watts (two decimal places)
        # power_w=$(echo "scale=2; 0.00231368267 * $power_mw" | bc)
        power_w=$(echo "scale=2; $power_mw / 1000000" | bc)        
        # voltage=$(echo "scale=1; $power_raw / $current" | bc)

        echo "Charging Current   | ${current} ~mA    "
        echo "Charging Voltage   | ${voltage} ~mV    "
        echo "Resulting Power    | ${power_w} W      "
        echo "System Power In    | ${syspower_w2} W    "
        echo "WallEnergyEstimate | ${power_w2} W    "
        echo "--------------------------"
    fi
    
    sleep $REFRESH_RATE

    lines=8
    printf "\033[%sA" "$lines" 2>/dev/null

done

# #!/bin/bash

# # Store last 30 power samples for ASCII graph
# declare -a trend=()
# max_points=5

# # Color codes
# RED="\033[31m"
# GREEN="\033[32m"
# YELLOW="\033[33m"
# CYAN="\033[36m"
# RESET="\033[0m"

# # Function to print "watch-like" header (no clear)
# print_header() {
#     printf "\n${CYAN}Mac Charging Monitor — Real-Time${RESET}\n"
#     printf "-----------------------------------\n"
# }

# while true; do
#     # Read battery info
#     current=$(ioreg -rw0 -c AppleSmartBattery | grep -o -e '"ChargingCurrent"=[0-9]*' | sed 's/.*=\([0-9]*\).*/\1/')
#     voltage=$(ioreg -rw0 -c AppleSmartBattery | grep -o -e '"ChargingVoltage"=[0-9]*' | sed 's/.*=\([0-9]*\).*/\1/')

#     # current=$(ioreg -rc AppleSmartBattery | awk -F'= ' '/"ChargingCurrent"/ {print $2}')
#     # voltage=$(ioreg -rc AppleSmartBattery | awk -F'= ' '/"ChargingVoltage"/ {print $2}')
#     # percent=$(ioreg -rc AppleSmartBattery | awk -F'= ' '/"Charge"/ {c=$2} /"MaxCapacity"/ {m=$2} END {if (m>0) printf "%.0f", (c/m)*100}')

#     # Compute power
#     if [[ -n "$current" && -n "$voltage" ]]; then
#         power_mw=$(( current * voltage ))
#         power_w=$(echo "scale=2; $power_mw / 1000000" | bc)
#     else
#         power_w="N/A"
#     fi

#     # Save sample for ASCII trend
#     if [[ "$power_w" != "N/A" ]]; then
#         trend+=("$power_w")
#         if (( ${#trend[@]} > max_points )); then
#             trend=("${trend[@]:1}")  # drop oldest
#         fi
#     fi

#     # Move cursor up to redraw only this section
#     lines=$((2 + max_points / 3 + 3))
#     printf "\033[%sA" "$lines" 2>/dev/null

#     print_header

#     # Decide color for power reading
#     color="$GREEN"
#     if (( $(echo "$power_w < 5" | bc -l) )); then
#         color="$YELLOW"
#     fi
#     if (( $(echo "$current < 0" | bc -l) )); then
#         color="$RED"  # discharging
#     fi

#     # printf "Battery:    %s%%\n" "$percent"
#     printf "Power Draw: ${color}%s W${RESET}\n" "$power_w"

#     printf "\nPower Trend (last %d samples):\n" "$max_points"

#     # ASCII graph — each sample → bar of '#' scaled by wattage
#     for w in "${trend[@]}"; do
#         # scale bar width: 1 char per watt, min 1
#         width=$(printf "%.0f" "$(echo "$w" | awk '{print ($1 < 1) ? 1 : $1}')")
#         printf "%5.2f W | " "$w"
#         printf "%${width}s\n" | tr ' ' '#'
#     done

#     printf "\n(Updated every 1s — Ctrl+C to exit)\n"

#     sleep 1
# done
