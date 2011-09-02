void print_controller_status()
{
    for (i=0; i<16; i++) {
       Serial.print(N64_raw_dump[i], DEC);
    }

    Serial.print("         Stick X:");
    Serial.print(N64_status.stick_x, DEC);
    Serial.print("         Stick Y:");
    Serial.println(N64_status.stick_y, DEC);
}


