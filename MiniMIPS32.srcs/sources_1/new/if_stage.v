`include "defines.v"

module if_stage (
    input 	wire 					cpu_clk_50M,
    input 	wire 					cpu_rst_n,
    input   wire [`JTSEL_BUS]       jtsel,
    input 	wire [`INST_ADDR_BUS]	jump_addr_1,
    input 	wire [`INST_ADDR_BUS]	jump_addr_2,
    input 	wire [`INST_ADDR_BUS]	jump_addr_3,
    input   wire [`STALL_BUS]       stall,
    input   wire                    flush,
    input 	wire [`INST_ADDR_BUS]	cp0_excaddr,

    output  wire                    ice,
    output 	reg  [`INST_ADDR_BUS] 	pc,
    output 	wire [`INST_ADDR_BUS]	iaddr,
    output 	wire [`INST_ADDR_BUS]	pc_plus_4,
    output  wire [`EXC_CODE_BUS]    if_exccode_o//��������׶ε�ָ����쳣����

    );
    
    assign pc_plus_4=(cpu_rst_n==`RST_ENABLE) ? `PC_INIT : pc+4;

    wire [`INST_ADDR_BUS] pc_next;
    assign pc_next = (jtsel==2'b00)?pc_plus_4:
                     (jtsel==2'b01)?jump_addr_1:            //j,jal
                     (jtsel==2'b10)?jump_addr_3:            //jr
                     (jtsel==2'b11)?jump_addr_2:`PC_INIT;   //beq,bne
                     

    reg ce;
    assign ice = (stall[1]==`TRUE_V||flush)? 0: ce;
    // ���ݴ������Ƿ�λȷ��ice�ź�
    always @(posedge cpu_clk_50M) begin
		if (cpu_rst_n == `RST_ENABLE) begin
			ce <= `CHIP_DISABLE;		      
		end else begin
			ce <= `CHIP_ENABLE; 		      
		end
	end
    


    // �ж�ice�ź��Ƿ���Ч
    always @(posedge cpu_clk_50M) begin
        if (ce == `CHIP_DISABLE)
            pc <= `PC_INIT;
        else begin
            if(flush==`TRUE_V) 
                pc<=cp0_excaddr;
            else if(stall[0]==`NOSTOP) begin
                pc <= pc_next;                 	
            end
        end                   

    end
    
    assign iaddr = (ice == `CHIP_DISABLE) ? `PC_INIT : pc;


    //ȡָ��ַ�����쳣
    assign if_exccode_o = (pc[1:0]!=2'b00) ? `EXC_ADEL : `EXC_NONE;


endmodule