/*
 * Reads from the controller_status struct and builds a 32 bit array ready to send to
 * the N64 when it queries us.  This is stored in n64_buffer[]
 */
 
void controller_to_n64()
{
    
    memset(n64_buffer, 0, sizeof(n64_buffer));      // clear it out

    // First byte in n64_buffer should contain:
    // A, B, Z, Start, Dup, Ddown, Dleft, Dright
    n64_buffer[0] |= (controller_status.data1 & 128);      // A
    n64_buffer[0] |= (controller_status.data1 & 64);       // B
    n64_buffer[0] |= (controller_status.data1 & 32);       // Z
    n64_buffer[0] |= (controller_status.data1 & 16);       // Start
    n64_buffer[0] |= (controller_status.data1 & 0x08);     // D pad up 
    n64_buffer[0] |= (controller_status.data1 & 0x04);     // D pad down
    n64_buffer[0] |= (controller_status.data1 & 0x02);     // D pad left
    n64_buffer[0] |= (controller_status.data1 & 0x021);    // D pad right    

    // Second byte to N64 should contain:
    // 0, 0, L, R, Cup, Cdown, Cleft, Cright
    n64_buffer[1] |= (controller_status.data2 & 128);      // A
    n64_buffer[1] |= (controller_status.data2 & 64);       // B
    n64_buffer[1] |= (controller_status.data2 & 32);       //Z
    n64_buffer[1] |= (controller_status.data2 & 16);       // Start
    n64_buffer[1] |= (controller_status.data2 & 0x08);     // D pad up 
    n64_buffer[1] |= (controller_status.data2 & 0x04);     // D pad down
    n64_buffer[1] |= (controller_status.data2 & 0x02);     // D pad left
    n64_buffer[1] |= (controller_status.data2 & 0x021);    // D pad right 

    // Control sticks:
    // 64 expects a signed value from -128 to 128 with 0 being neutral  
    n64_buffer[2] = controller_status.stick_x;             // Set the Stick X coordinate
    n64_buffer[3] = controller_status.stick_y;             // Set the Stick Y coordinate
    
}
