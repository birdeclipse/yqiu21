// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Primary design header
//
// This header should be included by all source files instantiating the design.
// The class here is then constructed to instantiate the design.
// See the Verilator manual for examples.

#ifndef _Vfmux_H_
#define _Vfmux_H_

#include "verilated.h"
class Vfmux__Syms;
class VerilatedVcd;

//----------

VL_MODULE(Vfmux) {
  public:
    // CELLS
    // Public to allow access to /*verilator_public*/ items;
    // otherwise the application code can consider these internals.
    
    // PORTS
    // The application code writes and reads these signals to
    // propagate new values into/out from the Verilated model.
    VL_IN8(clk,0,0);
    VL_IN8(a,0,0);
    VL_IN8(b,0,0);
    VL_IN8(sel,0,0);
    VL_OUT8(out1,0,0);
    //char	__VpadToAlign5[3];
    
    // LOCAL SIGNALS
    // Internals; generally not touched by application code
    
    // LOCAL VARIABLES
    // Internals; generally not touched by application code
    VL_SIG8(__Vclklast__TOP__clk,0,0);
    //char	__VpadToAlign17[3];
    VL_SIG(__Vm_traceActivity,31,0);
    
    // INTERNAL VARIABLES
    // Internals; generally not touched by application code
    //char	__VpadToAlign28[4];
    Vfmux__Syms*	__VlSymsp;		// Symbol table
    
    // PARAMETERS
    // Parameters marked /*verilator public*/ for use by application code
    
    // CONSTRUCTORS
  private:
    Vfmux& operator= (const Vfmux&);	///< Copying not allowed
    Vfmux(const Vfmux&);	///< Copying not allowed
  public:
    /// Construct the model; called by application code
    /// The special name  may be used to make a wrapper with a
    /// single model invisible WRT DPI scope names.
    Vfmux(const char* name="TOP");
    /// Destroy the model; called (often implicitly) by application code
    ~Vfmux();
    /// Trace signals in the model; called by application code
    void trace (VerilatedVcdC* tfp, int levels, int options=0);
    
    // USER METHODS
    
    // API METHODS
    /// Evaluate the model.  Application must call when inputs change.
    void eval();
    /// Simulation complete, run final blocks.  Application must call on completion.
    void final();
    
    // INTERNAL METHODS
  private:
    static void _eval_initial_loop(Vfmux__Syms* __restrict vlSymsp);
  public:
    void __Vconfigure(Vfmux__Syms* symsp, bool first);
  private:
    static QData	_change_request(Vfmux__Syms* __restrict vlSymsp);
  public:
    static void	_eval(Vfmux__Syms* __restrict vlSymsp);
    static void	_eval_initial(Vfmux__Syms* __restrict vlSymsp);
    static void	_eval_settle(Vfmux__Syms* __restrict vlSymsp);
    static void	_sequent__TOP__1(Vfmux__Syms* __restrict vlSymsp);
    static void	traceChgThis(Vfmux__Syms* __restrict vlSymsp, VerilatedVcd* vcdp, uint32_t code);
    static void	traceChgThis__2(Vfmux__Syms* __restrict vlSymsp, VerilatedVcd* vcdp, uint32_t code);
    static void	traceFullThis(Vfmux__Syms* __restrict vlSymsp, VerilatedVcd* vcdp, uint32_t code);
    static void	traceFullThis__1(Vfmux__Syms* __restrict vlSymsp, VerilatedVcd* vcdp, uint32_t code);
    static void	traceInitThis(Vfmux__Syms* __restrict vlSymsp, VerilatedVcd* vcdp, uint32_t code);
    static void	traceInitThis__1(Vfmux__Syms* __restrict vlSymsp, VerilatedVcd* vcdp, uint32_t code);
    static void traceInit (VerilatedVcd* vcdp, void* userthis, uint32_t code);
    static void traceFull (VerilatedVcd* vcdp, void* userthis, uint32_t code);
    static void traceChg  (VerilatedVcd* vcdp, void* userthis, uint32_t code);
} VL_ATTR_ALIGNED(128);

#endif  /*guard*/
