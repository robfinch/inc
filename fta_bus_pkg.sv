// ============================================================================
//        __
//   \\__/ o\    (C) 2015-2025  Robert Finch, Waterloo
//    \  __ /    All rights reserved.
//     \/_//     robfinch<remove>@finitron.ca
//       ||
//
// BSD 3-Clause License
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// 1. Redistributions of source code must retain the above copyright notice, this
//    list of conditions and the following disclaimer.
//
// 2. Redistributions in binary form must reproduce the above copyright notice,
//    this list of conditions and the following disclaimer in the documentation
//    and/or other materials provided with the distribution.
//
// 3. Neither the name of the copyright holder nor the names of its
//    contributors may be used to endorse or promote products derived from
//    this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
// Interrupts
//
// fta_bus sends interrupt messages on the response bus. This is indicated
// using a response error code of IRQ.
// Interrupt messages may be sent to a specific code and channel. This is
// specified in the tranid of the response.
// A core number of zero will cause all processors to process the interrupt.
// The tid portion of the tranid should be zero.
// The core number and channel number portion of the interrupt message are
// located in a programmable register in the device.
// Interrupt priority is controlled by the priority field in the response
// message. Messages with a higher priority will be processed by response
// buffers before lower priority ones.
// The data field of the response contains an eight-bit vector number to be
// used by the core processing the response.
// ============================================================================
//
package fta_bus_pkg;

typedef logic [39:0] fta_address_t;
typedef logic [5:0] fta_burst_len_t;		// number of beats in a burst -1
typedef logic [3:0] fta_channel_t;			// channel for devices like system cache
//typedef logic [7:0] fta_tranid_t;			// transaction id
typedef logic [7:0] fta_priv_level_t;	// 0=all access,
typedef logic [3:0] fta_priority_t;		// network transaction priority, higher is better
typedef logic [11:0] fta_asid_t;				// address space identifier
typedef logic [19:0] fta_key_t;					// access key

typedef struct packed {
	logic [5:0] core;
	logic [2:0] channel;
	logic [3:0] tranid;
} fta_tranid_t;

typedef enum logic [1:0] {
	APP = 2'd0,
	SUPERVISOR = 2'd1,
	HYPERVISOR = 2'd2,
	MACHINE = 2'd3
} fta_operating_mode_t;

typedef enum logic [2:0] {
	CLASSIC = 3'b000,
	FIXED = 3'b001,					// constant data address
	INCR = 3'b010,					// incrementing data address
	IO = 3'b100,						// Input/Output cycle
	ERC = 3'b101,						// record errors on write
	IRQA = 3'b110,					// interrupt acknowledge
	EOB = 3'b111						// end of data burst
//	SYNCLASS = 4'b1000				// synchronous classic
} fta_cycle_type_t;

typedef enum logic [2:0] {
	DATA = 3'b000,
	STACK = 3'b110,
	CODE = 3'b111
} fta_segment_t;

typedef enum logic [2:0] {
	LINEAR = 3'b000,
	WRAP4 = 3'b001,
	WRAP8 = 3'b010,
	WRAP16 = 3'b011,
	WRAP32 = 3'b100,
	WRAP64 = 3'b101,
	WRAP128 = 3'b110
} fta_burst_type_t;

// number of byte transferred in a beat
typedef enum logic [3:0] {
	nul = 4'd0,
	byt = 4'd1,
	wyde = 4'd2,
	tetra = 4'd3,
	penta = 4'd4,
	octa = 4'd5,
	hexi = 4'd6,
	dhexi = 4'd7,
	n96 = 4'd8,
	char = 4'd9,
	vect = 4'd11
} fta_size_t;

typedef enum logic [2:0] {
	OKAY = 3'd0,				// no error
	DECERR = 3'd1,			// decode error
	PROTERR = 3'd2,			// security violation
	ERR = 3'd3,					// general error
	IRQ = 3'd7					// interrupt request
} fta_error_t;

typedef enum logic [3:0] {
	NC_NB = 4'd0,										// Non-cacheable, non-bufferable
	NON_CACHEABLE = 4'd1,
	CACHEABLE_NB = 4'd2,						// Cacheable, non-bufferable
	CACHEABLE = 4'd3,								// Cacheable, bufferable
	WT_NO_ALLOCATE = 4'd8,					// Write Through
	WT_READ_ALLOCATE = 4'd9,
	WT_WRITE_ALLOCATE = 4'd10,
	WT_READWRITE_ALLOCATE = 4'd11,
	WB_NO_ALLOCATE = 4'd12,					// Write Back
	WB_READ_ALLOCATE = 4'd13,
	WB_WRITE_ALLOCATE = 4'd14,
	WB_READWRITE_ALLOCATE = 4'd15
} fta_cache_t;

typedef enum logic [4:0] {
	CMD_NONE = 5'd0,
	CMD_LOAD = 5'd1,
	CMD_LOADZ = 5'd2,
	CMD_STORE = 5'd3,
	CMD_STOREPTR = 5'd4,
	CMD_STORECAP = 5'd5,
	CMD_LEA = 5'd7,
	CMD_OPEN = 5'd8,						// gateway open
	CMD_CLOSE = 5'd9,						// gateway close
	CMD_DCACHE_LOAD = 5'd10,
	CMD_ICACHE_LOAD = 5'd11,
	CMD_CACHE = 5'd13,
	CMD_SWAP = 5'd16,
	CMD_MIN = 5'd18,
	CMD_MAX = 5'd19,
	CMD_ADD = 5'd20,
	CMD_ASL = 5'd22,
	CMD_LSR = 5'd23,
	CMD_AND = 5'd24,
	CMD_OR = 5'd25,
	CMD_EOR = 5'd26,
	CMD_MINU = 5'd28,
	CMD_MAXU = 5'd29,
	CMD_CAS = 5'd31
} fta_cmd_t;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Command requests
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

typedef struct packed {
	fta_operating_mode_t om;	// operating mode
	fta_cmd_t cmd;					// command
	fta_burst_type_t bte;	// burst type extension
	fta_cycle_type_t cti;	// cycle type indicator
	fta_burst_len_t blen;	// length of burst-1
	fta_size_t sz;					// transfer size
	fta_segment_t seg;			// segment
	logic cyc;						// valid cycle
	logic stb;						// data strobe
	logic we;							// write enable
	fta_asid_t asid;				// address space identifier
	fta_address_t vadr;		// virtual address
	fta_address_t padr;		// physical address
	logic [7:0] dat;			// data
	fta_tranid_t tid;			// transaction id
	logic csr;						// set or clear reservation we:1=clear 0=set
	fta_key_t [3:0] key;	// access keys
	fta_priv_level_t pl;		// privilege level
	fta_priority_t pri;		// transaction priority
	fta_cache_t cache;			// cache and buffer properties
} fta_cmd_request8_t;

typedef struct packed {
	fta_operating_mode_t om;	// operating mode
	fta_cmd_t cmd;					// command
	fta_burst_type_t bte;	// burst type extension
	fta_cycle_type_t cti;	// cycle type indicator
	fta_burst_len_t blen;	// length of burst-1
	fta_size_t sz;					// transfer size
	fta_segment_t seg;			// segment
	logic cyc;						// valid cycle
	logic stb;						// data strobe
	logic we;							// write enable
	fta_asid_t asid;				// address space identifier
	fta_address_t vadr;		// virtual address
	fta_address_t padr;		// physical address
	logic [1:0] sel;			// byte lane selects
	logic [15:0] dat;			// data
	fta_tranid_t tid;			// transaction id
	logic csr;						// set or clear reservation we:1=clear 0=set
	fta_key_t [3:0] key;	// access keys
	fta_priv_level_t pl;		// privilege level
	fta_priority_t pri;		// transaction priority
	fta_cache_t cache;			// cache and buffer properties
} fta_cmd_request16_t;

typedef struct packed {
	fta_operating_mode_t om;	// operating mode
	fta_cmd_t cmd;					// command
	fta_burst_type_t bte;	// burst type extension
	fta_cycle_type_t cti;	// cycle type indicator
	fta_burst_len_t blen;	// length of burst-1
	fta_size_t sz;					// transfer size
	fta_segment_t seg;			// segment
	logic cyc;						// valid cycle
	logic stb;						// data strobe
	logic we;							// write enable
	fta_asid_t asid;				// address space identifier
	fta_address_t vadr;		// virtual address
	fta_address_t padr;		// physical address
	logic [3:0] sel;			// byte lane selects
	logic [31:0] dat;			// data
	fta_tranid_t tid;			// transaction id
	logic csr;						// set or clear reservation we:1=clear 0=set
	fta_key_t [3:0] key;	// access keys
	fta_priv_level_t pl;		// privilege level
	fta_priority_t pri;		// transaction priority
	fta_cache_t cache;			// cache and buffer properties
} fta_cmd_request32_t;

typedef struct packed {
	fta_operating_mode_t om;	// operating mode
	fta_cmd_t cmd;					// command
	fta_burst_type_t bte;	// burst type extension
	fta_cycle_type_t cti;	// cycle type indicator
	fta_burst_len_t blen;	// length of burst-1
	fta_size_t sz;					// transfer size
	fta_segment_t seg;			// segment
	logic cyc;						// valid cycle
	logic stb;						// data strobe
	logic we;							// write enable
	fta_asid_t asid;				// address space identifier
	fta_address_t vadr;		// virtual address
	fta_address_t padr;		// physical address
	logic [7:0] sel;			// byte lane selects
	logic [63:0] dat;			// data
	fta_tranid_t tid;			// transaction id
	logic csr;						// set or clear reservation we:1=clear 0=set
	fta_key_t [3:0] key;	// access keys
	fta_priv_level_t pl;		// privilege level
	fta_priority_t pri;		// transaction priority
	fta_cache_t cache;			// cache and buffer properties
} fta_cmd_request64_t;

typedef struct packed {
	fta_operating_mode_t om;	// operating mode
	fta_cmd_t cmd;					// command
	fta_burst_type_t bte;	// burst type extension
	fta_cycle_type_t cti;	// cycle type indicator
	fta_burst_len_t blen;	// length of burst-1
	fta_size_t sz;					// transfer size
	fta_segment_t seg;			// segment
	logic cyc;						// valid cycle
	logic stb;						// data strobe
	logic we;							// write enable
	fta_asid_t asid;				// address space identifier
	fta_address_t vadr;		// virtual address
	fta_address_t padr;		// physical address
	logic [15:0] sel;			// byte lane selects
	logic ctag;						// capabilities tag bit
	logic [127:0] data1;	// data
	logic [127:0] data2;	// data
	fta_tranid_t tid;			// transaction id
	logic csr;						// set or clear reservation we:1=clear 0=set
	fta_key_t [3:0] key;	// access keys
	fta_priv_level_t pl;		// privilege level
	fta_priority_t pri;		// transaction priority
	fta_cache_t cache;			// cache and buffer properties
} fta_cmd_request128_t;

typedef struct packed {
	fta_operating_mode_t om;	// operating mode
	fta_cmd_t cmd;					// command
	fta_burst_type_t bte;	// burst type extension
	fta_cycle_type_t cti;	// cycle type indicator
	fta_burst_len_t blen;	// length of burst-1
	fta_size_t sz;					// transfer size
	fta_segment_t seg;			// segment
	logic cyc;						// valid cycle
	logic stb;						// data strobe
	logic we;							// write enable
	fta_asid_t asid;				// address space identifier
	fta_address_t vadr;		// virtual address
	fta_address_t padr;		// physical address
	logic [31:0] sel;			// byte lane selects
	logic ctag;						// capabilities tag bit
	logic [255:0] data1;		// data
	logic [255:0] data2;		// data
	fta_tranid_t tid;			// transaction id
	logic csr;						// set or clear reservation we:1=clear 0=set
	fta_key_t [3:0] key;	// access keys
	fta_priv_level_t pl;		// privilege level
	fta_priority_t pri;		// transaction priority
	fta_cache_t cache;			// cache and buffer properties
} fta_cmd_request256_t;

typedef struct packed {
	fta_operating_mode_t om;	// operating mode
	fta_cmd_t cmd;					// command
	fta_burst_type_t bte;	// burst type extension
	fta_cycle_type_t cti;	// cycle type indicator
	fta_burst_len_t blen;	// length of burst-1
	fta_size_t sz;					// transfer size
	fta_segment_t seg;			// segment
	logic cyc;						// valid cycle
	logic stb;						// data strobe
	logic we;							// write enable
	fta_asid_t asid;				// address space identifier
	fta_address_t vadr;		// virtual address
	fta_address_t padr;		// physical address
	logic [63:0] sel;			// byte lane selects
	logic [511:0] dat;		// data
	fta_tranid_t tid;			// transaction id
	logic csr;						// set or clear reservation we:1=clear 0=set
	fta_key_t [3:0] key;	// access keys
	fta_priv_level_t pl;		// privilege level
	fta_priority_t pri;		// transaction priority
	fta_cache_t cache;			// cache and buffer properties
} fta_cmd_request512_t;

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Read responses
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

typedef struct packed {
	fta_asid_t asid;				// address space identifier
	fta_tranid_t tid;			// transaction id
	logic stall;					// stall pipeline
	logic next;						// advance to next transaction
	logic ack;						// response acknowledge
	logic rty;						// retry
	fta_error_t err;			// error
	fta_priority_t pri;		// response priority
	fta_address_t adr;
	logic [7:0] dat;			// data
} fta_cmd_response8_t;

typedef struct packed {
	fta_asid_t asid;				// address space identifier
	fta_tranid_t tid;			// transaction id
	logic stall;					// stall pipeline
	logic next;						// advance to next transaction
	logic ack;						// response acknowledge
	logic rty;						// retry
	fta_error_t err;			// error
	fta_priority_t pri;		// response priority
	fta_address_t adr;
	logic [15:0] dat;			// data
} fta_cmd_response16_t;

typedef struct packed {
	fta_asid_t asid;				// address space identifier
	fta_tranid_t tid;			// transaction id
	logic stall;					// stall pipeline
	logic next;						// advance to next transaction
	logic ack;						// response acknowledge
	logic rty;						// retry
	fta_error_t err;			// error
	fta_priority_t pri;		// response priority
	fta_address_t adr;
	logic [31:0] dat;			// data
} fta_cmd_response32_t;

typedef struct packed {
	fta_asid_t asid;				// address space identifier
	fta_tranid_t tid;			// transaction id
	logic stall;					// stall pipeline
	logic next;						// advance to next transaction
	logic ack;						// response acknowledge
	logic rty;						// retry
	fta_error_t err;			// error
	fta_priority_t pri;		// response priority
	fta_address_t adr;
	logic [31:0] dat;			// data
} fta_response32_t;

typedef struct packed {
	fta_asid_t asid;				// address space identifier
	fta_tranid_t tid;			// transaction id
	logic stall;					// stall pipeline
	logic next;						// advance to next transaction
	logic ack;						// response acknowledge
	logic rty;						// retry
	fta_error_t err;			// error
	fta_priority_t pri;		// response priority
	fta_address_t adr;
	logic [63:0] dat;			// data
} fta_cmd_response64_t;

typedef struct packed {
	fta_asid_t asid;				// address space identifier
	fta_tranid_t tid;			// transaction id
	logic stall;					// stall pipeline
	logic next;						// advance to next transaction
	logic ack;						// response acknowledge
	logic rty;						// retry
	fta_error_t err;			// error
	fta_priority_t pri;		// response priority
	fta_address_t adr;
	logic ctag;						// capabilities tag bit
	logic [127:0] dat;		// data
} fta_cmd_response128_t;

typedef struct packed {
	fta_asid_t asid;				// address space identifier
	fta_tranid_t tid;			// transaction id
	logic stall;					// stall pipeline
	logic next;						// advance to next transaction
	logic ack;						// response acknowledge
	logic rty;						// retry
	fta_error_t err;			// error
	fta_priority_t pri;		// response priority
	fta_address_t adr;
	logic ctag;						// capabilities tag bit
	logic [127:0] dat;		// data
} fta_response128_t;

typedef struct packed {
	fta_asid_t asid;				// address space identifier
	fta_tranid_t tid;			// transaction id
	logic stall;					// stall pipeline
	logic next;						// advance to next transaction
	logic ack;						// response acknowledge
	logic rty;						// retry
	fta_error_t err;			// error
	fta_priority_t pri;		// response priority
	fta_address_t adr;
	logic ctag;						// capabilities tag bit
	logic [255:0] dat;		// data
} fta_cmd_response256_t;

typedef struct packed {
	fta_asid_t asid;				// address space identifier
	fta_tranid_t tid;			// transaction id
	logic stall;					// stall pipeline
	logic next;						// advance to next transaction
	logic ack;						// response acknowledge
	logic rty;						// retry
	fta_error_t err;			// error
	fta_priority_t pri;		// response priority
	fta_address_t adr;
	logic [511:0] dat;		// data
} fta_cmd_response512_t;


typedef struct packed
{
	// in the address field (40 bits)
	logic [5:0] pri;
	logic [1:0] stkndx;
	logic [15:0] segment;
	logic [7:0] bus;
	logic [4:0] device;
	logic [2:0] func;
	// in the data field
	logic [7:0] resv2;
	logic [5:0] irq_coreno;
	logic [1:0] om;
	logic [3:0] resv1;
	logic [11:0] vecno;
} fta_imessage_t;			// 72 bits

function fnFtaAllocate;
input fta_cache_t typ;
begin
	fnFtaAllocate =
		typ==fta_bus_pkg::CACHEABLE_NB ||
		typ==fta_bus_pkg::CACHEABLE ||
		typ==fta_bus_pkg::WT_READ_ALLOCATE ||
		typ==fta_bus_pkg::WT_WRITE_ALLOCATE ||
		typ==fta_bus_pkg::WT_READWRITE_ALLOCATE ||
		typ==fta_bus_pkg::WB_READ_ALLOCATE ||
		typ==fta_bus_pkg::WB_WRITE_ALLOCATE ||
		typ==fta_bus_pkg::WB_READWRITE_ALLOCATE
		;
end
endfunction

function fnFtaReadAllocate;
input fta_cache_t typ;
begin
	fnFtaReadAllocate =
		typ==fta_bus_pkg::CACHEABLE_NB ||
		typ==fta_bus_pkg::CACHEABLE ||
		typ==fta_bus_pkg::WT_READ_ALLOCATE ||
		typ==fta_bus_pkg::WT_READWRITE_ALLOCATE ||
		typ==fta_bus_pkg::WB_READ_ALLOCATE ||
		typ==fta_bus_pkg::WB_READWRITE_ALLOCATE
		;
end
endfunction

endpackage

interface fta_bus_interface;

	parameter DATA_WIDTH = 256;
	parameter VADR_WIDTH = 32;
	parameter PADR_WIDTH = 32;

  // Global signals
  logic clk;
  logic rst;

	// Request signals
	typedef struct packed {
	fta_bus_pkg::fta_operating_mode_t om;	// operating mode
	fta_bus_pkg::fta_cmd_t cmd;					// command
	fta_bus_pkg::fta_burst_type_t bte;	// burst type extension
	fta_bus_pkg::fta_cycle_type_t cti;	// cycle type indicator
	fta_bus_pkg::fta_burst_len_t blen;	// length of burst-1
	fta_bus_pkg::fta_size_t sz;					// transfer size
	fta_bus_pkg::fta_segment_t seg;			// segment
	logic cyc;						// valid cycle
	logic stb;						// data strobe
	logic we;							// write enable
	fta_bus_pkg::fta_asid_t asid;				// address space identifier
	logic [VADR_WIDTH-1:0] vadr;		// virtual address
	logic [PADR_WIDTH-1:0] padr;		// physical address
	logic [DATA_WIDTH/8-1:0] sel;			// byte lane selects
	logic ctag;						// capabilities tag bit
	logic [DATA_WIDTH-1:0] data1;	// data
	logic [DATA_WIDTH-1:0] data2;	// data
	fta_bus_pkg::fta_tranid_t tid;			// transaction id
	logic csr;						// set or clear reservation we:1=clear 0=set
	fta_bus_pkg::fta_key_t [3:0] key;	// access keys
	fta_bus_pkg::fta_priv_level_t pl;		// privilege level
	fta_bus_pkg::fta_priority_t pri;		// transaction priority
	fta_bus_pkg::fta_cache_t cache;			// cache and buffer properties
	} req_t;

	// Reponse signals
	typedef struct packed {
	fta_bus_pkg::fta_asid_t asid;				// address space identifier
	fta_bus_pkg::fta_tranid_t tid;			// transaction id
	logic stall;					// stall pipeline
	logic next;						// advance to next transaction
	logic ack;						// response acknowledge
	logic rty;						// retry
	fta_bus_pkg::fta_error_t err;			// error
	fta_bus_pkg::fta_priority_t pri;		// response priority
	logic [PADR_WIDTH-1:0] adr;
	logic ctag;						// capabilities tag bit
	logic [DATA_WIDTH-1:0] dat;		// data
	} resp_t;
	
	req_t req;
	resp_t resp;

	modport master (input rst, clk, output req, input resp);
	modport slave (input rst, clk, input req, output resp);
/*
	modport master(output m_om, m_cmd, m_bte, m_cti, m_blen, m_sz, m_seg, m_cyc, m_stb,
		m_we, m_asid, m_vadr, m_padr, m_sel, m_ctag, m_data1, m_data2, m_tid, m_csr,
		m_key, m_pl, m_pri, m_cache,
		input s_asid, s_tid, s_stall, s_next, s_ack, s_rty, s_err, s_pri, s_adr, s_ctag,
		s_dat);	
	modport slave(input m_om, m_cmd, m_bte, m_cti, m_blen, m_sz, m_seg, m_cyc, m_stb,
		m_we, m_asid, m_vadr, m_padr, m_sel, m_ctag, m_data1, m_data2, m_tid, m_csr,
		m_key, m_pl, m_pri, m_cache,
		output s_asid, s_tid, s_stall, s_next, s_ack, s_rty, s_err, s_pri, s_adr, s_ctag,
		s_dat);	
*/
endinterface

