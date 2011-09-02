void translate_raw_dump()
{
    // The controller_get function sloppily dumps its data 1 bit per byte
    // into the controller_raw_dump char array. It's our job to go through
    // that and put each piece neatly into the struct controller_status
    
    int i;
    
    memset(&controller_status, 0, sizeof(controller_status)); // Set all of the bytes of controller_status to 0
    
    // Line 1, bits: A, B, Z, Start, Dup, Ddown, Dleft, Dright
    for (i=0; i<8; i++) {
        controller_status.data1 |= controller_raw_dump[i] ? (0x80 >> i) : 0;  // At 0, controller_raw_dump[0] looks like 100000000
    }
    
    // Line 2, bits: 0, 0, L, R, Cup, Cdown, Cleft, Cright
    for (i=0; i<8; i++) {
        controller_status.data2 |= controller_raw_dump[8+i] ? (0x80 >> i) : 0;
    }
    
    // Line 3, bits: joystick x value (these are 8 bit chars, centered at 0x80 (128))
    for (i=0; i<8; i++) {
        controller_status.stick_x |= controller_raw_dump[16+i] ? (0x80 >> i) : 0;
    }
    
    // Line 4, bits: joystick y value
    for (i=0; i<8; i++) {
        controller_status.stick_y |= controller_raw_dump[24+i] ? (0x80 >> i) : 0;
    }
}
