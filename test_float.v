`include "adder-float.v"
`timescale 1ns/1ps
module floatadd_tb();
    reg clk,rst;
    reg [31:0] x,y;
    wire [31:0] z;
    wire [1:0] overflow;
    
    float_adder floatadd_test(
        .clk(clk),
        .rst(rst),
        .x(x),
        .y(y),
        .z(z),
        .overflow(overflow)
    );
    always #(10) clk<=~clk;
    initial begin
        clk=0;
        rst=1'b0;
        #20 rst=1'b1;
        #20 x=32'b00111111010001111010111000010100;//0.78
            y=32'b00111111000011001100110011001101;//0.55
        //ans=0.78+0.55=1.33 32'b00111111 10101010 00111101 01110001 3faa3d70

        #1000
        $display("%b + %b = %b", x, y, z);
        x=32'h4248CCCC;//50.2
        y=32'h3F8CCCCC;//1.1
        //ans=51.3  424d3332
        #1000
        $display("%b + %b = %b", x, y, z);
        x=32'h10A0201D;//6.3158350761658E-29
        y=32'h1FFFFFF5;//1.0842014616272E-19
        //ans=1.0842014616272E-19两正数相加，由于阶码相差63，所以小数可以忽略，结果与输入大数相等   1FFFFFF5
        #1000
        $display("%b + %b = %b", x, y, z);
        x=32'h00000000;
        y=32'h4248CCCC;
        //0+50.2=50.2   4248CCCC
        #1000
        $display("%b + %b = %b", x, y, z);
        x=32'b01000010110010000000000000000000;//100
        y=32'b01000011010010000000000000000000;//200
        //ans=300 32'b01000011 10010110 00000000 00000000   43960000
        #1000
        $display("%b + %b = %b", x, y, z);
        x=32'hBF000000;//-0.5
        y=32'h3F99999A;//1.2
        //ans=0.7   3f333334
        #1000
        $display("%b + %b = %b", x, y, z);
        x=32'hC2787DF4;//-62.123
        y=32'h42C86D0E;//100.213
        //ans=38.09     42185c28
        #1000
        $display("%b + %b = %b", x, y, z);
        x=32'h9EC0001D;//-2.032883758613E-20
        y=32'h9FFFFFF5;//-1.0842014616272E-19
        //ans=-1.2874898213326E-19  a017fffe
        #1000
        $display("%b + %b = %b", x, y, z);
        x=32'h1EA2281D;//1.7169007646178E-20
        y=32'h9FFFFFF5;//-1.0842014616272E-19
        //ans=-9.1251140132126E-20  9fd775ee
        #1000
        $display("%b + %b = %b", x, y, z);
        x=32'h9EE2281D;//-2.3945271224212E-20
        y=32'h1FFFFFF5;//1.0842014616272E-19
        // //ans=8.4474876554092E-20    1fc775ee
        #1000
        $display("%b + %b = %b", x, y, z);
        x=32'h1EE2281F;//2.3945274455386E-20
        y=32'h1FFFFFF0;//1.0842011385097E-19
        //ans=1.32365388306356E-19  201c44fb
        #1000
        $display("%b + %b = %b", x, y, z);
        x=32'h7F7FFFFF;
        y=32'h7F7FFFFF;//验证上溢出 overflow=2'b01 7FFFFFFF
        #1000
        $display("%b + %b = %b", x, y, z);
        x=32'h00800010;
        y=32'h80800001;//验证下溢出 0000001E
        #1000
        $display("%b + %b = %b", x, y, z);
        x=32'h000003FF;
        y=32'h3F8003FF;//非规格+ overflow=2'b11 3f8003ff
        #1000
        $display("%b + %b = %b", x, y, z);
        x=32'h7F800003;
        y=32'h7F800004;//验证NaN overflow=2'b11 FFFFFFFF
         #1000
         $display("%b + %b = %b", x, y, z);
        x=32'h00000000;//
        y=32'h9FFFFFF0;//-1.0842011385097E-19   9FFFFFF0
        //验证判断0阶段功能
        #1000
        $display("%b + %b = %b", x, y, z);
        x=32'h00000003;
        y=32'h00000005;//非规格数字+非规格 数字 00000008
        #1000
        $display("%b + %b = %b", x, y, z);
        x=32'h1FFFFFFF;//1.084202107862E-19
        y=32'h9FFFFFF0;//-1.0842011385097E-19
        //ans=0.0000009693523   15F00000
        #1000
        $display("%b + %b = %b", x, y, z);
        x=32'h00000003;
        y=32'h00800002;//非规格数字+正常数字 overflow=2'b11 
        #1000
        $display("%b + %b = %b", x, y, z);
        x=32'h1EE2281F;//2.3945274455386E-20
        y=32'h1FFFFFF0;//1.0842011385097E-19
        //ans=1.32365388306356E-19 
        #1000
        $display("%b + %b = %b", x, y, z);
        x=32'h00000003;
        y=32'h7F800004;//非规格数字+正常数字 overflow=2'b11 
        #1000
        $display("%b + %b = %b", x, y, z);
        x=32'h1EE2281F;//2.3945274455386E-20
        y=32'h1FFFFFF0;//1.0842011385097E-19
        //ans=1.32365388306356E-19 
        #1000
        $display("%b + %b = %b", x, y, z);
        x=32'h7F800000;
        y=32'h00000003;//验证无穷大，结果为无穷大 overflow=2'b11 
        #1000
        $display("%b + %b = %b", x, y, z);
        x=32'h1EE2281F;//2.3945274455386E-20
        y=32'h1FFFFFF0;//1.0842011385097E-19
        //ans=1.32365388306356E-19 
        #1000
        $display("%b + %b = %b", x, y, z);
        x=32'h7F800000;
        y=32'h1FFFFFF0;//验证无穷大，结果为无穷大 overflow=2'b11 
        
        #1000
        $display("%b + %b = %b", x, y, z);
        #2000 $stop;
    end
endmodule
