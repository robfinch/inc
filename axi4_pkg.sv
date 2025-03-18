package axi4_pkg;

typedef enum logic [1:0] {
	FIXED = 2'b00,
	INCR = 2'b01,
	WRAP = 2'b10
} axi4_burst_t;

typedef enum logic [2:0] {
	_1B = 3'b000,
	_2B = 3'b001,
	_4B = 3'b010,
	_8B = 3'b011,
	_16B = 3'b100,
	_32B = 3'b101,
	_64B = 3'b110,
	_128B = 3'b111
} axi4_size_t;

typedef enum logic [1:0] {
	OKAY = 2'b00,
	EXOKAY = 2'b01,
	SLVERR = 2'b10,
	DECERR = 2'b11
} axi4_resp_t;

typedef struct packed {
	logic wa;			// 1=write allocate recommended, but not mandatory
	logic ra;			// 1=read allocate recommended, but not mandatory
	logic m;			// 1=modifiable
	logic b;			// 1=bufferable
} axi4_cache_t;
endpackage

typedef struct packed {
	logic i;			// 1=instruction
	logic ns;			// 1=non secure
	logic p;			// 1=privileged
} axi4_prot_t;

typedef struct packed {
	logic [5:0] core;
	logic [2:0] channel;
	logic [3:0] tranid;
} axi4_id_t;

endpackage

// AMBA AXI-4 bus interface
interface axi4_interface;
parameter ADDR_WIDTH = 32;
parameter DATA_WIDTH = 256;

logic aclk;
logic aresetn;

// Write address channel
typedef struct packed {
	logic [ADDR_WIDTH-1:0] awaddr;
	logic [7:0] awlen;
	axi4_size_t awsize;
	axi4_burst_t awburst;
	axi4_cache_t awcache;
	axi4_prot_t awprot;
	axi4_id_t awid;
	logic awlock;
	logic [3:0] awqos;
	logic [3:0] awregion;
	logic awvalid;
	logic bready;							// part of the write response channel
} axi4_wac_t;
axi4_wac_t wac;

// Write data channel
typedef struct packed {
	logic [DATA_WIDTH/8-1:0] wstrb;
	logic [DATA_WIDTH-1:0] wdata;
	logic wlast;
	logic wvalid;
} axi4_wdc_t;
axi4_wdc_t wdc;

// Write response channel
typedef struct packed {
	logic awready;						// part of the write address channel
	logic wready;							// part of the write data channel
	logic bvalid;
	axi4_resp_t bresp;
	axi4_id_t bid;
} axi4_wrc_t;
axi4_wrc_t wrc;

// Read address channel
typedef struct packed {
	logic [ADDR_WIDTH-1:0] araddr;
	logic [7:0] arlen;
	axi4_size_t arsize;
	axi4_burst_t arburst;
	axi4_cache_t arcache;
	axi4_prot_t arprot;
	axi4_id_t arid;
	logic arlock;
	logic [3:0] arqos;
	logic [3:0] arregion;
	logic arvalid;
	logic rready;					// part of read data channel
	logic rlast;
} axi4_rac_t;
axi4_rac_t rac;

// Read data channel
typedef struct packed {
	logic arready;				// part of read address channel
	logic [DATA_WIDTH-1:0] rdata;
	logic rvalid;
	axi4_resp_t rresp;
	axi4_id_t rid;
} axi4_rdc_t;
axi4_rdc_t rdc;

modport master (
	output wac, wdc, rac,
	input wrc, rdc
);
modport slave (
	input wac, wdc, rac,
	output wrc, rdc
);

endinterface
