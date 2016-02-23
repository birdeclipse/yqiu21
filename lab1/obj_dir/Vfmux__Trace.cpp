// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Tracing implementation internals
#include "verilated_vcd_c.h"
#include "Vfmux__Syms.h"


//======================

void Vfmux::traceChg(VerilatedVcd* vcdp, void* userthis, uint32_t code) {
    // Callback from vcd->dump()
    Vfmux* t=(Vfmux*)userthis;
    Vfmux__Syms* __restrict vlSymsp = t->__VlSymsp; // Setup global symbol table
    if (vlSymsp->getClearActivity()) {
	t->traceChgThis (vlSymsp, vcdp, code);
    }
}

//======================


void Vfmux::traceChgThis(Vfmux__Syms* __restrict vlSymsp, VerilatedVcd* vcdp, uint32_t code) {
    Vfmux* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    int c=code;
    if (0 && vcdp && c) {}  // Prevent unused
    // Body
    {
	vlTOPp->traceChgThis__2(vlSymsp, vcdp, code);
    }
    // Final
    vlTOPp->__Vm_traceActivity = 0U;
}

void Vfmux::traceChgThis__2(Vfmux__Syms* __restrict vlSymsp, VerilatedVcd* vcdp, uint32_t code) {
    Vfmux* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    int c=code;
    if (0 && vcdp && c) {}  // Prevent unused
    // Body
    {
	vcdp->chgBit  (c+2,(vlTOPp->a));
	vcdp->chgBit  (c+3,(vlTOPp->b));
	vcdp->chgBit  (c+4,(vlTOPp->sel));
	vcdp->chgBit  (c+6,(((IData)(vlTOPp->sel) ? (IData)(vlTOPp->a)
			      : (IData)(vlTOPp->b))));
	vcdp->chgBit  (c+1,(vlTOPp->clk));
	vcdp->chgBit  (c+5,(vlTOPp->out1));
    }
}
