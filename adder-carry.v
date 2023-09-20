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
module pg_generator(
	input a,
	input b,
	output g,
	output p
);
	assign g = a & b;
	assign p = a | b;
endmodule

module clu(
	input	[3:0]	g,
	input	[3:0]	p,
	input	ci,
	output	[3:0]	co
);
	assign co[0] = g[0] | ci & p[0];
	assign co[1] = g[1] | g[0] & p[1] | ci & p[1] & p[0];
	assign co[2] = g[2] | g[1] & p[2] | g[0] & p[2] & p[1] | ci & p[2] & p[1] & p[0];
	assign co[3] = g[3] | g[2] & p[3] | g[1] & p[3] & p[2] | g[0] & p[3] & p[2] & p[1] | ci & p[3] & p[2] & p[1] & p[0];
endmodule

module tu(
	input	[3:0]	g,
	input	[3:0]	p,
	output	[3:0]	t
);
	assign t = ~g & p;
endmodule

module pgm_generator(
	input	[3:0]	g,
	input	[3:0]	p,
	output	gm,
	output pm
);
	assign gm = g[3] | g[2] & p[3] | g[1] & p[3] & p[2] | g[0] & p[3] & p[2] & p[1];
	assign pm = p[3] & p[2] & p[1] & p[0];
endmodule

module adder_4bit(
	input	[3:0]	a,
	input	[3:0]	b,
	input	ci,
	output	[3:0]	s,
	output	[3:0]	g,
	output	[3:0]	p
);
	wire [3:0]	co_clu;
	wire [3:0]	t;

	pg_generator	PG0(.a(a[0]),.b(b[0]),.g(g[0]),.p(p[0])),
					PG1(.a(a[1]),.b(b[1]),.g(g[1]),.p(p[1])),
					PG2(.a(a[2]),.b(b[2]),.g(g[2]),.p(p[2])),
					PG3(.a(a[3]),.b(b[3]),.g(g[3]),.p(p[3]));
	tu	TU(.g(g),.p(p),.t(t));
	clu	CLU(.g(g),.p(p),.ci(ci),.co(co_clu));
	assign s[0] = t[0] ^ ci;
	assign s[1] = t[1] ^ co_clu[0];
	assign s[2] = t[2] ^ co_clu[1];
	assign s[3] = t[3] ^ co_clu[2];
endmodule



module adder(
	input	[15:0]	a,
	input	[15:0]	b,
	output	[15:0]	sum,
	output	carry
);
	wire [15:0]	g;
	wire [15:0]	p;
	wire [3:0]	gm;
	wire [3:0]	pm;
	wire [3:0]	co;
	wire ci = 0;
	adder_4bit	CLA_1(.a(a[3:0]),.b(b[3:0]),.ci(ci),.s(sum[3:0]),.g(g[3:0]),.p(p[3:0])),
				CLA_2(.a(a[7:4]),.b(b[7:4]),.ci(co[0]),.s(sum[7:4]),.g(g[7:4]),.p(p[7:4])),
				CLA_3(.a(a[11:8]),.b(b[11:8]),.ci(co[1]),.s(sum[11:8]),.g(g[11:8]),.p(p[11:8])),
				CLA_4(.a(a[15:12]),.b(b[15:12]),.ci(co[2]),.s(sum[15:12]),.g(g[15:12]),.p(p[15:12]));
	pgm_generator	PG_1(.g(g[3:0]),.p(p[3:0]),.gm(gm[0]),.pm(pm[0])),
				  	PG_2(.g(g[7:4]),.p(p[7:4]),.gm(gm[1]),.pm(pm[1])),
					PG_3(.g(g[11:8]),.p(p[11:8]),.gm(gm[2]),.pm(pm[2])),
					PG_4(.g(g[15:12]),.p(p[15:12]),.gm(gm[3]),.pm(pm[3]));
	clu	CLU(.g(gm),.p(pm),.ci(ci),.co(co));
	assign carry = co[3];
endmodule
