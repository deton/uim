/*===========================================================================
 *  FileName : vector.c
 *  About    : R5RS vectors
 *
 *  Copyright (C) 2005-2006 Kazuki Ohta <mover AT hct.zaq.ne.jp>
 *
 *  All rights reserved.
 *
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions
 *  are met:
 *
 *  1. Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *  2. Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in the
 *     documentation and/or other materials provided with the distribution.
 *  3. Neither the name of authors nor the names of its contributors
 *     may be used to endorse or promote products derived from this software
 *     without specific prior written permission.
 *
 *  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS ``AS
 *  IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 *  THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 *  PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR
 *  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 *  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
 *  OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 *  WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 *  OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 *  ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
===========================================================================*/

#include "config.h"

/*=======================================
  System Include
=======================================*/

/*=======================================
  Local Include
=======================================*/
#include "sigscheme.h"
#include "sigschemeinternal.h"

/*=======================================
  File Local Struct Declarations
=======================================*/

/*=======================================
  File Local Macro Declarations
=======================================*/

/*=======================================
  Variable Declarations
=======================================*/

/*=======================================
  File Local Function Declarations
=======================================*/

/*=======================================
  Function Implementations
=======================================*/
/*===========================================================================
  R5RS : 6.3 Other data types : 6.3.6 Vectors
===========================================================================*/
ScmObj
scm_p_vectorp(ScmObj obj)
{
    DECLARE_FUNCTION("vector?", procedure_fixed_1);

    return MAKE_BOOL(VECTORP(obj));
}

ScmObj
scm_p_make_vector(ScmObj scm_len, ScmObj args)
{
    ScmObj *vec, filler;
    scm_int_t len, i;
    DECLARE_FUNCTION("make-vector", procedure_variadic_1);

    ENSURE_INT(scm_len);

    len = SCM_INT_VALUE(scm_len);
    if (len < 0)
        ERR_OBJ("length must be a positive integer", scm_len);

    vec = scm_malloc(sizeof(ScmObj) * len);
    if (NULLP(args)) {
        filler = SCM_UNDEF;
    } else {
        filler = POP(args);
        ASSERT_NO_MORE_ARG(args);
    }
    for (i = 0; i < len; i++)
        vec[i] = filler;

    return MAKE_VECTOR(vec, len);
}

ScmObj
scm_p_vector(ScmObj args)
{
    DECLARE_FUNCTION("vector", procedure_variadic_0);

    return scm_p_list2vector(args);
}

ScmObj
scm_p_vector_length(ScmObj vec)
{
    DECLARE_FUNCTION("vector-length", procedure_fixed_1);

    ENSURE_VECTOR(vec);

    return MAKE_INT(SCM_VECTOR_LEN(vec));
}

ScmObj
scm_p_vector_ref(ScmObj vec, ScmObj _k)
{
    scm_int_t k;
    DECLARE_FUNCTION("vector-ref", procedure_fixed_2);

    ENSURE_VECTOR(vec);
    ENSURE_INT(_k);

    k = SCM_INT_VALUE(_k);

    if (!SCM_VECTOR_VALID_INDEXP(vec, k))
        ERR_OBJ("index out of range", _k);

    return SCM_VECTOR_VEC(vec)[k];
}

ScmObj
scm_p_vector_setd(ScmObj vec, ScmObj _k, ScmObj obj)
{
    scm_int_t k;
    DECLARE_FUNCTION("vector-set!", procedure_fixed_3);

    ENSURE_VECTOR(vec);
#if SCM_CONST_VECTOR_LITERAL
    ENSURE_MUTABLE_VECTOR(vec);
#endif
    ENSURE_INT(_k);

    k = SCM_INT_VALUE(_k);

    if (!SCM_VECTOR_VALID_INDEXP(vec, k))
        ERR_OBJ("index out of range", _k);

    SCM_VECTOR_VEC(vec)[k] = obj;

    return SCM_UNDEF;
}

ScmObj
scm_p_vector2list(ScmObj vec)
{
    ScmQueue q;
    ScmObj res, *v;
    scm_int_t len, i;
    DECLARE_FUNCTION("vector->list", procedure_fixed_1);

    ENSURE_VECTOR(vec);

    v   = SCM_VECTOR_VEC(vec);
    len = SCM_VECTOR_LEN(vec);

    res = SCM_NULL;
    SCM_QUEUE_POINT_TO(q, res);
    for (i = 0; i < len; i++)
        SCM_QUEUE_ADD(q, v[i]);

    return res;
}

ScmObj
scm_p_list2vector(ScmObj lst)
{
    ScmObj *vec;
    scm_int_t len, i;
    DECLARE_FUNCTION("list->vector", procedure_fixed_1);

    len = scm_length(lst);
    if (!SCM_LISTLEN_PROPERP(len))
        ERR_OBJ("proper list required but got", lst);

    vec = scm_malloc(sizeof(ScmObj) * len);
    for (i = 0; i < len; i++)
        vec[i] = POP(lst);

    return MAKE_VECTOR(vec, len);
}

ScmObj
scm_p_vector_filld(ScmObj vec, ScmObj fill)
{
    ScmObj *v;
    scm_int_t len, i;
    DECLARE_FUNCTION("vector-fill!", procedure_fixed_2);

    ENSURE_VECTOR(vec);
#if SCM_CONST_VECTOR_LITERAL
    ENSURE_MUTABLE_VECTOR(vec);
#endif

    v   = SCM_VECTOR_VEC(vec);
    len = SCM_VECTOR_LEN(vec);
    for (i = 0; i < len; i++)
        v[i] = fill;

    return vec;
}
