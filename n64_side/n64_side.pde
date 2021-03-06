/*
 * HOW MUCH OF THIS CAN I TRIM DOWN AND RENAME APPROPRIATELY?
 */

#define N64_PIN 8
#define N64_HIGH DDRB &= ~0x01
#define N64_LOW DDRB |= 0x01
#define N64_QUERY (PINB & 0x01)

// Define the struct "controller_status", which contains the data that we get from the controller
struct {
    unsigned char data1;         // Creates a char "data1" which contains bits (1 or 0) for: A, B, Z, Start, Dup, Ddown, Dleft, Dright (DR,DL,DD,DU,S,Z,B,A)
    unsigned char data2;         // Creates a char "data2" which contains bits for: 0, 0, L, R, Cup, Cdown, Cleft, Cright (CR,CL,CD,CU,R,L,0,0)
    char stick_x;                // Creates a char "stick_x" which contains the x position of the joystick, from -128 to 127
    char stick_y;                // Creates a char "stick_y" which contains the y position of the joystick, from -128 to 127
} controller_status;
char n64_raw_dump[281];         // To hold N64 data - maximum recv is 1+2+32 bytes + 1 bit
unsigned char n64_command;      // The command byte from the N64 gets pushed into here

// bytes to send to the 64
// maximum we'll need to send is 33, 32 for a read request and 1 CRC byte
unsigned char n64_buffer[33];

void n64_send(unsigned char *buffer, char length);
void n64_get();
void controller_to_n64();

#include "crc_table.h"


void setup()
{
  Serial.begin(9600);

  Serial.println();
  Serial.println("Code has started!");

  // Communication with the N64 on this pin
  digitalWrite(N64_PIN, LOW);
  pinMode(N64_PIN, INPUT);
  
}



bool rumble = false;
void loop()
{
    int i;
    unsigned char data, addr;

    // clear out raw data buffers
    memset(n64_raw_dump, 0, sizeof(n64_raw_dump));
    
    noInterrupts();         // don't want interrupts getting in the way
    controller_to_n64();    // take in controller_status and make n64_buffer_dump
    interrupts();           // end of time-sensitive code

    noInterrupts();
    n64_get();      // Wait for incomming 64 command (this will block until the N64 sends us a command)

    // 0x00 is identify command
    // 0x01 is status
    // 0x02 is read
    // 0x03 is write
    
    switch (n64_command)
    {
        case 0x00:
        case 0xFF:
            // identify
            // mutilate the n64_buffer array with our status
            // we return 0x050001 to indicate we have a rumble pack
            // or 0x050002 to indicate the expansion slot is empty
            //
            // 0xFF I've seen sent from Mario 64 and Shadows of the Empire.
            // I don't know why it's different, but the controllers seem to
            // send a set of status bytes afterwards the same as 0x00, and
            // it won't work without it.
            n64_buffer[0] = 0x05;
            n64_buffer[1] = 0x00;
            n64_buffer[2] = 0x01;

            n64_send(n64_buffer, 3, 0);

            //Serial.println("It was 0x00: an identify command");
            break;
        case 0x01:
            // blast out the pre-assembled array in n64_buffer
            n64_send(n64_buffer, 4, 0);

            //Serial.println("It was 0x01: the query command");
            break;
        case 0x02:
            // A read. If the address is 0x8000, return 32 bytes of 0x80 bytes,
            // and a CRC byte.  this tells the system our attached controller
            // pack is a rumble pack

            // Assume it's a read for 0x8000, which is the only thing it should
            // be requesting anyways
            memset(n64_buffer, 0x80, 32);
            n64_buffer[32] = 0xB8; // CRC

            n64_send(n64_buffer, 33, 1);

            //Serial.println("It was 0x02: the read command");
            break;
        case 0x03:
            // A write. we at least need to respond with a single CRC byte.  If
            // the write was to address 0xC000 and the data was 0x01, turn on
            // rumble! All other write addresses are ignored. (but we still
            // need to return a CRC)

            // decode the first data byte (fourth overall byte), bits indexed
            // at 24 through 31
            data = 0;
            data |= (n64_raw_dump[16] != 0) << 7;
            data |= (n64_raw_dump[17] != 0) << 6;
            data |= (n64_raw_dump[18] != 0) << 5;
            data |= (n64_raw_dump[19] != 0) << 4;
            data |= (n64_raw_dump[20] != 0) << 3;
            data |= (n64_raw_dump[21] != 0) << 2;
            data |= (n64_raw_dump[22] != 0) << 1;
            data |= (n64_raw_dump[23] != 0);

            // get crc byte, invert it, as per the protocol for
            // having a memory card attached
            n64_buffer[0] = crc_repeating_table[data] ^ 0xFF;

            // send it
            n64_send(n64_buffer, 1, 1);

            // end of time critical code
            // was the address the rumble latch at 0xC000?
            // decode the first half of the address, bits
            // 8 through 15
            addr = 0;
            addr |= (n64_raw_dump[0] != 0) << 7;
            addr |= (n64_raw_dump[1] != 0) << 6;
            addr |= (n64_raw_dump[2] != 0) << 5;
            addr |= (n64_raw_dump[3] != 0) << 4;
            addr |= (n64_raw_dump[4] != 0) << 3;
            addr |= (n64_raw_dump[5] != 0) << 2;
            addr |= (n64_raw_dump[6] != 0) << 1;
            addr |= (n64_raw_dump[7] != 0);

            if (addr == 0xC0) {
                rumble = (data != 0);
            }

            //Serial.println("It was 0x03: the write command");
            //Serial.print("Addr was 0x");
            //Serial.print(addr, HEX);
            //Serial.print(" and data was 0x");
            //Serial.println(data, HEX);
            break;

    }

    interrupts();
  
}
