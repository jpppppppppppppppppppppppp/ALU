/* ACM Class System (I) Fall Assignment 1 
 *
 *
 * Implement your naive adder here
 * 
 * GUIDE:
 *   1. Create a RTL project in Vivado
 *   2. Put this file into `Sources'
 *   3. Put `test_adder.v' into `Simulation Sources'
 *   4. Run Behavioral Simulation
 *   5. Make sure to run at least 100 steps during the simulation (usually 100ns)
 *   6. You can see the results in `Tcl console'
 *
 */
module full_adder_bit(
	input a,
	input b,
	input c_in,
	output sum,
	output c_out
);
assign sum = a ^ b ^ c_in;
assign c_out = (a & b) | (c_in & (a ^ b));
endmodule

module adder(
	input [15:0]a,
	input [15:0]b,
	output [15:0]sum,
	output carry
);
wire sum15,sum14,sum13,sum12,sum11,sum10,sum9,sum8,sum7,sum6,sum5,sum4,sum3,sum2,sum1,sum0;
assign sum = {sum15,sum14,sum13,sum12,sum11,sum10,sum9,sum8,sum7,sum6,sum5,sum4,sum3,sum2,sum1,sum0};
wire c_out_0,c_out_1,c_out_2,c_out_3,c_out_4,c_out_5,c_out_6,c_out_7,c_out_8,c_out_9,c_out_10,c_out_11,c_out_12,c_out_13,c_out_14;
full_adder_bit f0(.a(a[0]),.b(b[0]),.c_in(0),.sum(sum0),.c_out(c_out_0));
full_adder_bit f1(.a(a[1]),.b(b[1]),.c_in(c_out_0),.sum(sum1),.c_out(c_out_1));
full_adder_bit f2(.a(a[2]),.b(b[2]),.c_in(c_out_1),.sum(sum2),.c_out(c_out_2));
full_adder_bit f3(.a(a[3]),.b(b[3]),.c_in(c_out_2),.sum(sum3),.c_out(c_out_3));
full_adder_bit f4(.a(a[4]),.b(b[4]),.c_in(c_out_3),.sum(sum4),.c_out(c_out_4));
full_adder_bit f5(.a(a[5]),.b(b[5]),.c_in(c_out_4),.sum(sum5),.c_out(c_out_5));
full_adder_bit f6(.a(a[6]),.b(b[6]),.c_in(c_out_5),.sum(sum6),.c_out(c_out_6));
full_adder_bit f7(.a(a[7]),.b(b[7]),.c_in(c_out_6),.sum(sum7),.c_out(c_out_7));
full_adder_bit f8(.a(a[8]),.b(b[8]),.c_in(c_out_7),.sum(sum8),.c_out(c_out_8));
full_adder_bit f9(.a(a[9]),.b(b[9]),.c_in(c_out_8),.sum(sum9),.c_out(c_out_9));
full_adder_bit f10(.a(a[10]),.b(b[10]),.c_in(c_out_9),.sum(sum10),.c_out(c_out_10));
full_adder_bit f11(.a(a[11]),.b(b[11]),.c_in(c_out_10),.sum(sum11),.c_out(c_out_11));
full_adder_bit f12(.a(a[12]),.b(b[12]),.c_in(c_out_11),.sum(sum12),.c_out(c_out_12));
full_adder_bit f13(.a(a[13]),.b(b[13]),.c_in(c_out_12),.sum(sum13),.c_out(c_out_13));
full_adder_bit f14(.a(a[14]),.b(b[14]),.c_in(c_out_13),.sum(sum14),.c_out(c_out_14));
full_adder_bit f15(.a(a[15]),.b(b[15]),.c_in(c_out_14),.sum(sum15),.c_out(carry));
endmodule