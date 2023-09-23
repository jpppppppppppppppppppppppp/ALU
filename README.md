# 浮点数加法器

## 基本要素

- 浮点数的格式：符号位 $1$ 位，阶码 $8$ 位，尾数 $23$ 位。

- 浮点数计算的五个步骤：对阶、尾数求和、规格化、舍入、溢出判断

​	IEEE 754浮点数的尾数是**规格化**的，其范围为 $1.000\dots0\times 2^{e}$ 到 $1.11111\dots1\times2^e$ ，其中 $e$ 为指数。规格化浮点数的最高位一定是 $1$ ，使尾数的所有位都是有效的，因而精度更高。除非这个浮点数是0，此时尾数全为0

​	

|      描述      |     指数     |    小数     |               值                |       十进制        |
| :------------: | :----------: | :---------: | :-----------------------------: | :-----------------: |
|       0        | $00\cdots00$ | $0\cdots00$ |                0                |         0.0         |
|       1        | $01\cdots11$ | $0\cdots00$ |          $1\times2^0$           |         1.0         |
| 最小非格式化数 | $00\cdots00$ | $0\cdots01$ |     $2^{-23}\times2^{-126}$     | $1.4\times10^{-45}$ |
| 最大非格式化数 | $00\cdots00$ | $1\cdots11$ | $(1-\varepsilon)\times2^{-126}$ | $1.2\times10^{-38}$ |
|  最小格式化数  | $00\cdots01$ | $0\cdots00$ |        $1\times2^{-126}$        | $1.2\times10^{-38}$ |
|  最大格式化数  | $11\cdots10$ | $1\cdots11$ | $(2-\varepsilon)\times2^{127}$  | $3.4\times10^{38}$  |

- 指数 $E=0$ 
  - 小数 $F=0$ ，正 $0$ 或负 $0$ 的表示
  - 小数 $F\not=0$ ，非规格化渐进式下溢区
- 指数 $1\leq E\leq 254$ ，规格化浮点数范围
- 指数 $E=255$
  - 小数 $F=0$ ，正无穷或负无穷
  - 小数 $F\not=0$ ，NaN

1. 浮点数 $0$ 附近有一块禁止区，其中的浮点数都是非规格化的，因此无法被表示成IEEE标准格式。其精度比规格化的精度低，会导致渐进式下溢。
2. IEEE标准规定，缺省的**舍入技术**应该向最近的值舍入。
   - 最简单的舍入机制是截断或向0舍入
   - 向最近的数舍入：选择距离该数最近的那个浮点数作为结果
   - 向正或负无穷大舍入：选择正或负无穷大方向上最近的有效浮点数作为结果
   - 向偶数舍入：当要舍入的数位于两个连续浮点数的正中时，IEEE舍入机制选择最低位为0的点
3. IEEE标准规定了 $4$ 种比较结果，分别是等于、小于、大于和无序，无序用于一个操作数是 NaN 数的情景。
4. IEEE标准规定了 $5$ 种异常：
   - 操作数不合法，NaN数，无穷大，求负数的平方根
   - 除数为 $0$
   - 上溢，当结果比最大的浮点数还大时，处理上溢的方法有终止计算和饱和运算等
   - 下溢：当结果比最小的浮点数还小时，处理下溢的方法有将最小浮点数设为 $0$ 或用一个小于 $2^{E_{min}}$ 的非规格化数表示最小浮点数等方式
   - 结果不准确：当某个操作产生舍入错误时

​	浮点运算可能引起尾数位数的相加，需要保持尾数位数不变的方法，最简单的技术就是截断，截断会产生诱导误差，诱导误差是偏差的，因为截断后的数总比截断前小。舍入是一种更好的技术，如果舍弃的位的值大于剩余数的最低位的一半，就将剩余数的最低位+1。

## 基本原理与设计

​	定义接口部分：时钟信号clk，复位信号 rst，输入[31:0]宽的加数x和y，输出[31:0]宽的结果z，[1:0]宽的溢出标志overflow。其中依次表示没有溢出、上溢、下溢和输入不是规格数。

```verilog
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

    always @(posedge clk) begin
        if(!rst)begin
            state_now<=3'b000;
        end
        else begin
            state_now<=state_next;
        end
    end
```

​	定义[24:0]宽的尾数部分m_x,m_y,m_z，需要考虑进位；定义[7:0]宽的指数部分exp_x,exp_y,exp_z；定义符号部分sign_z,sign_x,sign_y。

​	实现的是多周期的单精度浮点加法器，所以考虑到需要状态机，所以设定[2:0]宽的state_now,state_next分别表示当前状态和下一个状态，并且设定start = 3’b000（start是初始化阶段）,zerocheck = 3'b001（检查x=0或y=0阶段）,equalcheck = 3’b010（对阶阶段）,addm =3’b011（尾数相加阶段）,normal = 3’b100（规格化尾数阶段）,over = 3’b110（判断溢出阶段，此阶段同时输出结果部分）。

​	由于需要进行对偶数舍入，所以这里设定[24:0]宽的out_x,out_y来存储x与y右移出尾数的部分（相对顺序不变），设定[24:0]宽的mid_x,mid_y来存储x与y尾数的最低有效位的一半，设定[2:0]宽的大小标志bigger（如果exponent_x>exponent_y，则bigger=2’b01;如果exponent_x<exponent_y，则bigger=2’b10 ；如果exponent_x=exponent_y，则bigger=2’b00）,设定[7:0]宽的移动步数记录部分move_tot。

### 初始化阶段

分离x,y的指数和尾数和符号位，判断是否是规格化浮点数，如果不是，直接修改overflow为2'b11，重新进入初始化，进入下一组假发的计算。

```verilog
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
		if((exp_x == 8'd255 && m_x[22:0]!=0) || (exp_y == 8'd255 && m_y[22:0]!=0))//出现了NaN，结果返回NaN
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
```

### 检查两个输入是否为0

检查x或者y是零的情况，跳转到结束；如果都不是，进入对阶阶段，并对非规格化浮点数做特判。

```verilog
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
		if(m_x[22:0] != 23'b0 && exponent_x == 8'b0)
			begin
				m_x <= {1'b0, 1'b0, x[22:0]};
			end
		if(m_y[22:0] != 23'b0 && exponent_y == 8'b0)
			begin
				m_y <= {1'b0, 1'b0, y[22:0]};
			end
	end
```

### 对阶阶段

这个阶段需要进行尾数的舍入，且采用向偶数舍入的机制。

- 如果指数部分相同，则进入尾数相加的部分
- 如果指数部分不同，将尾数右移，并把右移出去的数按照原来的对应顺序存入out中，每次只右移一次。如果两者指数部分相差过大，可能导致尾数右移变成了0，影响可以忽略不计，直接返回较大的值。右移结束后，执行舍入操作。

```verilog
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
								if(m_y[0] == 0)
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
								if(m_x[0] == 0)
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
						exp_y <= exp_y + 1;
						m_y[23:0] <= {1'b01, m_y[23:1]};
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
						exp_x <= exp_x + 1;
						m_x[23:0] <= {1'b01, m_x[23:1]};
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
```

### 尾数相加阶段

此时两个加数的指数部分相等，那么z的指数部分也应该等于此。并通过符号位判断是同号相加还是异号相加。

如果最后结果的尾数全为零，可以跳过规格化尾数的阶段。

```verilog
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
```

### 规格化尾数阶段

如果存在进位则进行右移操作，指数部分+1，然后进入over阶段。如果不存在进位，则检查是否需要右规（判断条件是m_z[23]是否等于0，m_z[23]就是1.F中的1的那个位置），如果需要则指数部分-1，尾数右移。

```verilog
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
```

### 判断溢出阶段

此阶段判断上溢或下溢，并对结果赋值

```verilog
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
```

