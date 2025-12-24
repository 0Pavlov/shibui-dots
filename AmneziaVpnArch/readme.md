### 1. Installation
Install the tools and the Go backend (most stable).
```bash
yay -S amneziawg-tools amneziawg-go openresolv
```
*   *`openresolv` is required for DNS to work properly.*

### 2. Decode the `vpn://` Key
If you only have the `vpn://` text key and need to extract the raw IPs and Keys, run this **Python decoder** (replace the key variable with your new key):

```bash
python -c 'import sys, base64, zlib; k="YOUR_VPN_KEY_WITHOUT_VPN_PREFIX"; k += "=" * (4 - len(k) % 4); d = base64.urlsafe_b64decode(k); print(zlib.decompress(d[4:]).decode())'
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

**Paste Template (Fill with data from Step 2 the format will be different, so format it through any LLM):**
```ini
[Interface]
# Identity (From Python Output)
PrivateKey = <client_priv_key>
Address = <client_ip>/32
DNS = 1.1.1.1, 1.0.0.1
MTU = 1280

# Obfuscation (From Python Output)
Jc = <Jc>
Jmin = <Jmin>
Jmax = <Jmax>
S1 = <S1>
S2 = <S2>
H1 = <H1>
H2 = <H2>
H3 = <H3>
H4 = <H4>

[Peer]
# Connection (From Python Output)
PublicKey = <server_pub_key>
PresharedKey = <psk_key>
Endpoint = <server_ip>:44908
AllowedIPs = 0.0.0.0/0, ::/0
PersistentKeepalive = 25
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
