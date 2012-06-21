#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "../ppport.h"

#include "mruby.h"
#include "mruby/array.h"
#include "mruby/class.h"
#include "mruby/compile.h"
#include "mruby/hash.h"
#include "mruby/khash.h"
#include "mruby/proc.h"
#include "mruby/string.h"
#include "mruby/variable.h"

KHASH_DECLARE(ht, mrb_value, mrb_value, 1);
/* KHASH_DEFINE (ht, mrb_value, mrb_value, 1, mrb_hash_ht_hash_func, mrb_hash_ht_hash_equal); */

static
SV * mrb_value2sv(mrb_value v) {
    switch (mrb_type(v)) {
    case MRB_TT_FALSE:
        return &PL_sv_undef;
    case MRB_TT_FIXNUM:
        return newSViv(mrb_fixnum(v));
    case MRB_TT_STRING:
        return newSVpv((char*)RSTRING_PTR(v), (STRLEN)RSTRING_LEN(v));
    case MRB_TT_HASH: {
        HV * ret = newHV();
        khash_t(ht) * h = RHASH_TBL(v);
        khiter_t k;

        if (!h) { abort(); }
        for (k = kh_begin(h); k != kh_end(h); k++) {
            if (kh_exist(h, k)) {
                mrb_value kk = kh_key(h,k);
                mrb_value vv = kh_value(h,k);

                STRLEN key_len;
                char *key = SvPV(mrb_value2sv(kk), key_len);
                hv_store(ret, key, key_len, mrb_value2sv(vv), 0);
            }
        }

        return newRV_noinc((SV*)ret);
    }
    case MRB_TT_ARRAY: {
        int len = RARRAY_LEN(v);
        AV * ret = newAV();
        int i;
        mrb_value *ptr = RARRAY_PTR(v);
        for (i=0; i<len; i++) {
            av_push(ret, mrb_value2sv(ptr[i]));
        }
        return newRV_noinc((SV*)ret);
    }
    default:
        croak("This type of ruby value is not supported yet: %d", mrb_type(v));
    }
    abort();
}

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
        mXPUSHs(mrb_value2sv(ret));
        XSRETURN(1);

MODULE = mRuby      PACKAGE = mRuby::ParserState

void
pool_close(struct mrb_parser_state* st)
    PPCODE:
        mrb_pool_close(st->pool);
        XSRETURN_UNDEF;

MODULE = mRuby      PACKAGE = mRuby::RProc

