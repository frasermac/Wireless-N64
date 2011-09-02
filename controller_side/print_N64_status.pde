void print_N64_status()
{
    int i;
    // bits: A, B, Z, Start, Dup, Ddown, Dleft, Dright
    // bits: 0, 0, L, R, Cup, Cdown, Cleft, Cright
    Serial.println();
    Serial.print("Start: ");
    Serial.println(N64_status.data1 & 16 ? 1:0);

    Serial.print("Z:     ");
    Serial.println(N64_status.data1 & 32 ? 1:0);

    Serial.print("B:     ");
    Serial.println(N64_status.data1 & 64 ? 1:0);

    Serial.print("A:     ");
    Serial.println(N64_status.data1 & 128 ? 1:0);

    Serial.print("L:     ");
    Serial.println(N64_status.data2 & 32 ? 1:0);
    Serial.print("R:     ");
    Serial.println(N64_status.data2 & 16 ? 1:0);

    Serial.print("Cup:   ");
    Serial.println(N64_status.data2 & 0x08 ? 1:0);
    Serial.print("Cdown: ");
    Serial.println(N64_status.data2 & 0x04 ? 1:0);
    Serial.print("Cright:");
    Serial.println(N64_status.data2 & 0x01 ? 1:0);
    Serial.print("Cleft: ");
    Serial.println(N64_status.data2 & 0x02 ? 1:0);
    
    Serial.print("Dup:   ");
    Serial.println(N64_status.data1 & 0x08 ? 1:0);
    Serial.print("Ddown: ");
    Serial.println(N64_status.data1 & 0x04 ? 1:0);
    Serial.print("Dright:");
    Serial.println(N64_status.data1 & 0x01 ? 1:0);
    Serial.print("Dleft: ");
    Serial.println(N64_status.data1 & 0x02 ? 1:0);

    Serial.print("Stick X:");
    Serial.println(N64_status.stick_x, DEC);
    Serial.print("Stick Y:");
    Serial.println(N64_status.stick_y, DEC);
}

