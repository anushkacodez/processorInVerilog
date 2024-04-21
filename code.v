module ALU(ALUControl, A, B, ALUResult, Zero);
    input ALUControl;
	input   [7:0]  A, B;	    // inputs
	output  reg [7:0]  ALUResult;	// answer
	output  reg     Zero;	    // Zero=1 if ALUResult == 0
    wire [7:0] not_b;
    not(not_b[0],B[0]);
    not(not_b[1],B[1]);
    not(not_b[2],B[2]);
    not(not_b[3],B[3]);
    not(not_b[4],B[4]);
    not(not_b[5],B[5]);
    not(not_b[6],B[6]);
    not(not_b[7],B[7]);
    wire [7:0]add_output,sub_output;
    wire add_carry,sub_carry;
    eight_bit_Adder out1(A,B,1'b 0,add_output,add_carry);
    eight_bit_Adder out2(A,not_b,1'b 1,sub_output,sub_carry);
    
    always @(ALUControl,A,B)
    begin
		case (ALUControl)
		0: // ADD
        begin ALUResult<=add_output; end
        1: //SUBTRACT
        begin ALUResult<= sub_output; end
        endcase
	end
	always @(ALUResult) 
    begin
		if (ALUResult == 0) begin
			Zero <= 1;
		end else begin
			Zero <= 0;
		end
	end
endmodule


module half_add(a,b,s,c); 
  input a,b;
  output s,c; 
  xor x1(s,a,b);
  and a1(c,a,b);
endmodule


module FullAdder(a,b,cin,sum,cout);
  input a,b,cin;
  output sum,cout;
  wire x,y,z;
  half_add h1(.a(a),.b(b),.s(x),.c(y));
  half_add h2(.a(x),.b(cin),.s(sum),.c(z));
  or o1(cout,y,z);
endmodule


module eight_bit_Adder(a,b,cin,s,cout);
input [7:0]a,b;
input cin;
output wire [7:0]s;
output cout;
wire cout1,cout2,cout3,cout4,cout5,cout6,cout7;
FullAdder FA1(a[0],b[0],cin,s[0],cout1);
FullAdder FA2(a[1],b[1],cout1,s[1],cout2);
FullAdder FA3(a[2],b[2],cout2,s[2],cout3);
FullAdder FA4(a[3],b[3],cout3,s[3],cout4);
FullAdder FA5(a[4],b[4],cout4,s[4],cout5);
FullAdder FA6(a[5],b[5],cout5,s[5],cout6);
FullAdder FA7(a[6],b[6],cout6,s[6],cout7);
FullAdder FA8(a[7],b[7],cout7,s[7],cout);
endmodule


module instruction_register(input write_enable,input read_enable,input [15:0] data_in,output reg [15:0] data_out);
reg [15:0]temp;
always@(write_enable or read_enable)
begin
    if(write_enable)
    temp=data_in;
    else if (read_enable)
    data_out=temp;
end
endmodule

// module instruction_memory(input load_enable, input read_enable,input [7:0] pc,input [7:0] load_address,input[15:0] load_instruction,output reg [15:0] instruction_read);
// reg [15:0] instructions [255:0];
// always@(load_enable or read_enable)
// begin 
//     if(load_enable)
//     begin instructions[load_address]<=load_instruction; end
//     else if(read_enable)
//     begin instruction_read<=instructions[pc];end
// end
// endmodule
module program_counter(input reset, input write_enable, input read_enable,input [7:0]branch_pc,input select,output reg[7:0] pc_read);
reg [7:0] pc;
wire [7:0]pc_plus_4;
wire [7:0]pc_after_branch_after_subtract;
wire carry,carry2;
wire [7:0] pc_after_branch;
eight_bit_Adder a1(pc,8'b00000001,1'b0,pc_plus_4,carry);
eight_bit_Adder a2(pc,branch_pc,1'b0,pc_after_branch,carry);
eight_bit_Adder a3(pc_after_branch,8'b11111111,1'b0,pc_after_branch_after_subtract,carry2);



always@(reset or write_enable or read_enable)
begin 
    if(reset) pc<=8'b00000000;
    else if(read_enable) pc_read<=pc;
    else if(write_enable)
    begin 
        if(!select)
        pc<=pc_plus_4;
        else
        pc<=pc_after_branch_after_subtract;
    end
end
endmodule


module registerFile(write_enable, read_enable, input_address, input_data, out);
input write_enable, read_enable;
input [3:0]input_address;
input [7:0]input_data;
output reg [7:0]out;

reg [7:0] registers[15:0];

always@(write_enable, read_enable)
begin
    if(write_enable)
    begin
        registers[input_address]=input_data;
        //out=registers[input_address];
    end
    else if(read_enable)
    begin
        out=registers[input_address];
    end
end
endmodule


module mux2x1(input_data1, input_data2, sel, out);
input [7:0]input_data1;
input [7:0]input_data2;
input sel;
output reg [7:0]out;
always@(*)
begin
    case(sel)
        1'b0: out=input_data1;
        1'b1: out=input_data2;
    endcase
end
endmodule


module mux4v1(input_data1, input_data2, input_data3, input_data4, sel1, sel0, out);
input [7:0]input_data1, input_data2, input_data3, input_data4;
input sel1, sel0;
output [7:0]out;

wire [7:0]w1,w2;
mux2x1 m1(input_data1, input_data2, sel0, w1);
mux2x1 m2(input_data3, input_data4, sel0, w2);
mux2x1 m3(w1, w2, sel1, out);

endmodule

module mux3v1_4bit(input_data1, input_data2, input_data3,sel,out);
    input [3:0]input_data1, input_data2, input_data3;
    input [1:0] sel;
    output reg[3:0] out;
    always@(sel)
    begin 
        case(sel)
        2'b00: out<=input_data1;
        2'b01: out<=input_data2;
        2'b10: out<=input_data3;
        endcase
    end

endmodule
module mux3v1_8bit(input_data1, input_data2, input_data3,sel,out);
    input [7:0]input_data1, input_data2, input_data3;
    input [1:0] sel;
    output reg[7:0] out;
    always@(sel)
    begin 
        case(sel)
        2'b00: out<=input_data1;
        2'b01: out<=input_data2;
        2'b10: out<=input_data3;
        endcase
    end

endmodule   


module memory(write_enable ,read_enable, data_input, address_input, data_out);

    input write_enable;
    input read_enable;
    input [7:0] data_input;
    input [7:0] address_input;
    output reg [7:0]data_out;

    reg [7:0] memarr [255:0];
    always@(write_enable, read_enable)
    begin
                
        if(write_enable)
        begin
            memarr[address_input]=data_input;
            //$display("input fed: %d",memarr[address_input]);
            
        end
        else if(read_enable)
        begin
            data_out=memarr[address_input];
        end        
        //$display("read_enable %d memory read %d",read_enable,data_out);
    end
    
endmodule

module instruction_memory(read_enable, write_enable, input_instruc, address, out);
input read_enable, write_enable;
input [7:0]address;
input [15:0] input_instruc;
output reg[15:0] out;
reg [15:0] instruc_memory [255:0]; 

always@(*)
begin
    $display("0 %b",instruc_memory[0]);
    $display("1 %b",instruc_memory[1]);
    $display("2 %b",instruc_memory[2]);
    $display("3 %b",instruc_memory[3]);
    $display("4 %b",instruc_memory[4]);
    $display("5 %b",instruc_memory[5]);
end
always@(read_enable, write_enable)
begin
    if(read_enable)
    begin
        out=instruc_memory[address];
    end
    else if(write_enable)
    begin
        instruc_memory[address]=input_instruc;
        out=input_instruc;
    end
end
endmodule



module check_zero(data_input, result);
input [7:0]data_input;
output reg result;

always@(*)
begin
    if(data_input==8'b00000000)result<=1;
    else result<=0;
end
endmodule





module controller(clk,valid,pc_reset, pc_select,pc_read_enable,pc_write_enable,instruc_mem_read, instruc_mem_write,
instruc_reg_read,instruc_reg_write,mux_register_write_select,
register_write_enable,register_read_enable,instruc_mem_address_select,
mem_read_enable,mem_write_enable,alu_select,
check_zero_out,rf_address_mux,temp_a_write_enable,temp_b_write_enable,instruc_reg_out);
//take input from comaparator
input clk;
input [1:0]valid;
output reg pc_reset, pc_select,pc_read_enable,pc_write_enable;
output reg instruc_mem_read, instruc_mem_write,instruc_mem_address_select;
output reg instruc_reg_read,instruc_reg_write;
output reg [1:0]mux_register_write_select;
//output reg mux_register_read_select;
output reg register_write_enable,register_read_enable;
output reg mem_read_enable,mem_write_enable,alu_select;
input check_zero_out;
reg [5:0] cstate=0,nstate=0;
input [15:0] instruc_reg_out;
output reg [1:0]rf_address_mux;
output reg temp_a_write_enable,temp_b_write_enable;
always@(posedge clk)
begin
    cstate<=nstate;
    
end
always@(posedge clk)
begin
    $display("cstate: %d, nstate: %d",cstate,nstate);
    $display("instruc_reg_out: %b",instruc_reg_out);

end

  always@(cstate,valid)
begin
    case(cstate)
    0:
    begin 
        if(valid==2'b01) 
        begin
            instruc_mem_address_select=0;
            instruc_mem_write=1;
            nstate=30;
        end
        else if(valid==2'b11) nstate=31;
    end
    30:
    begin 
        instruc_mem_write=0;
        if(valid==2'b11) nstate=31;
        else if(valid==2'b00)nstate=0;
    end
    31: //pc_Reset
    begin
        pc_reset=1;
        nstate=1;
    end
    1:// read pc
    begin
        pc_reset=0; 
        pc_read_enable=1;
        
        nstate=2;
    end
    2: //fetch from instruc_mem and writing into instruction reg
    begin
        pc_read_enable=0;
        instruc_mem_address_select=1;
        instruc_mem_read=1;
        nstate=32;
    end
    32:
    begin
        instruc_mem_read=0;
        instruc_reg_write=1;
        nstate=3;
    end
    3: //pc increment (inbuilt pc increment DONT SENT TO ALU)
    begin
        instruc_reg_write=0;
        pc_select=0;
        pc_write_enable=1;
        nstate=4;
    end
    4: //reading instruction register
    begin
        pc_write_enable=0;
        instruc_reg_read=1;
        nstate=5;
    end
    5: //decode
    begin
        instruc_reg_read=0;
        case(instruc_reg_out[15:12])
            0: nstate<=11;
            1: nstate<=6;
            2: nstate<=7;
            3: nstate<=8;
            4: nstate<=9;
            5: nstate<=10;
            // default:
        endcase
    end

    //load
    11: //read from memory
    begin 
        mem_read_enable=1;
        nstate<=12; 
    end
    12: //load read data into register
    begin 
        mux_register_write_select=2'b01;
        mem_read_enable=0;
        rf_address_mux=0;
        register_write_enable=1;
        nstate<=13;
    end
    13: //end state of load
    begin
        register_write_enable=0;
        nstate<=1;
    end


    //store
    6: //reading register file
    begin
        rf_address_mux=0;
        //mux_register_read_select=0;
        register_read_enable=1;
        nstate<=14;
    end
    14: //memory write
    begin
        register_read_enable=0;
        mem_write_enable=1;
        nstate<=15;
    end
    15: //end state of store
    begin
        mem_write_enable=0;
        nstate<=1;
    end


    //addition
    7: //read register A
        begin
            rf_address_mux=1;
       // mux_register_read_select=0;
        register_read_enable=1;
        nstate<=16;
        end

    16: 
        begin

        register_read_enable=0;
        temp_a_write_enable=1;
        nstate<=17;
        end


    17: ///read register B
        begin
            temp_a_write_enable=0;
            rf_address_mux=2;
           // mux_register_read_select=1;
            register_read_enable=1;
            nstate<=18;
        end

    18: 
        begin
            register_read_enable=0;
            temp_b_write_enable=1;
            nstate<=19;
        end


    19: //addition
        begin
            temp_b_write_enable=0;
            alu_select=0;
            nstate<=20;
        end
    20: //writing the sum into register file
        begin
            rf_address_mux=0;
            mux_register_write_select=2'b00;
            register_write_enable=1;
            nstate<=21;
        end

    21: //off kardo write enable
        begin
            register_write_enable=0;
            nstate<=1;
        end

    //load constant
    8: //changing select for writing
        begin
            rf_address_mux=0;
            mux_register_write_select=2'b10;
            register_write_enable=1;
            nstate<=21;
        end


    //subtract

    9: //read register A
        begin
            rf_address_mux=1;
       // mux_register_read_select=0;
        register_read_enable=1;
        nstate<=22;
        end

    22: 
        begin
        register_read_enable=0;
        temp_a_write_enable=1;
        nstate<=23;
        end


    23: ///read register B
        begin
            temp_a_write_enable=0;
            rf_address_mux=2;
            //mux_register_read_select=1;
            register_read_enable=1;
            nstate<=24;
        end

    24: //store in temp register
        begin
            register_read_enable=0;
            temp_b_write_enable=1;
            nstate<=25;
        end

    25: //subtraction
        begin
             temp_b_write_enable=0;
            alu_select=1;
            nstate<=26;
        end
    26: //writing the sum into register file
        begin
            rf_address_mux=0;
            mux_register_write_select=2'b00;
            register_write_enable=1;
            nstate<=27;
        end

    27: //off kardo write enable
        begin
            register_write_enable=0;
            nstate<=1;
        end

    //jump
    10://read register
    begin 
        rf_address_mux=0;
        register_read_enable=1;

        nstate=28;
    end
    28: //check for zero
        begin
            register_read_enable=0;
            if(check_zero_out)
            begin
                pc_select=1;
                pc_write_enable=1;
                nstate<=29;
            end
            else
            nstate<=1;
        end
    29: //
        begin   
            pc_write_enable=0;
            nstate<=1;
        end
    

endcase
end
endmodule

module temp_reg(input write_enable,input [7:0]data_in,output reg [7:0] data_out);
always@(write_enable)
data_out<=data_in;
endmodule



module final_design(input clk,input[1:0] valid,input [15:0]instruction,input [7:0] instruction_address,output [7:0]ALUResult, output check_zero_out);
wire [15:0] instruction_memory_output,instruction_register_output;
wire instruc_mem_read, instruc_mem_write,instruc_mem_address_select;
wire instruc_reg_read,instruc_reg_write;
wire [7:0]instru_address_final;
wire [7:0]pc_output;
wire pc_reset, pc_select,pc_read_enable,pc_write_enable;
wire mem_read_enable,mem_write_enable;
wire [7:0]memory_output;
wire [7:0] reg_file_output;
//wire check_zero_out;
wire [3:0] address_input_to_rf;
wire [1:0]rf_address_mux;
wire [7:0]data_input_to_rf;
wire [1:0]mux_register_write_select;
wire register_write_enable,register_read_enable;
wire alu_select;
//wire [7:0]ALUResult;
wire zero;
wire [7:0] a_val,b_val;
wire temp_a_write_enable,temp_b_write_enable;

program_counter PC(.reset(pc_reset), .write_enable(pc_write_enable), .read_enable(pc_read_enable),.branch_pc(instruction_register_output[7:0]),.select(pc_select), .pc_read(pc_output));
mux2x1 muxx1(.input_data1(instruction_address), .input_data2(pc_output), .sel(instruc_mem_address_select), .out(instru_address_final));
instruction_memory M1(.read_enable(instruc_mem_read), .write_enable(instruc_mem_write), .input_instruc(instruction), .address(instru_address_final), .out(instruction_memory_output));
instruction_register IR(.write_enable(instruc_reg_write), .read_enable(instruc_reg_read),.data_in(instruction_memory_output),.data_out(instruction_register_output));

always@(posedge clk)
begin
    $display("pc:%b, instru_address_final:%b, instruction_register_output:%b, instruction_memory_output:%b",pc_output, instru_address_final,instruction_register_output,instruction_memory_output);
end

controller fsm(
    .clk(clk),
    .valid(valid),
    .pc_reset(pc_reset), 
    .pc_select(pc_select),
    .instruc_reg_out(instruction_register_output),
    .pc_read_enable(pc_read_enable),
    .pc_write_enable(pc_write_enable),
    .instruc_mem_read(instruc_mem_read), 
    .instruc_mem_write(instruc_mem_write),
  	.instruc_mem_address_select(instruc_mem_address_select),
    .instruc_reg_read(instruc_reg_read),
    .instruc_reg_write(instruc_reg_write),
    .mux_register_write_select(mux_register_write_select),
    .register_write_enable(register_write_enable),
    .register_read_enable(register_read_enable),
    .mem_read_enable(mem_read_enable),
    .mem_write_enable(mem_write_enable),
    .alu_select(alu_select),
    .check_zero_out(check_zero_out),
    .rf_address_mux(rf_address_mux),
    .temp_a_write_enable(temp_a_write_enable),
    .temp_b_write_enable(temp_b_write_enable)
);

temp_reg A(
    .write_enable(temp_a_write_enable),
    .data_in(reg_file_output),
    .data_out(a_val));

temp_reg B(
    .write_enable(temp_b_write_enable),
    .data_in(reg_file_output),
    .data_out(b_val));
memory M2(
    .write_enable(mem_write_enable) ,
    .read_enable(mem_read_enable), 
    .data_input(reg_file_output), 
    .address_input(instruction_register_output[7:0]), 
    .data_out(memory_output));
check_zero fk(
    .data_input(reg_file_output), 
    .result(check_zero_out));
mux3v1_4bit fk2(
    .input_data1(instruction_register_output[11:8]),
    .input_data2(instruction_register_output[7:4]),
    .input_data3(instruction_register_output[3:0]),
    .sel(rf_address_mux),.out(address_input_to_rf));
registerFile RF(
    .write_enable(register_write_enable), 
    .read_enable(register_read_enable), 
    .input_address(address_input_to_rf), 
    .input_data(data_input_to_rf), 
    .out(reg_file_output));
mux3v1_8bit fk3(
    .input_data1(ALUResult),
    .input_data2(memory_output),
    .input_data3(instruction_register_output[7:0]),
    .sel(mux_register_write_select),
    .out(data_input_to_rf));
ALU alu(
    .ALUControl(alu_select), 
    .A(a_val), 
    .B(b_val), 
    .ALUResult(ALUResult), 
    .Zero(zero));

endmodule
