`include "defines.v"

module wb_stage(
    input  	wire                  	 	cpu_rst_n,
   	// �ӷô�׶λ�õ���Ϣ
   	input  	wire                   		wb_mreg_i,
   	input  	wire [`BSEL_BUS      ] 	    wb_dre_i,
    input  	wire [`REG_ADDR_BUS  ] 	    wb_wa_i,
    input  	wire                   		wb_wreg_i,
    input  	wire [`REG_BUS       ] 	    wb_dreg_i,
   	input  	wire                   		wb_whilo_i,
    input  	wire [`DOUBLE_REG_BUS] 	    wb_hilo_i,
    input  	wire [`ALUOP_BUS     ] 	    wb_aluop_i,
   	// �����ݴ洢������������
   	input  	wire [`WORD_BUS      ] 	    dm,
    //�쳣�������
    input  	wire                   		cp0_we_i,
    input  	wire [`REG_ADDR_BUS  ] 	    cp0_waddr_i,
    input  	wire [`REG_BUS       ] 	    cp0_wdata_i,

   	// д��Ŀ�ļĴ���������
   	output 	wire [`REG_ADDR_BUS  ] 	    wb_wa_o,
    output 	wire                   		wb_wreg_o,
   	output 	wire [`WORD_BUS      ] 	    wb_wd_o,
   	output 	wire                   		wb_whilo_o,
    output 	wire [`DOUBLE_REG_BUS] 	    wb_hilo_o,
    output  wire [`ALUOP_BUS     ] 	    wb_aluop_o,
    //����ǰ��
    output  wire                        wb2exe_whilo,
    output  wire [`DOUBLE_REG_BUS]      wb2exe_hilo,
    //����ǰ�ƣ��쳣����
    output  wire                        wb2mem_cp0_we,
    output  wire [`REG_ADDR_BUS  ]      wb2mem_cp0_wa,
    output  wire [`REG_BUS       ]      wb2mem_cp0_wd,
    output  wire                        wb2exe_cp0_we,
    output  wire [`REG_ADDR_BUS  ]      wb2exe_cp0_wa,
    output  wire [`REG_BUS       ]      wb2exe_cp0_wd,
    //�쳣�������
    output  wire                   		cp0_we_o,
    output  wire [`REG_ADDR_BUS  ] 	    cp0_waddr_o,
    output  wire [`REG_BUS       ] 	    cp0_wdata_o

   	);
    // ����ͨ�üĴ����Ѻ�HILO�Ĵ������ź�
   	assign wb_wa_o      	=    (cpu_rst_n == `RST_ENABLE) ? 5'b0 : wb_wa_i;
   	assign wb_wreg_o	    =    (cpu_rst_n == `RST_ENABLE) ? 1'b0 : wb_wreg_i;
   	assign wb_whilo_o   	=    (cpu_rst_n == `RST_ENABLE) ? 1'b0 : wb_whilo_i;
   	assign wb_hilo_o    	=    (cpu_rst_n == `RST_ENABLE) ? 64'b0: wb_hilo_i;
    assign wb_aluop_o    	=    (cpu_rst_n == `RST_ENABLE) ? 8'b0 : wb_aluop_i;
    //����ǰ��
    assign wb2exe_whilo     =    (cpu_rst_n == `RST_ENABLE) ? 1'b0 : wb_whilo_i;
    assign wb2exe_hilo      =    (cpu_rst_n == `RST_ENABLE) ? 1'b0 : wb_hilo_i;
    //����ǰ��(�쳣����)
    assign wb2mem_cp0_we    =    (cpu_rst_n == `RST_ENABLE) ? 1'b0 : cp0_we_i;
    assign wb2mem_cp0_wa    =    (cpu_rst_n == `RST_ENABLE) ? 5'b0 : cp0_waddr_i;
    assign wb2mem_cp0_wd    =    (cpu_rst_n == `RST_ENABLE) ? `ZERO_WORD: cp0_wdata_i;
    assign wb2exe_cp0_we    =    (cpu_rst_n == `RST_ENABLE) ? 1'b0 : cp0_we_i;
    assign wb2exe_cp0_wa    =    (cpu_rst_n == `RST_ENABLE) ? 5'b0 : cp0_waddr_i;
    assign wb2exe_cp0_wd    =    (cpu_rst_n == `RST_ENABLE) ? `ZERO_WORD: cp0_wdata_i;
    //ֱ������cp0������
    assign cp0_we_o     	=    (cpu_rst_n == `RST_ENABLE) ? 1'b0 : cp0_we_i;
    assign cp0_waddr_o    	=    (cpu_rst_n == `RST_ENABLE) ? 5'b0 : cp0_waddr_i;
    assign cp0_wdata_o    	=    (cpu_rst_n == `RST_ENABLE) ? `ZERO_WORD: cp0_wdata_i;

    wire unsign =  (wb_aluop_i == `MINIMIPS32_LBU)|(wb_aluop_i == `MINIMIPS32_LHU);

    // ���ݶ��ֽ�ʹ���źţ������ݴ洢��������������ѡ���Ӧ���ֽ�
   	wire [`WORD_BUS] data  = (cpu_rst_n == `RST_ENABLE) ? `ZERO_WORD : 
                    (wb_dre_i == 4'b1111     ) ? {dm[7:0], dm[15:8], dm[23:16], dm[31:24]} :
                    ((wb_dre_i == 4'b1100)&unsign ) ? {16'b0, dm[23:16], dm[31:24]} :
                    ((wb_dre_i == 4'b0011)&unsign ) ? {16'b0, dm[7:0], dm[15:8]} :
                    ((wb_dre_i == 4'b1000)&unsign ) ? {24'b0, dm[31:24]} :
                    ((wb_dre_i == 4'b0100)&unsign ) ? {24'b0, dm[23:16]} :
                    ((wb_dre_i == 4'b0010)&unsign ) ? {24'b0, dm[15:8 ]} :
                    ((wb_dre_i == 4'b0001)&unsign ) ? {24'b0, dm[7 :0 ]} :
                    (wb_dre_i == 4'b1100     ) ? {{16{dm[23]}},dm[23:16], dm[31:24]} :
                    (wb_dre_i == 4'b0011     ) ? {{16{dm[7]}},dm[7:0], dm[15:8]} :
                    (wb_dre_i == 4'b1000     ) ? {{24{dm[31]}}, dm[31:24]} :
                    (wb_dre_i == 4'b0100     ) ? {{24{dm[23]}}, dm[23:16]} :
                    (wb_dre_i == 4'b0010     ) ? {{24{dm[15]}}, dm[15:8 ]} :
                    (wb_dre_i == 4'b0001     ) ? {{24{dm[7 ]}}, dm[7 :0 ]} : `ZERO_WORD;
                    
                    
    // ���ݴ洢�����Ĵ���ʹ���ź�mreg��ѡ�����մ�д��ͨ�üĴ���������
   	assign wb_wd_o = (cpu_rst_n == `RST_ENABLE ) ? `ZERO_WORD : 
                    (wb_mreg_i == `MREG_ENABLE) ? data : wb_dreg_i;

endmodule
