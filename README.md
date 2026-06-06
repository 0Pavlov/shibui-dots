# shibui-dots

A curated, minimalist suite for the modern terminal and web - built on Arch, Hyprland, and a hand‑written Quickshell.  
Designed for clarity, not distractions. Keyboard‑driven, with the philosophy that if you know a function exists, it shouldn't permanently occupy your screen.

> **Alpha state** - This setup is my personal daily driver and is actively being extended as new needs arise. It is nowhere near complete or compatible with every possible hardware configuration.  
> **Documentation lag** - Capturing and documenting features properly is a tedious process. The readme inevitably trails behind the actual, living set of features.

---

## What you'll find here

### The overall feel
Clean workspace switching and automatic window arrangement.

<p width="100%">
  <video src="https://github.com/user-attachments/assets/178f11e1-1c72-4bed-bc28-4ac198b447f0"></video>
</p>

### Dynamic theme switching
A custom theme switcher that integrates seamlessly - here, with Ghostty terminal following suit instantly.  
It is written in Python, integrates with Hyprland, Quickshell, and Nvim, and has a quickshell OSD that calls it as a CLI tool. Adding new themes is supported both by the OSD and the theme switcher, though the switcher itself requires theme sourcing adjustments across all tools it works with (I will probably release it as a separate tool).

<p width="100%">
  <video src="https://github.com/user-attachments/assets/1571a263-a6bb-48ef-a7ba-34ac18453a3a"></video>
</p>

### Alive and expressive top bar widget
The middle widget of the top bar reacts in real‑time to your battery level (laptop), changing appearance to keep you informed. It also picks up the colors of the theme set by the theme switcher.

#### Low battery state
| Theme 1 | Theme 2 |
|---------|---------|
| <video src="https://github.com/user-attachments/assets/a24ea9ab-b804-4fbd-b487-7431fdd6b5c3"></video> | <video src="https://github.com/user-attachments/assets/f1ba82b0-212b-4f1d-a996-492117261e8b"></video> |

#### Very low battery state
| Theme 1 | Theme 2 |
|---------|---------|
| <video src="https://github.com/user-attachments/assets/ae174464-2e1d-4520-9816-f60a53c63f19"></video> | <video src="https://github.com/user-attachments/assets/5ce41a52-ce1c-4be8-baa4-13284ec35b36"></video> |

### Window management
Tiling, moving, and resizing windows - all support both mouse and keyboard‑driven workflows. It leverages the latest Hyprland `.lua` changes and the newly added spring animations.

<p width="100%">
  <video src="https://github.com/user-attachments/assets/adeb0a13-e641-43b7-bd39-4c58526cbce4"></video>
</p>

---

*More is already built and running – I'll update this readme as I find the time to record and write it up.*
