# gilbhax

gilbhax is an [LJE](https://github.com/yogwoggf/lj-expand) script for Garry's Mod that provides various cheats such as aimbot, ESP, and screen capturing warnings.

This is just an example LJE script to demonstrate active code execution with LJE and how to structure scripts around stealth. Gilbhax currently remains undetected on a majority of anti-cheat systems. Use at your own risk! (or don't cheat at all!)

# Dependencies

You **NEED** to have [ljeutil](https://github.com/Eyoko1/ljeutil) installed for gilbhax to work. Simply clone it into your `.lje_scripts` folder alongside gilbhax.

## Features

- Aimbot
    - PID controlled aiming for smoothness
    - Natural perturbations to simulate human aim
    - Target selection based on angle and distance
- ESP
    - Draws players above walls
    - Name and team display
- Screen Capture Warning
    - Detects when a screen capture is being taken
    - Notifies the user
- Post-PostRender rendering
    - Renders after all other PostRender hooks to avoid interference
    - Rejects any Lua-made attempt to run PostRender hooks

## Installation

This assumes you have Git installed. It is fine if you do not, but you won't be able to easily update gilbhax.

# Git Method
1. Ensure you have [LJE](https://github.com/yogwoggf/lj-expand) installed
2. Navigate to your `.lje_scripts` folder in your user directory (i.e. `C:\Users\YourName\.lje_scripts\`)
3. Run `git clone https://github.com/yogwoggf/gilbhax.git`
4. Launch GMod with LJE and enjoy.

# Manual Method
1. Ensure you have [LJE](https://github.com/yogwoggf/lj-expand) installed
2. Download the ZIP of this repository by clicking the green "Code" button and selecting "Download ZIP"
3. Extract the contents of the ZIP into your `.lje_scripts` folder in your user directory (i.e. `C:\Users\YourName\.lje_scripts\`)
4. Ensure the folder structure is `.lje_scripts/gilbhax/` with the files inside the `gilbhax` folder
5. Launch GMod with LJE and enjoy.

**Do not** extract the zip into a double subfolder like `gilbhax/gilbhax`. It should just be one folder named `gilbhax` directly inside `.lje_scripts`.