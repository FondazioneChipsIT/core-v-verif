# gvsoc-developer agent memory

## Applied Fixes

- [fix_d20_mhpmcounter_write_illegal.md](./fix_d20_mhpmcounter_write_illegal.md) — D20: mhpmcounter unimplemented CSRs use write_illegal=true (not write_mask=0)
- [fix_d21_mret_sret_mcause_zero.md](./fix_d21_mret_sret_mcause_zero.md) — D21: remove illegal mcause/scause zero on mret/sret (non-compliant, spec says only trap entry writes cause CSRs)
