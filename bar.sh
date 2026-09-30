#!/bin/sh

# ============================================================
# Lemonbar Configuration
# ============================================================

# --- Bar size / position ---
WIDTH=700
HEIGHT=28
Y=8

# Center horizontally
SCREEN_WIDTH=$(xrandr | awk '/ connected primary/{print $4}' | cut -d'x' -f1)

# Fallback if there is no "primary" output
if [ -z "$SCREEN_WIDTH" ]; then
    SCREEN_WIDTH=$(xrandr | awk '/ connected/{print $3}' | head -n1 | cut -d'x' -f1)
fi

X=$(( (SCREEN_WIDTH - WIDTH) / 2 ))


# ============================================================
# Colors
# ============================================================

# Dark wallpaper / ship interior
BG="#0B0D0D"

# Warm off-white
FG="#ded6c7"

# Blue from the wallpaper
BLUE="#739BB5"

# Muted text
MUTED="#817b70"


# ============================================================
# Font
# ============================================================



# ============================================================
# Get active workspace
# ============================================================

get_workspace() {
    xprop -root _NET_CURRENT_DESKTOP 2>/dev/null |
        awk -F'= ' '{print $2}' |
        tr -d ' '
}


# ============================================================
# Draw a workspace number
# ============================================================

workspace() {
    WS="$1"
    ACTIVE="$2"

    if [ "$WS" = "$ACTIVE" ]; then
        # Active workspace:
        # blue background with dark text
        printf '%%{B%s}%%{F%s}  %s  %%{B-}%%{F-}' \
            "$BLUE" \
            "$BG" \
            "$WS"
    else
        # Inactive workspace
        printf '  %s  ' "$WS"
    fi
}


# ============================================================
# Main loop
# ============================================================

while :; do

    # Current time
    TIME=$(date '+%I:%M %p')

if [ "$(pactl get-sink-mute @DEFAULT_SINK@ | awk '{print $2}')" = "yes" ]; then
    VOLUME="MUTE"
else
    VOLUME=$(pactl get-sink-volume @DEFAULT_SINK@ |
        grep -o '[0-9]\+%' |
        head -1)

    [ -z "$VOLUME" ] && VOLUME="0%"
fi

    # Get SXWM workspace
    ACTIVE=$(get_workspace)

    # SXWM/X11 starts at workspace 0,
    # while the bar displays workspaces 1-6.
    if [ -n "$ACTIVE" ]; then
        ACTIVE=$((ACTIVE + 1))
    fi


    # --------------------------------------------------------
    # Left side: 1 2 3
    # --------------------------------------------------------

    LEFT="$(workspace 1 "$ACTIVE")  $(workspace 2 "$ACTIVE")  $(workspace 3 "$ACTIVE")"


    # --------------------------------------------------------
    # Right side: 4 5 6
    # --------------------------------------------------------

    RIGHT="$(workspace 4 "$ACTIVE")  $(workspace 5 "$ACTIVE")  $(workspace 6 "$ACTIVE")"


    # --------------------------------------------------------
    # Draw everything
    # --------------------------------------------------------

   printf '%%{l}%s%%{c}%%{F%s}%s  %s%%{F-}%%{r}%s\n' \
    "$LEFT" \
    "$FG" \
    "$TIME" \
    "$VOLUME" \
    "$RIGHT" 

    sleep 0.2

done | /home/norm/.config/lemonbar/lemonbar \
    -g "${WIDTH}x${HEIGHT}+${X}+${Y}" \
    -B "$BG" \
    -F "$FG" \
    -f "Simsun-ExtB:size=14"
