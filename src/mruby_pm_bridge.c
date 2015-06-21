#include "mruby_pm_bridge.h"

#include "mruby/array.h"
#include "mruby/hash.h"
#include "mruby/string.h"
#include "mruby/error.h"

#define hv_foreach(hv, entry, block) {  \
  HV* hash = hv;                        \
  hv_iterinit(hash);                    \
  HE* entry;                            \
  while ((entry = hv_iternext(hash))) { \
    block;                              \
  }                                     \
}


SV * mruby_pm_bridge_value2sv(pTHX_ mrb_state *mrb, const mrb_value v) {
    switch (mrb_type(v)) {
    case MRB_TT_UNDEF:
      return &PL_sv_undef;
    case MRB_TT_FALSE: {
      if (mrb_fixnum(v)) {
        return sv_bless(newRV_inc(sv_2mortal(newSVsv(&PL_sv_undef))), gv_stashpv("mRuby::Bool::False", TRUE));
      }
      else {
        return &PL_sv_undef;
      }
    }
    case MRB_TT_TRUE:
      return sv_bless(newRV_inc(sv_2mortal(newSViv(1))), gv_stashpv("mRuby::Bool::True", TRUE));
    case MRB_TT_FIXNUM:
      return newSViv(mrb_fixnum(v));
    case MRB_TT_FLOAT:
      return newSVnv(mrb_float(v));
    case MRB_TT_STRING:
      return newSVpvn((char*)RSTRING_PTR(v), (STRLEN)RSTRING_LEN(v));
    case MRB_TT_SYMBOL: {
      mrb_int len;
      const char *name = mrb_sym2name_len(mrb, mrb_symbol(v), &len);
      return sv_bless(newRV_inc(sv_2mortal(newSVpvn((char*)name, (STRLEN)len))), gv_stashpv("mRuby::Symbol", TRUE));
    }
    case MRB_TT_HASH: {
      const mrb_value  keys = mrb_hash_keys(mrb, v);
      const mrb_value *ptr  = RARRAY_PTR(keys);
      const int        len  = RARRAY_LEN(keys);

      HV * ret = newHV_mortal();

      int i;
      for (i=0; LIKELY(i<len); i++) {
        const mrb_value kk = ptr[i];
        const mrb_value vv = mrb_hash_get(mrb, v, kk);

        SV * key_sv = sv_2mortal(mruby_pm_bridge_value2sv(aTHX_ mrb, kk));
        SV * val_sv = mruby_pm_bridge_value2sv(aTHX_ mrb, vv);
        hv_store_ent(ret, key_sv, SvROK(val_sv) ? SvREFCNT_inc(sv_2mortal(val_sv)) : val_sv, 0);
      }

      return newRV_inc((SV*)ret);
    }
    case MRB_TT_ARRAY: {
      const mrb_value *ptr = RARRAY_PTR(v);
      const int        len = RARRAY_LEN(v);

      AV * ret = newAV_mortal();

      int i;
      for (i=0; LIKELY(i<len); i++) {
        SV * val_sv = mruby_pm_bridge_value2sv(aTHX_ mrb, ptr[i]);
        av_push(ret, SvROK(val_sv) ? SvREFCNT_inc(sv_2mortal(val_sv)) : val_sv);
      }

      return newRV_inc((SV*)ret);
    }
    case MRB_TT_EXCEPTION: {
      mrb_value bt = mrb_exc_backtrace(mrb, v);
      return sv_bless(SvREFCNT_inc(sv_2mortal(mruby_pm_bridge_value2sv(aTHX_ mrb, bt))), gv_stashpv("mRuby::Exception", TRUE));
    }
    default:
      croak("This type of ruby value is not supported yet: %d", mrb_type(v));
    }
    abort();
}

