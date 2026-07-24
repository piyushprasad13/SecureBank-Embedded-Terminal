# SecureBank Embedded Terminal

## Overview

SecureBank Embedded Terminal is an embedded banking simulation system developed using the AT89C52 (8051) microcontroller. The project demonstrates secure user authentication through an infrared sensor and keypad-based PIN verification while providing basic banking operations on a 16×2 LCD.

---

## Features

- IR Sensor based user detection
- PIN Authentication
- Secure Login
- Balance Inquiry
- Cash Deposit
- Cash Withdrawal
- LCD Display Interface
- Status LEDs for system indication

---

## Hardware Used

- AT89C52 (8051) Microcontroller
- 16×2 LCD Display
- 4×4 Matrix Keypad
- Infrared Sensor
- Crystal Oscillator
- LEDs
- Breadboard
- Power Supply

---

## Software Used

- Keil uVision
- Embedded Assembly Language

---

## Project Files

- `SecureBank.asm` – Source Code
- `bank.hex` – Compiled HEX File
- `bank.uvproj` – Keil Project
- `Circuit_diagram.jpeg` – Circuit Diagram
- `Front_View.jpeg` – Project Prototype

---

## Working

1. Detects user presence using the IR sensor.
2. Prompts the user to enter a PIN.
3. Verifies the entered PIN.
4. Displays banking options on the LCD.
5. Executes the selected banking operation.

---

## Future Improvements

- EEPROM-based account storage
- RFID/Smart Card authentication
- Fingerprint authentication
- Password encryption
- Transaction history

---

## Author

**Piyush Prasad**
B.Tech Electronics & Communication Engineering
