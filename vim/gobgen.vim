" Vim GObject generator plugin
" Last Change: 2007 Sep 10
" Maintainer: Andrey Dubravin <daa84@inbox.ru>
" Modified: Andre Moreira Magalhaes <andrunko@gmail.com>
" License: This file is placed in the public domain.

if exists("loaded_gobgen")
    finish
endif
let loaded_gobgen = 1

function! GOBGenerateC()
    if input("Use filename to generate object name (y/n)? ", "y") != "y"
        let prefix = input("Enter object prefix name (flybird-directory): ")
    else
        let prefix = expand("%:t:r")
    endif

    if prefix == ""
        echohl ErrorMsg
        echo "Can't create class without prefix"
        echohl None
        return
    endif

    let parentName = input("Enter parent type name (Default G_TYPE_OBJECT): ")
    if parentName == ""
        let parentName = "G_TYPE_OBJECT"
    endif

    let prefix = substitute(prefix, "-", "_", "g")

    let typeName = substitute(prefix, "_\\(.\\)\\|^\\(.\\)", "\\U\\1\\U\\2", "g")
    let typeNamePrivate = typeName . "Private"

    let defineName = toupper(prefix)

    exec "normal I#ifdef HAVE_CONFIG_H"
    exec "normal o#include \"config.h\""
    exec "normal o#endif"
    normal o

    exec "normal otypedef struct _" . typeName . "Private " . typeName . "Private;"
    normal o

    exec "normal ostruct _" . typeNamePrivate
    normal o{
    normal o};
    normal o

    exec "normal o#define" defineName . "_GET_PRIVATE(o) \\"
    exec "normal o(G_TYPE_INSTANCE_GET_PRIVATE ((o)," defineName . "_TYPE," typeNamePrivate . "))"
    normal o

    exec "normal ostatic void " . prefix . "_class_init (" . typeName . "Class *klass);"
    exec "normal ostatic void " . prefix . "_init       (" . typeName "*self);"
    exec "normal ostatic void " . prefix . "_dispose    (GObject *object);"
    exec "normal ostatic void " . prefix . "_finalize   (GObject *object);"
    exec "normal ostatic void " . prefix . "_set_property (GObject *object, guint property_id, const GValue *value, GParamSpec *pspec);"
    exec "normal ostatic void " . prefix . "_get_property (GObject *object, guint property_id, GValue *value, GParamSpec *pspec);"
    normal o

    exec "normal oG_DEFINE_TYPE (" . typeName . "," prefix . ", " . parentName . ");"
    normal o

    normal oenum {
    normal oPROP_ZERO,
    normal oN_PROPERTIES
    normal o};
    normal o

    normal oenum {
    normal oSIGNAL_0,
    normal oN_SIGNALS
    normal o};
    normal o

    normal ostatic int obj_signals[N_SIGNALS] = { 0, };
    normal o

    normal ostatic GParamSpec *obj_properties[N_PROPERTIES] = { NULL, };
    normal o

    " class init
    normal ostatic void
    exec "normal o" . prefix . "_class_init (" . typeName . "Class *klass)"
    normal o{
    exec "normal oGObjectClass *object_class = G_OBJECT_CLASS (klass);"
    normal o
    exec "normal og_type_class_add_private (klass, sizeof (" . typeNamePrivate . "));"
    normal o
    exec "normal oobject_class->dispose =" prefix . "_dispose;"
    exec "normal oobject_class->finalize =" prefix . "_finalize;"
    exec "normal oobject_class->set_property = " prefix . "_set_property;"
    exec "normal oobject_class->get_property = " prefix . "_get_property;"
    normal og_object_class_install_properties (object_class,
    normal oN_PROPERTIES,
    normal oobj_properties);
    normal o}
    normal o

    " set_property
    normal ostatic void
    exec "normal o" . prefix . "_set_property (GObject *object,"
    normal oguint property_id,
    normal oconst GValue *value,
    normal oGParamSpec *pspec)
    normal o{
    exec "normal o" . typeName . " *self = " . defineName . " (object);"
    normal oswitch (property_id) {
    normal odefault:
    normal oG_OBJECT_WARN_INVALID_PROPERTY_ID (object, property_id, pspec);
    normal obreak;
    normal o}
    normal o}
    normal o

    " get_property
    normal ostatic void
    exec "normal o" . prefix . "_get_property (GObject *object,"
    normal oguint property_id,
    normal oGValue *value,
    normal oGParamSpec *pspec)
    normal o{
    exec "normal o" . typeName . " *self = " . defineName . " (object);"
    normal oswitch (property_id) {
    normal odefault:
    normal oG_OBJECT_WARN_INVALID_PROPERTY_ID (object, property_id, pspec);
    normal obreak;
    normal o}
    normal o}

    " init
    normal ostatic void
    exec "normal o" . prefix . "_init (" . typeName "*self)"
    normal o{
    exec "normal o" . typeName . "Private *priv;"
    exec "normal opriv = self->priv = " . defineName . "_GET_PRIVATE (self);"
    normal o}
    normal o

    " dispose
    normal ostatic void
    exec "normal o" . prefix . "_dispose (GObject *object)"
    normal o{
    exec "normal oG_OBJECT_CLASS (" . prefix . "_parent_class)->dispose (object);"
    normal o}
    normal o

    " finalize
    normal ostatic void
    exec "normal o" . prefix . "_finalize (GObject *object)"
    normal o{
    exec "normal oG_OBJECT_CLASS (" . prefix . "_parent_class)->finalize (object);"
    normal o}
endfunction

function! GOBGenerateH()
    if input("Use filename to generate object name (y/n)? ", "y") != "y"
        let prefix = input("Enter object prefix name (flybird-directory):")
    else
        let prefix = expand("%:t:r")
    endif

    if prefix == ""
        echohl ErrorMsg
        echo "Can't create class without prefix"
        echohl None
        return
    endif

    let parentName = input("Enter parent class name (Default GObject): ")
    if parentName == ""
        let parentName = "GObject"
    endif

    let prefix = substitute(prefix, "-", "_", "g")

    let typeName = substitute(prefix, "_\\(.\\)\\|^\\(.\\)", "\\U\\1\\U\\2", "g")
    let typeNamePrivate = typeName . "Private"

    let defineName = toupper(prefix)

    " setup needed defines

    exec "normal I#ifndef __" . defineName . "_H__"
    exec "normal o#define __" . defineName . "_H__"

    normal o
    exec "normal o#include <glib.h>"
    exec "normal o#include <glib-object.h>"
    normal o
    normal oG_BEGIN_DECLS
    normal o

    exec "normal o#define " . defineName . "_TYPE            (" . prefix . "_get_type ())"
    exec "normal o#define " . defineName . "(obj)            (G_TYPE_CHECK_INSTANCE_CAST ((obj), " . defineName . "_TYPE," typeName . "))"
    exec "normal o#define " . defineName . "_CLASS(klass)    (G_TYPE_CHECK_CLASS_CAST ((klass), " . defineName . "_TYPE," typeName . "Class))"
    exec "normal o#define IS_" . defineName . "(obj)         (G_TYPE_CHECK_INSTANCE_TYPE ((obj), " . defineName . "_TYPE))"
    exec "normal o#define IS_" . defineName . "_CLASS(klass) (G_TYPE_CHECK_CLASS_TYPE ((klass), " . defineName . "_TYPE))"
    exec "normal o#define " . defineName . "_GET_CLASS(obj)  (G_TYPE_INSTANCE_GET_CLASS ((obj), " . defineName . "_TYPE," typeName . "Class))"

    normal o
    exec "normal otypedef struct _" . typeName . "      " . typeName . ";"
    exec "normal otypedef struct _" . typeName . "Class " . typeName . "Class;"
    exec "normal otypedef struct _" . typeName . "Private " . typeName . "Private;"
    normal o

    " Variable memeber structure
    exec "normal ostruct _" . typeName . "Class"
    exec "normal o{"
    exec "normal o" . parentName . "Class parent_class;"
    exec "normal o};"
    normal o

    exec "normal ostruct _" . typeName
    exec "normal o{"
    exec "normal o" . parentName "parent;"
    exec "normal o" . typeName . "Private *priv;"
    exec "normal o};"

    normal o
    exec "normal oGType" prefix . "_get_type (void);"
    normal o

    exec "normal o" . typeName . " *" . prefix. "_new ();"
    normal o

    normal oG_END_DECLS

    normal o
    exec "normal o#endif"
endfunction

command! GOBGenerateC call GOBGenerateC()
command! GOBGenerateH call GOBGenerateH()
