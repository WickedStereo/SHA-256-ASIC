//////////////////////////////////////////////////////////////////////////////////
// Module: message_padder
// Function: SHA-256 Message Padding System
// Standard: NIST FIPS 180-4 §5.1.1
// Parameters:
//   MSG_BITS     = 96      - Input message width (bits)
//   PADDED_BITS  = 512     - Output block size (bits)
// Ports:
//   message      - Input message [MSG_BITS-1:0]
//   padded_message - Padded output [PADDED_BITS-1:0]
//   block_count  - Number of 512-bit blocks generated
// Notes:
//   - Implements padding rules: 1-append, 0-pad, length-finalize
//   - CURRENT LIMITATION: Single-block messages only
//////////////////////////////////////////////////////////////////////////////////


// SHA-256 padding scheme per NIST FIPS 180-4:
// 1. Append '1' bit (0x80 byte for byte-aligned messages)
// 2. Add k zero bits where k = (448 - (L + 1)) mod 512
// 3. Append 64-bit message length in big-endian


module message_padder #(
  parameter MSG_BITS = 96,			// Input message width
  parameter PADDED_BITS = 512		// Output block size
) 
(
  input logic [MSG_BITS-1:0] message,
  output logic block_count,			// CURRENT LIMITATION: Only supports single-block messages
									// TODO: Implement multi-block support using block_count

  output logic [PADDED_BITS-1:0] padded_message
);
  
  localparam ZERO_BITS = PADDED_BITS - MSG_BITS - 1 - 64;

  logic [PADDED_BITS-1:0] padded_message_reg;

  assign padded_message_reg[PADDED_BITS-1:PADDED_BITS-MSG_BITS] = message;
  assign padded_message_reg[PADDED_BITS-MSG_BITS-1] = 1'b1;
  assign padded_message_reg[PADDED_BITS-MSG_BITS-2-:ZERO_BITS] = '0;
  assign padded_message_reg[63:0] = MSG_BITS;

  assign padded_message = padded_message_reg;
  assign block_count = 1;
  
endmodule