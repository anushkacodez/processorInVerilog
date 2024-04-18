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



module memory(reset, write_enable ,read_enable, data_input, address_input, data_out);

    input write_enable, reset;
    input read_enable;
    input [7:0] data_input;
    input [7:0] address_input;
    output reg [7:0]data_out;

    reg [7:0] memarr [255:0];
    always@(reset, write_enable, read_enable)
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

always@(read_enable, write_enable)
begin
    if(read_enable)
    begin
        out=instruc_memory[address];
    end
    else if(write_enable)
    begin
        instruc_memory[address]=input_instruc;
    end
end
endmodule





module controller();
reg [4:0] cstate=0,nstate=0;

input [15:0] instruc_reg_out;

always@(posedge clk)
begin
    cstate<=nstate;
    
end

always@(cstate)
begin
    case(cstate)
    0: //pc_Reset
    begin
        PC_reset=1;
        nstate<=1;
    end
    1: //fetch from instruc_mem and writing into instruction reg
    begin
        PC_reset=0;
        instruc_mem_read=1;
        instruc_reg_write=1;
        nstate<=2;
    end
    2: //pc increment (inbuilt pc increment DONT SENT TO ALU)
    begin
        instruc_mem_read=0;
        instruc_reg_write=0;
        PC_incr=1;
        nstate<=3;
    end
    3: //reading instruction register
    begin
        PC_incr=0;
        instruc_reg_read=1;
        nstate<=4;
    end
    4: 
    begin
        instruc_reg_read=0;
        case(instruc_reg_out[15:12])
            0: nstate<=5;
            1: nstate<=6;
            2: nstate<=7;
            3: nstate<=8;
            4: nstate<=9;
            5: nstate<=10;
            // default:
        endcase
    end
    5:
    begin
        
    end
endcase
end

endmodule
