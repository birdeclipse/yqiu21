// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vfmux.h for the primary calling header

#include "Vfmux.h"             // For This
#include "Vfmux__Syms.h"

//--------------------
// STATIC VARIABLES


//--------------------

VL_CTOR_IMP(Vfmux) {
    Vfmux__Syms* __restrict vlSymsp = __VlSymsp = new Vfmux__Syms(this, name());
    Vfmux* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Reset internal values
    
    // Reset structure values
    clk = VL_RAND_RESET_I(1);
    a = VL_RAND_RESET_I(1);
    b = VL_RAND_RESET_I(1);
    sel = VL_RAND_RESET_I(1);
    out1 = VL_RAND_RESET_I(1);
    __Vclklast__TOP__clk = VL_RAND_RESET_I(1);
    __Vm_traceActivity = VL_RAND_RESET_I(32);
}

void Vfmux::__Vconfigure(Vfmux__Syms* vlSymsp, bool first) {
    if (0 && first) {}  // Prevent unused
    this->__VlSymsp = vlSymsp;
}

Vfmux::~Vfmux() {
    delete __VlSymsp; __VlSymsp=NULL;
}

//--------------------


void Vfmux::eval() {
    Vfmux__Syms* __restrict vlSymsp = this->__VlSymsp; // Setup global symbol table
    Vfmux* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Initialize
    if (VL_UNLIKELY(!vlSymsp->__Vm_didInit)) _eval_initial_loop(vlSymsp);
    // Evaluate till stable
    VL_DEBUG_IF(VL_PRINTF("\n----TOP Evaluate Vfmux::eval\n"); );
    int __VclockLoop = 0;
    QData __Vchange=1;
    while (VL_LIKELY(__Vchange)) {
	VL_DEBUG_IF(VL_PRINTF(" Clock loop\n"););
	vlSymsp->__Vm_activity = true;
	_eval(vlSymsp);
	__Vchange = _change_request(vlSymsp);
	if (++__VclockLoop > 100) vl_fatal(__FILE__,__LINE__,__FILE__,"Verilated model didn't converge");
    }
}

void Vfmux::_eval_initial_loop(Vfmux__Syms* __restrict vlSymsp) {
    vlSymsp->__Vm_didInit = true;
    _eval_initial(vlSymsp);
    vlSymsp->__Vm_activity = true;
    int __VclockLoop = 0;
    QData __Vchange=1;
    while (VL_LIKELY(__Vchange)) {
	_eval_settle(vlSymsp);
	_eval(vlSymsp);
	__Vchange = _change_request(vlSymsp);
	if (++__VclockLoop > 100) vl_fatal(__FILE__,__LINE__,__FILE__,"Verilated model didn't DC converge");
    }
}

//--------------------
// Internal Methods

VL_INLINE_OPT void Vfmux::_sequent__TOP__1(Vfmux__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_PRINTF("    Vfmux::_sequent__TOP__1\n"); );
    Vfmux* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    // ALWAYS at rtl/flop.v:11
    vlTOPp->out1 = ((IData)(vlTOPp->sel) ? (IData)(vlTOPp->a)
		     : (IData)(vlTOPp->b));
}

void Vfmux::_eval(Vfmux__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_PRINTF("    Vfmux::_eval\n"); );
    Vfmux* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    if (((IData)(vlTOPp->clk) & (~ (IData)(vlTOPp->__Vclklast__TOP__clk)))) {
	vlTOPp->_sequent__TOP__1(vlSymsp);
    }
    // Final
    vlTOPp->__Vclklast__TOP__clk = vlTOPp->clk;
}

void Vfmux::_eval_initial(Vfmux__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_PRINTF("    Vfmux::_eval_initial\n"); );
    Vfmux* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
}

void Vfmux::final() {
    VL_DEBUG_IF(VL_PRINTF("    Vfmux::final\n"); );
    // Variables
    Vfmux__Syms* __restrict vlSymsp = this->__VlSymsp;
    Vfmux* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
}

void Vfmux::_eval_settle(Vfmux__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_PRINTF("    Vfmux::_eval_settle\n"); );
    Vfmux* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
}

VL_INLINE_OPT QData Vfmux::_change_request(Vfmux__Syms* __restrict vlSymsp) {
    VL_DEBUG_IF(VL_PRINTF("    Vfmux::_change_request\n"); );
    Vfmux* __restrict vlTOPp VL_ATTR_UNUSED = vlSymsp->TOPp;
    // Body
    // Change detection
    QData __req = false;  // Logically a bool
    return __req;
}
