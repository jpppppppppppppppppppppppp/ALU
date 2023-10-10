module booth_16x16(
    input   wire    a_signed,
    input   wire    b_signed,
    input   wire    [15:0]  mul_a,
    input   wire    [15:0]  mul_b,
    output  wire    [17:0]  pp1,
    output  wire    [17:0]  pp2,
    output  wire    [17:0]  pp3,
    output  wire    [17:0]  pp4,
    output  wire    [17:0]  pp5,
    output  wire    [17:0]  pp6,
    output  wire    [17:0]  pp7,
    output  wire    [17:0]  pp8,
    output  wire    [17:0]  pp9
);

wire    [1:0]   sign_a = a_signed ? {2{mul_a[15]}} : 2'b00;
wire    [1:0]   sign_b = b_signed ? {2{mul_b[15]}} : 2'b00;

wire    [17:0]  todo = {sign_a, mul_a};
wire    [17:0]  negtodo = ~todo + 1;
wire    [17:0]  doubletodo = todo << 1;
wire    [17:0]  negdoubletodo = negtodo << 1;

wire    [18:0]  b = {sign_b, mul_b, 1'b0};
assign pp1 = (b[2:0] == 3'b001 || b[2:0] == 3'b010) ? todo :
             (b[2:0] == 3'b101 || b[2:0] == 3'b110)  ? negtodo :
             (b[2:0] == 3'b011) ? doubletodo :
             (b[2:0] == 3'b100) ? negdoubletodo : 18'b0;
assign pp2 = (b[4:2] == 3'b001 || b[4:2] == 3'b010) ? todo :
             (b[4:2] == 3'b101 || b[4:2] == 3'b110)  ? negtodo :
             (b[4:2] == 3'b011) ? doubletodo :
             (b[4:2] == 3'b100) ? negdoubletodo : 18'b0;
assign pp3 = (b[6:4] == 3'b001 || b[6:4] == 3'b010) ? todo :
             (b[6:4] == 3'b101 || b[6:4] == 3'b110)  ? negtodo :
             (b[6:4] == 3'b011) ? doubletodo :
             (b[6:4] == 3'b100) ? negdoubletodo : 18'b0;
assign pp4 = (b[8:6] == 3'b001 || b[8:6] == 3'b010) ? todo :
             (b[8:6] == 3'b101 || b[8:6] == 3'b110)  ? negtodo :
             (b[8:6] == 3'b011) ? doubletodo :
             (b[8:6] == 3'b100) ? negdoubletodo : 18'b0;
assign pp5 = (b[10:8] == 3'b001 || b[10:8] == 3'b010) ? todo :
             (b[10:8] == 3'b101 || b[10:8] == 3'b110)  ? negtodo :
             (b[10:8] == 3'b011) ? doubletodo :
             (b[10:8] == 3'b100) ? negdoubletodo : 18'b0;
assign pp6 = (b[12:10] == 3'b001 || b[12:10] == 3'b010) ? todo :
             (b[12:10] == 3'b101 || b[12:10] == 3'b110)  ? negtodo :
             (b[12:10] == 3'b011) ? doubletodo :
             (b[12:10] == 3'b100) ? negdoubletodo : 18'b0;
assign pp7 = (b[14:12] == 3'b001 || b[14:12] == 3'b010) ? todo :
             (b[14:12] == 3'b101 || b[14:12] == 3'b110)  ? negtodo :
             (b[14:12] == 3'b011) ? doubletodo :
             (b[14:12] == 3'b100) ? negdoubletodo : 18'b0;
assign pp8 = (b[16:14] == 3'b001 || b[16:14] == 3'b010) ? todo :
             (b[16:14] == 3'b101 || b[16:14] == 3'b110)  ? negtodo :
             (b[16:14] == 3'b011) ? doubletodo :
             (b[16:14] == 3'b100) ? negdoubletodo : 18'b0;                                                                              
assign pp9 = (b[18:16] == 3'b001 || b[18:16] == 3'b010) ? todo :
             (b[18:16] == 3'b101 || b[18:16] == 3'b110)  ? negtodo :
             (b[18:16] == 3'b011) ? doubletodo :
             (b[18:16] == 3'b100) ? negdoubletodo : 18'b0;
endmodule

module half_adder(input   wire a,
                  input   wire b,
		  output  wire s,
		  output  wire co);

  assign s  = a ^ b;
  assign co = a & b;
endmodule

module full_adder(input   wire a,
                  input   wire b,
		  input   wire ci,
		  output  wire s,
		  output  wire co);

  assign s  = a ^ b ^ ci;
  assign co = (a & b) | (a & ci) | (b & ci);
endmodule

module wtree_3to2_16x16(
    input   wire    [17:0]  pp1,
    input   wire    [17:0]  pp2,
    input   wire    [17:0]  pp3,
    input   wire    [17:0]  pp4,
    input   wire    [17:0]  pp5,
    input   wire    [17:0]  pp6,
    input   wire    [17:0]  pp7,
    input   wire    [17:0]  pp8,
    input   wire    [17:0]  pp9,
    output  wire    [31:0]  final_p
);

wire    [21:0]  a11data, a11carry;
assign a11data[1:0] = pp1[1:0];
assign a11carry[1:0] = 2'b0;
half_adder hadd_1_1_1 (.a(pp1[ 2]), .b(pp2[ 0]),               .s(a11data[ 2]), .co(a11carry[ 2])),
           hadd_1_1_2 (.a(pp1[ 3]), .b(pp2[ 1]),               .s(a11data[ 3]), .co(a11carry[ 3]));
full_adder fadd_1_1_1 (.a(pp1[ 4]), .b(pp2[ 2]), .ci(pp3[ 0]), .s(a11data[ 4]), .co(a11carry[ 4])),
           fadd_1_1_2 (.a(pp1[ 5]), .b(pp2[ 3]), .ci(pp3[ 1]), .s(a11data[ 5]), .co(a11carry[ 5])),
           fadd_1_1_3 (.a(pp1[ 6]), .b(pp2[ 4]), .ci(pp3[ 2]), .s(a11data[ 6]), .co(a11carry[ 6])),
           fadd_1_1_4 (.a(pp1[ 7]), .b(pp2[ 5]), .ci(pp3[ 3]), .s(a11data[ 7]), .co(a11carry[ 7])),
           fadd_1_1_5 (.a(pp1[ 8]), .b(pp2[ 6]), .ci(pp3[ 4]), .s(a11data[ 8]), .co(a11carry[ 8])),
           fadd_1_1_6 (.a(pp1[ 9]), .b(pp2[ 7]), .ci(pp3[ 5]), .s(a11data[ 9]), .co(a11carry[ 9])),
           fadd_1_1_7 (.a(pp1[10]), .b(pp2[ 8]), .ci(pp3[ 6]), .s(a11data[10]), .co(a11carry[10])),
           fadd_1_1_8 (.a(pp1[11]), .b(pp2[ 9]), .ci(pp3[ 7]), .s(a11data[11]), .co(a11carry[11])),
           fadd_1_1_9 (.a(pp1[12]), .b(pp2[10]), .ci(pp3[ 8]), .s(a11data[12]), .co(a11carry[12])),
           fadd_1_1_10(.a(pp1[13]), .b(pp2[11]), .ci(pp3[ 9]), .s(a11data[13]), .co(a11carry[13])),
           fadd_1_1_11(.a(pp1[14]), .b(pp2[12]), .ci(pp3[10]), .s(a11data[14]), .co(a11carry[14])),
           fadd_1_1_12(.a(pp1[15]), .b(pp2[13]), .ci(pp3[11]), .s(a11data[15]), .co(a11carry[15])),
           fadd_1_1_13(.a(pp1[16]), .b(pp2[14]), .ci(pp3[12]), .s(a11data[16]), .co(a11carry[16])),
           fadd_1_1_14(.a(pp1[17]), .b(pp2[15]), .ci(pp3[13]), .s(a11data[17]), .co(a11carry[17])),
           fadd_1_1_15(.a(pp1[17]), .b(pp2[16]), .ci(pp3[14]), .s(a11data[18]), .co(a11carry[18])),
           fadd_1_1_16(.a(pp1[17]), .b(pp2[17]), .ci(pp3[15]), .s(a11data[19]), .co(a11carry[19])),
           fadd_1_1_17(.a(pp1[17]), .b(pp2[17]), .ci(pp3[16]), .s(a11data[20]), .co(a11carry[20])),
           fadd_1_1_18(.a(pp1[17]), .b(pp2[17]), .ci(pp3[17]), .s(a11data[21]), .co(a11carry[21]));
wire    [21:0]  a12data, a12carry;
assign a12data[1:0] = pp4[1:0];
assign a12carry[1:0] = 2'b0;
half_adder hadd_1_2_1 (.a(pp4[ 2]), .b(pp5[ 0]),               .s(a12data[ 2]), .co(a12carry[ 2])),
           hadd_1_2_2 (.a(pp4[ 3]), .b(pp5[ 1]),               .s(a12data[ 3]), .co(a12carry[ 3]));
full_adder fadd_1_2_1 (.a(pp4[ 4]), .b(pp5[ 2]), .ci(pp6[ 0]), .s(a12data[ 4]), .co(a12carry[ 4])),
           fadd_1_2_2 (.a(pp4[ 5]), .b(pp5[ 3]), .ci(pp6[ 1]), .s(a12data[ 5]), .co(a12carry[ 5])),
           fadd_1_2_3 (.a(pp4[ 6]), .b(pp5[ 4]), .ci(pp6[ 2]), .s(a12data[ 6]), .co(a12carry[ 6])),
           fadd_1_2_4 (.a(pp4[ 7]), .b(pp5[ 5]), .ci(pp6[ 3]), .s(a12data[ 7]), .co(a12carry[ 7])),
           fadd_1_2_5 (.a(pp4[ 8]), .b(pp5[ 6]), .ci(pp6[ 4]), .s(a12data[ 8]), .co(a12carry[ 8])),
           fadd_1_2_6 (.a(pp4[ 9]), .b(pp5[ 7]), .ci(pp6[ 5]), .s(a12data[ 9]), .co(a12carry[ 9])),
           fadd_1_2_7 (.a(pp4[10]), .b(pp5[ 8]), .ci(pp6[ 6]), .s(a12data[10]), .co(a12carry[10])),
           fadd_1_2_8 (.a(pp4[11]), .b(pp5[ 9]), .ci(pp6[ 7]), .s(a12data[11]), .co(a12carry[11])),
           fadd_1_2_9 (.a(pp4[12]), .b(pp5[10]), .ci(pp6[ 8]), .s(a12data[12]), .co(a12carry[12])),
           fadd_1_2_10(.a(pp4[13]), .b(pp5[11]), .ci(pp6[ 9]), .s(a12data[13]), .co(a12carry[13])),
           fadd_1_2_11(.a(pp4[14]), .b(pp5[12]), .ci(pp6[10]), .s(a12data[14]), .co(a12carry[14])),
           fadd_1_2_12(.a(pp4[15]), .b(pp5[13]), .ci(pp6[11]), .s(a12data[15]), .co(a12carry[15])),
           fadd_1_2_13(.a(pp4[16]), .b(pp5[14]), .ci(pp6[12]), .s(a12data[16]), .co(a12carry[16])),
           fadd_1_2_14(.a(pp4[17]), .b(pp5[15]), .ci(pp6[13]), .s(a12data[17]), .co(a12carry[17])),
           fadd_1_2_15(.a(pp4[17]), .b(pp5[16]), .ci(pp6[14]), .s(a12data[18]), .co(a12carry[18])),
           fadd_1_2_16(.a(pp4[17]), .b(pp5[17]), .ci(pp6[15]), .s(a12data[19]), .co(a12carry[19])),
           fadd_1_2_17(.a(pp4[17]), .b(pp5[17]), .ci(pp6[16]), .s(a12data[20]), .co(a12carry[20])),
           fadd_1_2_18(.a(pp4[17]), .b(pp5[17]), .ci(pp6[17]), .s(a12data[21]), .co(a12carry[21]));
wire    [19:0]  a13data, a13carry;
assign a13data[1:0] = pp7[1:0];
assign a13carry[1:0] = 2'b0;
half_adder hadd_1_3_1 (.a(pp7[ 2]), .b(pp8[ 0]),               .s(a13data[ 2]), .co(a13carry[ 2])),
           hadd_1_3_2 (.a(pp7[ 3]), .b(pp8[ 1]),               .s(a13data[ 3]), .co(a13carry[ 3]));
full_adder fadd_1_3_1 (.a(pp7[ 4]), .b(pp8[ 2]), .ci(pp9[ 0]), .s(a13data[ 4]), .co(a13carry[ 4])),
           fadd_1_3_2 (.a(pp7[ 5]), .b(pp8[ 3]), .ci(pp9[ 1]), .s(a13data[ 5]), .co(a13carry[ 5])),
           fadd_1_3_3 (.a(pp7[ 6]), .b(pp8[ 4]), .ci(pp9[ 2]), .s(a13data[ 6]), .co(a13carry[ 6])),
           fadd_1_3_4 (.a(pp7[ 7]), .b(pp8[ 5]), .ci(pp9[ 3]), .s(a13data[ 7]), .co(a13carry[ 7])),
           fadd_1_3_5 (.a(pp7[ 8]), .b(pp8[ 6]), .ci(pp9[ 4]), .s(a13data[ 8]), .co(a13carry[ 8])),
           fadd_1_3_6 (.a(pp7[ 9]), .b(pp8[ 7]), .ci(pp9[ 5]), .s(a13data[ 9]), .co(a13carry[ 9])),
           fadd_1_3_7 (.a(pp7[10]), .b(pp8[ 8]), .ci(pp9[ 6]), .s(a13data[10]), .co(a13carry[10])),
           fadd_1_3_8 (.a(pp7[11]), .b(pp8[ 9]), .ci(pp9[ 7]), .s(a13data[11]), .co(a13carry[11])),
           fadd_1_3_9 (.a(pp7[12]), .b(pp8[10]), .ci(pp9[ 8]), .s(a13data[12]), .co(a13carry[12])),
           fadd_1_3_10(.a(pp7[13]), .b(pp8[11]), .ci(pp9[ 9]), .s(a13data[13]), .co(a13carry[13])),
           fadd_1_3_11(.a(pp7[14]), .b(pp8[12]), .ci(pp9[10]), .s(a13data[14]), .co(a13carry[14])),
           fadd_1_3_12(.a(pp7[15]), .b(pp8[13]), .ci(pp9[11]), .s(a13data[15]), .co(a13carry[15])),
           fadd_1_3_13(.a(pp7[16]), .b(pp8[14]), .ci(pp9[12]), .s(a13data[16]), .co(a13carry[16])),
           fadd_1_3_14(.a(pp7[17]), .b(pp8[15]), .ci(pp9[13]), .s(a13data[17]), .co(a13carry[17])),
           fadd_1_3_15(.a(pp7[17]), .b(pp8[16]), .ci(pp9[14]), .s(a13data[18]), .co(a13carry[18])),
           fadd_1_3_16(.a(pp7[17]), .b(pp8[17]), .ci(pp9[15]), .s(a13data[19]), .co(a13carry[19]));

wire    [27:0]  a21data, a21carry;
assign a21data[0] = a11data[0];
assign a21carry[0] = 1'b0;
half_adder hadd_2_1_1 (.a(a11data[ 1]), .b(a11carry[ 0]),               .s(a21data[ 1]), .co(a21carry[ 1])),
           hadd_2_1_2 (.a(a11data[ 2]), .b(a11carry[ 1]),               .s(a21data[ 2]), .co(a21carry[ 2])),
           hadd_2_1_3 (.a(a11data[ 3]), .b(a11carry[ 2]),               .s(a21data[ 3]), .co(a21carry[ 3])),
           hadd_2_1_4 (.a(a11data[ 4]), .b(a11carry[ 3]),               .s(a21data[ 4]), .co(a21carry[ 4])),
           hadd_2_1_5 (.a(a11data[ 5]), .b(a11carry[ 4]),               .s(a21data[ 5]), .co(a21carry[ 5]));
full_adder fadd_2_1_1 (.a(a11data[ 6]), .b(a11carry[ 5]), .ci(a12data[ 0]), .s(a21data[ 6]), .co(a21carry[ 6])),
           fadd_2_1_2 (.a(a11data[ 7]), .b(a11carry[ 6]), .ci(a12data[ 1]), .s(a21data[ 7]), .co(a21carry[ 7])),
           fadd_2_1_3 (.a(a11data[ 8]), .b(a11carry[ 7]), .ci(a12data[ 2]), .s(a21data[ 8]), .co(a21carry[ 8])),
           fadd_2_1_4 (.a(a11data[ 9]), .b(a11carry[ 8]), .ci(a12data[ 3]), .s(a21data[ 9]), .co(a21carry[ 9])),
           fadd_2_1_5 (.a(a11data[10]), .b(a11carry[ 9]), .ci(a12data[ 4]), .s(a21data[10]), .co(a21carry[10])),
           fadd_2_1_6 (.a(a11data[11]), .b(a11carry[10]), .ci(a12data[ 5]), .s(a21data[11]), .co(a21carry[11])),
           fadd_2_1_7 (.a(a11data[12]), .b(a11carry[11]), .ci(a12data[ 6]), .s(a21data[12]), .co(a21carry[12])),
           fadd_2_1_8 (.a(a11data[13]), .b(a11carry[12]), .ci(a12data[ 7]), .s(a21data[13]), .co(a21carry[13])),
           fadd_2_1_9 (.a(a11data[14]), .b(a11carry[13]), .ci(a12data[ 8]), .s(a21data[14]), .co(a21carry[14])),
           fadd_2_1_10(.a(a11data[15]), .b(a11carry[14]), .ci(a12data[ 9]), .s(a21data[15]), .co(a21carry[15])),
           fadd_2_1_11(.a(a11data[16]), .b(a11carry[15]), .ci(a12data[10]), .s(a21data[16]), .co(a21carry[16])),
           fadd_2_1_12(.a(a11data[17]), .b(a11carry[16]), .ci(a12data[11]), .s(a21data[17]), .co(a21carry[17])),
           fadd_2_1_13(.a(a11data[18]), .b(a11carry[17]), .ci(a12data[12]), .s(a21data[18]), .co(a21carry[18])),
           fadd_2_1_14(.a(a11data[19]), .b(a11carry[18]), .ci(a12data[13]), .s(a21data[19]), .co(a21carry[19])),
           fadd_2_1_15(.a(a11data[20]), .b(a11carry[19]), .ci(a12data[14]), .s(a21data[20]), .co(a21carry[20])),
           fadd_2_1_16(.a(a11data[21]), .b(a11carry[20]), .ci(a12data[15]), .s(a21data[21]), .co(a21carry[21])),
           fadd_2_1_17(.a(a11data[21]), .b(a11carry[21]), .ci(a12data[16]), .s(a21data[22]), .co(a21carry[22])),
           fadd_2_1_18(.a(a11data[21]), .b(a11carry[21]), .ci(a12data[17]), .s(a21data[23]), .co(a21carry[23])),
           fadd_2_1_19(.a(a11data[21]), .b(a11carry[21]), .ci(a12data[18]), .s(a21data[24]), .co(a21carry[24])),
           fadd_2_1_20(.a(a11data[21]), .b(a11carry[21]), .ci(a12data[19]), .s(a21data[25]), .co(a21carry[25])),
           fadd_2_1_21(.a(a11data[21]), .b(a11carry[21]), .ci(a12data[20]), .s(a21data[26]), .co(a21carry[26])),
           fadd_2_1_22(.a(a11data[21]), .b(a11carry[21]), .ci(a12data[21]), .s(a21data[27]), .co(a21carry[27]));

wire    [24:0]  a22data, a22carry;
assign a22data[4:0] = a12carry[4:0];
assign a22carry[4:0] = 5'b0;
half_adder hadd_2_2_1 (.a(a12carry[ 5]), .b(a13data[ 0]),                    .s(a22data[ 5]), .co(a22carry[ 5]));
full_adder fadd_2_2_1 (.a(a12carry[ 6]), .b(a13data[ 1]), .ci(a13carry[ 0]), .s(a22data[ 6]), .co(a22carry[ 6])),
           fadd_2_2_2 (.a(a12carry[ 7]), .b(a13data[ 2]), .ci(a13carry[ 1]), .s(a22data[ 7]), .co(a22carry[ 7])),
           fadd_2_2_3 (.a(a12carry[ 8]), .b(a13data[ 3]), .ci(a13carry[ 2]), .s(a22data[ 8]), .co(a22carry[ 8])),
           fadd_2_2_4 (.a(a12carry[ 9]), .b(a13data[ 4]), .ci(a13carry[ 3]), .s(a22data[ 9]), .co(a22carry[ 9])),
           fadd_2_2_5 (.a(a12carry[10]), .b(a13data[ 5]), .ci(a13carry[ 4]), .s(a22data[10]), .co(a22carry[10])),
           fadd_2_2_6 (.a(a12carry[11]), .b(a13data[ 6]), .ci(a13carry[ 5]), .s(a22data[11]), .co(a22carry[11])),
           fadd_2_2_7 (.a(a12carry[12]), .b(a13data[ 7]), .ci(a13carry[ 6]), .s(a22data[12]), .co(a22carry[12])),
           fadd_2_2_8 (.a(a12carry[13]), .b(a13data[ 8]), .ci(a13carry[ 7]), .s(a22data[13]), .co(a22carry[13])),
           fadd_2_2_9 (.a(a12carry[14]), .b(a13data[ 9]), .ci(a13carry[ 8]), .s(a22data[14]), .co(a22carry[14])),
           fadd_2_2_10(.a(a12carry[15]), .b(a13data[10]), .ci(a13carry[ 9]), .s(a22data[15]), .co(a22carry[15])),
           fadd_2_2_11(.a(a12carry[16]), .b(a13data[11]), .ci(a13carry[10]), .s(a22data[16]), .co(a22carry[16])),
           fadd_2_2_12(.a(a12carry[17]), .b(a13data[12]), .ci(a13carry[11]), .s(a22data[17]), .co(a22carry[17])),
           fadd_2_2_13(.a(a12carry[18]), .b(a13data[13]), .ci(a13carry[12]), .s(a22data[18]), .co(a22carry[18])),
           fadd_2_2_14(.a(a12carry[19]), .b(a13data[14]), .ci(a13carry[13]), .s(a22data[19]), .co(a22carry[19])),
           fadd_2_2_15(.a(a12carry[20]), .b(a13data[15]), .ci(a13carry[14]), .s(a22data[20]), .co(a22carry[20])),
           fadd_2_2_16(.a(a12carry[21]), .b(a13data[16]), .ci(a13carry[15]), .s(a22data[21]), .co(a22carry[21])),
           fadd_2_2_17(.a(a12carry[21]), .b(a13data[17]), .ci(a13carry[16]), .s(a22data[22]), .co(a22carry[22])),
           fadd_2_2_18(.a(a12carry[21]), .b(a13data[18]), .ci(a13carry[17]), .s(a22data[23]), .co(a22carry[23])),
           fadd_2_2_19(.a(a12carry[21]), .b(a13data[19]), .ci(a13carry[18]), .s(a22data[24]), .co(a22carry[24]));

wire    [31:0]  a31data, a31carry;
assign a31data[0] = a21data[0];
assign a31carry[0] = 1'b0;
half_adder hadd_3_1_1 (.a(a21data[ 1]), .b(a21carry[ 0]),                   .s(a31data[ 1]), .co(a31carry[ 1])),
           hadd_3_1_2 (.a(a21data[ 2]), .b(a21carry[ 1]),                   .s(a31data[ 2]), .co(a31carry[ 2])),
           hadd_3_1_3 (.a(a21data[ 3]), .b(a21carry[ 2]),                   .s(a31data[ 3]), .co(a31carry[ 3])),
           hadd_3_1_4 (.a(a21data[ 4]), .b(a21carry[ 3]),                   .s(a31data[ 4]), .co(a31carry[ 4])),
           hadd_3_1_5 (.a(a21data[ 5]), .b(a21carry[ 4]),                   .s(a31data[ 5]), .co(a31carry[ 5])),
           hadd_3_1_6 (.a(a21data[ 6]), .b(a21carry[ 5]),                   .s(a31data[ 6]), .co(a31carry[ 6]));
full_adder fadd_3_1_1 (.a(a21data[ 7]), .b(a21carry[ 6]), .ci(a22data[ 0]), .s(a31data[ 7]), .co(a31carry[ 7])),
           fadd_3_1_2 (.a(a21data[ 8]), .b(a21carry[ 7]), .ci(a22data[ 1]), .s(a31data[ 8]), .co(a31carry[ 8])),
           fadd_3_1_3 (.a(a21data[ 9]), .b(a21carry[ 8]), .ci(a22data[ 2]), .s(a31data[ 9]), .co(a31carry[ 9])),
           fadd_3_1_4 (.a(a21data[10]), .b(a21carry[ 9]), .ci(a22data[ 3]), .s(a31data[10]), .co(a31carry[10])),
           fadd_3_1_5 (.a(a21data[11]), .b(a21carry[10]), .ci(a22data[ 4]), .s(a31data[11]), .co(a31carry[11])),
           fadd_3_1_6 (.a(a21data[12]), .b(a21carry[11]), .ci(a22data[ 5]), .s(a31data[12]), .co(a31carry[12])),
           fadd_3_1_7 (.a(a21data[13]), .b(a21carry[12]), .ci(a22data[ 6]), .s(a31data[13]), .co(a31carry[13])),
           fadd_3_1_8 (.a(a21data[14]), .b(a21carry[13]), .ci(a22data[ 7]), .s(a31data[14]), .co(a31carry[14])),
           fadd_3_1_9 (.a(a21data[15]), .b(a21carry[14]), .ci(a22data[ 8]), .s(a31data[15]), .co(a31carry[15])),
           fadd_3_1_10(.a(a21data[16]), .b(a21carry[15]), .ci(a22data[ 9]), .s(a31data[16]), .co(a31carry[16])),
           fadd_3_1_11(.a(a21data[17]), .b(a21carry[16]), .ci(a22data[10]), .s(a31data[17]), .co(a31carry[17])),
           fadd_3_1_12(.a(a21data[18]), .b(a21carry[17]), .ci(a22data[11]), .s(a31data[18]), .co(a31carry[18])),
           fadd_3_1_13(.a(a21data[19]), .b(a21carry[18]), .ci(a22data[12]), .s(a31data[19]), .co(a31carry[19])),
           fadd_3_1_14(.a(a21data[20]), .b(a21carry[19]), .ci(a22data[13]), .s(a31data[20]), .co(a31carry[20])),
           fadd_3_1_15(.a(a21data[21]), .b(a21carry[20]), .ci(a22data[14]), .s(a31data[21]), .co(a31carry[21])),
           fadd_3_1_16(.a(a21data[22]), .b(a21carry[21]), .ci(a22data[15]), .s(a31data[22]), .co(a31carry[22])),
           fadd_3_1_17(.a(a21data[23]), .b(a21carry[22]), .ci(a22data[16]), .s(a31data[23]), .co(a31carry[23])),
           fadd_3_1_18(.a(a21data[24]), .b(a21carry[23]), .ci(a22data[17]), .s(a31data[24]), .co(a31carry[24])),
           fadd_3_1_19(.a(a21data[25]), .b(a21carry[24]), .ci(a22data[18]), .s(a31data[25]), .co(a31carry[25])),
           fadd_3_1_20(.a(a21data[26]), .b(a21carry[25]), .ci(a22data[19]), .s(a31data[26]), .co(a31carry[26])),
           fadd_3_1_21(.a(a21data[27]), .b(a21carry[26]), .ci(a22data[20]), .s(a31data[27]), .co(a31carry[27])),
           fadd_3_1_22(.a(a21data[27]), .b(a21carry[27]), .ci(a22data[21]), .s(a31data[28]), .co(a31carry[28])),
           fadd_3_1_23(.a(a21data[27]), .b(a21carry[27]), .ci(a22data[22]), .s(a31data[29]), .co(a31carry[29])),
           fadd_3_1_24(.a(a21data[27]), .b(a21carry[27]), .ci(a22data[23]), .s(a31data[30]), .co(a31carry[30])),
           fadd_3_1_25(.a(a21data[27]), .b(a21carry[27]), .ci(a22data[24]), .s(a31data[31]), .co(a31carry[31]));

wire    [31:0]  a41data, a41carry;
assign a41data[0] = a31data[0];
assign a41carry[0] = 1'b0;
half_adder hadd_4_1_1 (.a(a31data[ 1]), .b(a31carry[ 0]),                    .s(a41data[ 1]), .co(a41carry[ 1])),
           hadd_4_1_2 (.a(a31data[ 2]), .b(a31carry[ 1]),                    .s(a41data[ 2]), .co(a41carry[ 2])),
           hadd_4_1_3 (.a(a31data[ 3]), .b(a31carry[ 2]),                    .s(a41data[ 3]), .co(a41carry[ 3])),
           hadd_4_1_4 (.a(a31data[ 4]), .b(a31carry[ 3]),                    .s(a41data[ 4]), .co(a41carry[ 4])),
           hadd_4_1_5 (.a(a31data[ 5]), .b(a31carry[ 4]),                    .s(a41data[ 5]), .co(a41carry[ 5])),
           hadd_4_1_6 (.a(a31data[ 6]), .b(a31carry[ 5]),                    .s(a41data[ 6]), .co(a41carry[ 6])),
           hadd_4_1_7 (.a(a31data[ 7]), .b(a31carry[ 6]),                    .s(a41data[ 7]), .co(a41carry[ 7]));
full_adder fadd_4_1_1 (.a(a31data[ 8]), .b(a31carry[ 7]), .ci(a22carry[ 0]), .s(a41data[ 8]), .co(a41carry[ 8])),
           fadd_4_1_2 (.a(a31data[ 9]), .b(a31carry[ 8]), .ci(a22carry[ 1]), .s(a41data[ 9]), .co(a41carry[ 9])),
           fadd_4_1_3 (.a(a31data[10]), .b(a31carry[ 9]), .ci(a22carry[ 2]), .s(a41data[10]), .co(a41carry[10])),
           fadd_4_1_4 (.a(a31data[11]), .b(a31carry[10]), .ci(a22carry[ 3]), .s(a41data[11]), .co(a41carry[11])),
           fadd_4_1_5 (.a(a31data[12]), .b(a31carry[11]), .ci(a22carry[ 4]), .s(a41data[12]), .co(a41carry[12])),
           fadd_4_1_6 (.a(a31data[13]), .b(a31carry[12]), .ci(a22carry[ 5]), .s(a41data[13]), .co(a41carry[13])),
           fadd_4_1_7 (.a(a31data[14]), .b(a31carry[13]), .ci(a22carry[ 6]), .s(a41data[14]), .co(a41carry[14])),
           fadd_4_1_8 (.a(a31data[15]), .b(a31carry[14]), .ci(a22carry[ 7]), .s(a41data[15]), .co(a41carry[15])),
           fadd_4_1_9 (.a(a31data[16]), .b(a31carry[15]), .ci(a22carry[ 8]), .s(a41data[16]), .co(a41carry[16])),
           fadd_4_1_10(.a(a31data[17]), .b(a31carry[16]), .ci(a22carry[ 9]), .s(a41data[17]), .co(a41carry[17])),
           fadd_4_1_11(.a(a31data[18]), .b(a31carry[17]), .ci(a22carry[10]), .s(a41data[18]), .co(a41carry[18])),
           fadd_4_1_12(.a(a31data[19]), .b(a31carry[18]), .ci(a22carry[11]), .s(a41data[19]), .co(a41carry[19])),
           fadd_4_1_13(.a(a31data[20]), .b(a31carry[19]), .ci(a22carry[12]), .s(a41data[20]), .co(a41carry[20])),
           fadd_4_1_14(.a(a31data[21]), .b(a31carry[20]), .ci(a22carry[13]), .s(a41data[21]), .co(a41carry[21])),
           fadd_4_1_15(.a(a31data[22]), .b(a31carry[21]), .ci(a22carry[14]), .s(a41data[22]), .co(a41carry[22])),
           fadd_4_1_16(.a(a31data[23]), .b(a31carry[22]), .ci(a22carry[15]), .s(a41data[23]), .co(a41carry[23])),
           fadd_4_1_17(.a(a31data[24]), .b(a31carry[23]), .ci(a22carry[16]), .s(a41data[24]), .co(a41carry[24])),
           fadd_4_1_18(.a(a31data[25]), .b(a31carry[24]), .ci(a22carry[17]), .s(a41data[25]), .co(a41carry[25])),
           fadd_4_1_19(.a(a31data[26]), .b(a31carry[25]), .ci(a22carry[18]), .s(a41data[26]), .co(a41carry[26])),
           fadd_4_1_20(.a(a31data[27]), .b(a31carry[26]), .ci(a22carry[19]), .s(a41data[27]), .co(a41carry[27])),
           fadd_4_1_21(.a(a31data[28]), .b(a31carry[27]), .ci(a22carry[20]), .s(a41data[28]), .co(a41carry[28])),
           fadd_4_1_22(.a(a31data[29]), .b(a31carry[28]), .ci(a22carry[21]), .s(a41data[29]), .co(a41carry[29])),
           fadd_4_1_23(.a(a31data[30]), .b(a31carry[29]), .ci(a22carry[22]), .s(a41data[30]), .co(a41carry[30])),
           fadd_4_1_24(.a(a31data[31]), .b(a31carry[30]), .ci(a22carry[23]), .s(a41data[31]), .co(a41carry[31]));

assign final_p = a41data + {a41carry[30:0], 1'b0};
endmodule





module multi16x16(
    input   wire    a_signed,
    input   wire    b_signed,
    input   wire    [15:0]  mula,
    input   wire    [15:0]  mulb,
    output  wire    [31:0]  out
);
wire [17:0] pp1, pp2, pp3, pp4, pp5, pp6, pp7, pp8, pp9;
booth_16x16 booth1(
    .a_signed(a_signed),
    .b_signed(b_signed),
    .mul_a(mula),
    .mul_b(mulb),
    .pp1(pp1),
    .pp2(pp2),
    .pp3(pp3),
    .pp4(pp4),
    .pp5(pp5),
    .pp6(pp6),
    .pp7(pp7),
    .pp8(pp8),
    .pp9(pp9)
    );

wtree_3to2_16x16 tree(
    .pp1(pp1),
    .pp2(pp2),
    .pp3(pp3),
    .pp4(pp4),
    .pp5(pp5),
    .pp6(pp6),
    .pp7(pp7),
    .pp8(pp8),
    .pp9(pp9),
    .final_p(out)
    );
endmodule