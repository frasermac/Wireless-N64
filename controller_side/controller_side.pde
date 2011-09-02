/*
 * Arduino read N64 Controller Data
 * From 'Use an Arduino with an N64 controller" by Peter Den Hartog
 * http://www.instructables.com/id/Use-an-Arduino-with-an-N64-controller/
 * Which was adapted from "Gamecube controller to Nintendo 64 adapter" by Andrew Brown
 * https://github.com/brownan/Gamecube-N64-Controller
 * Cleaned up & annotated by frontispiece
 */


/*
 * To use, hook up the following to the Arduino Duemilanove:
 * CONT PIN            ADAPT PIN          ARD PIN
 * gnd (left)          red                gnd
 * pwr (right)         black              3.3 V
 * data (cntr)         white              digital pin 2 w 1k pull-up to 3.3 V
 */

#include "pins_arduino.h"  // Include default Arduino pins

// These operations translate to 1 op code, which takes 2 cycles
// These definitions are used to control port registers, allowing faster and
// lower-level control of i/o (http://www.arduino.cc/en/Reference/PortManipulation)
// Remember, "0x" is just a common prefix to indicate a base-16 hexadecimal number (e.g. 0x04 is just hex 04)

#define N64_PIN 2                // Communicate with the N64 over digital pin 2
#define N64_PIN_DIR DDRD         // Sets the expression "N64_PIN_DIR" to control whether the pin is read/write - NOT USED AT ALL?
#define N64_HIGH DDRD &= ~0x04   // Defines the expression "N64_HIGH" as "set digital pin 2 as an input", which as it's railed, goes HIGH
#define N64_LOW DDRD |= 0x04     // Defines the expression "N64_LOW" as "set digital pin 2 as an output", which as it's railed, goes LOW
#define N64_QUERY (PIND & 0x04)  // Defines the expression "N64_QUERY" as "is digital pins 2 HIGH?"

// Define the struct "N64_status", which contains the data that we get from the controller
struct {
    unsigned char data1;         // Creates a char "data1" which contains bits (1 or 0) for: A, B, Z, Start, Dup, Ddown, Dleft, Dright
    unsigned char data2;         // Creates a char "data2" which contains bits for: 0, 0, L, R, Cup, Cdown, Cleft, Cright
    char stick_x;                // Creates a char "stick_x" which contains the x position of the joystick, from -128 to 127
    char stick_y;                // Creates a char "stick_y" which contains the y position of the joystick, from -128 to 127
} N64_status;
char N64_raw_dump[33];           // Creates an array of 33 chars, to contain the bytes of memory the controller sends (1 received bit per byte)


void N64_send(unsigned char *buffer, char length);    // Declares the function "N64_send", which takes a dereferenced pointer and a length as inputs
void N64_get();                                       // Declares the function "N64_get", which waits for the controller data and puts it into N64_raw_dump
void translate_raw_data();                            // Declares the function "translate_raw_data", which takes in N64_raw_dump, and interprets it into button states
void print_N64_status();                              // Declares the function "print_N64_status", which prints the controller data in a human-friendly manner to the serial

void setup()
{
  Serial.begin(115200);          // Sets the baud rate (115200 bits per second over the serial)

  digitalWrite(N64_PIN, LOW);    // Sets the data pin to low from the outset - we don't want to push +5V to the controller at any point
  pinMode(N64_PIN, INPUT);       // Sets the data pin as an input pin

  // Initialize the controller by sending it a null byte. This is unnecessary 
  // for a standard controller, but is required for a 3rd party Wavebird controller
  unsigned char initialize = 0x00;
  noInterrupts();
  N64_send(&initialize, 1);

  // Stupid routine to wait for the controller to stop
  // sending its response. We don't care what it is, but we
  // can't start asking for status if it's still responding
  int x;
  for (x=0; x<64; x++) {         // Make sure the line is idle for 64 iterations, should be plenty
      if (!N64_QUERY)
          x = 0;
  }

  // Query for the controller's status to get the 0 point for the control stick
  unsigned char command[] = {0x40, 0x03, 0x00};
  N64_send(command, 3);
  //unsigned char command[] = {0x01};
  //N64_send(command, 1);          // Send 0x01, which means "give status" to the controller
  N64_get();                     // Read in data and dump it to N64_raw_dump
  interrupts();
  translate_raw_data();  
}

void loop()
{
    int i;
    unsigned char data, addr;

    // Command to send to the controller - The last bit is rumble, flip it to rumble
    // (yes this does need to be inside the loop, the array gets mutilated when it goes through gc_send)
    unsigned char command[] = {0x01}; 
    //if (rumble) {
    //    command[2] = 0x01;
    //}

    noInterrupts();                  // Don't want interrupts getting in the way
    N64_send(command, 1);            // Send the initial command
    N64_get();                       // Read in data and dump it to N64_raw_dump
    interrupts();                    // End of time sensitive code

    translate_raw_data();            // Translate the data in N64_raw_dump to something useful

    for (i=0; i<16; i++) {
       Serial.print(N64_raw_dump[i], DEC);
    }

    Serial.print("         Stick X:");
    Serial.print(N64_status.stick_x, DEC);
    Serial.print("         Stick Y:");
    Serial.println(N64_status.stick_y, DEC);

    // DEBUG: print it
    //print_N64_status();
    //delay(2000);
    delay(25);
}


