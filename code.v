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
        if(reset)
        begin
            memarr[0]=6'b000000;
            memarr[1]=6'b000000;
            memarr[2]=6'b000000;
            memarr[3]=6'b000000;
            memarr[4]=6'b000000;
            memarr[5]=6'b000000;
            memarr[6]=6'b000000;
            memarr[7]=6'b000000;
            memarr[8]=6'b000000;
            memarr[9]=6'b000000;
            memarr[10]=6'b000000;
            memarr[11]=6'b000000;
            memarr[12]=6'b000000;
            memarr[13]=6'b000000;
            memarr[14]=6'b000000;
            memarr[15]=6'b000000;
        end        
        else if(write_enable)
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
