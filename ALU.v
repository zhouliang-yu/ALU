module alu(i_datain, gr1, gr2, zero, negative, overflow, c);

output signed[31:0] c;

/**flag*/
output zero;
output overflow;
output neg;
reg [31:0] lo, hi;

input signed[31:0] i_datain, gr1, gr2;

reg[5:0] opcode, func;
reg[4:0] sa;
reg[31:0] imm;



//reg zf;
//reg nf;
reg[31:0] reg_A, reg_B, reg_C;


parameter gr0 = 32'h0000_0000;
parameter Width = 32;
parameter MSB = Width - 1;
reg [31:0] unsigned_regB, unsigned_regA;

always @(*)
begin

sa = i_datain[10:6];
opcode = i_datain[31:26];
func = i_datain[5:0];
reg_A = gr1;
reg_B = gr2;
imm = {{16{i_datain[15]}} ,i_datain[15:0]};

case(opcode)

6'b000000: begin //R-Type
    case(func)
        6'h20: begin //add
            reg_A = gr1;
            reg_B = gr2;
            reg_C = reg_A + reg_B;
            overflow = ((reg_A[31] == reg_B[31]) && (~reg_C[31] == reg_A[31])?1:0;
            zero = (reg_C)?1:0;
            neg = reg_C[MSB];
        end

        //addu
        6'h21: begin //addu
            reg_A = gr1;
            unsigned_regA = gr1;
            reg_B = gr2;
            unsigned_regB = gr2;
            reg_C = unsigned_regA + unsigned_regB;
            zero = (reg_C)?1:0;
            overflow = 1'b0;
            neg = 1'b0;
        end

        //sub
        6'h22: begin 
            reg_A = gr1;
            reg_B = gr2;
            reg_C = reg_A - reg_B;
            overflow = (reg_A[31] == 0 && reg_B[31] == 0 && reg_C[31] == 0)? 1:0;
            zero = reg_C? 0:1;
            neg = reg_C[MSB];
        end
        
        //subu
        6'h23: begin
            reg_A = gr1;
            unsigned_regA = gr1;
            reg_B = gr2;
            unsigned_regB = gr2;
            reg_C = unsigned_regA + unsigned_regB;
            zero = reg_C? 0:1;
            overflow = 1'b0;
            neg = 1'b0;
        end

        //and
        6'h24: begin
            reg_A = gr1;
            reg_B = gr2;
            reg_C = reg_A & reg_B;
            zero = (reg_C)?0:1;
            overflow = 1'b0;
            neg = reg_C[MSB];
        end

        //or 
        6'h25:begin
            reg_A = gr1;
            reg_B = gr2;
            reg_C = reg_A | reg_B;
            overflow = 1'b0;
            neg = reg_C[MSB];
            zero = reg_C?0:1;
        end

        //xor 
        6'h26: begin
            reg_A = gr1;
            reg_C = reg_A ^ reg_B;
            overflow = 1'b0;
            neg = reg_C[MSB];
            zero = reg_C?0:1;
        end

        //nor 
        6'h27: begin
            reg_A = gr1;
            reg_B = gr2;
            reg_C = ~(reg_A|reg_B);
            overflow = 1'b0;
            neg = reg_C[MSB];
            zero = reg_C ? 0:1;
        end

        //slt
        6'h2a: begin
            reg_A = gr1;
            reg_B = gr2;
            reg_C = reg_A < reg_B;
            overflow = 1'b0;
            neg = 1'b0;
            zero = reg_C ? 0:1;
        end

        //sltu
        6'h2b: begin
            reg_A = gr1;
            unsigned_regA = reg_A;
            reg_B = gr2;
            unsigned_regB = reg_B;
            reg_C = unsigned_regA < unsigned_regB;
            overflow = 1'b0;
            neg = 1'b0;
            zero = reg_C ? 0:1;
        end

        //sll
        6'h0:begin
            reg_A = gr1;
            reg_B = {{27{1'b0}}, shamt};
            reg_C = reg_A << reg_B;
            overflow = 1'b0;
            neg = reg_C[MSB];
            zero = reg_C ? 0:1;
        end

        //sllv
        6'h4:begin
            reg_A = gr1;
            reg_B = gr2;
            reg_C = reg_A << reg_B;
            overflow = 1'b0;
            neg = reg_C[MSB];
            zero = reg_C ? 0:1;
        end

        //srl
        6'h2: begin
            reg_A = gr1;
            reg_B = {{27{1'b0}}, shamt};
            reg_C = reg_A >> reg_B;
            overflow = 1'b0;
            neg = reg_C[MSB];
            zero = reg_C ? 0:1;
        end

        //srlv
        6'h6: begin
            reg_A = gr1;
            reg_B = gr2;
            reg_C = reg_A >> reg_B;
            overflow = 1'b0;
            neg = reg_C[MSB];
            zero = reg_C ? 0:1;
        end

        //sra
        6'h3: begin
            reg_A = gr1;
            reg_B = {{27{1'b0}}, shamt};
            reg_C = reg_A >>> reg_B;
            overflow = 1'b0;
            neg = reg_C[MSB];
            zero = reg_C ? 0:1;
        end

        //srav
        6'h7:begin
            reg_A = gr1;
            reg_B = gr2
            reg_C = reg_A >>> reg_B;
            overflow = 1'b0;
            neg = reg_C[MSB];
            zero = reg_C ? 0:1;
        end

    endcase

end //R-Type end

default:begin //I-Type
    case(func) 
        //addi
        6'h8: begin
            reg_B = imm;
            reg_A = gr1;
            reg_C = reg_A + reg_B;
            overflow = ((reg_A[31] == reg_B[31]) && (~reg_C[31] == reg_A[31])?1:0;
            zero = (reg_C)?1:0;
            neg = reg_C[MSB];
        end

        //addiu
        6'h9: begin
            reg_B = imm;
            reg_A = gr1;
            unsigned_regA = gr1;
            reg_B = gr2;
            unsigned_regB = imm;
            reg_C = unsigned_regA + unsigned_regB;
            zero = (reg_C)?1:0;
            overflow = 1'b0;
            neg = 1'b0;
        end

        //ori
        6'hd: begin
            reg_B = imm;
            reg_A = gr1;
            reg_C = reg_A | reg_B;
            overflow = 1'b0;
            neg = reg_C[MSB];
            zero = reg_C?0:1;
        end

        //xori
        6'he: begin
            reg_B = imm;
            reg_A = gr1;
            reg_C = reg_A ^ reg_B;
            overflow = 1'b0;
            neg = reg_C[MSB];
            zero = reg_C?0:1;
        end

        //beq
        6'h4: begin
            reg_A = gr1;
            reg_B = imm;
            reg_C = reg_A - reg_B;
            overflow = (reg_A[31] == 0 && reg_B[31] == 0 && reg_C[31] == 0)? 1:0;
            zero = reg_C? 0:1;
            neg = reg_C[MSB];
        end

        //bne
        6'h4: begin
            reg_A = gr1;
            reg_B = imm;
            reg_C = reg_A - reg_B;
            overflow = (reg_A[31] == 0 && reg_B[31] == 0 && reg_C[31] == 0)? 1:0;
            zero = reg_C? 0:1;
            neg = reg_C[MSB];
        end

        //slti
        6'ha: begin
            reg_A = gr1;
            reg_B = imm;
            reg_C = reg_A < reg_B;
            overflow = 1'b0;
            neg = 1'b0;
            zero = reg_C ? 0:1;
        end

        //sltiu
        6'hb: begin
            reg_A = gr1;
            unsigned_regA = reg_A;
            reg_B = imm;
            unsigned_regB = reg_B;
            reg_C = unsigned_regA < unsigned_regB;
            overflow = 1'b0;
            neg = 1'b0;
            zero = reg_C ? 0:1;
        end

        //lw
        6'h23: begin
            reg_A = gr1;
            reg_B = imm;
            reg_C = reg_A + reg_B;
            overflow = 1'b0;
            neg = 1'b0;
            zero = reg_C ? 0:1;
        end

        //sw
        6'h2b: begin
            reg_A = gr1;
            reg_B = imm;
            reg_C = reg_A + reg_B;
            overflow = 1'b0;
            neg = 1'b0;
            zero = reg_C ? 0:1;
        end

        

    endcase

end

endcase

end

assign c = reg_C[31:0];

endmodule


