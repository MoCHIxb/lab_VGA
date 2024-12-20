module background #(
    parameter ADDR_WIDTH = 15,
    parameter H_LENGTH   = 200,
    parameter V_LENGTH   = 150
) (
    input clk,
    input frame_clk,
    input rstn,
    input scroll_enabled,
    input [ADDR_WIDTH-1:0] addr,
    input [7:0] n,         // 每n个frame_clk更新一次offset，图片向下滚动速度为每秒72/n个像素

    output [11:0] rgb
);

  wire [ADDR_WIDTH-1:0] scroll_addr;
  reg [ADDR_WIDTH-1:0] offset;  // 偏移量
  wire [7:0] count;  // 计数器

  // 使用参数预计算常量值
  localparam MAX_OFFSET = H_LENGTH * V_LENGTH;

  // 在每个frame_clk上升沿更新偏移量
  always @(posedge frame_clk) begin
    if (!rstn) begin
      offset <= 0;
    end else if (count == 0 && scroll_enabled) begin
      offset <= (offset + H_LENGTH == MAX_OFFSET) ? 0 : offset + H_LENGTH;
    end
  end

  // 优化滚动地址计算
  assign scroll_addr = (addr >= offset) ? (addr - offset) : (MAX_OFFSET - (offset - addr));

  Rom_Background background (
      .clka (clk),
      .addra(scroll_addr),
      .douta(rgb)
  );

  Counter #(8, 255) counter (  // 每个frame_clk计数器减1
      .clk       (frame_clk),
      .rstn      (rstn),
      .load_value(n - 1),
      .enable    (1),
      .count     (count)
  );

  initial begin
    offset <= 0;
  end

endmodule
