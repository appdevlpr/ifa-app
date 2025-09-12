#!/bin/bash
# ======================================
# Interactive Vite + Tunnel launcher
# Filename: vite-ng.sh
# Termux + Proot-Debian ready
# ======================================

echo "🚀 Vite + Tunnel interactive launcher"

# ===== CONFIG =====
MOUNT_POINT="$HOME/android_storage"
RECOMMENDED_PATH="$MOUNT_POINT/appDev"
FALLBACK_DIR="$HOME"
DEFAULT_VITE_PORT=5173

# ===== STEP 0: Setup storage folder =====
[ ! -d "$MOUNT_POINT" ] && mkdir -p "$MOUNT_POINT"
mkdir -p "$RECOMMENDED_PATH"

# ===== STEP 0b: Prepare and verify paths =====
prepare_path() {
    local path="$1"
    local create="$2"   # "yes" to allow creating
    if [ ! -e "$path" ]; then
        if [[ "$create" == "yes" ]]; then
            echo "⚡ Path does not exist. Creating: $path"
            mkdir -p "$path" || { echo "❌ Could not create $path"; exit 1; }
        else
            echo "❌ Path does not exist: $path"
            exit 1
        fi
    fi
    if [ ! -r "$path" ] || [ ! -w "$path" ]; then
        echo "❌ Path not readable/writable: $path"
        exit 1
    fi
}

# Verify recommended folder
prepare_path "$RECOMMENDED_PATH" "yes"

# ===== STEP 1: Scan for valid Vite projects =====
scan_projects() {
    local base_dir="$1"
    local arr=()
    for pkg in $(find "$base_dir" -maxdepth 3 -type f -name "package.json" 2>/dev/null); do
        if grep -q '"dev"' "$pkg"; then
            arr+=("$(dirname "$pkg")")
        fi
    done
    echo "${arr[@]}"
}

PROJECTS=()
PROJECTS=($(scan_projects "$RECOMMENDED_PATH"))
[ ${#PROJECTS[@]} -eq 0 ] && PROJECTS=($(scan_projects "$FALLBACK_DIR"))
[ ${#PROJECTS[@]} -eq 0 ] && { echo "❌ No Vite projects found."; exit 1; }

# ===== STEP 2: Offer to move projects outside recommended folder =====
TO_MOVE=()
for i in "${!PROJECTS[@]}"; do
    proj="${PROJECTS[$i]}"
    if [[ "$proj" != "$RECOMMENDED_PATH"* ]]; then
        TO_MOVE+=("$proj")
    fi
done

if [ ${#TO_MOVE[@]} -gt 0 ]; then
    echo "⚠️ Projects outside recommended folder found:"
    for i in "${!TO_MOVE[@]}"; do echo "[$i] ${TO_MOVE[$i]}"; done
    read -p "Move any to $RECOMMENDED_PATH? (y/n): " move_choice
    if [[ "$move_choice" =~ ^[yY]$ ]]; then
        read -p "Enter numbers (comma-separated) to move: " move_nums
        IFS=',' read -ra nums <<< "$move_nums"
        for n in "${nums[@]}"; do
            proj="${TO_MOVE[$n]}"
            target="$RECOMMENDED_PATH/$(basename "$proj")"
            echo "📦 Moving $proj -> $target"
            mv "$proj" "$target" || { echo "❌ Move failed"; exit 1; }
            for j in "${!PROJECTS[@]}"; do
                [ "${PROJECTS[$j]}" == "$proj" ] && PROJECTS[$j]="$target"
            done
        done
    fi
fi

# ===== STEP 3: Choose project =====
echo "📂 Found the following valid Vite projects:"
for i in "${!PROJECTS[@]}"; do echo "[$i] ${PROJECTS[$i]}"; done
read -p "Enter the number of the project to launch: " choice
if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -ge "${#PROJECTS[@]}" ]; then echo "❌ Invalid choice."; exit 1; fi
PROJECT_DIR="${PROJECTS[$choice]}"
echo "✅ Selected: $PROJECT_DIR"

# Verify final project path
prepare_path "$PROJECT_DIR" "no"

# ===== STEP 4: Check existing processes =====
EXISTING_VITE=$(lsof -iTCP:$DEFAULT_VITE_PORT -sTCP:LISTEN -t 2>/dev/null)
EXISTING_NGROK=$(pgrep -f "$MOUNT_POINT/ngrok")
EXISTING_LT=$(pgrep -f lt)
EXISTING_LX=$(pgrep -f lx)
EXISTING_CF=$(pgrep -f cloudflared)

if [ -n "$EXISTING_VITE" ] || [ -n "$EXISTING_NGROK$EXISTING_LT$EXISTING_LX$EXISTING_CF" ]; then
    echo "⚠️ Existing processes detected:"
    [ -n "$EXISTING_VITE" ] && echo "Vite PID(s): $EXISTING_VITE"
    [ -n "$EXISTING_NGROK" ] && echo "Ngrok PID(s): $EXISTING_NGROK"
    [ -n "$EXISTING_LT" ] && echo "LocalTunnel PID(s): $EXISTING_LT"
    [ -n "$EXISTING_LX" ] && echo "LocalXpose PID(s): $EXISTING_LX"
    [ -n "$EXISTING_CF" ] && echo "Cloudflared PID(s): $EXISTING_CF"
    read -p "Kill existing processes? (y/n): " kill_choice
    if [[ "$kill_choice" =~ ^[yY]$ ]]; then
        for pid in $EXISTING_VITE $EXISTING_NGROK $EXISTING_LT $EXISTING_LX $EXISTING_CF; do
            kill -0 "$pid" 2>/dev/null && kill "$pid" && echo "✅ Killed PID $pid"
        done
    else
        echo "ℹ️ Exiting."
        exit 0
    fi
fi

# ===== STEP 5: Tmux install + start =====
read -p "Start Vite in a new tmux session? (y/n): " new_session
USE_TMUX="n"
[[ "$new_session" =~ ^[yY]$ ]] && USE_TMUX="y"

if [[ "$USE_TMUX" == "y" ]]; then
    if ! command -v tmux >/dev/null 2>&1; then
        echo "⚠️ tmux not found. Installing..."
        if command -v pkg >/dev/null 2>&1; then
            pkg install -y tmux
        elif command -v apt >/dev/null 2>&1; then
            apt update && apt install -y tmux
        fi
    fi
    tmux new-session -d -s "vite_$(basename "$PROJECT_DIR")" "npm run dev > $PROJECT_DIR/vite_start.log 2>&1"
    if [ $? -eq 0 ]; then
        echo "✅ Vite started in tmux session: vite_$(basename "$PROJECT_DIR")"
    else
        echo "⚠️ Could not start tmux session. Running in current terminal..."
        npm run dev > "$PROJECT_DIR/vite_start.log" 2>&1 &
        USE_TMUX="n"
    fi
else
    npm run dev > "$PROJECT_DIR/vite_start.log" 2>&1 &
fi
sleep 3

# ===== STEP 6: Detect Vite port =====
VITE_LOG="$PROJECT_DIR/vite_start.log"
VITE_ACTUAL_PORT=$(grep -oP 'http://localhost:\K[0-9]+' "$VITE_LOG" | head -n 1)
[ -z "$VITE_ACTUAL_PORT" ] && VITE_ACTUAL_PORT=$DEFAULT_VITE_PORT
echo "⚡ Vite running on port $VITE_ACTUAL_PORT"

# ===== STEP 7: Tunnel selection =====
echo "🌐 Choose tunnel:"
TUNNELS=()
OPTIONS=()
idx=0

[ -x "$MOUNT_POINT/ngrok" ] && { OPTIONS+=("Ngrok"); TUNNELS+=("ngrok"); echo "[$idx] Ngrok"; idx=$((idx+1)); }
command -v lt >/dev/null 2>&1 && { OPTIONS+=("LocalTunnel"); TUNNELS+=("lt"); echo "[$idx] LocalTunnel"; idx=$((idx+1)); }
command -v lx >/dev/null 2>&1 && { OPTIONS+=("LocalXpose"); TUNNELS+=("lx"); echo "[$idx] LocalXpose"; idx=$((idx+1)); }
command -v cloudflared >/dev/null 2>&1 && { OPTIONS+=("Cloudflared"); TUNNELS+=("cloudflared"); echo "[$idx] Cloudflared"; idx=$((idx+1)); }

OPTIONS+=("Vite local server only")
TUNNELS+=("local")
echo "[$idx] Vite local server only"

read -p "Enter number of choice: " tunnel_choice
TUNNEL="${TUNNELS[$tunnel_choice]}"
echo "✅ Selected tunnel: $TUNNEL"

# ===== STEP 8: Clean logs =====
NGROK_LOG="$PROJECT_DIR/ngrok.log"
LT_LOG="$PROJECT_DIR/lt.log"
LX_LOG="$PROJECT_DIR/lx.log"
CF_LOG="$PROJECT_DIR/cloudflared.log"

> "$NGROK_LOG" > "$LT_LOG" > "$LX_LOG" > "$CF_LOG"

# ===== STEP 9: Start selected tunnel =====
TUNNEL_PID=""
case "$TUNNEL" in
    ngrok) $MOUNT_POINT/ngrok http $VITE_ACTUAL_PORT > "$NGROK_LOG" 2>&1 & TUNNEL_PID=$! ;;
    lt) lt --port $VITE_ACTUAL_PORT > "$LT_LOG" 2>&1 & TUNNEL_PID=$! ;;
    lx) lx tunnel http $VITE_ACTUAL_PORT > "$LX_LOG" 2>&1 & TUNNEL_PID=$! ;;
    cloudflared) cloudflared tunnel --url http://localhost:$VITE_ACTUAL_PORT > "$CF_LOG" 2>&1 & TUNNEL_PID=$! ;;
    local) echo "⚡ Running local Vite server only." ;;
esac

# ===== STEP 10: Instructions =====
echo "----------------------------------------"
echo "✅ Vite + Tunnel launched!"
echo "Project: $PROJECT_DIR"
echo "Vite port: $VITE_ACTUAL_PORT"

if [ "$TUNNEL" != "local" ]; then
    echo "🌐 Check the tunnel log for the public URL:"
    case "$TUNNEL" in
        ngrok) echo "  cat $NGROK_LOG" ;;
        lt) echo "  cat $LT_LOG" ;;
        lx) echo "  cat $LX_LOG" ;;
        cloudflared) echo "  cat $CF_LOG" ;;
    esac
    echo "➡️ Copy the URL from log and paste it into your browser."
else
    echo "⚡ Running locally. Open in browser at http://localhost:$VITE_ACTUAL_PORT"
fi

echo "🛑 To stop Vite + Tunnel processes:"
echo "  kill $VITE_PID ${TUNNEL_PID:-}"
echo "----------------------------------------"

if [[ "$USE_TMUX" == "y" ]]; then
    echo "ℹ️ tmux session name: vite_$(basename "$PROJECT_DIR")"
    echo "Attach with: tmux attach -t vite_$(basename "$PROJECT_DIR")"
fi

