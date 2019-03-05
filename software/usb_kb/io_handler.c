//io_handler.c
#include "io_handler.h"
#include <stdio.h>

void IO_init(void)
{
	*otg_hpi_reset = 1;
	*otg_hpi_cs = 1;
	*otg_hpi_r = 1;
	*otg_hpi_w = 1;
	*otg_hpi_address = 0;
	*otg_hpi_data = 0;
	// Reset OTG chip
	*otg_hpi_cs = 0;
	*otg_hpi_reset = 0;
	*otg_hpi_reset = 1;
	*otg_hpi_cs = 1;
}

void IO_write(alt_u8 Address, alt_u16 Data)
{
//*************************************************************************//
//									TASK								   //
//*************************************************************************//
//							Write this function							   //
//*************************************************************************//

	*otg_hpi_r = 1; // disable read

	*otg_hpi_address = Address; // set up data and address
	*otg_hpi_data = Data;

	*otg_hpi_cs = 0; // enable chip
	*otg_hpi_w = 0; // enable write

	*otg_hpi_w = 1; //disable write
	*otg_hpi_cs = 1; //disable chip
}

alt_u16 IO_read(alt_u8 Address)
{
	alt_u16 temp;
//*************************************************************************//
//									TASK								   //
//*************************************************************************//
//							Write this function							   //
//*************************************************************************//
	//printf("%x\n",temp);

	*otg_hpi_w = 1; //disable write

	*otg_hpi_address = Address; // set up address

	*otg_hpi_cs = 0; // enable chip
	*otg_hpi_r = 0; //enable read

	temp = *otg_hpi_data; //sets temp to whatever otg_hpi_data is pointing to (dereference)

	*otg_hpi_r = 1; //disable read
	*otg_hpi_cs = 1; //disable chip
	return temp;
}
