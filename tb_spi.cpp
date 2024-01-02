#include <stdlib.h>
#include <iostream>
#include <vector>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Vspi.h"

#define MAX_SIM_TIME 20
vluint64_t sim_time = 0;
Vspi *dut = new Vspi;
VerilatedVcdC *m_trace = new VerilatedVcdC;

std::vector<uint8_t> to_binary(uint8_t num) {
    std::vector<uint8_t> binaryVector;

    for (int i = 7; i >= 0; --i) {
        binaryVector.push_back((num & (1 << i)) ? 1 : 0);
    }

    return binaryVector;
}

void clk(){
    dut->eval();
    dut->i_clk ^=1;
    dut->eval();
    m_trace->dump(sim_time);
    sim_time++;
}

void send_byte(uint8_t input_byte){
    dut->i_tx_byte = input_byte;
    dut->i_tx_start = 1;
    for(int  i= 0; i < 8; i++) {
        clk();
        clk();
    }
    dut->i_tx_start = 0;
    dut->i_tx_byte = 0;
}

void recieve_byte(u_int8_t input_byte){
    std::vector<uint8_t> input_byte_binary = to_binary(input_byte);
    dut->i_tx_start = 1;
    for(int  i= 0; i < 8; i++){ 
        printf("%d",(int)input_byte_binary[i]);
        dut->i_poci = input_byte_binary[i];
        clk();
        clk();
    }
    dut->i_poci = 0;
    dut->i_tx_start = 0; 
}

void send_recieve_byte(u_int8_t input_byte_tx, u_int8_t input_byte_rx){
    std::vector<uint8_t> input_byte_rx_binary = to_binary(input_byte_rx);
    dut->i_tx_start = 1;
    dut->i_tx_byte = input_byte_tx;
    for(int i = 0; i < 8; i++){
        dut->i_poci = input_byte_rx_binary[i];
        clk();
        clk();
    }
    dut->i_poci = 0;
    dut->i_tx_start = 0;
}
int main(int argc, char** argv, char** env) {

    Verilated::traceEverOn(true);
    dut->trace(m_trace, 5);
    m_trace->open("waveform.vcd");

        send_byte(7);
        send_byte(255);
        recieve_byte(15);
        send_recieve_byte(4,4);
        clk();
        clk();

    m_trace->close();
    delete dut;
    exit(EXIT_SUCCESS);
}

