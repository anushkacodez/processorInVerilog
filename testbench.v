`timescale 1ns / 1ps

module testbench;

    reg clk=0;
    reg [1:0]valid=0;
    reg [15:0] instruction;
    reg [7:0] instruction_address;
   
    
    // Instantiate the module
    final_design uut (
        .clk(clk),
        .valid(valid),
        .instruction(instruction),
        .instruction_address(instruction_address)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Initialize all inputs
    initial begin
      	#10;
      	#5;
        valid=1;
      	//#2
      	instruction = 16'b0011000000000001; //RF[0]=1; load constant
        instruction_address = 8'b00000000;
      	#5;
       	valid=0;
       	
        #10;
        #5;
        valid=1;
        //#2
        instruction = 16'b0011000000000001; //RF[0]=1; load constant
        instruction_address = 8'b00000000;
        #5;
        valid=0;       	
      
      
        #10;
        // Reset
        #5;
        valid=1;
      	//#2
        instruction = 16'b0001000000000000; // store D[0]=RF[0]=1;
        instruction_address = 8'b00000001;
      	#5;
        valid=0;
		
      	#10;
        // Change in inputs to see change in behavior
        #5;
        valid=1;
        instruction = 16'b0011000100000010; // load constant RF[1]=2
        instruction_address = 8'b00000010;
      	#5;
        valid=0;
      
      	#10;

        
		#5;
        valid=1;
      	//#2
        instruction = 16'b0001000100000001; // store D[1]=RF[1]=2
        instruction_address = 8'b00000011;
      	#5;
        valid=0;
      
      	#10;

        #5;
        valid=1;
      	//#2
        instruction = 16'b0000001000000000; // load RF[2]=D[0]=1
        instruction_address = 8'b00000100;
      	#5;
        valid=0;
      	#10;

        #5;
        valid=1;
      	//#2
        instruction = 16'b0010001100100001; //add RF[3]=RF[1]+RF[2]=3
        instruction_address = 8'b00000101;
      	#5;
        valid=0;
        #10;

        #5;
        valid=1;
      	//#2
        instruction = 16'b0011010100000000; // load constant RF[5]=0;
        instruction_address = 8'b00000110;
      	#5;
        valid=0;
      	#10;

        #5;
        valid=1;
      	//#2
        instruction = 16'b0101010100000010; // jump 2 steps ahead
        instruction_address = 8'b00000111;
      	#5;
        valid=0;
      	#10;


        #5;
        valid=1;
      	//#2                
        instruction = 16'b0011000000000000; // load constant RF[0]=0
        instruction_address = 8'b00001000;
      	#5;
        valid=0;
      	#10;

        #5;
        valid=1;
      	//#2                
        instruction = 16'b0100010000100011; // subtract RF[4]=RF[2]-RF[3]=-2
        instruction_address = 8'b00001001;
      	#5;
        valid=0;
      	#10;
        #20;
        #3;
        valid=2'b11;

        #2000;
        $finish; // Terminate simulation
    end
    

endmodule
