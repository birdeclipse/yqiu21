// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Tracing implementation internals
#include "verilated_vcd_c.h"
#include "Vfmux__Syms.h"


//======================

void Vfmux::trace (VerilatedVcdC* tfp, int, int) {
    tfp->spTrace()->addCallback (&Vfmux::traceInit, &Vfmux::traceFull, &Vfmux::traceChg, this);
}
void Vfmux::traceInit(VerilatedVcd* vcdp, void* userthis, uint32_t code) {
    // Callback from vcd->open()
    Vfmux* t=(Vfmux*)userthis;
    Vfmux__Syms* __restrict vlSymsp = t->__VlSymsp; // Setup global symbol table
    if (!Verilated::calcUnusedSigs()) vl_fatal(__FILE__,__LINE__,__FILE__,"Turning on wave traces requires Verilated::traceEverOn(true) call before time 0.");
    vcdp->scopeEscape(' ');
    t->traceInitThis (vlSymsp, vcdp, code);
    vcdp->scopeEscape('.');
}
void Vfmux::traceFull(VerilatedVcd* vcdp, void* userthis, uint32_t code) {
    // Callback from vcd->dump()
    Vfmux* t=(Vfmux*)userthis;
    Vfmux__Syms* __restrict vlSymsp = t->__VlSymsp; // Setup global symbol table
    t->traceFullThis (vlSymsp, vcdp, code);
}

//======================


void Vfmux::traceInitThis(Vfmux__Syms* __restrict vlSymsp, VerilatedVcd* vcdp, uint32_t code) {
    Vfmux* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    int c=code;
    if (0 && vcdp && c) {}  // Prevent unused
    vcdp->module(vlSymsp->name()); // Setup signal names
    // Body
    {
	vlTOPp->traceInitThis__1(vlSymsp, vcdp, code);
    }
}

void Vfmux::traceFullThis(Vfmux__Syms* __restrict vlSymsp, VerilatedVcd* vcdp, uint32_t code) {
    Vfmux* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    int c=code;
    if (0 && vcdp && c) {}  // Prevent unused
    // Body
    {
	vlTOPp->traceFullThis__1(vlSymsp, vcdp, code);
    }
    // Final
    vlTOPp->__Vm_traceActivity = 0U;
}

void Vfmux::traceInitThis__1(Vfmux__Syms* __restrict vlSymsp, VerilatedVcd* vcdp, uint32_t code) {
    Vfmux* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    int c=code;
    if (0 && vcdp && c) {}  // Prevent unused
    // Body
    {
	vcdp->declBit  (c+1,"clk",-1);
	vcdp->declBit  (c+2,"a",-1);
	vcdp->declBit  (c+3,"b",-1);
	vcdp->declBit  (c+4,"sel",-1);
	vcdp->declBit  (c+5,"out1",-1);
	vcdp->declBit  (c+1,"v clk",-1);
	vcdp->declBit  (c+2,"v a",-1);
	vcdp->declBit  (c+3,"v b",-1);
	vcdp->declBit  (c+4,"v sel",-1);
	vcdp->declBit  (c+5,"v out1",-1);
	vcdp->declBit  (c+6,"v out1_next",-1);
	vcdp->declBit  (c+1,"v f clk",-1);
	vcdp->declBit  (c+6,"v f d",-1);
	vcdp->declBit  (c+5,"v f q",-1);
    }
}

void Vfmux::traceFullThis__1(Vfmux__Syms* __restrict vlSymsp, VerilatedVcd* vcdp, uint32_t code) {
    Vfmux* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    int c=code;
    if (0 && vcdp && c) {}  // Prevent unused
    // Body
    {
	vcdp->fullBit  (c+2,(vlTOPp->a));
	vcdp->fullBit  (c+3,(vlTOPp->b));
	vcdp->fullBit  (c+4,(vlTOPp->sel));
	vcdp->fullBit  (c+6,(((IData)(vlTOPp->sel) ? (IData)(vlTOPp->a)
			       : (IData)(vlTOPp->b))));
	vcdp->fullBit  (c+1,(vlTOPp->clk));
	vcdp->fullBit  (c+5,(vlTOPp->out1));
    }
}
