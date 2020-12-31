`include "defines.v"

module MiniMIPS32_SYS(
    input 	wire 		            sys_clk_100M,
   	input 	wire 		            sys_rst_n,
    //input   wire [`CP0_INT_BUS]     int,

    output  wire    [15:0]          led,
    output  wire    [2:0]           led_rgb0,
    output  wire    [2:0]           led_rgb1,
    output  wire    [7:0]           num_csn,
    output  wire    [6:0]           num_a_g
   	);


    //时钟模块输出信号
   	wire			            cpu_clk_50M;
   	
    //指令存储器 输出信号
    wire [`INST_BUS     ] 		inst_dout;
    //数据存储器 输出信号
    wire [`INST_BUS     ] 		data_dout;

    //MiniMIPS32处理器 输出信号
    wire                  		ice;
    wire [`INST_ADDR_BUS]	    iaddr;
    wire                  		dce;
    wire [`INST_ADDR_BUS] 	    daddr;
   	wire [`BSEL_BUS     ] 		we;
   	wire [`INST_BUS     ] 		din;

    //dev_if0 输出信号
    wire [`INST_BUS      ]      inst;
    wire [`INST_BUS      ]      dout;
    wire                        inst_ce;
    wire [`INST_ADDR_BUS]       inst_addr;
    wire                        data_ce;
    wire [`BSEL_BUS      ]      data_we;
    wire [`INST_ADDR_BUS]       data_addr;
    wire [`INST_BUS      ]      data_din;
    wire                        io_ce;
    //wire [`BSEL_BUS      ]      io_we;
    wire                        io_we;
    wire [`INST_ADDR_BUS]       io_addr;
    wire [`INST_BUS      ]      io_din;


    //io_dec0 输出信号
    wire [`INST_BUS     ] 		io_dout;



   	clk_wiz_0 clocking (
       	      .clk_out1(cpu_clk_50M),     
       	      .clk_in1(sys_clk_100M)
   	); 
   
   	inst_rom inst_rom0 (
     	      .clka(cpu_clk_50M),    
     	      .ena(inst_ce),      
     	      .addra(inst_addr[16:2]),//32K个存储单元，地址宽15 bits
     	      .douta(inst_dout)
   	);

   	data_ram data_ram0 (
       	      .clka(cpu_clk_50M),
       	      .ena(data_ce), 
       	      .wea(data_we),      
       	      .addra(data_addr[12:2]), 
       	      .dina(data_din),    
       	      .douta(data_dout) 
   	);


   	MiniMIPS32 minimips32 (
              .inst(inst),
              .dm(dout),
              //.int(int),
       	      .cpu_clk_50M(cpu_clk_50M),
       	      .cpu_rst_n(sys_rst_n),
            
              .ice(ice),
       	      .iaddr(iaddr),
       	      .dce(dce),
       	      .daddr(daddr),
       	      .we(we),
       	      .din(din)
   	);


    dev_if dev_if0 (
              .sys_rst_n(sys_rst_n),
              .ice(ice),
              .iaddr(iaddr),
              .dce(dce),
              .daddr(daddr),
              .we(we),
              .din(din),
              .inst_dout(inst_dout),
              .data_dout(data_dout),
              .io_dout(io_dout),


              .inst(inst),
              .dout(dout),
              .inst_ce(inst_ce),
              .inst_addr(inst_addr),
              .data_ce(data_ce),
              .data_we(data_we),
              .data_addr(data_addr),
              .data_din(data_din),
              .io_ce(io_ce),
              .io_we(io_we),
              .io_addr(io_addr),
              .io_din(io_din)     
    );

    io_dec io_dec0(
              .ce(io_ce),
              .we(io_we),
              .addr(io_addr),
              .din(io_din),
              .clk(cpu_clk_50M),
              .rst_n(sys_rst_n),

              .led(led),
              .led_rgb0(led_rgb0),
              .led_rgb1(led_rgb1),
              .num_csn(num_csn),
              .num_a_g(num_a_g),
              .dout(io_dout)
    );


endmodule

