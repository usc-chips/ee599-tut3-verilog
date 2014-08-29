//========================================================================
// Simple Four-Element Sorting Unit
//========================================================================
// This module sorts four N-bit elements into ascending order using a
// merge-sort-like hardware algorithm unrolled in space. We break the
// four elements into two pairs and sort each pair independently. Then we
// compare the smaller elements from each pair and the larger elements
// from each pair before arranging the middle two elements.
//
// This implementation uses a structural RTL coding style and is
// pipelined into three stages with exactly one comparison along the
// critical path in each stage.

`ifndef EX_SORTER_SORTER_STRUCT_V
`define EX_SORTER_SORTER_STRUCT_V

`include "ex-sorter-MinMaxUnit.v"

`include "vc-regs.v"
`include "vc-assert.v"
`include "vc-trace.v"

module ex_sorter_SorterStruct
#(
  parameter p_nbits = 1
)(
  input  logic               clk,
  input  logic               reset,

  input  logic               in_val,
  input  logic [p_nbits-1:0] in0,
  input  logic [p_nbits-1:0] in1,
  input  logic [p_nbits-1:0] in2,
  input  logic [p_nbits-1:0] in3,

  output logic               out_val,
  output logic [p_nbits-1:0] out0,
  output logic [p_nbits-1:0] out1,
  output logic [p_nbits-1:0] out2,
  output logic [p_nbits-1:0] out3
);

  //----------------------------------------------------------------------
  // Stage S0->S1 pipeline registers
  //----------------------------------------------------------------------

  logic val_S1;

  vc_ResetReg#(1) val_S0S1
  (
   .clk   (clk),
   .reset (reset),
   .d     (in_val),
   .q     (val_S1)
  );

  // This is probably the only place where it might be acceptable to use
  // positional port binding since (a) it is so common and (b) there are
  // very few ports to bind.

  logic [p_nbits-1:0] elm0_S1;
  logic [p_nbits-1:0] elm1_S1;
  logic [p_nbits-1:0] elm2_S1;
  logic [p_nbits-1:0] elm3_S1;

  vc_Reg#(p_nbits) elm0_S0S1( clk, elm0_S1, in0 );
  vc_Reg#(p_nbits) elm1_S0S1( clk, elm1_S1, in1 );
  vc_Reg#(p_nbits) elm2_S0S1( clk, elm2_S1, in2 );
  vc_Reg#(p_nbits) elm3_S0S1( clk, elm3_S1, in3 );

  //----------------------------------------------------------------------
  // Stage S1 combinational logic
  //----------------------------------------------------------------------

  logic [p_nbits-1:0] mmuA_out_min_S1;
  logic [p_nbits-1:0] mmuA_out_max_S1;

  ex_sorter_MinMaxUnit#(p_nbits) mmuA_S1
  (
    .in0     (elm0_S1),
    .in1     (elm1_S1),
    .out_min (mmuA_out_min_S1),
    .out_max (mmuA_out_max_S1)
  );

  logic [p_nbits-1:0] mmuB_out_min_S1;
  logic [p_nbits-1:0] mmuB_out_max_S1;

  ex_sorter_MinMaxUnit#(p_nbits) mmuB_S1
  (
    .in0     (elm2_S1),
    .in1     (elm3_S1),
    .out_min (mmuB_out_min_S1),
    .out_max (mmuB_out_max_S1)
  );

  //----------------------------------------------------------------------
  // Stage S1->S2 pipeline registers
  //----------------------------------------------------------------------

  logic val_S2;

  vc_ResetReg#(1) val_S1S2
  (
   .clk   (clk),
   .reset (reset),
   .d     (val_S1),
   .q     (val_S2)
  );

  logic [p_nbits-1:0] elm0_S2;
  logic [p_nbits-1:0] elm1_S2;
  logic [p_nbits-1:0] elm2_S2;
  logic [p_nbits-1:0] elm3_S2;

  vc_Reg#(p_nbits) elm0_S1S2( clk, elm0_S2, mmuA_out_min_S1 );
  vc_Reg#(p_nbits) elm1_S1S2( clk, elm1_S2, mmuA_out_max_S1 );
  vc_Reg#(p_nbits) elm2_S1S2( clk, elm2_S2, mmuB_out_min_S1 );
  vc_Reg#(p_nbits) elm3_S1S2( clk, elm3_S2, mmuB_out_max_S1 );

  //----------------------------------------------------------------------
  // Stage S2 combinational logic
  //----------------------------------------------------------------------

  logic [p_nbits-1:0] mmuA_out_min_S2;
  logic [p_nbits-1:0] mmuA_out_max_S2;

  ex_sorter_MinMaxUnit#(p_nbits) mmuA_S2
  (
    .in0     (elm0_S2),
    .in1     (elm2_S2),
    .out_min (mmuA_out_min_S2),
    .out_max (mmuA_out_max_S2)
  );

  logic [p_nbits-1:0] mmuB_out_min_S2;
  logic [p_nbits-1:0] mmuB_out_max_S2;

  ex_sorter_MinMaxUnit#(p_nbits) mmuB_S2
  (
    .in0     (elm1_S2),
    .in1     (elm3_S2),
    .out_min (mmuB_out_min_S2),
    .out_max (mmuB_out_max_S2)
  );

  //----------------------------------------------------------------------
  // Stage S2->S3 pipeline registers
  //----------------------------------------------------------------------

  logic val_S3;

  vc_ResetReg#(1) val_S2S3
  (
   .clk   (clk),
   .reset (reset),
   .d     (val_S2),
   .q     (val_S3)
  );

  logic [p_nbits-1:0] elm0_S3;
  logic [p_nbits-1:0] elm1_S3;
  logic [p_nbits-1:0] elm2_S3;
  logic [p_nbits-1:0] elm3_S3;

  vc_Reg#(p_nbits) elm0_S2S3( clk, elm0_S3, mmuA_out_min_S2 );
  vc_Reg#(p_nbits) elm1_S2S3( clk, elm1_S3, mmuA_out_max_S2 );
  vc_Reg#(p_nbits) elm2_S2S3( clk, elm2_S3, mmuB_out_min_S2 );
  vc_Reg#(p_nbits) elm3_S2S3( clk, elm3_S3, mmuB_out_max_S2 );

  //----------------------------------------------------------------------
  // Stage S3 combinational logic
  //----------------------------------------------------------------------

  logic [p_nbits-1:0] mmuA_out_min_S3;
  logic [p_nbits-1:0] mmuA_out_max_S3;

  ex_sorter_MinMaxUnit#(p_nbits) mmuA_S3
  (
    .in0     (elm1_S3),
    .in1     (elm2_S3),
    .out_min (mmuA_out_min_S3),
    .out_max (mmuA_out_max_S3)
  );

  // Assign output ports

  assign out_val = val_S3;
  assign out0    = elm0_S3;
  assign out1    = mmuA_out_min_S3;
  assign out2    = mmuA_out_max_S3;
  assign out3    = elm3_S3;

  //----------------------------------------------------------------------
  // Assertions
  //----------------------------------------------------------------------

  always @( posedge clk ) begin
    if ( !reset ) begin
      `VC_ASSERT_NOT_X( in_val );
      `VC_ASSERT_NOT_X( val_S1 );
      `VC_ASSERT_NOT_X( val_S2 );
      `VC_ASSERT_NOT_X( val_S3 );
      `VC_ASSERT_NOT_X( out_val );
    end
  end

  //----------------------------------------------------------------------
  // Line Tracing
  //----------------------------------------------------------------------

  logic [(`VC_TRACE_NBITS_TO_NCHARS(p_nbits)*4+5)*8-1:0] str;

  `VC_TRACE_BEGIN
  begin

    // Inputs

    $sformat( str, "{%x,%x,%x,%x}", in0, in1, in2, in3 );
    vc_trace.append_val_str( trace_str, in_val, str  );
    vc_trace.append_str( trace_str, "|" );

    // Pipeline stage S1

    $sformat( str, "{%x,%x,%x,%x}", elm0_S1, elm1_S1, elm2_S1, elm3_S1 );
    vc_trace.append_val_str( trace_str, val_S1, str  );
    vc_trace.append_str( trace_str, "|" );

    // Pipeline stage S2

    $sformat( str, "{%x,%x,%x,%x}", elm0_S2, elm1_S2, elm2_S2, elm3_S2 );
    vc_trace.append_val_str( trace_str, val_S2, str  );
    vc_trace.append_str( trace_str, "|" );

    // Pipeline stage S3

    $sformat( str, "{%x,%x,%x,%x}", elm0_S3, elm1_S3, elm2_S3, elm3_S3 );
    vc_trace.append_val_str( trace_str, val_S3, str  );
    vc_trace.append_str( trace_str, "|" );

    // Outputs

    $sformat( str, "{%x,%x,%x,%x}", out0, out1, out2, out3 );
    vc_trace.append_val_str( trace_str, out_val, str  );

  end
  `VC_TRACE_END

endmodule

`endif /* EX_SORTER_SORTER_STRUCT_V */
