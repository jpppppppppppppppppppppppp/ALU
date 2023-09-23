module float_adder(
    input   clk,
    input   rst,
    input   [31:0]  x,
    input   [31:0]  y,
    output  reg [31:0]  z,
    output  reg [1:0]   overflow//2'b00:没有溢出    2'b01:上溢  2'b10:下溢  2'b11:输入不是规格数
);
    reg [24:0]  m_x, m_y, m_z;
    reg [7:0]   exp_x, exp_y, exp_z;
    reg [2:0]   state_now, state_next;
    reg sign_x, sign_y, sign_z;

    reg [24:0] out_x,out_y,mid_y,mid_x;
    reg [7:0] move_tot;
    reg [2:0] bigger;

    parameter start = 3'b000, zerocheck = 3'b001, equalcheck = 3'b010, addm = 3'b011, normal = 3'b100, over = 3'b110;

    always @(posedge clk) begin
        if(!rst)begin
            state_now <= start;
        end
        else begin
            state_now <= state_next;
        end
    end

    always @(state_now, state_next, exp_x, exp_y, exp_z, m_x, m_y, m_z, out_x, out_y, mid_x, mid_y) begin
        case(state_now)
            start:
                begin
                    bigger <= 2'b00;
                    exp_x <= x[30:23];
                    exp_y <= y[30:23];
                    m_x <= {1'b0, 1'b1, x[22:0]};
                    m_y <= {1'b0, 1'b1, y[22:0]};
                    out_x <= 25'b0;
                    out_y <= 25'b0;
                    move_tot <= 8'b0;
                    mid_y<={24'b0,1'b1};
                    mid_x<={24'b0,1'b1};
                    //判断规格化浮点数，只有指数属于[1,254]以及实数0是规格化浮点数
                    if((exp_x == 8'd255 && m_x[22:0] != 0) || (exp_y == 8'd255 && m_y[22:0] != 0))//出现了NaN，结果返回NaN
                        begin
                            overflow <= 2'b11;
                            state_next <= over;
                            sign_z <= 1'b1;
                            exp_z <= 8'b11111111;
                            m_z <= 23'b11111111111111111111111;
                        end
                    else if((exp_x == 8'd255 && m_x[22:0] == 0) || (exp_y == 8'd255 && m_y[22:0] == 0))//出现了无穷大，结果返回无穷大
                        begin
                            overflow <= 2'b11;
                            state_next <= over;
                            sign_z <= 1'b0;
                            exp_z <= 8'b11111111;
                            m_z <= 23'b0;
                        end
                    else
                        begin
                            overflow <= 2'b00;
                            state_next <= zerocheck;
                        end
                end
            zerocheck:
                begin
                    if(m_x[22:0] == 23'b0 && exp_x == 8'b0)
                        begin
                            sign_z <= y[31];
                            exp_z <= exp_y;
                            m_z <= m_y;
                            state_next <= over;
                        end
                    else if(m_y[22:0] == 23'b0 && exp_y == 8'b0)
                        begin
                            sign_z <= x[31];
                            exp_z <= exp_x;
                            m_z <= m_x;
                            state_next <= over;
                        end
                    else
                        begin
                            state_next <= equalcheck;
                        end
                    //以下为非规格化数字的处理，需要把预装填的1清除
                    if(m_x[22:0] != 23'b0 && exp_x == 8'b0)
                        begin
                            m_x <= {1'b0, 1'b0, x[22:0]};
                        end
                    if(m_y[22:0] != 23'b0 && exp_y == 8'b0)
                        begin
                            m_y <= {1'b0, 1'b0, y[22:0]};
                        end
                end
            equalcheck:
                begin
                    if(exp_x == exp_y)
                        begin
                            if(bigger == 2'b0)
                                begin
                                    state_next <= addm;//指数对齐，进入尾数相加阶段
                                end
                            else if(bigger == 2'b10)
                                begin
                                    if(out_y > mid_y)
                                        begin
                                            m_y <= m_y + 1'b1;
                                        end 
                                    else if(out_y < mid_y)
                                        begin
                                            m_y <= m_y;
                                        end
                                    else if(out_y == m_y)
                                        begin
                                            if(m_y[0] == 1)
                                                begin
                                                    m_y <= m_y + 1'b1;
                                                end
                                            else
                                                begin
                                                    m_y <= m_y;
                                                end
                                        end
                                    state_next <= addm;
                                end
                            else if(bigger == 2'b01)
                                begin
                                    if(out_x > mid_x)
                                        begin
                                            m_x <= m_x + 1'b1;
                                        end 
                                    else if(out_x < mid_x)
                                        begin
                                            m_x <= m_x;
                                        end
                                    else if(out_x == m_x)
                                        begin
                                            if(m_x[0] == 1)
                                                begin
                                                    m_x <= m_x + 1'b1;
                                                end
                                            else
                                                begin
                                                    m_x <= m_x;
                                                end
                                        end
                                    state_next <= addm;
                                end
                        end
                    else
                        begin
                            if(exp_x > exp_y)
                                begin
                                    bigger <= 2'b01;
                                    exp_y <= exp_y + 1'b1;
                                    m_y[23:0] <= {1'b0, m_y[23:1]};
                                    out_y[move_tot] <= m_y[0];
                                    mid_y = {mid_y[23:0], mid_y[24]};
                                    move_tot <= move_tot + 1'b1;
                                    if(m_y == 24'b0)//指数相差太大，导致尾数全为0
                                        begin
                                            sign_z <= sign_x;
                                            exp_z <= exp_x;
                                            m_z <= m_x;
                                            state_next <= over;
                                        end
                                    else
                                        begin
                                            state_next <= equalcheck;
                                        end
                                end 
                            else
                                begin
                                    bigger <= 2'b10;
                                    exp_x <= exp_x + 1'b1;
                                    m_x[23:0] <= {1'b0, m_x[23:1]};
                                    out_x[move_tot] <= m_x[0];
                                    mid_x = {mid_x[23:0], mid_x[24]};
                                    move_tot <= move_tot + 1'b1;
                                    if(m_x == 24'b0)//指数相差太大，导致尾数全为0
                                        begin
                                            sign_z <= sign_y;
                                            exp_z <= exp_y;
                                            m_z <= m_y;
                                            state_next <= over;
                                        end
                                    else
                                        begin
                                            state_next <= equalcheck;
                                        end
                                end
                        end
                end
            addm:
                begin
                    if(x[31] ^ y[31] == 1'b0)
                        begin
                            exp_z <= exp_x;
                            sign_z <= x[31];
                            m_z <= m_x + m_y;
                            state_next <= normal;
                        end 
                    else
                        begin
                            if(m_x > m_y)
                                begin
                                    exp_z <= exp_x;
                                    sign_z <= x[31];
                                    m_z <= m_x - m_y;
                                    state_next <= normal;
                                end
                            else if(m_x < m_y)
                                begin
                                    exp_z <= exp_y;
                                    sign_z <= y[31];
                                    m_z <= m_y - m_x;
                                    state_next <= normal;
                                end
                            else
                                begin
                                    exp_z <= exp_x;
                                    m_z <= 23'b0;
                                    state_next <= over;
                                end
                        end
                end
            normal:
                begin
                    if(m_z[24] == 1'b1)
                        begin
                            if(m_z[0] == 1)
                                begin
                                    m_z <= m_z + 1'b1;
                                    m_z[0] <= 0;
                                    state_next <= normal;
                                end
                            else
                                begin
                                     m_z <= {1'b0, m_z[24:1]};
                                    exp_z <= exp_z + 1'b1;
                                    state_next <= over;
                                end
                        end 
                    else
                        begin
                            if(m_z[23] == 1'b0 && exp_z >= 1)
                                begin
                                    m_z <= {m_z[23:1], 1'b0};
                                    exp_z <= exp_z - 1'b1;
                                    state_next <= normal;
                                end 
                            else
                                begin
                                    state_next <= over;
                                end
                        end
                end
            over:
                begin
                    z = {sign_z, exp_z[7:0], m_z[22:0]};
                    if(overflow)
                        begin
                            overflow <= overflow;
                            state_next <= start;
                        end
                    else if(exp_z == 8'd255)
                        begin
                            overflow <= 2'b01;
                            state_next <= start;
                        end
                    else if(exp_z == 8'd0 && m_z[22:0] != 23'b0)
                        begin
                            overflow <= 2'b10;
                            state_next <= start;
                        end
                    else
                        begin
                            overflow <= 2'b0;
                            state_next <= start;
                        end
                end
            default:
                begin
                    state_next <= start;
                end
        endcase    
    end
endmodule