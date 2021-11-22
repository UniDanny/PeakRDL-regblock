module tb;
    timeunit 1ns;
    timeprecision 1ps;

    logic rst = '1;
    logic clk = '0;
    initial forever begin
        #10ns;
        clk = ~clk;
    end

    //--------------------------------------------------------------------------
    // DUT Signal declarations
    //--------------------------------------------------------------------------
{%- if exporter.hwif.has_input_struct %}
    regblock_pkg::regblock__in_t hwif_in;
{%- endif %}

{%- if exporter.hwif.has_output_struct %}
    regblock_pkg::regblock__out_t hwif_out;
{%- endif %}

{%- block declarations %}
{%- endblock %}

    //--------------------------------------------------------------------------
    // Clocking
    //--------------------------------------------------------------------------
    default clocking cb @(posedge clk);
        default input #1step output #1;
        output rst;
{%- if exporter.hwif.has_input_struct %}
        output hwif_in;
{%- endif %}

{%- if exporter.hwif.has_output_struct %}
        input hwif_out;
{%- endif %}

{%- filter indent %}
{%- block clocking_dirs %}
{%- endblock %}
{%- endfilter %}
    endclocking

    //--------------------------------------------------------------------------
    // CPUIF
    //--------------------------------------------------------------------------
    {{cls.cpuif.get_tb_inst(cls, exporter)|indent}}

    //--------------------------------------------------------------------------
    // DUT
    //--------------------------------------------------------------------------
    regblock dut (.*);

{%- if exporter.hwif.has_output_struct %}
    initial forever begin
        ##1; if(!rst) assert(!$isunknown({>>{hwif_out}})) else $error("hwif_out has X's!");
    end
{%- endif %}

    //--------------------------------------------------------------------------
    // Test Sequence
    //--------------------------------------------------------------------------
    initial begin
        cb.rst <= '1;
    {%- if exporter.hwif.has_input_struct %}
        cb.hwif_in <= '{default: '0};
    {%- endif %}

        begin
            {%- filter indent(8) %}
            {%- block seq %}
            {%- endblock %}
            {%- endfilter %}
        end

        ##5;
        $finish();
    end

    //--------------------------------------------------------------------------
    // Monitor for timeout
    //--------------------------------------------------------------------------
    initial begin
        ##{{cls.timeout_clk_cycles}};
        $fatal(1, "Test timed out after {{cls.timeout_clk_cycles}} clock cycles");
    end

endmodule