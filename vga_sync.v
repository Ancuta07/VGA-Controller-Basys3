`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.07.2025 10:30:35
// Design Name: 
// Module Name: vga_sync
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module sync(
    input  wire clk,       // 25 MHz pixel clock
    input  wire rst,
    output reg hsync,
    output reg vsync,
    output wire video_on,
    output wire [9:0] x,
    output wire [9:0] y
);

    // Parametrii timing VGA pentru 640x480 60Hz
    parameter H_TOTAL       = 800;
    parameter H_SYNC_START  = 656;
    parameter H_SYNC_END    = 752;
    parameter H_VISIBLE     = 640;

    parameter V_TOTAL       = 525;
    parameter V_SYNC_START  = 490;
    parameter V_SYNC_END    = 492;
    parameter V_VISIBLE     = 480;

    reg [9:0] h_count = 0;
    reg [9:0] v_count = 0;

    // Contorizare orizontală și verticală
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            h_count <= 0;
            v_count <= 0;
        end else begin
            if (h_count == H_TOTAL - 1) begin
                h_count <= 0;
                if (v_count == V_TOTAL - 1)
                    v_count <= 0;
                else
                    v_count <= v_count + 1;
            end else begin
                h_count <= h_count + 1;
            end
        end
    end

    // Semnale sincronizare active low
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            hsync <= 1;
            vsync <= 1;
        end else begin
            hsync <= ~((h_count >= H_SYNC_START) && (h_count < H_SYNC_END));
            vsync <= ~((v_count >= V_SYNC_START) && (v_count < V_SYNC_END));
        end
    end

    // Zona activă (video_on)
    assign video_on = (h_count < H_VISIBLE) && (v_count < V_VISIBLE);

    // Coordonatele pixelului curent
    assign x = h_count;
    assign y = v_count;

endmodule

