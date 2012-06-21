#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "../ppport.h"

#include "mruby.h"
#include "mruby/proc.h"
#include "mruby/compile.h"
#include "mruby/string.h"

MODULE = mRuby      PACKAGE = mRuby

MODULE = mRuby      PACKAGE = mRuby::State

void
new(const char *klass)
    PPCODE:
        mrb_state* mrb = mrb_open();
        XPUSHs(sv_bless(newRV_noinc(sv_2mortal(newSViv(PTR2IV(mrb)))), gv_stashpv(klass, TRUE)));
        XSRETURN(1);

void
parse_string(mrb_state *mrb, const char *src)
    PPCODE:
        struct mrb_parser_state* st = mrb_parse_string(mrb, src);
        XPUSHs(sv_bless(newRV_noinc(sv_2mortal(newSViv(PTR2IV(st)))), gv_stashpv("mRuby::ParserState", TRUE)));
        XSRETURN(1);

void
generate_code(mrb_state *mrb, struct mrb_parser_state* st)
    PPCODE:
        int n = mrb_generate_code(mrb, st->tree);
        XSRETURN_IV(n);

void
proc_new(mrb_state *mrb, int n)
    PPCODE:
        struct RProc * proc = mrb_proc_new(mrb, mrb->irep[n]);
        XPUSHs(sv_bless(newRV_noinc(sv_2mortal(newSViv(PTR2IV(proc)))), gv_stashpv("mRuby::RProc", TRUE)));
        XSRETURN(1);

void
run(mrb_state *mrb, struct RProc* proc, SV *val)
    PPCODE:
        mrb_value ret = mrb_run(mrb, proc, mrb_nil_value());
        switch (ret.tt) {
            case MRB_TT_FALSE:
                XSRETURN_UNDEF;
                break;
            case MRB_TT_FIXNUM:
                mXPUSHi(mrb_fixnum(ret));
                XSRETURN(1);
            case MRB_TT_STRING:
                mXPUSHp((char*)RSTRING_PTR(ret), (STRLEN)RSTRING_LEN(ret));
                XSRETURN(1);
            default:
                /* to do more... */
                abort();
        }
        abort();

MODULE = mRuby      PACKAGE = mRuby::ParserState

void
pool_close(struct mrb_parser_state* st)
    PPCODE:
        mrb_pool_close(st->pool);
        XSRETURN_UNDEF;

MODULE = mRuby      PACKAGE = mRuby::RProc

