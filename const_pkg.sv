package const_pkg;

`define TRUE	1'b1
`define FALSE	1'b0
`define HIGH	1'b1
`define LOW		1'b0
`define VAL		1'b1
`define INV		1'b0

 parameter TRUE = `TRUE;
 parameter FALSE = `FALSE;
 parameter VAL = `VAL;
 parameter INV = `INV;
 parameter HIGH = `HIGH;
 parameter LOW = `LOW;
 parameter ACK = 1'b1;
 parameter NACK = 1'b0;

endpackage
