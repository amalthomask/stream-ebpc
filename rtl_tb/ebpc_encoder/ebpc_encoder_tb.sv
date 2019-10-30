module ebpc_encoder_tb;
  import hs_drv_pkg::*;
  
  localparam int unsigned DATA_W = 8;
  localparam int unsigned MIN_IN_WAIT_CYCLES = 0;
  localparam int unsigned MAX_IN_WAIT_CYCLES = 3;
  localparam int unsigned MIN_OUT_WAIT_CYCLES = 0;
  localparam int unsigned MAX_OUT_WAIT_CYCLES = 3;

  localparam string       INPUT_STIM_FILE = "../../simvectors/encoder/vgg16/vgg16_f0.01_bs1_nb4_ww8_input.stim";
  localparam string       BPC_EXPVAL_FILE = "../../simvectors/encoder/vgg16/vgg16_f0.01_bs1_nb4_ww8_bpc.expresp";
  localparam string       ZNZ_EXPVAL_FILE = "../../simvectors/encoder/vgg16/vgg16_f0.01_bs1_nb4_ww8_znz.expresp";

  localparam time         CLK_PERIOD = 2.5ns;
  localparam time         RST_TIME = 10.27*CLK_PERIOD;
  localparam time         TA = 0.2*CLK_PERIOD;
  localparam time         TT = 0.8*CLK_PERIOD;

  logic                   clk;
  logic                   rst_n;


  HandshakeIf_t #(.DATA_W(DATA_W))           in_if(.clk_i(clk));
  HandshakeIf_t #(.DATA_W(DATA_W))           bpc_if(.clk_i(clk));
  HandshakeIf_t #(.DATA_W(DATA_W))           znz_if(.clk_i(clk));

  HandshakeDrv #(
                 .DATA_W(DATA_W),
                 .TA(TA),
                 .TT(TT),
                 .MIN_WAIT(MIN_IN_WAIT_CYCLES),
                 .MAX_WAIT(MAX_IN_WAIT_CYCLES),
                 .HAS_LAST(1'b1),
                 .NAME("Data Input")
                 )
  in_drv;

  HandshakeDrv #(
                 .DATA_W(DATA_W),
                 .TA(TA),
                 .TT(TT),
                 .MIN_WAIT(MIN_IN_WAIT_CYCLES),
                 .MAX_WAIT(MAX_IN_WAIT_CYCLES),
                 .HAS_LAST(1'b0),
                 .NAME("BPC Output")
                 )
  bpc_drv;

  HandshakeDrv #(
                 .DATA_W(DATA_W),
                 .TA(TA),
                 .TT(TT),
                 .MIN_WAIT(MIN_IN_WAIT_CYCLES),
                 .MAX_WAIT(MAX_IN_WAIT_CYCLES),
                 .HAS_LAST(1'b0),
                 .NAME("ZNZ Output")
                 )
  znz_drv;

 initial begin
   bpc_if.last = 1'b0;
   znz_if.last = 1'b0;
   in_drv      = new(in_if);
   bpc_drv     = new(bpc_if);
   znz_drv     = new(znz_if);
   #(2*RST_TIME);
   fork
     in_drv.feed_inputs(INPUT_STIM_FILE);
     bpc_drv.read_outputs(BPC_EXPVAL_FILE);
     znz_drv.read_outputs(ZNZ_EXPVAL_FILE);
   join
   $stop;
 end



  rst_clk_drv #(
                .CLK_PERIOD(CLK_PERIOD),
                .RST_TIME(RST_TIME)
                )
  clk_drv
    (
     .clk_o(clk),
     .rst_no(rst_n)
     );                         

  ebpc_encoder dut_i (
                      .clk_i(clk),
                      .rst_ni(rst_n),
                      .data_i(in_if.data),
                      .last_i(in_if.last),
                      .vld_i(in_if.vld),
                      .rdy_o(in_if.rdy),
                      .znz_data_o(znz_if.data),
                      .znz_vld_o(znz_if.vld),
                      .znz_rdy_i(znz_if.rdy),
                      .bpc_data_o(bpc_if.data),
                      .bpc_vld_o(bpc_if.vld),
                      .bpc_rdy_i(bpc_if.rdy)
                      );

  endmodule