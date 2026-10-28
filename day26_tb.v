`timescale 1ns/1ps
module tb_day26_all;

    reg clk = 0;
    always #5 clk = ~clk;

    integer tests = 0;
    integer errors = 0;
    integer i;

    reg ga, gb;
    wire gnot, gand, gor;
    not_gate u_not (.a(ga), .y(gnot));
    and_gate u_and (.a(ga), .b(gb), .y(gand));
    or_gate  u_or  (.a(ga), .b(gb), .y(gor));

    reg rv, rr;
    wire rready;
    ready_logic u_ready (
        .out_valid(rv), .out_ready(rr), .in_ready(rready)
    );

    reg hv, hr, hov, hor;
    wire hifire, hofire;
    handshake_logic u_handshake (
        .in_valid(hv), .in_ready(hr),
        .out_valid(hov), .out_ready(hor),
        .input_fire(hifire), .output_fire(hofire)
    );

    reg drst, dload;
    reg [7:0] din;
    wire [7:0] dout;
    data_register u_data (
        .clk(clk), .rst(drst), .load(dload),
        .data_in(din), .data_out(dout)
    );

    reg vrst, vset, vclear;
    wire vout;
    valid_register u_valid (
        .clk(clk), .rst(vrst), .set_valid(vset),
        .clear_valid(vclear), .valid(vout)
    );

    reg brst, bin_valid, bout_ready;
    reg [7:0] bin_data;
    wire bin_ready, bout_valid;
    wire [7:0] bout_data;
    valid_ready_buffer u_buffer (
        .clk(clk), .rst(brst),
        .in_valid(bin_valid), .in_ready(bin_ready), .in_data(bin_data),
        .out_valid(bout_valid), .out_ready(bout_ready), .out_data(bout_data)
    );

    reg trst, source_valid, sink_ready;
    reg [7:0] source_data;
    wire source_ready, sink_valid;
    wire [7:0] sink_data;
    top_valid_ready u_top (
        .clk(clk), .rst(trst),
        .source_valid(source_valid), .source_ready(source_ready),
        .source_data(source_data), .sink_valid(sink_valid),
        .sink_ready(sink_ready), .sink_data(sink_data)
    );

    // Display actual and expected values in fixed-width columns.
    // All values are shown as 8-digit hexadecimal numbers.
    task check;
        input condition;
        input [8*40-1:0] message;
        input [31:0] actual;
        input [31:0] expected;
        begin
            tests = tests + 1;
            if (condition === 1'b1) begin
                $display(" %-4d | %-30s | %08h | %08h | PASS",
                         tests, message, actual, expected);
            end
            else begin
                errors = errors + 1;
                $display(" %-4d | %-30s | %08h | %08h | FAIL",
                         tests, message, actual, expected);
                $display(1, "Check failed at time %0t", $time);
            end
        end
    endtask

    task tick;
        begin
            @(posedge clk);
            #1;
        end
    endtask

    initial begin
        $display("\n==========================================================================");
        $display("             DAY 26 | VALID-READY DESIGN VERIFICATION");
        $display("==========================================================================");
        $display(" TEST | TEST DESCRIPTION               | ACTUAL   | EXPECTED | RESULT");
        $display("------|--------------------------------|----------|----------|--------");

        // Initialize all inputs.
        drst=1; dload=0; din=0;
        vrst=1; vset=0; vclear=0;
        brst=1; bin_valid=0; bin_data=0; bout_ready=0;
        trst=1; source_valid=0; source_data=0; sink_ready=0;
        ga=0; gb=0; rv=0; rr=0;
        hv=0; hr=0; hov=0; hor=0;

        $display("\nTASK 1 | Gate-level logic");
        for (i=0; i<4; i=i+1) begin
            {ga,gb}=i[1:0];
            #1;
            check(gnot === ~ga, "NOT gate", gnot, ~ga);
            check(gand === (ga & gb), "AND gate", gand, (ga & gb));
            check(gor === (ga | gb), "OR gate", gor, (ga | gb));
        end

        $display("\nTASK 2 | Ready logic");
        for (i=0; i<4; i=i+1) begin
            {rv,rr}=i[1:0];
            #1;
            check(rready === ((~rv) | rr),
                  "Ready equation", rready, ((~rv) | rr));
        end

        $display("\nTASK 3 | Handshake logic");
        for (i=0; i<16; i=i+1) begin
            {hv,hr,hov,hor}=i[3:0];
            #1;
            check(hifire === (hv & hr),
                  "Input handshake", hifire, (hv & hr));
            check(hofire === (hov & hor),
                  "Output handshake", hofire, (hov & hor));
        end

        $display("\nTASK 4 | Data register reset");
        tick();
        check(dout === 8'h00, "Reset clears data", dout, 8'h00);

        $display("\nTASK 5 | Data register load and hold");
        drst=0; dload=1; din=8'hA5;
        tick();
        check(dout === 8'hA5, "Load captures A5", dout, 8'hA5);

        dload=0; din=8'h3C;
        tick();
        check(dout === 8'hA5, "Hold keeps A5", dout, 8'hA5);

        $display("\nTASK 6 | Valid register");
        tick();
        check(vout === 1'b0, "Reset clears valid", vout, 1'b0);

        vrst=0; vset=1; vclear=0;
        tick();
        check(vout === 1'b1, "Set valid", vout, 1'b1);

        vset=0; vclear=1;
        tick();
        check(vout === 1'b0, "Clear valid", vout, 1'b0);

        $display("\nTASK 7 | Buffer reset and input");
        tick();
        check(bout_valid === 1'b0, "Buffer starts empty", bout_valid, 1'b0);

        brst=0; bin_valid=1; bin_data=8'hA5; bout_ready=0;
        tick();
        check((bout_valid === 1'b1) && (bout_data === 8'hA5),
              "Accept A5", {23'b0, bout_valid, bout_data},
              {23'b0, 1'b1, 8'hA5});

        $display("\nTASK 8 | Buffer stall and hold");
        bin_data=8'h3C; bin_valid=1; bout_ready=0;
        #1;
        check(bin_ready === 1'b0,
              "Full buffer blocks input", bin_ready, 1'b0);

        tick();
        check((bout_valid === 1'b1) && (bout_data === 8'hA5),
              "Stall holds A5", {23'b0, bout_valid, bout_data},
              {23'b0, 1'b1, 8'hA5});

        $display("\nTASK 9 | Replace and consume data");
        bout_ready=1; bin_valid=1; bin_data=8'h3C;
        #1;
        check(bin_ready === 1'b1,
              "Ready permits replacement", bin_ready, 1'b1);

        tick();
        check((bout_valid === 1'b1) && (bout_data === 8'h3C),
              "Replacement stores 3C", {23'b0, bout_valid, bout_data},
              {23'b0, 1'b1, 8'h3C});

        bin_valid=0; bout_ready=1;
        tick();
        check(bout_valid === 1'b0,
              "Consume empties buffer", bout_valid, 1'b0);

        $display("\nTASK 10 | Top-module integration");
        tick();
        check(sink_valid === 1'b0, "Top reset", sink_valid, 1'b0);

        trst=0; source_valid=1; source_data=8'hD2; sink_ready=0;
        tick();
        check((sink_valid === 1'b1) && (sink_data === 8'hD2),
              "Source sends D2", {23'b0, sink_valid, sink_data},
              {23'b0, 1'b1, 8'hD2});

        source_valid=0; sink_ready=1;
        tick();
        check(sink_valid === 1'b0,
              "Sink consumes D2", sink_valid, 1'b0);

        $display("\n==========================================================================");
        $display("                         VERIFICATION SUMMARY");
        $display("==========================================================================");
        $display(" Total Checks  : %0d", tests);
        $display(" Failed Checks : %0d", errors);

        if (errors == 0)
            $display(" Final Result  : ALL TESTS PASSED");
        else
            $display(" Final Result  : TESTS FAILED");

        $display("==========================================================================");
        #1;
        $finish;
    end
endmodule
