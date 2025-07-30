#  VGA Animation Project – Day & Night Scene (FPGA / Verilog)

This project implements a simple VGA animation using Verilog and an FPGA development board (e.g., Basys3). The animation displays a **day and night cycle** with basic graphic elements:

-  **Daytime**: green grass, blue sky, animated sun and moving clouds  
-  **Nighttime**: dark background, crescent moon, and stars

The transition between day and night is done automatically or via a control signal. The animation is rendered at **Full HD resolution (1920x1080)** using VGA output.

---

## Technologies & Tools

- Verilog HDL  
- Vivado Design Suite  
- Basys3 FPGA Board (or compatible)  
- VGA 1080p output  
- Clock frequency divider, counters, and RGB control  

---

## Features

- Pixel-level rendering based on X/Y counters  
- Simple FSM or logic to switch between day/night  
- Modular Verilog code, easy to extend (e.g., add animations or sensors)

---

## Possible Extensions

- Add motion sensors (e.g., PIR) to trigger animations  
- Add user interaction (buttons/switches)  
- Add custom background or text overlays






https://github.com/user-attachments/assets/cd5c72f7-e625-4678-a7c7-692450dd0976


