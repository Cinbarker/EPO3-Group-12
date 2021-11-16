# Specifications
- Cell States: Mine, Flag, Cleared
- Up to 16 * 16
- Ram min size = 16 * 16 * 2 = 512 bits = 64 bytes

Cases: 
- WORST: Read per pixel = 16 * 16 * 240 * 240 * 60 = 884,736,000 reads / second
- Read per cell each line = 16 * 16 * 11 * 11 * 60 = 1,858,560 reads / second
- Read per cell = 16 * 16 * 60 = 15,360 reads / second

Solutions:
- Use parallel and don't save number of adjacent numbers, use 4 bit size ram -> Reduce write pins
  - Can we calculate adj nums fast enough?
- Use SPI ram -> Reduce addr and write pins
  - Complicated
  - How will it fit with timing?
- Use parallel and have address clock based with a counter -> Reduce addr pins
  - Cursor / write rate is limited to the display write frequency
- Use relative addr ram? -> Reduce addr pins
  - Maybe there is a counter for this
- Plex the address and write outputs pins with a buffer for the address when write needs to be used?
  - Write speed needs to be fast enough (fit within the writing of one cell)

SRAM or EEPROM?