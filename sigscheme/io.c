/*===========================================================================
 *  FileName : io.c
 *  About    : io related functions
 *
 *  Copyright (C) 2005      by Kazuki Ohta (mover@hct.zaq.ne.jp)
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
 *  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS ``AS IS''
 *  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 *  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 *  ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE
 *  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 *  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
 *  GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 *  HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 *  LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 *  OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 *  SUCH DAMAGE.
===========================================================================*/
/*=======================================
  System Include
=======================================*/
#include <stdio.h>

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
ScmObj scm_std_input_port   = NULL;
ScmObj scm_std_output_port  = NULL;
ScmObj scm_current_input_port   = NULL;
ScmObj scm_current_output_port  = NULL;

ScmObj SigScm_features      = NULL;

static const char *lib_path = NULL;

/*=======================================
  File Local Function Declarations
=======================================*/
#if SCM_GCC4_READY_GC
static SCM_GC_PROTECTED_FUNC_DECL(ScmObj, SigScm_load_internal, (const char *c_filename));
#else
static ScmObj SigScm_load_internal(const char *c_filename);
#endif /* SCM_GCC4_READY_GC */
static char*  create_valid_path(const char *c_filename);
#if SCM_USE_NONSTD_FEATURES
static ScmObj create_loaded_str(ScmObj filename);
static int    file_existsp(const char *filepath);
#endif

/*=======================================
  Function Implementations
=======================================*/
void SigScm_set_lib_path(const char *path)
{
    lib_path = path;
}

/*=======================================
  R5RS : 6.6 Input and Output
=======================================*/
/*===========================================================================
  R5RS : 6.6 Input and Output : 6.6.1 Ports
===========================================================================*/
ScmObj ScmOp_call_with_input_file(ScmObj filepath, ScmObj proc)
{
    ScmObj port = SCM_NULL;
    ScmObj ret  = SCM_NULL;

    if (!STRINGP(filepath))
        SigScm_ErrorObj("call-with-input-file : string required but got", filepath);
    if (!FUNCP(proc) && !CLOSUREP(proc))
        SigScm_ErrorObj("call-with-input-file : proc required but got ", proc);
    
    /* open port */
    port = ScmOp_open_input_file(filepath);
    
    ret = Scm_call(proc, LIST_1(port));

    /* close port */
    ScmOp_close_input_port(port);

    return ret;
}

ScmObj ScmOp_call_with_output_file(ScmObj filepath, ScmObj proc)
{
    ScmObj port = SCM_NULL;
    ScmObj ret  = SCM_NULL;

    if (!STRINGP(filepath))
        SigScm_ErrorObj("call-with-output-file : string required but got ", filepath);
    if (!FUNCP(proc) && !CLOSUREP(proc))
        SigScm_ErrorObj("call-with-output-file : proc required but got ", proc);
    
    /* open port */
    port = ScmOp_open_output_file(filepath);
    
    /* (apply proc (port)) */
    ret = Scm_call(proc, LIST_1(port));

    /* close port */
    ScmOp_close_output_port(port);

    return ret;
}

ScmObj ScmOp_input_portp(ScmObj obj)
{
    if (PORTP(obj) && SCM_PORT_PORTDIRECTION(obj) == PORT_INPUT)
        return SCM_TRUE;

    return SCM_FALSE;
}

ScmObj ScmOp_output_portp(ScmObj obj)
{
    if (PORTP(obj) && SCM_PORT_PORTDIRECTION(obj) == PORT_OUTPUT)
        return SCM_TRUE;

    return SCM_FALSE;
}

ScmObj ScmOp_current_input_port(void)
{
    return scm_current_input_port;
}

ScmObj ScmOp_current_output_port(void)
{
    return scm_current_output_port;
}

ScmObj ScmOp_with_input_from_file(ScmObj filepath, ScmObj thunk)
{
    ScmObj tmp_port = SCM_NULL;
    ScmObj ret      = SCM_NULL;

    if (!STRINGP(filepath))
        SigScm_ErrorObj("with-input-from-file : string required but got ", filepath);
    if (!FUNCP(thunk) && !CLOSUREP(thunk))
        SigScm_ErrorObj("with-input-from-file : proc required but got ", thunk);
    
    /* set scm_current_input_port */
    tmp_port = scm_current_input_port;
    scm_current_input_port = ScmOp_open_input_file(filepath);
    
    /* (apply thunk ())*/
    ret = Scm_call(thunk, SCM_NULL);

    /* close port */
    ScmOp_close_input_port(scm_current_input_port);

    /* restore scm_current_input_port */
    scm_current_input_port = tmp_port;

    return ret;
}

ScmObj ScmOp_with_output_to_file(ScmObj filepath, ScmObj thunk)
{
    ScmObj tmp_port = SCM_NULL;
    ScmObj ret      = SCM_NULL;

    if (!STRINGP(filepath))
        SigScm_ErrorObj("with-output-to-file : string required but got ", filepath);
    if (!FUNCP(thunk) && !CLOSUREP(thunk))
        SigScm_ErrorObj("with-output-to-file : proc required but got ", thunk);
    
    /* set scm_current_output_port */
    tmp_port = scm_current_output_port;
    scm_current_output_port = ScmOp_open_output_file(filepath);
    
    /* (thunk)*/
    ret = Scm_call(thunk, SCM_NULL);

    /* close port */
    ScmOp_close_output_port(scm_current_output_port);

    /* restore scm_current_output_port */
    scm_current_output_port = tmp_port;

    return ret;
}

ScmObj ScmOp_open_input_file(ScmObj filepath)
{
    FILE *f = NULL;

    if (!STRINGP(filepath))
        SigScm_ErrorObj("open-input-file : string requred but got ", filepath);

    /* Open File */
    f = fopen(SCM_STRING_STR(filepath), "r");
    if (!f)
        SigScm_ErrorObj("open-input-file : cannot open file ", filepath);

    /* Allocate ScmPort */
    return Scm_NewFilePort(f, SCM_STRING_STR(filepath), PORT_INPUT);
}

ScmObj ScmOp_open_output_file(ScmObj filepath)
{
    FILE *f = NULL;

    if (!STRINGP(filepath))
        SigScm_ErrorObj("open-output-file : string requred but got ", filepath);

    /* Open File */
    f = fopen(SCM_STRING_STR(filepath), "w");
    if (!f)
        SigScm_ErrorObj("open-output-file : cannot open file ", filepath);

    /* Return new ScmPort */
    return Scm_NewFilePort(f, SCM_STRING_STR(filepath), PORT_OUTPUT);
}

ScmObj ScmOp_close_input_port(ScmObj port)
{
    if (!PORTP(port))
        SigScm_ErrorObj("close-input-port : port requred but got ", port);

    if (SCM_PORTINFO_FILE(port))
        fclose(SCM_PORTINFO_FILE(port));

    return SCM_UNDEF;
}

ScmObj ScmOp_close_output_port(ScmObj port)
{
    if (!PORTP(port))
        SigScm_ErrorObj("close-output-port : port requred but got ", port);
    
    if (SCM_PORTINFO_FILE(port))
        fclose(SCM_PORTINFO_FILE(port));

    return SCM_UNDEF;
}

/*===========================================================================
  R5RS : 6.6 Input and Output : 6.6.2 Input
===========================================================================*/
ScmObj ScmOp_read(ScmObj args)
{
    ScmObj port = scm_current_input_port;

    /* get port */
    if (!NULLP(args) && PORTP(CAR(args)))
        port = CAR(args);

    return SigScm_Read(port);
}

ScmObj ScmOp_read_char(ScmObj args)
{
    ScmObj port = scm_current_input_port;
    char  *buf  = NULL;

    /* get port */
    if (!NULLP(args) && PORTP(CAR(args)))
        port = CAR(args);

    /* TODO : implement this multibyte-char awareness */
    buf = (char *)malloc(sizeof(char) * 2);
    buf[0] = getc(SCM_PORTINFO_FILE(port));
    buf[1] = '\0';
    return Scm_NewChar(buf);
}

ScmObj ScmOp_peek_char(ScmObj arg, ScmObj env)
{
    /* TODO : implement this */
}

ScmObj ScmOp_eof_objectp(ScmObj obj)
{
    return (EOFP(obj)) ? SCM_TRUE : SCM_FALSE;
}

ScmObj ScmOp_char_readyp(ScmObj arg, ScmObj env)
{
    /* TODO : implement this */
}

/*===========================================================================
  R5RS : 6.6 Input and Output : 6.6.3 Output
===========================================================================*/
ScmObj ScmOp_write(ScmObj obj, ScmObj args)
{
    ScmObj port = scm_current_output_port;

    /* get port */
    if (!NULLP(args) && PORTP(CAR(args)))
        port = CAR(args);

    SigScm_WriteToPort(port, obj);
    return SCM_UNDEF;
}

ScmObj ScmOp_display(ScmObj obj, ScmObj args)
{
    ScmObj port = scm_current_output_port;
    
    /* get port */
    if (!NULLP(args) && PORTP(CAR(args)))
        port = CAR(args);

    SigScm_DisplayToPort(port, obj);
    return SCM_UNDEF;
}

ScmObj ScmOp_newline(ScmObj args)
{
    /* get port */
    ScmObj port = scm_current_output_port;

    /* (newline port) */
    if (!NULLP(args) && PORTP(CAR(args)))
        port = CAR(args);

    SigScm_DisplayToPort(port, Scm_NewStringCopying("\n"));
    return SCM_UNDEF;
}

ScmObj ScmOp_write_char(ScmObj obj, ScmObj args)
{
    ScmObj port = scm_current_output_port;

    /* sanity check */
    if (!CHARP(obj))
        SigScm_ErrorObj("write-char : char required but got ", obj);

    /* get port */
    if (!NULLP(args) && PORTP(CAR(args)))
        port = CAR(args);

    SigScm_DisplayToPort(port, obj);
    return SCM_UNDEF;
}

/*===========================================================================
  R5RS : 6.6 Input and Output : 6.6.4 System Interface
===========================================================================*/
ScmObj SigScm_load(const char *c_filename)
{
#if !SCM_GCC4_READY_GC
    ScmObj stack_start = NULL;
#endif
    ScmObj succeeded   = SCM_FALSE;

#if SCM_GCC4_READY_GC
    SCM_GC_CALL_PROTECTED_FUNC(succeeded, SigScm_load_internal, (c_filename));
#else
    /* start protecting stack */
    SigScm_GC_ProtectStack(&stack_start);

    succeeded = SigScm_load_internal(c_filename);

    /* now no need to protect stack */
    SigScm_GC_UnprotectStack(&stack_start);
#endif

    return succeeded;
}

static ScmObj SigScm_load_internal(const char *c_filename)
{
    ScmObj port         = SCM_FALSE;
    ScmObj s_expression = SCM_FALSE;
    ScmObj filepath     = SCM_FALSE;
    char  *c_filepath   = create_valid_path(c_filename);

    CDBG((SCM_DBG_FILE, "loading %s", c_filename));

    /* sanity check */
    if (!c_filepath)
        SigScm_Error("SigScm_load_internal : file \"%s\" not found",
                     c_filename);

    filepath = Scm_NewString(c_filepath);
    port = ScmOp_open_input_file(filepath);
    
    /* read & eval cycle */
    while (s_expression = SigScm_Read(port), !EOFP(s_expression)) {
        EVAL(s_expression, SCM_INTERACTION_ENV);
    }

    ScmOp_close_input_port(port);

    CDBG((SCM_DBG_FILE, "done."));

    return SCM_TRUE;
}

/* FIXME:
 * - Simplify
 * - Avoid using strcat() and strcpy() to increase security. Use strncat(),
 *   strncpy() or other safe functions instead
 */
/* TODO: reject relative paths to ensure security */
static char* create_valid_path(const char *filename)
{
    char *c_filename = strdup(filename);
    char *filepath   = NULL;

    /* construct filepath */
    if (lib_path) {
        /* try absolute path */
        if (file_existsp(c_filename))
            return c_filename;

        /* use lib_path */
        filepath = (char*)malloc(strlen(lib_path) + strlen(c_filename) + 2);
        strcpy(filepath, lib_path);
        strcat(filepath, "/");
        strcat(filepath, c_filename);
        if (file_existsp(filepath)) {
            free(c_filename);
            return filepath;
        }
    }
    
    /* clear */
    if (filepath)
        free(filepath);

    /* fallback */
    filepath = (char*)malloc(strlen(c_filename) + 1);
    strcpy(filepath, c_filename);
    if (file_existsp(filepath)) {
        free(c_filename);
        return filepath;
    }

    free(c_filename);
    free(filepath);
    return NULL;
}

ScmObj ScmOp_load(ScmObj filename)
{
    char *c_filename = SCM_STRING_STR(filename);
    SigScm_load_internal(c_filename);

#if SCM_STRICT_R5RS
    return SCM_UNDEF;
#else
    return SCM_TRUE;
#endif
}

#if SCM_USE_NONSTD_FEATURES
/* FIXME: add ScmObj SigScm_require(const char *c_filename) */

ScmObj ScmOp_require(ScmObj filename)
{
    ScmObj loaded_str = SCM_FALSE;
#if SCM_COMPAT_SIOD
    ScmObj retsym     = SCM_FALSE;
#endif

    if (!STRINGP(filename))
        SigScm_ErrorObj("require : string required but got ", filename);

    loaded_str = create_loaded_str(filename);
    if (FALSEP(ScmOp_providedp(loaded_str))) {
        ScmOp_load(filename);
        ScmOp_provide(loaded_str);
    }

#if SCM_COMPAT_SIOD
    retsym = Scm_Intern(SCM_STRING_STR(loaded_str));
    SCM_SYMBOL_SET_VCELL(retsym, SCM_TRUE);

    return retsym;
#else
    return SCM_TRUE;
#endif
}

static ScmObj create_loaded_str(ScmObj filename)
{
    char  *loaded_str = NULL;
    int    size = 0;

    /* generate loaded_str, contents is filename-loaded* */
    size = (strlen(SCM_STRING_STR(filename)) + strlen("*-loaded*") + 1);
    loaded_str = (char*)malloc(sizeof(char) * size);
    snprintf(loaded_str, size, "*%s-loaded*", SCM_STRING_STR(filename));
    
    return Scm_NewString(loaded_str);
}

/*
 * TODO: replace original specification with a SRFI standard or other de facto
 * standard
 */
ScmObj ScmOp_provide(ScmObj feature)
{
    if (!STRINGP(feature))
        SigScm_ErrorObj("provide : string required but got ", feature);

    /* record to SigScm_features */
    SCM_SYMBOL_SET_VCELL(SigScm_features,
                         CONS(feature, SCM_SYMBOL_VCELL(SigScm_features)));

    return SCM_TRUE;
}

/*
 * TODO: replace original specification with a SRFI standard or other de facto
 * standard
 */
ScmObj ScmOp_providedp(ScmObj feature)
{
    ScmObj provided = SCM_FALSE;

    if (!STRINGP(feature))
        SigScm_ErrorObj("provide : string required but got ", feature);

    provided = ScmOp_member(feature, SCM_SYMBOL_VCELL(SigScm_features));

    return (NFALSEP(provided)) ? SCM_TRUE : SCM_FALSE;
}

/*
 * TODO: describe compatibility with de facto standard of other Scheme
 * implementations
 */
ScmObj ScmOp_file_existsp(ScmObj filepath)
{
    if (!STRINGP(filepath))
        SigScm_ErrorObj("file-exists? : string requred but got ", filepath);

    return (file_existsp(SCM_STRING_STR(filepath))) ? SCM_TRUE : SCM_FALSE;
}

/* TODO: remove to ensure security */
ScmObj ScmOp_delete_file(ScmObj filepath)
{
    if (!STRINGP(filepath))
        SigScm_ErrorObj("delete-file : string requred but got ", filepath);

    if (remove(SCM_STRING_STR(filepath)) == -1)
        SigScm_ErrorObj("delete-file : delete failed. file = ", filepath);
    
    return SCM_TRUE;
}

static int file_existsp(const char *c_filepath)
{
    FILE *f = fopen(c_filepath, "r");
    if (!f)
        return 0;

    fclose(f);
    return 1;
}
#endif /* SCM_USE_NONSTD_FEATURES */
