`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.07.2025 10:23:45
// Design Name: 
// Module Name: top
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


module top(
    input wire clk,         // 100 MHz clock
    input wire rst,
    output wire Hsync,
    output wire Vsync,
    output wire [3:0] vgaRed,
    output wire [3:0] vgaGreen,
    output wire [3:0] vgaBlue
);

    // ---------------- Clock divider 100MHz -> 25MHz ------------------
    reg clk_25 = 0;
    reg [1:0] div_cnt = 0;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            clk_25 <= 0;
            div_cnt <= 0;
        end else begin
            div_cnt <= div_cnt + 1;
            if (div_cnt == 1) begin
                clk_25 <= ~clk_25;
                div_cnt <= 0;
            end
        end
    end

    // ------------------ Sync VGA ------------------------------------
    wire video_on;
    wire [9:0] x, y;
    wire vsync_int;
    sync sync_inst(
        .clk(clk_25),
        .rst(rst),
        .hsync(Hsync),
        .vsync(vsync_int),
        .video_on(video_on),
        .x(x),
        .y(y)
    );

    assign Vsync = vsync_int;

    // --------------- Pozițiile și flagul animației ------------------
    reg [9:0] sun_pos = 0;
    reg [9:0] moon_pos = 639;
    reg moon_active = 0;      // 0 = zi / soare activ, 1 = noapte / lună activă

    always @(posedge vsync_int or posedge rst) begin
        if (rst) begin
            sun_pos <= 0;
            moon_pos <= 639;
            moon_active <= 0;
        end else begin
            if (!moon_active) begin
                // Ziua: soarele se deplasează
                if (sun_pos < 639) 
                    sun_pos <= sun_pos + 1;
               else begin
                    sun_pos <= 0;
                    moon_active <= 1;           // trecem la noapte
                    moon_pos <= 639;            // poziția inițială a lunii
                end
                moon_pos <= 639;                 // luna asteapta la margine când e zi
            end else begin
                // Noaptea: luna se deplasează
                if (moon_pos > 0) 
                    moon_pos <= moon_pos - 1;
            else begin
                    moon_pos <= 0;
                    moon_active <= 0;               // revenim la zi
                    sun_pos <= 0;
                end
                sun_pos <= 0;                        // soarele stă când e noapte
            end
        end
    end

    // ---------------- Parametri pozitii verticale --------------------
    localparam SUN_Y = 200;
    localparam MOON_Y = 200;
    wire ground = y > 400;

    // ---------------- Zone de desen soare si semiluna -----------------
    wire sun_area = ((x - sun_pos)*(x - sun_pos) + (y - SUN_Y)*(y - SUN_Y)) < 900; // raza 30^2
    wire moon_outer = ((x - moon_pos)*(x - moon_pos) + (y - MOON_Y)*(y - MOON_Y)) < 625; // raza 25^2
    wire moon_cutout = ((x - (moon_pos + 10))*(x - (moon_pos + 10)) + (y - MOON_Y)*(y - MOON_Y)) < 400; // raza 20^2 decupaj
    wire moon_area = moon_outer & ~moon_cutout;

    // --------------- Control zi/noapte pentru afișare -----------------
    wire is_day = (moon_active == 0);
    wire is_night = (moon_active == 1);
    
    // Definire nori - cercuri albe la poziții fixe
wire cloud1 = ( ((x-100)*(x-100) + (y-150)*(y-150)) < 900 ) || // cerc raza 30 la (100,150)
              ( ((x-130)*(x-130) + (y-140)*(y-140)) < 625 ) || // cerc raza 25 la (130,140)
              ( ((x-160)*(x-160) + (y-150)*(y-150)) < 900 );  // cerc raza 30 la (160,150)


    
    
    //Definire stele - puncte mici (raza 2) la poziții fixe (sau pseudoaleatorii)
wire star1 = ((x-50)*(x-50) + (y-50)*(y-50)) < 9;    // raza 3 la (50,50)
wire star2 = ((x-200)*(x-200) + (y-100)*(y-100)) < 9;
wire star3 = ((x-300)*(x-300) + (y-80)*(y-80)) < 9;
wire star4 = ((x-400)*(x-400) + (y-60)*(y-60)) < 9;
wire star5 = ((x-500)*(x-500) + (y-90)*(y-90)) < 9;
wire star6 = ((x-600)*(x-600) + (y-70)*(y-70)) < 9;
wire stars = star1 || star2 || star3 || star4 || star5 || star6;

// Trunchi copac 1 (x între 80 și 90, y între 350 și 410)
wire tree_trunk1 = ((x >= 80) && (x <= 90) && (y >= 350) && (y <= 410));
// Coroană copac 1 (cerc de centru 85, 340∶ raza ~20)
wire tree_crown1 = ((x-85)*(x-85)+(y-340)*(y-340) < 400);


    // ---------------- Colorare pixeli --------------------------------
    reg [3:0] red, green, blue;
always @* begin
    if (!video_on) begin
        red = 0; green = 0; blue = 0; // Negru în afara zonei vizibile
    end 
    else if (is_day && sun_area) begin
        red = 4'hF; green = 4'hF; blue = 0;  // Soare galben
    end 
    else if (is_night && moon_area) begin
        red = 4'hF; green = 4'hE; blue = 2; // Semilună albastru deschis
    end 
    // Nori si stele după priorități, dacă ai
    else if (is_day && cloud1) begin
        red = 4'hF; green = 4'hF; blue = 4'hF; // Nori albi zi
    end 
    else if (is_night && stars) begin
        red = 4'hF; green = 4'hF; blue = 4'hF; // Stele noapte
    end 
    // Copac - afișează și ziua și noaptea, cu culori diferite
    else if (tree_trunk1) begin
        if (is_day) begin
            red = 4; green = 2; blue = 0;        // Trunchi maro zi
        end else begin
            red = 2; green = 1; blue = 0;        // Trunchi închis noapte
        end
    end
    else if (tree_crown1) begin
        if (is_day) begin
            red = 1; green = 14; blue = 2;       // Frunze verde deschis zi
        end else begin
            red = 1; green = 6; blue = 2;        // Frunze verde închis noapte
        end
    end 
    
    else if (is_day && ground) begin
        red = 0; green = 4'hF; blue = 0;          // Iarbă verde zi
    end 
    else if (is_day) begin
        red = 4'hB; green = 4'hD; blue = 4'hF;    // Cer albastru zi
    end 
    else if (is_night && ground) begin
        red = 4'h6; green = 3'h3; blue = 0;       // Pământ brun noapte
    end 
    else begin
        red = 0; green = 0; blue = 4'h4;          // Cer închis noapte
    end
end


    assign vgaRed = red;
    assign vgaGreen = green;
    assign vgaBlue = blue;

endmodule