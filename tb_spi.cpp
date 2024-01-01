#include <stdlib.h>
#include <iostream>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Vspi.h"

#define MAX_SIM_TIME 20
vluint64_t sim_time = 0;
Vspi *dut = new Vspi;
VerilatedVcdC *m_trace = new VerilatedVcdC;

void clk(){
    dut->i_clk ^=1;
    dut->eval();
    m_trace->dump(sim_time);
    sim_time++;
}

void send_byte(){
    dut->tx_start = 1;
    for(int  i= 0; i < 16; i++) clk();
    dut->tx_start = 0;
    clk();
}
int main(int argc, char** argv, char** env) {

    Verilated::traceEverOn(true);
    dut->trace(m_trace, 5);
    m_trace->open("waveform.vcd");

        dut->i_tx_byte = 7;
        send_byte();
        dut->i_tx_byte = 255;
        send_byte();



    m_trace->close();
    delete dut;
    exit(EXIT_SUCCESS);
}

