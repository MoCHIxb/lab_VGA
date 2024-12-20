// 自机模块
module Player #(
    parameter ADDR_WIDTH = 15,
    parameter SPEED_X = 2,
    parameter BUNCE_V = -2,  //回弹初速度
    parameter G_CONST = 1,  //重力加速度
    parameter X_WHITH = 30,  //物体宽
    parameter Y_WHITH = 36,  //物体长
    parameter H_LENGTH  = 200, //宽度
    parameter V_LENGTH  = 150  //高度
)(
    input clk,
    input frame_clk,
    input rstn,
    input [H_LENGTH-1:0] addr_x,  //输入起始中心x坐标
    input [V_LENGTH-1:0] addr_y,  //输入起始中心y坐标
    input [127:0] key_state,
    input enable_scroll,    //借用一下，实现暂停功能
    input collision,       //碰撞信号
    input [7:0] n,         // 每n个frame_clk更新一次offset，物体向下滚动速度为每秒72/n个像素,即刷新率

    output reg [H_LENGTH-1:0] loc_x, //x位置
    output reg [V_LENGTH-1:0] loc_y  //y位置
);
reg  arrow; //判断左右移动方向，取1为左,取0为右
reg  [7:0] speed_x;  
reg  [7:0] speed_y;
wire [7:0] count_x;  // 计数器
wire [7:0] count_y;  // 计数器

// 在每个frame_clk上升沿更新计数器和偏移量
always @(posedge frame_clk) begin
    if (!rstn) begin
        loc_x <= addr_x;
        loc_y <= addr_y;
    end 
    else begin
      if (count_y == 0) begin  // 计数器为零，y轴移动
        loc_y <= (loc_y + speed_y) % V_LENGTH;
      end
      if (count_x == 0) begin  // 计数器为零，x轴移动
        if (arrow) begin
            loc_x <= (loc_x + speed_x) % H_LENGTH;
        end
        else begin
            loc_x <= (loc_x - speed_x) % H_LENGTH;
        end
      end
    end
end

//更新当前x方向速度，根据键盘输入key_state确定左右
always @(posedge frame_clk) begin
    speed_x <= 0;
    if (key_state[1]) begin//键盘输入（具体输入信号未完成）
        speed_x <= SPEED_X;
        arrow <= 1;
    end
    else if (key_state[0]) begin
        speed_x <= SPEED_X;
        arrow <= 0;
    end
end

//更新当前y方向速度，根据collision确定碰撞
always @(posedge frame_clk) begin
    speed_y <= speed_y + G_CONST;
    if (collision) begin
        speed_y <= BUNCE_V;
    end
end

Counter #(8, 255) counter_x (// 每个frame_clk计数器减1
  .clk       (frame_clk),
  .rstn      (rstn),
  .load_value(n - 1),
  .enable    (enable_scroll),
  .count     (count_x)
);

Counter #(8, 255) counter_y (// 每个frame_clk计数器减1
  .clk       (frame_clk),
  .rstn      (rstn),
  .load_value(n - 1),
  .enable    (enable_scroll),
  .count     (count_y)
);

initial begin //初始化
    loc_x <= addr_x;
    loc_y <= addr_y;
    arrow <= 0;
    speed_x <= 0;
    speed_y <= 0;
end

endmodule
