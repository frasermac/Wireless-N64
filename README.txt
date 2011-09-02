This code is adapted from Andrew Brown's (brilliant) N64 to Gamecube Adapter, which I understand is itself adapted from the venerable cube64 project.

If you're looking to get lost on the internet, here are my picks of gripping dispatches from the world of N64 projects:

- Cube64:
	http://cia.vc/stats/project/navi-misc/cube64
- Andrew Brown's Gamecube N64 Controller:
	https://github.com/brownan/Gamecube-N64-Controller
- çlvaro Garc’a's Wii N64 Controller:
	https://github.com/maxpowel/Wii-N64-Controller



MANIFEST:    

controller side:
        N64_get             -   gets controller button states
        N64_send            -   sends commands to the controller
        print_N64_status    -   prints button states to serial
        translate_raw_data  -   converts N64_raw_dump to N64_status
        
console side:
	crc_table.h         -   for console crc check
        GC_to_64            -   converts N64_status to n64_buffer[]
        get_N64_command     -   gets the N64 and puts it in n64_command and gathers extra stuff too
        N64_send            -   sends responses to the N64
