module Game #(
    parameter ADDR_WIDTH = 15,
    parameter H_LENGTH   = 200,
    parameter V_LENGTH   = 150
) (
    input clk,
    input rstn,
    input frame_clk,
    input [ADDR_WIDTH-1:0] render_addr,  //渲染坐标/地址

    // 游戏键盘输入
    input left,
    input right,
    input shoot,
    input space,

    output reg [1:0] game_state,  //游戏状态
    // output in-game object x, y, priority
    output [15:0] score,
    output [15:0] high_score,
    output reg enable_scroll,
    output reg [7:0] n,
    output [$clog2(H_LENGTH)-1:0] player_x,
    output [$clog2(V_LENGTH)-1:0] player_y,
    output [$clog2(H_LENGTH)-1:0] boss_x,
    output [$clog2(V_LENGTH)-1:0] boss_y,
    output [$clog2(H_LENGTH)-1:0] bullet_x,
    output [$clog2(V_LENGTH)-1:0] bullet_y
);

  // wire [$clog2(H_LENGTH)-1:0] next_player_x;
  // wire [$clog2(V_LENGTH)-1:0] next_player_y;
  // wire [$clog2(H_LENGTH)-1:0] next_boss_x;
  // wire [$clog2(V_LENGTH)-1:0] next_boss_y;
  // wire [$clog2(H_LENGTH)-1:0] next_bullet_x;
  // wire [$clog2(V_LENGTH)-1:0] next_bullet_y;

  // test
  assign boss_x = 100;
  assign boss_y = 20;
  assign bullet_x = 10;
  assign bullet_y = 20;

  // 状态机测试代码，需要具体修改
  // Game state definitions
  localparam GAME_MENU = 2'b00;
  localparam GAME_PLAYING = 2'b01;
  localparam GAME_OVER = 2'b10;

  reg [1:0] next_game_state;

  always @(posedge clk) begin
    if (!rstn) begin
      game_state <= GAME_MENU;
    end else begin
      game_state <= next_game_state;
    end
  end

  // always @(posedge clk) begin
  //   if (!rstn) begin
      
  //   end
  // end

  // 状态机切换逻辑
  always @(posedge frame_clk) begin
    if (!rstn) begin
      next_game_state <= GAME_MENU;
    end else begin
      case (game_state)
        GAME_MENU: begin
          if (left) begin
            next_game_state <= GAME_PLAYING;
          end else begin
            next_game_state <= GAME_MENU;
          end
        end
        GAME_PLAYING: begin
          if (space) begin
            next_game_state <= GAME_OVER;
          end else begin
            next_game_state <= GAME_PLAYING;
          end
        end
        GAME_OVER: begin
          if (right) begin
            next_game_state <= GAME_MENU;
          end else begin
            next_game_state <= GAME_OVER;
          end
        end
      endcase
    end
  end

  Score score_inst (
      .clk(clk),
      .frame_clk(frame_clk),
      .rstn(rstn),
      .game_state(game_state),
      .n(n),

      .score(score),
      .high_score(high_score)
  );

  Player player_inst (
      .clk(clk),
      .frame_clk(frame_clk),
      .rstn(rstn),
      .key_state(0),
      .enable_scroll(enable_scroll),
      .collision(0),
      .n(n),

      .loc_x(player_x),
      .loc_y(player_y)
  );

  initial begin
    enable_scroll = 1;
    n = 2;
  end

endmodule