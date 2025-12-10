# WISHBONE Bus
## Overview
This document outlines the additions to and usage of the WISHBONE bus by Finitron.

Finitron IP cores are being adapted to use the WISHBONE bus.
There is a parameter (BUS_PROTOCOL) for most cores to select the bus protocol.
0=Standard synchronous bus
1=Asynchronous operation

## Note about ACK
For the synchronous bus protocol:
The Finitron IP cores expect ACK to be able to hold the bus until ACK is negated. An ACK may be multiple cycles wide while it waits for an indication of the end of the bus cycle.
The end of the bus cycle occurs when CYC or STB is deasserted.
This is as outlined in the WISHBONE spec document, but many IP cores may not follow this exactly.

For the synchronous bus standard ACK (and the response bus data) is held until CYC is negated.
Finitron cores zero out all the bus signals making the bus inactive when ACK is deasserted.

For the asynchronous bus protocol:
ACK and the response bus signals are active for only a single clock cycle. ACK will automatically negate after one clock.
The response bus signals will be zeroed out after one clock cycle.

## Signals
The following signals are in addition to the WISHBONE signals.

TID: transaction id, required for the asynchronous bus.
Without a transaaction id there would be no way for the master to know what transaction the slaves repsonse belongs to.
It is assumed with an asynchronous bus the master may begin multiple transactions before a response comes back.
The TID contains the master's core number (6 bits), channel number (3 bits), and a four bit id.

ERR: The bus error signal is widened to three bits so that a meaningful error response may be returned.
If there are no errors ERR will equal OKAY.

## MSI interrupts
Finitron has adapted the bus to support MSI interrupts.
An MSI interrupt is indicated with an ERR response of IRQ
The interrupt information is returned in the data field of the response.
The response bus must be 64-bit.
The TID field identifies the interrupt controller to notify.
