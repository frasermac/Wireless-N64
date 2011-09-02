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
 * (the controller pin directions are with the flat part down, facing the plug male end)
 *
 * CONTROLLER PIN      ARDUINO PIN
 * GND (left)          GND
 * PWR (right)         3.3 V
 * DATA (cntr)         digital pin 2 AND 1k pull-up resistor to 3.3 V
*/

// These operations translate to 1 op code, which takes 2 cycles
// These definitions are used to control port registers, allowing faster and
// lower-level control of i/o (http://www.arduino.cc/en/Reference/PortManipulation)
// Remember, "0x" is just a common prefix to indicate a base-16 hexadecimal number (e.g. 0x04 is just hex 04)

#define CONTROLLER_PIN 2                // Communicate with the controller over digital pin 2
#define CONTROLLER_HIGH DDRD &= ~0x04   // Defines the expression "CONTROLLER_HIGH" as "set digital pin 2 as an input", which as it's railed, goes HIGH
#define CONTROLLER_LOW DDRD |= 0x04     // Defines the expression "CONTROLLER_LOW" as "set digital pin 2 as an output", which as it's railed, goes LOW
#define CONTROLLER_QUERY (PIND & 0x04)  // Defines the expression "CONTROLLER_QUERY" as "is digital pins 2 HIGH?"

// Define the struct "controller_status", which contains the data that we get from the controller
struct {
    unsigned char data1;         // Creates a char "data1" which contains bits (1 or 0) for: A, B, Z, Start, Dup, Ddown, Dleft, Dright (DR,DL,DD,DU,S,Z,B,A)
    unsigned char data2;         // Creates a char "data2" which contains bits for: 0, 0, L, R, Cup, Cdown, Cleft, Cright (CR,CL,CD,CU,R,L,0,0)
    char stick_x;                // Creates a char "stick_x" which contains the x position of the joystick, from -128 to 127
    char stick_y;                // Creates a char "stick_y" which contains the y position of the joystick, from -128 to 127
} controller_status;
char controller_raw_dump[33];    // Creates an array of 33 chars, to contain the bytes of memory the controller sends (1 received bit per byte)

void controller_send(unsigned char *buffer, char length);    // Declares the function "controller_send", which sends a dereferenced pointer of some length to the controller
void controller_get();                                       // Declares the function "controller_get", which waits for the controller data and puts it into controller_raw_dump
void translate_raw_dump();                                   // Declares the function "translate_raw_dump", which translates the controller_raw_dump array into the controller_status struct
void print_controller_status();                              // Declares the function "print_controller_status", which prints the controller_status in a human-friendly manner to the serial

void setup()
{
  Serial.begin(115200);                 // Sets the baud rate (115200 bits per second over the serial)

  digitalWrite(CONTROLLER_PIN, LOW);    // Sets the data pin to low from the outset - we don't want to push +5V to the controller at any point
  pinMode(CONTROLLER_PIN, INPUT);       // Sets the data pin as an input pin

  // Initialize the controller by sending it a null byte. This is unnecessary 
  // for a standard controller, but is required for a 3rd party Wavebird controller
  unsigned char initialize = 0x00;
  noInterrupts();
  controller_send(&initialize, 1);

  // Stupid routine to wait for the controller to stop sending its response
  int x;
  for (x=0; x<64; x++) {         // Make sure the line is idle (i.e. HIGH) for 64 iterations, should be plenty
      if (!CONTROLLER_QUERY)
          x = 0;
  }
  interrupts();
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
    controller_send(command, 1);            // Send the initial command
    controller_get();                       // Read in data and dump it to controller_raw_dump
    interrupts();                    // End of time sensitive code

    translate_raw_dump();            // Translate the data in controller_raw_dump to something useful

    print_controller_status();
    delay(25);
}


