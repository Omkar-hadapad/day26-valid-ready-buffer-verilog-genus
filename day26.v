`timescale 1ns/1ps

// ============================================================
// Day 26: Valid-Ready Data Interface
// Single-file, hierarchical Verilog design
// File: day26_valid_ready.v
//
// Includes:
//   1. not_gate
//   2. and_gate
//   3. or_gate
//   4. ready_logic
//   5. handshake_logic
//   6. data_register
//   7. valid_register
//   8. valid_ready_buffer
//   9. top_valid_ready
//
// Buffer behavior:
//   - One-entry, 8-bit buffer
//   - Synchronous active-high reset
//   - Allows simultaneous output consumption and input replacement
// ============================================================


// -------------------------
// 1. NOT gate
// -------------------------
module not_gate (
    input  a,
    output y
);
    assign y = ~a;
endmodule


// -------------------------
// 2. AND gate
// -------------------------
module and_gate (
    input  a,
    input  b,
    output y
);
    assign y = a & b;
endmodule


// -------------------------
// 3. OR gate
// -------------------------
module or_gate (
    input  a,
    input  b,
    output y
);
    assign y = a | b;
endmodule


// -------------------------
// 4. Ready logic
// in_ready = ~out_valid | out_ready
// -------------------------
module ready_logic (
    input  out_valid,
    input  out_ready,
    output in_ready
);
    wire not_out_valid;

    not_gate u_not (
        .a(out_valid),
        .y(not_out_valid)
    );

    or_gate u_or (
        .a(not_out_valid),
        .b(out_ready),
        .y(in_ready)
    );
endmodule


// -------------------------
// 5. Handshake logic
// input_fire  = in_valid  & in_ready
// output_fire = out_valid & out_ready
// -------------------------
module handshake_logic (
    input  in_valid,
    input  in_ready,
    input  out_valid,
    input  out_ready,
    output input_fire,
    output output_fire
);
    and_gate u_input_and (
        .a(in_valid),
        .b(in_ready),
        .y(input_fire)
    );

    and_gate u_output_and (
        .a(out_valid),
        .b(out_ready),
        .y(output_fire)
    );
endmodule


// -------------------------
// 6. 8-bit data register
// Synchronous active-high reset
// -------------------------
module data_register (
    input        clk,
    input        rst,
    input        load,
    input  [7:0] data_in,
    output reg [7:0] data_out
);
    always @(posedge clk) begin
        if (rst)
            data_out <= 8'b0;
        else if (load)
            data_out <= data_in;
    end
endmodule


// -------------------------
// 7. Valid-state register
// Synchronous active-high reset
// -------------------------
module valid_register (
    input  clk,
    input  rst,
    input  set_valid,
    input  clear_valid,
    output reg valid
);
    always @(posedge clk) begin
        if (rst)
            valid <= 1'b0;
        else if (set_valid)
            valid <= 1'b1;
        else if (clear_valid)
            valid <= 1'b0;
    end
endmodule


// -------------------------
// 8. One-entry valid-ready buffer
// -------------------------
module valid_ready_buffer (
    input        clk,
    input        rst,

    input        in_valid,
    output       in_ready,
    input  [7:0] in_data,

    output       out_valid,
    input        out_ready,
    output [7:0] out_data
);
    wire input_fire;
    wire output_fire;
    wire load_data;
    wire set_valid;
    wire clear_valid;

    ready_logic u_ready_logic (
        .out_valid(out_valid),
        .out_ready(out_ready),
        .in_ready(in_ready)
    );

    handshake_logic u_handshake (
        .in_valid(in_valid),
        .in_ready(in_ready),
        .out_valid(out_valid),
        .out_ready(out_ready),
        .input_fire(input_fire),
        .output_fire(output_fire)
    );

    // Capture incoming data when accepted.
    assign load_data = input_fire;

    // Set valid when input is accepted.
    assign set_valid = input_fire;

    // Clear valid when output is consumed and no new input
    // replaces it on the same clock edge.
    assign clear_valid = output_fire && !input_fire;

    data_register u_data_register (
        .clk(clk),
        .rst(rst),
        .load(load_data),
        .data_in(in_data),
        .data_out(out_data)
    );

    valid_register u_valid_register (
        .clk(clk),
        .rst(rst),
        .set_valid(set_valid),
        .clear_valid(clear_valid),
        .valid(out_valid)
    );

endmodule


// -------------------------
// 9. Top-level module
// -------------------------
module top_valid_ready (
    input        clk,
    input        rst,

    input        source_valid,
    output       source_ready,
    input  [7:0] source_data,

    output       sink_valid,
    input        sink_ready,
    output [7:0] sink_data
);
    valid_ready_buffer u_buffer (
        .clk(clk),
        .rst(rst),

        .in_valid(source_valid),
        .in_ready(source_ready),
        .in_data(source_data),

        .out_valid(sink_valid),
        .out_ready(sink_ready),
        .out_data(sink_data)
    );
endmodule
