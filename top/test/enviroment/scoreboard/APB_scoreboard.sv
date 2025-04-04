package APB_scoreboard_pkg;
    import  uvm_pkg::*,
            APB_master_seq_item_pkg::*,
            APB_slave_seq_item_pkg::*,
            shared_pkg::*; // For enums and parameters
    
    `include "apb_defines.svh" // For macros

    `include "uvm_macros.svh"
    class APB_scoreboard extends uvm_scoreboard;
        `uvm_component_utils(APB_scoreboard)
        
        uvm_analysis_export #(APB_master_seq_item) master_sb_export;
        uvm_tlm_analysis_fifo #(APB_master_seq_item) apb_master_sb;
        APB_master_seq_item master_seq_item_sb;

        uvm_analysis_export #(APB_slave_seq_item) slave_sb_export;
        uvm_tlm_analysis_fifo #(APB_slave_seq_item) apb_slave_sb;
        APB_slave_seq_item slave_seq_item_sb;

        int error_count = 0, correct_count = 0;
        
        // Default Constructor
        function new(string name = "APB_scoreboard",uvm_component parent);
            super.new(name,parent);
        endfunction

        // Build Phase
        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            master_sb_export = new("master_sb_export",this);
            apb_master_sb=new("apb_master_sb",this);
            slave_sb_export = new("slave_sb_export",this);
            apb_slave_sb=new("apb_slave_sb",this);
        endfunction

        // Connect Phase
        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            master_sb_export.connect(apb_master_sb.analysis_export);
            slave_sb_export.connect(apb_slave_sb.analysis_export);
        endfunction

        // Run Phase
        task run_phase(uvm_phase phase);
            super.run_phase(phase);
            forever begin
                apb_master_sb.get(master_seq_item_sb);
                apb_slave_sb.get(slave_seq_item_sb);
                check_results(master_seq_item_sb,slave_seq_item_sb);
            end
        endtask

        // Report Phase
        function void report_phase(uvm_phase phase);
            super.report_phase(phase);
            `uvm_info("report_phase",$sformatf("At time %0t: Simulation Ends and Error count= %0d, Correct count= %0d",$time,error_count,correct_count),UVM_MEDIUM);
        endfunction

        function void check_results(APB_master_seq_item seq_item_ch, APB_slave_seq_item seq_item_ch_slave);
            if ( seq_item_ch_slave.PRDATA != seq_item_ch_slave.PRDATA_ref
                || seq_item_ch_slave.PREADY != seq_item_ch_slave.PREADY_ref
                || seq_item_ch_slave.PSLVERR != seq_item_ch_slave.PSLVERR_ref
                || seq_item_ch.PWRITE != seq_item_ch.PWRITE_ref
                || seq_item_ch.PADDR != seq_item_ch.PADDR_ref
                || seq_item_ch.PWDATA != seq_item_ch.PWDATA_ref
                || seq_item_ch.PSTRB != seq_item_ch.PSTRB_ref
                || seq_item_ch.PPROT != seq_item_ch.PPROT_ref
                ) begin
                error_count++;
                `uvm_error("run_phase","Comparison Error between the golden model and the DUT")
                `uvm_info("MASTER", $sformatf("Master Transaction:\n%s", seq_item_ch.sprint()), UVM_MEDIUM)
                `uvm_info("SLAVE", $sformatf("Slave Transaction:\n%s", seq_item_ch_slave.sprint()), UVM_MEDIUM)
            end
            else
                correct_count++;
        endfunction
    endclass : APB_scoreboard

endpackage : APB_scoreboard_pkg