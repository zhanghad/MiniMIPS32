`include "defines.v"

module exe_stage (
    input  wire 					cpu_clk_50M,//���ڳ�������
    input  wire 					cpu_rst_n,
    // ����׶δ������Ϣ
    input   wire [`ALUTYPE_BUS	] 	exe_alutype_i,
    input   wire [`ALUOP_BUS	] 	exe_aluop_i,
    input   wire [`REG_BUS 		] 	exe_src1_i,
    input   wire [`REG_BUS 		] 	exe_src2_i,
    input   wire [`REG_ADDR_BUS ] 	exe_wa_i,
    input   wire 					exe_wreg_i,
    input	wire	                exe_mreg_i,
    input	wire [`REG_BUS	]	    exe_din_i,
    input	wire	                exe_whilo_i,
    //��HILO�Ĵ�����õ�����
    input	wire [`REG_BUS	]	    hi_i,
    input	wire [`REG_BUS	]	    lo_i,
    //�ӷô�׶λ�ȡ��hi��lo(add)
    input   wire                    mem2exe_whilo,
    input   wire [`DOUBLE_REG_BUS]  mem2exe_hilo,
    //��д�ؽ׶λ�ȡ��hi��lo(add)
    input   wire                    wb2exe_whilo,
    input   wire [`DOUBLE_REG_BUS]  wb2exe_hilo,
    input   wire [`INST_ADDR_BUS ]  ret_addr,
    //�쳣���
    input   wire [`REG_ADDR_BUS ] 	cp0_addr_i,
    input   wire [`REG_BUS ] 	    cp0_data_i,
    input   wire                    mem2exe_cp0_we,
    input   wire [`REG_ADDR_BUS ] 	mem2exe_cp0_wa,
    input   wire [`REG_BUS ] 	    mem2exe_cp0_wd,
    input   wire                    wb2exe_cp0_we,
    input   wire [`REG_ADDR_BUS ] 	wb2exe_cp0_wa,
    input   wire [`REG_BUS ] 	    wb2exe_cp0_wd,
    input   wire [`INST_ADDR_BUS ]  exe_pc_i,
    input   wire                    exe_in_delay_i,
    input   wire [`EXC_CODE_BUS ]   exe_exccode_i,

    // ִ�н׶��������Ϣ
    output  wire [`ALUOP_BUS] 	    exe_aluop_o,
    output  wire [`REG_ADDR_BUS] 	exe_wa_o,
    output  wire 					exe_wreg_o,
    output  wire [`REG_BUS]  	    exe_wd_o,
    output  wire	                exe_mreg_o,
    output	wire [`REG_BUS]	        exe_din_o,
    output	wire	                exe_whilo_o,
    output	wire [`DOUBLE_REG_BUS]	exe_hilo_o,
    //����ǰ�Ƶ�����
    output wire                     exe2id_wreg,
    output wire [`REG_ADDR_BUS ]    exe2id_wa,
    output wire [`REG_BUS      ]    exe2id_wd,
    output wire                     exe2id_mreg,    
    //ִ�н׶η�������ͣ����
    output	wire	                stallreq_exe,
    //�쳣���
    output	wire	                cp0_re_o,
    output  wire [`REG_ADDR_BUS ] 	cp0_raddr_o,
    output	wire	                cp0_we_o,
    output  wire [`REG_ADDR_BUS ] 	cp0_waddr_o,
    output	wire [`REG_BUS]	        cp0_wdata_o,
    output  wire [`INST_ADDR_BUS ]  exe_pc_o,
    output	wire	                exe_in_delay_o,
    output  wire [`EXC_CODE_BUS ]   exe_exccode_o
    );

    // ֱ�Ӵ�����һ�׶ε���Ϣ
    assign exe_aluop_o  =   (cpu_rst_n  ==  `RST_ENABLE) ? 8'b0 : exe_aluop_i;
    assign exe_mreg_o	=	(cpu_rst_n	==	`RST_ENABLE) ? 1'b0	: exe_mreg_i;
    assign exe_din_o	=	(cpu_rst_n	==	`RST_ENABLE) ? 32'b0: exe_din_i;
    assign exe_whilo_o	=	(cpu_rst_n	==	`RST_ENABLE) ? 1'b0 : exe_whilo_i;
    assign exe_pc_o     =   (cpu_rst_n	==	`RST_ENABLE) ? `PC_INIT : exe_pc_i;
    assign exe_in_delay_o=   (cpu_rst_n	==	`RST_ENABLE) ? 1'b0 : exe_in_delay_i;
    //����ǰ��
    assign exe2id_wreg = (cpu_rst_n == `RST_ENABLE) ? `WRITE_DISABLE : exe_wreg_i;
    assign exe2id_wa   = (cpu_rst_n == `RST_ENABLE) ? 5'b0 : exe_wa_i;
    assign exe2id_mreg = (cpu_rst_n == `RST_ENABLE) ? 1'b0 : exe_mreg_i;
    
    wire    [`REG_BUS ]         logicres;   //�����߼�������
    wire	[`REG_BUS ]	        shiftres;   //������λ������
    wire	[`REG_BUS ]	        moveres;    //�����ƶ��������
    wire	[`REG_BUS ]	        hi_t;	    //����hi�Ĵ���������ֵ
    wire	[`REG_BUS ]	        lo_t;	    //����lo�Ĵ���������ֵ
    wire	[`REG_BUS ]	        arithres;	//������������Ľ��
    wire	[`REG_BUS ]	        memres;	    //����ô������ַ
    wire	[`REG_BUS ]	        cp0_t;      //����cp0�Ĵ���������ֵ
    
    wire	[`DOUBLE_REG_BUS]	mulres;     //����˷������Ľ��(add)
    wire	[`DOUBLE_REG_BUS]	mulures;
    reg     [`DOUBLE_REG_BUS]   divres;      // ������������Ľ��

/*********************** ����ָ����� begin*******************************/
    
    
    // ��������
    wire                      signed_div_i;
    wire [`REG_BUS          ] div_opdata1;
    wire [`REG_BUS          ] div_opdata2;
    wire                      div_start;
    reg                       div_ready;

    assign stallreq_exe = (cpu_rst_n == `RST_ENABLE) ? `NOSTOP : 
                          (((exe_aluop_i == `MINIMIPS32_DIV) || (exe_aluop_i == `MINIMIPS32_DIVU))  && (div_ready == `DIV_NOT_READY))  ? `STOP : `NOSTOP;

    assign div_opdata1  = (cpu_rst_n == `RST_ENABLE) ? `ZERO_WORD : 
                          ((exe_aluop_i == `MINIMIPS32_DIV) || (exe_aluop_i == `MINIMIPS32_DIVU)) ? exe_src1_i : `ZERO_WORD;

    assign div_opdata2  = (cpu_rst_n == `RST_ENABLE) ? `ZERO_WORD : 
                          ((exe_aluop_i == `MINIMIPS32_DIV) || (exe_aluop_i == `MINIMIPS32_DIVU)) ? exe_src2_i : `ZERO_WORD;                                    
    assign div_start    = (cpu_rst_n == `RST_ENABLE) ? `DIV_STOP : 
                          (((exe_aluop_i == `MINIMIPS32_DIV) || (exe_aluop_i == `MINIMIPS32_DIVU)) && (div_ready == `DIV_NOT_READY))  ? `DIV_START : `DIV_STOP; 

    assign signed_div_i = (cpu_rst_n == `RST_ENABLE) ? 1'b0 : 
                          (exe_aluop_i == `MINIMIPS32_DIV ) ? 1'b1 : 1'b0; 

    wire   [34:0]                     div_temp;
    wire   [34:0]                     div_temp0;
    wire   [34:0]                     div_temp1;
    wire   [34:0]                     div_temp2;
    wire   [34:0]                     div_temp3;
    wire   [ 1:0]                     mul_cnt;

    //��¼���̷������˼��֣�������16ʱ����ʾ���̷�����
    reg    [ 5:0]                     cnt;

    reg    [65:0]                     dividend;
    reg    [ 1:0]                     state;
    reg    [33:0]                     divisor;
    reg    [31:0]                     temp_op1;
    reg    [31:0]                     temp_op2;
    
    wire   [33:0]                     divisor_temp;
    wire   [33:0]                     divisor2;
    wire   [33:0]                     divisor3;
    
    assign divisor_temp = temp_op2;                   
    assign divisor2     = divisor_temp << 1;       //����������������˷���
    assign divisor3     = divisor2 + divisor;      //������������
    
    //dividend�ĵ�32λ������Ǳ��������м�������k�ε���������ʱ��dividend[k:0]  
    //����ľ��ǵ�ǰ�õ����м�����dividend[32:k+1]����ľ��Ǳ������л�û�в�������  
    //�����ݣ�dividend��32λ��ÿ�ε���ʱ�ı�����
    assign div_temp0 = {1'b000,dividend[63:32]} - {1'b000,`ZERO_WORD};  //���������뱻������ 0 �������
    assign div_temp1 = {1'b000,dividend[63:32]} - {1'b0,divisor};       //���������뱻������ 1 �������
    assign div_temp2 = {1'b000,dividend[63:32]} - {1'b0,divisor2};      //���������뱻������ 2 �������
    assign div_temp3 = {1'b000,dividend[63:32]} - {1'b0,divisor3};      //���������뱻������ 3 �������
    
    assign div_temp  = (div_temp3[34] == 1'b0 ) ? div_temp3 : 
                       (div_temp2[34] == 1'b0 ) ? div_temp2 : div_temp1;
                      
    assign mul_cnt   = (div_temp3[34] == 1'b0 ) ? 2'b11 : 
                       (div_temp2[34] == 1'b0 ) ? 2'b10 : 2'b01;
    
    always @ (posedge cpu_clk_50M) begin
        if (cpu_rst_n == `RST_ENABLE) begin
            state         <= `DIV_FREE;
            div_ready     <= `DIV_NOT_READY;
            divres       <= {`ZERO_WORD,`ZERO_WORD};
        end else begin
        case (state)
    //*******************   DIV_FREE״̬    ***********************  
    //�����������  
    //��1����ʼ�������㣬�������Ϊ0����ô����DivByZero״̬  
    //��2����ʼ�������㣬�ҳ�����Ϊ0����ô����DivOn״̬����ʼ��cntΪ0����  
    //     �����з��ų������ұ��������߳���Ϊ������ô�Ա��������߳����������Ĳ��롣  
    //     �������浽divisor�У��������������λ���浽dividend�ĵ�32λ��  
    //     ׼�����е�һ�ε���  
    //��3��û�н��г������㣬����div_readyΪ0��divresΪ0  
    //*********************************************************** 
              `DIV_FREE: begin                       //DIV_FREE
                  if(div_start == `DIV_START) begin
                      if(div_opdata2 == `ZERO_WORD) begin        // ����Ϊ0
                          state <= `DIV_BY_ZERO;
                      end else begin                            // ����Ϊ0
                          state <= `DIV_ON;
                          cnt   <= 6'b000000;
                        
                        if(exe_aluop_i == `MINIMIPS32_DIV) begin
                            if(div_opdata1[31] == 1'b1 ) begin
                                temp_op1 = ~div_opdata1 + 1;    // ȡ�����Ĳ���
                            end else begin
                                temp_op1 = div_opdata1;
                            end
                            if(div_opdata2[31] == 1'b1 ) begin
                                temp_op2 = ~div_opdata2 + 1;    // ȡ�����Ĳ���
                            end else begin
                                temp_op2 = div_opdata2;
                            end
                        end

                        else begin//(exe_aluop_i == `MINIMIPS32_DIVU)
                            temp_op1 = div_opdata1;
                            temp_op2 = div_opdata2;
                        end
                        
                        dividend        <= {`ZERO_WORD,`ZERO_WORD};
                        dividend[31:0]  <= temp_op1;
                        divisor         <= temp_op2;
                    end
                end else begin     // û�п�ʼ��������
                        div_ready  <= `DIV_NOT_READY;
                        divres <= {`ZERO_WORD,`ZERO_WORD};
                end              
              end

    //*******************   DivByZero״̬    ********************  
    //�������DivByZero״̬����ôֱ�ӽ���DivEnd״̬�������������ҽ��Ϊ0  
    //*********************************************************** 
              `DIV_BY_ZERO: begin               //DivByZero
                 dividend <= {`ZERO_WORD,`ZERO_WORD};
                  state    <= `DIV_END;                 
              end

    //*******************   DivOn״̬      ***********************  
    //��1�����cnt��Ϊ16����ô��ʾ���̷���û�н�������ʱ  
    //    ����������div_tempΪ������ô�˴ε��������0����  
    //    ���������div_tempΪ������ô�˴ε��������1��dividend  
    //    �����λ����ÿ�εĵ��������ͬʱ����DivOn״̬��cnt��1��  
    //��2�����cntΪ16����ô��ʾ���̷�������������з���  
    //    �������ұ�����������һ��һ������ô�����̷��Ľ���������Ĳ��룬�õ����յ�  
    //    ������˴����̡�������Ҫ�������Ĳ��롣�̱�����dividend�ĵ�32λ������  
    //    ������dividend�ĸ�32λ��ͬʱ����DivEnd״̬��  
    //***********************************************************
              `DIV_ON: begin               //DivOn
                  if(cnt != 6'b100010) begin    //cnt��Ϊ16����ʾ���̷���û�н���
                    if(div_temp[34] == 1'b1) begin
                        //���div_temp[32]Ϊ1����ʾ��minuend-n�����С��0��  
                          //��dividend������һλ�������ͽ���������û�в��������  
                          //���λ���뵽��һ�ε����ı������У�ͬʱ��0׷�ӵ��м���
                        dividend <= {dividend[63:0] , 2'b00};
                    end else begin
                        //���div_temp[32]Ϊ0����ʾ��minuend-n��������ڵ�  
                          //��0���������Ľ���뱻������û�в���������λ���뵽��  
                          //һ�ε����ı������У�ͬʱ��1׷�ӵ��м��� 
                        dividend <= {div_temp[31:0] , dividend[31:0] , mul_cnt};
                    end
                    cnt <= cnt + 2;
                end else begin    //���̷�����
                
                if(exe_aluop_i == `MINIMIPS32_DIV) begin
                    if((div_opdata1[31] ^ div_opdata2[31]) == 1'b1) begin
                        dividend[31:0] <= (~dividend[31:0] + 1);    // ȡ�����Ĳ���
                    end
                    if((div_opdata1[31] ^ dividend[65]) == 1'b1) begin              
                        dividend[65:34] <= (~dividend[65:34] + 1);    // ȡ�����Ĳ���
                    end
                end//`MINIMIPS32_DIV�򲻸ı�dividend
                
                state <= `DIV_END;        //����DivEnd״̬ 
                cnt   <= 6'b000000;       //cnt����         
               end
              end

     //*******************   DivEnd״̬    ***********************  
     //�������������divres�Ŀ����64λ�����32λ�洢��������32λ�洢�̣�  
     //��������ź�div_readyΪDivResultReady����ʾ����������Ȼ��ȴ�EXģ��  
     //����DivStop�źţ���EXģ������DivStop�ź�ʱ��DIVģ��ص�DIV_FREE״̬  
     //********************************************************** 
              `DIV_END: begin               //DivEnd
               divres <= {dividend[65:34], dividend[31:0]};  
               div_ready  <= `DIV_READY;
               if(div_start == `DIV_STOP) begin
                      state         <= `DIV_FREE;
                    div_ready     <= `DIV_NOT_READY;
                    divres      <= {`ZERO_WORD,`ZERO_WORD};
               end
              end
          endcase
        end
    end
/*********************** ����ָ����� end*********************************/ 


    //�쳣���
    assign cp0_we_o = (cpu_rst_n == `RST_ENABLE) ? 1'b0:
        (exe_aluop_i==`MINIMIPS32_MTC0)?1'b1:1'b0;
    assign cp0_wdata_o = (cpu_rst_n == `RST_ENABLE) ? `ZERO_WORD :
        (exe_aluop_i==`MINIMIPS32_MTC0)?exe_src2_i:`ZERO_WORD;
    assign cp0_waddr_o = (cpu_rst_n == `RST_ENABLE) ? `REG_NOP:cp0_addr_i;
    assign cp0_raddr_o = (cpu_rst_n == `RST_ENABLE) ? `REG_NOP:cp0_addr_i;
    assign cp0_re_o = (cpu_rst_n == `RST_ENABLE) ? 1'b0:
        (exe_aluop_i==`MINIMIPS32_MFC0)?1'b1:1'b0;
    //�ж��Ƿ�������cp0�мĴ�����������أ������cp0�Ĵ���������ֵ
    assign cp0_t = (cp0_re_o!=`READ_ENABLE)?`ZERO_WORD:
        (mem2exe_cp0_we==`WRITE_ENABLE && mem2exe_cp0_wa==cp0_raddr_o)?mem2exe_cp0_wd:
        (wb2exe_cp0_we==`WRITE_ENABLE && wb2exe_cp0_wa==cp0_raddr_o)?wb2exe_cp0_wd:cp0_data_i;

    
    // ����aluop�����߼�����
    assign logicres = (cpu_rst_n == `RST_ENABLE) ? `ZERO_WORD :
        (exe_aluop_i == `MINIMIPS32_AND ) ? (exe_src1_i & exe_src2_i):
        (exe_aluop_i == `MINIMIPS32_ORI ) ? (exe_src1_i | exe_src2_i):
        (exe_aluop_i == `MINIMIPS32_OR  ) ? (exe_src1_i | exe_src2_i):
        (exe_aluop_i == `MINIMIPS32_NOR ) ? ~(exe_src1_i | exe_src2_i):
        (exe_aluop_i == `MINIMIPS32_XOR ) ? (exe_src1_i ^ exe_src2_i):
        (exe_aluop_i == `MINIMIPS32_ANDI) ? (exe_src1_i & exe_src2_i):
        (exe_aluop_i == `MINIMIPS32_XORI) ? (exe_src1_i ^ exe_src2_i):
        (exe_aluop_i == `MINIMIPS32_LUI ) ? exe_src2_i : `ZERO_WORD;
        
    
    //����aluop������λ����
    assign shiftres = (cpu_rst_n == `RST_ENABLE) ? `ZERO_WORD :
        (exe_aluop_i == `MINIMIPS32_SRL ) ? (exe_src2_i >> exe_src1_i):
        (exe_aluop_i == `MINIMIPS32_SRA ) ? $signed(($signed(exe_src2_i)) >>> exe_src1_i):
        (exe_aluop_i == `MINIMIPS32_SLLV) ? (exe_src2_i << exe_src1_i):
        (exe_aluop_i == `MINIMIPS32_SRLV) ? (exe_src2_i >> exe_src1_i):
        (exe_aluop_i == `MINIMIPS32_SRAV) ? $signed(($signed(exe_src2_i)) >>> exe_src1_i):
        (exe_aluop_i == `MINIMIPS32_SLL ) ? (exe_src2_i << exe_src1_i) : `ZERO_WORD;
    
   //����aluop���������ƶ����õ����µ�HILO�Ĵ�����ֵ(MTHI,MTLOָ��)
    assign hi_t =   (cpu_rst_n == `RST_ENABLE) ? `ZERO_WORD :
                    (mem2exe_whilo==`WRITE_ENABLE) ? mem2exe_hilo[63:32]:
                    (wb2exe_whilo==`WRITE_ENABLE) ? wb2exe_hilo[63:32] : hi_i;
    assign lo_t =   (cpu_rst_n == `RST_ENABLE) ? `ZERO_WORD :
                    (mem2exe_whilo==`WRITE_ENABLE) ? mem2exe_hilo[31:0]:
                    (wb2exe_whilo==`WRITE_ENABLE) ? wb2exe_hilo[31:0] : lo_i;

    assign moveres = (cpu_rst_n == `RST_ENABLE) ? `ZERO_WORD :
        (exe_aluop_i == `MINIMIPS32_MFHI) ? hi_t:
        (exe_aluop_i == `MINIMIPS32_MFLO) ? lo_t: 
        (exe_aluop_i == `MINIMIPS32_MFC0) ? cp0_t:`ZERO_WORD;

   //����aluop������������
    assign arithres = (cpu_rst_n == `RST_ENABLE) ? `ZERO_WORD :
        (exe_aluop_i == `MINIMIPS32_ADD  ) ? (exe_src1_i + exe_src2_i):
        (exe_aluop_i == `MINIMIPS32_LB   ) ? (exe_src1_i + exe_src2_i):
        (exe_aluop_i == `MINIMIPS32_LW   ) ? (exe_src1_i + exe_src2_i):
        (exe_aluop_i == `MINIMIPS32_SB   ) ? (exe_src1_i + exe_src2_i):
        (exe_aluop_i == `MINIMIPS32_SW   ) ? (exe_src1_i + exe_src2_i):
        (exe_aluop_i == `MINIMIPS32_SH   ) ? (exe_src1_i + exe_src2_i):
        (exe_aluop_i == `MINIMIPS32_ADDIU) ? (exe_src1_i + exe_src2_i):
        (exe_aluop_i == `MINIMIPS32_SUBU ) ? (exe_src1_i + (~exe_src2_i) + 1):
        (exe_aluop_i == `MINIMIPS32_SLT  ) ? (($signed(exe_src1_i) < $signed(exe_src2_i)) ? 32'b1: 32'b0):
        (exe_aluop_i == `MINIMIPS32_ADDU ) ? (exe_src1_i + exe_src2_i):
        (exe_aluop_i == `MINIMIPS32_SUB  ) ? (exe_src1_i + (~exe_src2_i) + 1):
        (exe_aluop_i == `MINIMIPS32_SLTU ) ? (($unsigned(exe_src1_i) < $unsigned(exe_src2_i)) ? 32'b1 : 32'b0):
        (exe_aluop_i == `MINIMIPS32_ADDI ) ? (exe_src1_i + exe_src2_i):
        (exe_aluop_i == `MINIMIPS32_SLTI ) ? (($signed(exe_src1_i) < $signed(exe_src2_i)) ? 32'b1: 32'b0):
        (exe_aluop_i == `MINIMIPS32_SLTIU) ? ($unsigned(exe_src1_i) < $unsigned(exe_src2_i) ? 32'b1: 32'b0):
        (exe_aluop_i == `MINIMIPS32_LBU  ) ? (exe_src1_i + exe_src2_i):
        (exe_aluop_i == `MINIMIPS32_LH   ) ? (exe_src1_i + exe_src2_i):
        (exe_aluop_i == `MINIMIPS32_LHU  ) ? (exe_src1_i + exe_src2_i):`ZERO_WORD;
   //����aluop���г˳������㣬������������һ�׶�
    assign mulres           = ($signed(exe_src1_i) * $signed(exe_src2_i));
    assign mulures          =(exe_src1_i * exe_src2_i);

    assign exe_hilo_o = (cpu_rst_n == `RST_ENABLE) ? `ZERO_DWORD :
        (exe_aluop_i == `MINIMIPS32_MULTU)? mulures:
        (exe_aluop_i == `MINIMIPS32_MULT) ? mulres :
        (exe_aluop_i == `MINIMIPS32_DIV)  ? divres :
        (exe_aluop_i == `MINIMIPS32_DIVU)  ? divres :
        (exe_aluop_i == `MINIMIPS32_MTHI)  ? {exe_src1_i,exe_src1_i} :
        (exe_aluop_i == `MINIMIPS32_MTLO)  ? {exe_src1_i,exe_src1_i} : `ZERO_DWORD;

    assign exe_wa_o = (cpu_rst_n == `RST_ENABLE ) ? 5'b0 : exe_wa_i;
    assign exe_wreg_o = (cpu_rst_n == `RST_ENABLE ) ? 1'b0 : exe_wreg_i;



    //�ж��Ƿ������������쳣
    // wire [31:0] exe_src2_t =(exe_aluop_i==`MINIMIPS32_SUB)?(~exe_src2_i)+1 : exe_src2_i;
    // wire [31:0] arith_tmp=exe_src1_i+exe_src2_t;
    // wire [31:0] arith_tmp_2=exe_src1_i+exe_src2_i;
    // wire ov = (exe_aluop_i == `MINIMIPS32_SUB) ? ((!exe_src1_i[31] && !exe_src2_t[31] && arith_tmp[31]) || (exe_src1_i[31] && exe_src2_t[31] && !arith_tmp[31]))
    //            : (exe_aluop_i == `MINIMIPS32_ADD || exe_aluop_i == `MINIMIPS32_ADDI) ? 
    //            ((!exe_src1_i[31] && !exe_src2_i[31] && arith_tmp_2[31]) || (exe_src1_i[31] && exe_src2_i[31] && !arith_tmp_2[31])):0;
    
    wire ov = (exe_aluop_i == `MINIMIPS32_SUB) ? 
                   ((exe_src1_i[31] && !exe_src2_i[31] && !arithres[31])||(!exe_src1_i[31] && exe_src2_i[31] && arithres[31])) 
                   :
                   (exe_aluop_i == `MINIMIPS32_ADD || exe_aluop_i == `MINIMIPS32_ADDI) ? 
                       ((exe_src1_i[31] && exe_src2_i[31] && !arithres[31])||(!exe_src1_i[31] && !exe_src2_i[31] && arithres[31])) : 0;

    //����쳣
    assign exe_exccode_o = (cpu_rst_n == `RST_ENABLE ) ? `EXC_NONE:
        //(exe_aluop_i != `EXC_NONE) ? exe_exccode_i:
        ((exe_aluop_i==`MINIMIPS32_ADD|| exe_aluop_i==`MINIMIPS32_ADDI || exe_aluop_i==`MINIMIPS32_SUB)&&(ov==`TRUE_V))?`EXC_OV:exe_exccode_i;
    
    //����alutypeȷ��ִ�н׶����յ�������
    assign exe_wd_o = (cpu_rst_n == `RST_ENABLE ) ? `ZERO_WORD :
        (exe_alutype_i == `LOGIC ) ? logicres :
        (exe_alutype_i == `SHIFT ) ? shiftres :
        (exe_alutype_i == `MOVE  ) ? moveres  :
        (exe_alutype_i == `ARITH ) ? arithres : 
        (exe_alutype_i == `JUMP  ) ? ret_addr : `ZERO_WORD;
    //����ǰ��
    assign exe2id_wd = exe_wd_o;

endmodule