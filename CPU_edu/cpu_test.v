module test;

    reg ck = 0;
    always #5 ck = ~ck;

    reg [3:0] index_reg1 = 4'b0000;
    reg [3:0] index_reg2 = 4'b0001;

    reg [7:0] regfile_input = 8'h01;

    reg rw = 1'b1;

    wire [7:0] o1;
    wire [7:0] o2;


    reg_file myreg(ck, index_reg1, index_reg2, regfile_input, rw,
                    o1, o2);

    initial begin
        $dumpfile("regfile_test.vcd");
        $dumpvars(0, test);

        #7 index_reg1 = 4'b0001;
        #7 regfile_input = 8'hF9;

        #100 $finish;

    end

endmodule




