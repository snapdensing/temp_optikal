# Generic test wrapper specifications

In order to drive module input pins of MLC and read its outputs, we will use a generic test wrapper that is controlled via UART. The UART side will be connected to a host PC and will be used for sending commands to actuate test inputs to the MLC (or any other unit under test (UUT)), and sample MLC outputs and send for evaluation in the host PC.

## Wrapper Ports

This section describes the top-level ports of the test wrapper.

### System and UART

| Port | Direction | Width | Description |
|------|-----------|-------|-------------|
|clk   | input     | 1     | Global clock |
|nrst  | input     | 1     | Global reset. Active low |
|txd   | output    | 1     | UART transmit |
|rxd   | input     | 1     | UART receive  |

### Vector Output Interface

| Port | Direction | Width | Description |
|------|-----------|-------|-------------|
|vctrout_ch0 | output | 8 | Channel 0 vector output |
|vctrout_ch1 | output | 8 | Channel 1 vector output |
|vctrout_ch2 | output | 8 | Channel 2 vector output |
|vctrout_ch3 | output | 8 | Channel 3 vector output |

### Trigger Output Interface
| Port | Direction | Width | Description |
|------|-----------|-------|-------------|
|trigout_ch0 | output | 1 | Channel 0 trigger output | 
|trigout_ch1 | output | 1 | Channel 1 trigger output | 
|trigout_ch2 | output | 1 | Channel 2 trigger output | 
|trigout_ch3 | output | 1 | Channel 3 trigger output | 

### Vector Input Interface
| Port | Direction | Width | Description |
|------|-----------|-------|-------------|
|vctrin_ch0 | input | 8 | Channel 0 vector input |
|vctrin_ch1 | input | 8 | Channel 1 vector input |
|vctrin_ch2 | input | 8 | Channel 2 vector input |
|vctrin_ch3 | input | 8 | Channel 3 vector input |

## Interfaces

This section describes the operation of the test interfaces. All of the interfaces are controlled via commands sent from the UART through wrapper input `rxd`. Feedback (replies) from the wrapper are subsequently sent through the wrapper output `txd`. 

### Vector Output

This interface will be used to set vector inputs on the UUT. Each channel of the interface is addressed by the channel number (`chX`). To set a vector output interface, send the following command through UART:

| Byte 0 | Byte 1 | Byte 2 |
|--------|--------|--------|
| 0xA5   | Channel | Value |

For example, to set `vctrout_ch2` to `0xAB`, you must send the command `0xA502AB`.

As a reply to the host computer, the test wrapper should echo back the entire command through `txd`.

The vector output signal should be held by the test wrapper until another command is sent to set the corresponding channel. At reset, set all vector output signals to `0x00`.

### Trigger Output

This interface will be used to send single pulse or level-triggered enable signals to the UUT. Each channel of the interface is addressed by the channel number (`chX`). To send an enable signal, send the following command through UART:

| Byte 0 | Byte 1 |
|--------|--------|
| 0x5C   | Channel |

For example, to activate the `trigout_ch3` signal, you must send the command `0x5C03`. As a reply to the host computer, the test wrapper should echo back the entire command through `txd`.

The type of trigger sent by the test wrapper is dependent on the `Trigger Type` parameter associated with that particular channel. The trigger types are:

| Type | Type encoding | Description |
|------|-------------|---------------|
|toggle| 0x00 | Activation inverts the previous value of the trigger output. Reset value of trigger is 0 |
|pulse high | 0x01 | Idle value of trigger signal is 0. Activation sends a 1 (high) pulse that has a pulse width of `trigger_val` clock cycles, after which signal is reset to 0 (low). |
|pulse low | 0x02 | Idle value of trigger signal is 1. Activation sends a 0 (low) pulse that has a pulse width of `trigger_val` clock cycles, after which signal is reset to 1 (high). |

The trigger type can be changed by sending the following command through UART:

| Byte 0 | Byte 1 | Byte 2 | Byte 3 |
|--------|--------|--------|--------|
| 0x53   | Channel | Trigger Type | `trigger_val` |

For example, to set the `trigout_ch0` to send 2cc high pulses when enabled, you must send the command: `0x53000102`. As a reply to the host computer, the test wrapper should echo back the entire command through `txd`.

For toggle trigger types, `trigger_val` is ignored. For pulse high or pulse low trigger types, a `trigger_val` value of 0x00 is interpreted as if the value was 0x01. Changing the trigger type to pulse high or pulse low also immediately changes the idle value of the trigger line (low and high, respectively). Changing the trigger type to toggle retains the previous (idle) value of the trigger line. 

### Vector Input

This interface will be used to monitor vector outputs from the UUT. The value seen at these input ports are serialized and sent through UART for observation in the host pc. To read an interface, the following command should be sent:

| Byte 0 | Byte 1 |
|--------|--------|
| 0x00   | Channel |

For example, to read the value of `vctrin_ch1`, you must send the command `0x0001`.

The test wrapper replies with the following packet:

| Byte 0 | Byte 1 | Byte 2 |
|--------|--------|--------|
| 0x00   | Channel | Value |

Bytes 0 and 1 are just echoes of the command sent, while byte 2 must contain the value read from `vctrin_ch1`.
