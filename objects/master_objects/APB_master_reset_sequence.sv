package APB_master_reset_sequence_pkg;

    import uvm_pkg::*,
           APB_master_seq_item_pkg::*,
           shared_pkg::*; // For enums and parameters
    `include "uvm_macros.svh"
           
    class APB_master_reset_sequence extends uvm_sequence #(APB_master_seq_item);

        `uvm_object_utils (APB_master_reset_sequence)
        APB_master_seq_item master_seq_item;

        function new (string name = "APB_master_reset_sequence");
            super.new(name);
        endfunction

        task body;
            master_seq_item = APB_master_seq_item::type_id::create("master_seq_item");
            start_item(master_seq_item);
                master_seq_item.SWRITE = `LOW;
                master_seq_item.SADDR = `LOW;
                master_seq_item.SWDATA = `LOW;
                master_seq_item.SSTRB = `LOW;
                master_seq_item.SPROT = `LOW;
                master_seq_item.transfer = `LOW;
                master_seq_item.PRESETn = `LOW;
                master_seq_item.cs = IDLE;
            finish_item(master_seq_item);
        endtask
        
    endclass : APB_master_reset_sequence

endpackage : APB_master_reset_sequence_pkg