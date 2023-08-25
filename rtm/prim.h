EXPORT struct cdf_prim_loc {
	unsigned int __count;
	wchar_t **__names;
	struct cell_func *cdf_q_signal;
	struct cell_func *cdf_q_dr;
	struct cell_array *cdf_spn;
	struct cell_doper_box *cdf_eq;
	struct cell_func_box *cdf_squeeze;
	struct cell_func_box *cdf_is_simple;
	struct cell_func_box *cdf_is_numeric;
	struct cell_func_box *cdf_is_char;
	struct cell_func_box *cdf_is_integer;
	struct cell_func_box *cdf_is_bool;
	struct cell_func_box *cdf_is_span;
	struct cell_func_box *cdf_max_shp;
	struct cell_func_box *cdf_has_nat_vals;
	struct cell_func_box *cdf_chk_scl;
	struct cell_func_box *cdf_both_simple;
	struct cell_func_box *cdf_both_numeric;
	struct cell_func_box *cdf_both_integer;
	struct cell_func_box *cdf_both_char;
	struct cell_func_box *cdf_both_bool;
	struct cell_func_box *cdf_any;
	struct cell_moper *cdf_numeric;
	struct cell_doper *cdf_ambiv;
	struct cell_func_box *cdf_same;
	struct cell_moper_box *cdf_veach;
	struct cell_moper_box *cdf_scalar;
	struct cell_func_box *cdf_chk_valid_shape;
	struct cell_func *cdf_reshape;
	struct cell_func *cdf_rho;
	struct cell_func_box *cdf_idx_rnk_check;
	struct cell_func_box *cdf_idx_rng_check;
	struct cell_func_box *cdf_flatten_idx;
	struct cell_func_box *cdf_idx_shp_check;
	struct cell_moper_box *cdf_set_get_idx;
	struct cell_func *cdf_set;
	struct cell_doper *cdf_mst_vals;
	struct cell_moper *cdf_mst;
	struct cell_func *cdf_materialize;
	struct cell_func *cdf_sqd_idx;
	struct cell_func *cdf_sqd;
	struct cell_func *cdf_brk;
	struct cell_func *cdf_rgt;
	struct cell_func *cdf_lft;
	struct cell_func *cdf_ravel;
	struct cell_func *cdf_catenate;
	struct cell_func *cdf_cat;
	struct cell_func *cdf_table;
	struct cell_func *cdf_catenatefirst;
	struct cell_func *cdf_ctf;
	struct cell_func *cdf_depth;
	struct cell_func *cdf_eqv;
	struct cell_func *cdf_nqv;
	struct cell_func *cdf_index_gen;
	struct cell_func *cdf_index_of;
	struct cell_func *cdf_iot;
	struct cell_func *cdf_disclose;
	struct cell_func *cdf_pick;
	struct cell_func *cdf_dis;
	struct cell_func *cdf_enclose;
	struct cell_func *cdf_par;
	struct cell_func *cdf_nest;
	struct cell_func *cdf_nst;
	struct cell_func *cdf_conjugate;
	struct cell_func *cdf_add;
	struct cell_func *cdf_sub;
	struct cell_func *cdf_sign;
	struct cell_func *cdf_mul;
	struct cell_func *cdf_div;
	struct cell_func *cdf_absolute;
	struct cell_func *cdf_residue;
	struct cell_func *cdf_res;
	struct cell_func *cdf_floor_array;
	struct cell_func *cdf_min;
	struct cell_func *cdf_ceil_array;
	struct cell_func *cdf_max;
	struct cell_func *cdf_exp;
	struct cell_func *cdf_log;
	struct cell_func *cdf_pitimes;
	struct cell_func *cdf_trig;
	struct cell_func *cdf_cir;
	struct cell_func *cdf_binomial;
	struct cell_func *cdf_fac;
	struct cell_func *cdf_notscl;
	struct cell_func *cdf_without;
	struct cell_func *cdf_not;
	struct cell_func *cdf_logand;
	struct cell_func *cdf_and;
	struct cell_func *cdf_logor;
	struct cell_func *cdf_lor;
	struct cell_func *cdf_nan;
	struct cell_func *cdf_nor;
	struct cell_func *cdf_lessthan;
	struct cell_func *cdf_lth;
	struct cell_func *cdf_lesseql;
	struct cell_func *cdf_lte;
	struct cell_func_box *cdf_eql_vec;
	struct cell_func *cdf_equal;
	struct cell_func *cdf_eql;
	struct cell_func *cdf_greatereql;
	struct cell_func *cdf_gte;
	struct cell_func *cdf_greaterthan;
	struct cell_func *cdf_gth;
	struct cell_func *cdf_firstocc;
	struct cell_func_box *cdf_neq_vec;
	struct cell_func *cdf_noteq;
	struct cell_func *cdf_neq;
	struct cell_func *cdf_mix;
	struct cell_func *cdf_take;
	struct cell_func *cdf_tke;
	struct cell_func *cdf_split;
	struct cell_func *cdf_drop;
	struct cell_func *cdf_drp;
	struct cell_func_box *cdf_reverse_axis;
	struct cell_func_box *cdf_rotate_axis;
	struct cell_func *cdf_reverse_first;
	struct cell_func *cdf_rotate_first;
	struct cell_func *cdf_rtf;
	struct cell_func *cdf_reverse_last;
	struct cell_func *cdf_rotate_last;
	struct cell_func *cdf_rot;
	struct cell_func *cdf_transpose;
	struct cell_func *cdf_transpose_target;
	struct cell_func *cdf_trn;
	struct cell_func *cdf_gdu;
	struct cell_func *cdf_gdd;
	struct cell_func *cdf_enc;
	struct cell_func *cdf_dec;
	struct cell_func *cdf_enlist;
	struct cell_func *cdf_member;
	struct cell_func *cdf_mem;
	struct cell_func *cdf_fnd;
	struct cell_func *cdf_unique;
	struct cell_func *cdf_union;
	struct cell_func *cdf_unq;
	struct cell_func *cdf_int;
	struct cell_func *cdf_stn;
	struct cell_func *cdf_deal;
	struct cell_func *cdf_roll;
	struct cell_func *cdf_rol;
	struct cell_func *cdf_matinv;
	struct cell_func *cdf_matdiv;
	struct cell_func *cdf_mdv;
	struct cell_moper *cdf_com;
	struct cell_moper *cdf_map;
	struct cell_moper_box *cdf_identity;
	struct cell_doper_box *cdf_reduce;
	struct cell_doper_box *cdf_nwreduce;
	struct cell_func_box *cdf_red_check;
	struct cell_moper *cdf_rdf;
	struct cell_moper *cdf_red;
	struct cell_func_box *cdf_where_nz;
	struct cell_func *cdf_where;
	struct cell_func *cdf_interval_idx;
	struct cell_func *cdf_iou;
	struct cell_func *cdf_rpf;
	struct cell_func *cdf_rep;
	struct cell_doper_box *cdf_scan;
	struct cell_moper *cdf_scf;
	struct cell_moper *cdf_scn;
	struct cell_func *cdf_xpf;
	struct cell_func *cdf_xpd;
	struct cell_moper *cdf_oup;
	struct cell_doper *cdf_dot;
	struct cell_doper *cdf_pow;
	struct cell_doper *cdf_jot;
	struct cell_doper *cdf_rnk;
	struct cell_moper *cdf_key;
} cdf_prim;

