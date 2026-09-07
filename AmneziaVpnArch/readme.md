### 1. Installation
Install the tools and the Go backend (most stable).
```bash
yay -S amneziawg-tools amneziawg-go openresolv
```
*   *`openresolv` is required for DNS to work properly.*

### 2. Decode the `vpn://` Key
If you only have the `vpn://` text key and need to extract the raw IPs and Keys, run this **Python decoder** (replace the key variable with your new key):

OR just use 'AmneziaWG native format' option while generating a config in the 'parent' app (the function is brought back in the recent 3.1 update).

```Python
import base64
import json
import zlib

VPN_CONNECTION_KEY = "your key"

def decode_vpn_string(vpn_str):
    encoded = vpn_str.replace("vpn://", "").strip()
    padding = 4 - (len(encoded) % 4)
    if padding != 4:
        encoded += "=" * padding
    
    compressed = base64.urlsafe_b64decode(encoded)
    decompressed = zlib.decompress(compressed[4:])
    return json.loads(decompressed)

def find_ini_string(data):
    if isinstance(data, dict):
        if "config" in data and isinstance(data["config"], str) and "[Interface]" in data["config"]:
            return data["config"]
            
        for k, v in data.items():
            if isinstance(v, str):
                v_str = v.strip()
                if v_str.startswith("{") or v_str.startswith("["):
                    try:
                        parsed = json.loads(v_str)
                        res = find_ini_string(parsed)
                        if res: return res
                    except json.JSONDecodeError:
                        pass
                
                if "[Interface]" in v and "[Peer]" in v:
                    return v
                    
            elif isinstance(v, (dict, list)):
                res = find_ini_string(v)
                if res: return res
                
    elif isinstance(data, list):
        for item in data:
            res = find_ini_string(item)
            if res: return res
            
    return None

def main():
    try:
        data = decode_vpn_string(VPN_CONNECTION_KEY)
    except Exception as e:
        print(f"Error decoding VPN string: {e}")
        return

    # Grab the clean WireGuard string
    raw_config = find_ini_string(data)

    if raw_config:
        # Swap Amnezia's unresolved DNS placeholders with actual addresses
        final_config = raw_config.replace("$PRIMARY_DNS", "1.1.1.1").replace("$SECONDARY_DNS", "1.0.0.1")
        print(final_config.strip())
    else:
        print("# Could not find the embedded [Interface] config text.")

if __name__ == "__main__":
    main()
```

```bash
python decoder.py > awg0.conf
```

### 3. Create the Configuration

**Create directory:**
```bash
sudo mkdir -p /etc/amnezia/amneziawg/
```

**Create file:**
```bash
sudo nvim /etc/amnezia/amneziawg/awg0.conf
```

**Secure it:**
```bash
sudo chmod 600 /etc/amnezia/amneziawg/awg0.conf
```

### 4. Enable Autostart

```bash
# Enable to start on boot
sudo systemctl enable --now awg-quick@awg0
```

```bash
# Disable
sudo systemctl disable --now awg-quick@awg0
```

For hyprland exec-once you must alter the visudo

Snippet from hyprland.conf:
# Run amnezia vpn (remove if isn't installed or you don't have yourusername ALL=(root) NOPASSWRD: /usr/bin/awg-quick up awg0 in your visudo)
exec-once = sudo awg-quick up awg0
# Usefull commands
# Disconnect
#sudo awg-quick down awg0
# Reconnect
#sudo awg-quick up awg0
# Check Status
#sudo awg


*Note: Because the config is in a non-standard path (`/etc/amnezia/amneziawg/`), if standard `awg-quick` fails to find it in the future, you can symlink it:*
```bash
sudo ln -s /etc/amnezia/amneziawg/awg0.conf /etc/amneziawg/awg0.conf
```

Disable the GUI service to avoid conflicts
```bash
sudo systemctl disable --now amnezia-vpn-service
```

### 5. Cheat Sheet Commands
*   **Check Status:** `sudo awg`
*   **Check IP:** `curl ifconfig.me`
*   **Manual Start:** `sudo awg-quick up awg0`
*   **Manual Stop:** `sudo awg-quick down awg0`
