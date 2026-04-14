// RISCV32I CPU top module
// Minimal stub: immediately signal program finish via I/O 0x30004

module cpu(
  input  wire                 clk_in,           // system clock signal
  input  wire                 rst_in,           // reset signal
  input  wire                 rdy_in,           // ready signal, pause cpu when low

  input  wire [ 7:0]          mem_din,          // data input bus
  output wire [ 7:0]          mem_dout,         // data output bus
  output wire [31:0]          mem_a,            // address bus (only 17:0 is used)
  output wire                 mem_wr,           // write/read signal (1 for write)
  
  input  wire                 io_buffer_full,   // 1 if uart buffer is full
  
  output wire [31:0]          dbgreg_dout       // cpu register output (debugging demo)
);

// This stub does not execute instructions. It only writes a byte to
// I/O address 0x30004 (program finish) once after reset and then idles.

localparam IO_FINISH_ADDR = 32'h0003_0004;

reg [31:0] mem_a_r;
reg [7:0]  mem_dout_r;
reg        mem_wr_r;
reg [31:0] dbgreg_dout_r;

assign mem_a       = mem_a_r;
assign mem_dout    = mem_dout_r;
assign mem_wr      = mem_wr_r;
assign dbgreg_dout = dbgreg_dout_r;

// Simple FSM to perform one write then idle
reg [1:0] state; // 0: init, 1: write_finish, 2: idle

always @(posedge clk_in) begin
  if (rst_in) begin
    state          <= 2'd0;
    mem_a_r        <= 32'd0;
    mem_dout_r     <= 8'd0;
    mem_wr_r       <= 1'b0;
    dbgreg_dout_r  <= 32'd0;
  end else if (!rdy_in) begin
    // Stall: deassert write while paused
    mem_wr_r       <= 1'b0;
  end else begin
    case (state)
      2'd0: begin
        // Issue program-finish write to 0x30004
        mem_a_r    <= IO_FINISH_ADDR;
        mem_dout_r <= 8'd0;
        mem_wr_r   <= 1'b1;
        state      <= 2'd1;
      end
      2'd1: begin
        // Deassert write and go idle
        mem_wr_r   <= 1'b0;
        state      <= 2'd2;
      end
      default: begin
        // Idle forever
        mem_wr_r   <= 1'b0;
      end
    endcase
  end
end

endmodule
