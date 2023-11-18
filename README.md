# SERIAL COMMUNICATION PROJECT

## Project Overview

This project involves the use of the SPI interface on the ATMEGA324PA microcontroller to facilitate communication between a Slave microcontroller and a Master microcontroller. The Slave microcontroller is responsible for scanning a matrix keypad (8x8) to obtain keycodes. These keycodes are then transferred to the Master microcontroller using the SPI interface. The Master microcontroller, upon receiving the keycodes, displays them on both a 16x2 LCD and transmits them via UART to a virtual terminal in Proteus software or Hercules software terminal.

## Components

- **Microcontrollers:**
  - ATMEGA324PA (Master)
  - ATMEGA324PA (Slave)

- **Peripheral Devices:**
  - 8x8 Matrix Keypad
  - 16x2 LCD
  - UART for virtual terminal communication
  - Proteus software or Hercules software for monitoring the virtual terminal

## Implementation Details

### Slave Microcontroller

- The Slave microcontroller is responsible for scanning the 8x8 matrix keypad to obtain keycodes.
- Upon obtaining a keycode, it prepares the data for transmission.
- It uses the SPI interface to send the prepared keycode to the Master microcontroller.
- The transmission is triggered using the INT0 external interrupt pin on the Master microcontroller.

### Master Microcontroller

- The Master microcontroller is configured to listen for the INT0 external interrupt.
- Upon the interrupt trigger, it initializes the SPI interface as the master to receive data from the Slave microcontroller.
- After successfully receiving the keycode, the Master microcontroller displays it on the 16x2 LCD.
- Simultaneously, the Master microcontroller transmits the keycode via UART to a virtual terminal in Proteus software or Hercules software.

### Synchronization Signal (REQ)
In this project, a synchronization signal named REQ is employed to orchestrate the seamless operation between the Master and Slave microcontrollers. The REQ signal plays a crucial role in ensuring a synchronized protocol between the two.

Functionality:

Initialization: The REQ signal is initially set to logic level 1. This initial setting prevents the Slave microcontroller from interrupting the Master microcontroller before the completion of the master's configuration process.

Synchronization: Once the Master microcontroller has completed its pre-setup protocol and is ready to receive data from the Slave, it clears the REQ signal. This action serves as an indicator to the Slave microcontroller that it is now permitted to interrupt and transmit the keycode data.

## Setup and Configuration

1. Connect the 8x8 matrix keypad to the Slave microcontroller.
2. Connect the SPI interface and relevant signal between the Slave and Master microcontrollers.
3. Connect the 16x2 LCD to the Master microcontroller.
4. Ensure proper UART connections for virtual terminal communication.
5. Load the provided code onto the respective microcontrollers.
6. Simulate the project in Proteus software and/or Hercules software.

## Code Organization

- The project code is organized into two folders for the Slave and Master microcontrollers.
- Each folder contains the source code files.

## Simulation

- Use Proteus software and/or Hercules software for simulating the project.
- Monitor the virtual terminal to observe the keycodes transmitted by the Master microcontroller.
- The 16x2 LCD should display the received keycodes.

## Contributors

- Minh Nguyen Nhat Tuan
- Huy Thoong Quoc
- Nhien Nguyen Duc Thanh

## Acknowledgments

This project owes gratitude to the following resources:

ATmega164A/PA/324A/PA/644A/PA/1284/P Datasheet: The comprehensive documentation provided by Microchip served as an invaluable reference, guiding the understanding and implementation of features specific to the microcontroller.

Microprocessor EE3413 Course at HCMUT: The knowledge gained from the Microprocessor EE3413 course at Ho Chi Minh City University of Technology (HCMUT) greatly influenced the design and execution of this project. The course materials and resources played a pivotal role in shaping the technical aspects of the code and system architecture.

These acknowledgments reflect the project reliance on external references and educational resources, emphasizing the collaborative nature of knowledge acquisition and application in the field of microprocessor systems.
