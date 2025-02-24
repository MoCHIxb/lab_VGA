// 控制器模块
module Controllor #(
    parameter ADDR_WIDTH = 15,
    parameter H_LENGTH   = 200,
    parameter V_LENGTH   = 150,
    parameter MAX_BULLET = 5
) (
    input clk,
    input rstn,
    input btnc,
    btnl,
    btnr,
    btnu,
    btnd,
    input Left,
    Right,
    Shoot,
    Space,
    R,

    output reg [15:0] LED,
    output [3 : 0] VGA_R,
    output [3 : 0] VGA_G,
    output [3 : 0] VGA_B,
    output VGA_HS,
    output VGA_VS,
    output [1:0] game_state,
    output clk_o
);
  wire pclk;
  wire clk_25mhz;
  wire clk_5mhz;
  wire [11:0] rdata;
  wire [ADDR_WIDTH-1:0] raddr;
  wire [ADDR_WIDTH-1:0] render_addr;
  wire [15:0] score;
  wire [15:0] high_score;
  wire left, right, shoot, space;
  wire frame;
  wire frame_clk;
  assign clk_o = pclk;

  // 像素时钟
  pclk pixel_clock_inst (
      .clk_out1(pclk),
      .clk_out2(clk_25mhz),
      .clk_out3(clk_5mhz),
      .reset   (~rstn),
      .locked  (),
      .clk_in1 (clk)
  );

  // 游戏输入
  GameInput game_input_inst (
      .btnc(btnc),
      .btnl(btnl),
      .btnr(btnr),
      .btnu(btnu),
      .btnd(btnd),

      .left (left),
      .right(right),
      .shoot(shoot),
      .space(space)
  );

  // 游戏逻辑
  Game game_inst (
      .clk(clk_5mhz),
      .frame_clk(frame_clk),
      .rstn(rstn),
      //   .render_addr(render_addr),
      .left((left || Left)),
      .right((right || Right)),
      .shoot((shoot || Shoot)),
      .space((space || Space)),
      .r(R),

      // output in-game object x, y, priority, color
      .game_state(game_state),
      // .bullet_lookup_i(bullet_index),
      .score(score),
      .high_score(high_score),
      .enable_scroll(enable_scroll),
      .n(),
      .bg_v(),
      .player_x(),
      .player_y(),
      .player_y_out(),
      .player_anime_state(),
      .enemy_x(),
      .enemy_y(),
      .enemy_display(),
      .enemy_HP(),
      .bullet_x(),
      .bullet_y(),
      .bullet_display(),
      .stair_x(),
      .stair_y(),
      .stair_display()
  );

  // 帧生成
  FrameGenerator #(
      .ADDR_WIDTH(ADDR_WIDTH),
      .H_LENGTH  (H_LENGTH),
      .V_LENGTH  (V_LENGTH)
  ) frame_gen_inst (
      .ram_clk(clk),
      .rom_clk(pclk),
      .clk(clk_25mhz),
      .frame_clk(frame_clk),
      .rstn(rstn),

      //input in-game .x, .y, .priority, .color
      .game_state(game_state),
      // .bullet_index(bullet_index),
      .scroll_enabled(game_inst.enable_scroll),
      .n(game_inst.n),
      .v(game_inst.bg_v),
      //   .render_addr(),
      .score(score),
      .high_score(high_score),
      .player_x(game_inst.player_x),
      .player_y(game_inst.player_y),
      .player_anime_state(game_inst.player_anime_state),
      .boss_x(game_inst.enemy_x),
      .boss_y(game_inst.enemy_y),
      .boss_display(game_inst.enemy_display),
      .boss_HP(game_inst.enemy_HP),
      .bullet_x(game_inst.bullet_x),
      .bullet_y(game_inst.bullet_y),
      .bullet_display(game_inst.bullet_display),
      .stair_x(game_inst.stair_x),
      .stair_y(game_inst.stair_y),
      .stair_display(game_inst.stair_display),

      .raddr(raddr),
      .rdata(rdata)
  );

  wire h_enable;
  wire v_enable;
  // 实例化DisplaySyncTiming同步时序模块
  DisplaySyncTiming dst (
      .rstn(rstn),
      .pclk(pclk),
      .h_enable(h_enable),
      .v_enable(v_enable),
      .h_sync(VGA_HS),
      .v_sync(VGA_VS),
      .frame(frame)
  );

  // 实例化DisplayDataProcessor数据处理模块
  DisplayDataProcessor #(
      .ADDR_WIDTH(ADDR_WIDTH),
      .H_LENGTH  (H_LENGTH),
      .V_LENGTH  (V_LENGTH)
  ) ddp (
      .h_enable(h_enable),
      .v_enable(v_enable),
      .rstn(rstn),
      .pclk(pclk),
      .read_data(rdata),
      .rgb_out({VGA_R, VGA_G, VGA_B}),
      .read_addr(raddr)
  );

  PulseSync #(
      .WIDTH(1)
  ) ps (
      .sync_in  (frame),
      .clk      (clk_5mhz),
      .pulse_out(frame_clk)
  );

  always @(posedge frame_clk) begin
    LED[15] <= LED[14];
    LED[14] <= LED[13];
    LED[13] <= LED[12];
    LED[12] <= LED[11];
    LED[11] <= LED[10];
    LED[10] <= LED[9];
    LED[9]  <= LED[8];
    LED[8]  <= LED[7];
    LED[7]  <= LED[6];
    LED[6]  <= LED[5];
    LED[5]  <= LED[4];
    LED[4]  <= LED[3];
    LED[3]  <= LED[2];
    LED[2]  <= LED[1];
    LED[1]  <= LED[0];
    LED[0]  <= LED[15];
  end

  initial begin
    LED = 16'b0000_0000_1111_1111;
  end


endmodule

