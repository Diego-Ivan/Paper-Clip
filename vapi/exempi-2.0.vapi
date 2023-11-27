/*
 * exempi
 *
 * Original Authors of xmp.h
 * Copyright (C) 2007-2023 Hubert Figuière
 * Copyright 2002-2007 Adobe Systems Incorporated
 * All rights reserved.
 *
 * VAPI Authors:
 * Copyright (c) 2023 Diego Iván M.E
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * 1 Redistributions of source code must retain the above copyright
 * notice, this list of conditions and the following disclaimer.
 *
 * 2 Redistributions in binary form must reproduce the above copyright
 * notice, this list of conditions and the following disclaimer in the
 * documentation and/or other materials provided with the
 * distribution.
 *
 * 3 Neither the name of the Authors, nor the names of its
 * contributors may be used to endorse or promote products derived
 * from this software wit hout specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 * COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 * OF THE POSSIBILITY OF SUCH DAMAGE.
 */

[CCode (cheader_filename = "exempi/xmp.h")]
namespace Xmp {
    [Flags]
    [CCode (cprefix = "XMP_OPEN_", has_type_id = false)]
    public enum OpenFileOptions {
        NOOPTION,
        READ,
        FORUPDATE,
        ONLYXMP,
        CACHENAIL,
        STRICTLY,
        USESMARTHANDLER,
        USEPACKETSCANNING,
        LIMITSCANNING,
        REPAIR_FILE,
        OPTIMIZEFILELAYOUT,
        INBACKGROUND;
    }

    [Flags]
    [CCode (cprefix = "XMP_CLOSE_", has_type_id = false)]
    public enum CloseFileOptions {
        NOOPTION,
        SAFEUPDATE;
    }

    [CCode (cprefix = "XMP_FT_")]
    public enum FileType {
        PDF,
        PS,
        EPS,
        TIFF,
        GIF,
        PNG,
        WEBP,
        SWF,
        FLA,
        FLV,
        MOV,
        AVI,
        CIN,
        WAV,
        MP3,
        SES,
        CEL,
        MPEG,
        MPEG2,
        MPEG4,
        MXF,
        WMAV,
        AIFF,
        RED,
        ARRI,
        HEIF,
        P2,
        XDCAM_FAM,
        XDCAM_SAM,
        XDCAM_EX,
        AVCHD,
        SONY_HDV,
        CANON_XF,
        AVC_ULTRA,
        HTML,
        XML,
        TEXT,
        SVG,
        PHOTOSHOP,
        ILLUSTRATOR,
        INDESIGN,
        AEPROJECT,
        AEPROJTEMPLATE,
        AEFILTERPRESET,
        ENCOREPROJECT,
        PREMIERPROJECT,
        PREMIERTITLE,
        UCF,
        UNKNOWN;

        [CCode (cname = "xmp_files_get_format_info")]
        public bool get_format_info (out FileFormatOptions options);

        [CCode (cname = "xmp_files_check_file_format")]
        public static FileType check_file_format (string file_path);
    }

    [Flags]
    [CCode (cprefix = "XMP_ITER_")]
    public enum IterOptions {
        CLASSMASK,
        PROPERTIES,
        ALIASES,
        NAMESPACES,
        JUSTCHILDREN,
        JUSTLEAFNODES,
        JUSTLEAFNAME,
        INCLUDEALIASES,
        OMITQUALIFIERS
    }

    [Flags]
    [CCode (cprefix = "XMP_ITER_SKIP")]
    public enum IterSkipOptions {
        SUBTREE,
        SIBLINGS
    }

    [Flags]
    [CCode (cprefix = "XMP_FMT_")]
    public enum FileFormatOptions {
        CAN_INJECT_XMP,
        CAN_EXPAND,
        CAN_REWRITE,
        PREFERS_IN_PLACE,
        CAN_RECONCILE,
        ALLOWS_ONLY_XMP,
        RETURNS_RAW_PACKET,
        HANDLER_OWNS_FILE,
        ALLOW_SAFE_UPDATE,
        NEEDS_READONLY_PACKET,
        USE_SIDECAR_XMP,
        FOLDER_BASED_FORMAT
    }

    [Flags]
    [CCode (cprefix = "XMP_PROP_")]
    public enum PropsBits {
        VALUE_IS_URI,
        HAS_QUALIFIERS,
        IS_QUALIFIER,
        HAS_LANG,
        HAS_TYPE,
        VALUE_IS_STRUCT,
        VALUE_IS_ARRAY,
        ARRAY_IS_UNORDERED,
        ARRAY_IS_ORDERED,
        ARRAY_IS_ALT,
        ARRAY_IS_ALTTEXT,
        ARRAY_INSERT_BEFORE,
        ARRAY_INSERT_AFTER,
        IS_ALIAS,
        HAS_ALIASES,
        IS_INTERNAL,
        IS_STABLE,
        IS_DERIVED,

        ARRAY_FORM_MASK,
        COMPOSITE_MASK
    }

    [Flags]
    [CCode (cprefix = "XMP_SERIAL_", cname = "uint32_t")]
    public enum SerializeOptions {
        OMITPACKETWRAPPER,
        READONLYPACKET,
        USECOMPACTFORMAT,
        INCLUDETHUMBNAILPAD,
        EXACTPACKETLENGTH,
        WRITEALIASCOMMENTS,
        OMITALLFORMATTING,
        [CCode (cname = "_XMP_LITTLEENDIAN_BIT")]
        LITTLE_ENDIAN_BIT,
        [CCode (cname = "_XMP_UTF16_BIT")]
        UTF16_BIT,
        [CCode (cname = "_XMP_UTF32_BIT")]
        UTF32_BIT,
        ENCODINGMASK,
        ENCODEUTF8,
        ENCODEUTF16BIG,
        ENCODEUTF16LITTLE,
        ENCODEUTF32BIG,
        ENCODEUTF32LITTLE
    }

    [CCode (has_type_id = false)]
    public struct PacketInfo {
        int64 offset;
        int32 length;
        [CCode (cname = "padSize")]
        int32 pad_size;
        [CCode (cname = "charForm")]
        uint8 char_form;
        bool writeable;
        [CCode (cname = "hasWrapper")]
        bool has_wrapper;
    }

    public bool init ();
    public void terminate ();
    public int get_error ();

    [Compact (opaque = true)]
    [CCode (cname = "struct _XmpString", lower_case_cprefix = "xmp_string_", free_function = "xmp_string_free")]
    internal class String {
        public size_t length {
            [CCode (cname = "xmp_string_len")]get;
        }
        [CCode (cname = "xmp_string_new")]
        public String ();
        [CCode (cname = "xmp_string_cstr")]
        public unowned string to_string ();
    }

    [Compact (opaque = true)]
    [CCode (cname = "struct _Xmp", lower_case_cprefix = "xmp_", free_function = "xmp_free")]
    public class Packet {
        [CCode (cname = "xmp_new_empty")]
        public Packet.empty ();
        [CCode (cname = "xmp_new")]
        public Packet (string buffer);

        public Packet copy ();

        [CCode (cname = "__vala_xmp_serialize")]
        public bool serialize (out string buffer, SerializeOptions options, uint32 padding) {
            String xmp_str = new String ();
            bool retval = serialize_xmp (xmp_str, (uint32) options, padding);
            buffer = xmp_str.to_string ();
            return retval;
        }

        [CCode (cname = "xmp_serialize")]
        private bool serialize_xmp (String buffer, uint32 options, uint32 padding);

        [CCode (cname = "__vala_xmp_serialize_and_format")]
        public bool serialize_and_format (out string buffer, SerializeOptions options,
                                          uint32 padding, string new_line, string tab, int32 indent) {
            String xmp_str = new String ();
            bool retval = serialize_and_format_xmp (xmp_str, (uint32) options, padding, new_line,
                                                    tab, indent);
            buffer = xmp_str.to_string ();
            return retval;
        }

        [CCode (cname = "xmp_serialize_and_format")]
        private bool serialize_and_format_xmp (String buffer, uint32 options, uint32 padding, string new_line, string tab, int32 indent);

        [CCode (cname = "__vala_xmp_get_property")]
        public bool get_property (string schema, string name, out string property, out PropsBits props_bits) {
            bool retval;
            var xmp_str = new String ();
            uint32 bits;
            retval = get_property_xmp_str (schema, name, xmp_str, out bits);
            props_bits = (PropsBits) bits;
            property = xmp_str.to_string ();
            return retval;
        }
        [CCode (cname = "xmp_get_property")]
        private bool get_property_xmp_str (string scheme, string name, String property, out uint32 propsbits);

        [CCode (cname = "__vala_xmp_get_property_date_time")]
        public bool get_property_date_time (string schema, string name, out GLib.DateTime property, out PropsBits props_bits) {
            string property_str;
            bool property_exists = get_property (schema, name, out property_str, out props_bits);
            if (property_exists) {
                property = new GLib.DateTime.from_iso8601 (property_str, null);
            } else {
                property = null;
            }
            return property_exists;
        }

        [CCode (cname = "__vala_xmp_get_property_float")]
        public bool get_property_float (string schema, string name, out double property, ref PropsBits? props_bits) {
            bool retval;
            if (props_bits == null) {
                retval = get_property_float_xmp_str (schema, name, out property, null);
            } else {
                uint32 bits = 0x0;
                retval = get_property_float_xmp_str (schema, name, out property, out bits);
                props_bits = (PropsBits) bits;
            }
            return retval;
        }
        [CCode (cname = "xmp_get_property_float")]
        private bool get_property_float_xmp_str (string schema, string name, out double property, out uint32? propsbits);

        [CCode (cname = "__vala_xmp_get_property_bool")]
        public bool get_property_bool (string schema, string name, out bool property, ref PropsBits? props_bits) {
            bool retval;
            if (props_bits == null) {
                retval = get_property_bool_xmp (schema, name, out property, null);
            } else {
                uint32 bits = 0x0;
                retval = get_property_bool_xmp (schema, name, out property, out bits);
                props_bits = (PropsBits) bits;
            }
            return retval;
        }

        [CCode (cname = "xmp_get_property_bool")]
        private bool get_property_bool_xmp (string schema, string name, out bool property, out uint32? bits);

        [CCode (cname = "__vala_xmp_get_property_int")]
        public bool get_property_int (string schema, string name, out int property, ref PropsBits? props_bits) {
            bool retval;
            if (props_bits == null) {
                retval = get_property_int32 (schema, name, out property, null);
            } else {
                uint32 bits = 0x0;
                retval = get_property_int32 (schema, name, out property, out bits);
                props_bits = (PropsBits) bits;
            }
            return retval;
        }

        [CCode (cname = "xmp_get_property_int32")]
        private bool get_property_int32 (string schema, string name, out int32 property, out uint32? bits);

        [CCode (cname = "__vala_xmp_get_array_item")]
        public bool get_array_item (string schema, string name, int index, out string property, ref PropsBits? props_bits) {
            bool retval;
            var xmp_str = new String ();
            if (props_bits == null) {
                retval = get_array_item_xmp (schema, name, index, xmp_str, null);
            } else {
                uint32 bits = 0x0;
                retval = get_array_item_xmp (schema, name, index, xmp_str, null);
                props_bits = (PropsBits) bits;
            }
            property = xmp_str.to_string ();
            return retval;
        }
        [CCode (cname = "xmp_get_array_item")]
        private bool get_array_item_xmp (string schema, string name, int32 index, String property, out uint32? bits);

        public bool set_property (string schema, string name, string @value, uint32 option_bits);
        public bool set_property_float (string schema, string name, float @value, uint32 option_bits);
        public bool set_property_int32 (string schema, string name, int32 @value, uint32 option_bits);
        public bool set_property_int64 (string schema, string name, int64 @value, uint32 option_bits);
        public bool set_array_item (string schema, string name, int32 index, string @value, uint32 option_bits);

        [CCode (cname = "__vala_xmp_set_property_date")]
        public bool set_property_date (string schema, string name, GLib.DateTime @value, uint32 option_bits) {
            return set_property (schema, name, @value.format_iso8601 (), option_bits);
        }

        public bool append_array_item (string schema, string name, uint32 array_options, string @value, uint32 option_bits);

        public bool delete_property (string schema, string name);
        public bool has_property (string schema, string name);

        [CCode (cname = "__vala_xmp_get_localized_text")]
        public bool get_localized_text (string schema, string name, string generic_lang,
                                        string specific_lang, ref string? actual_lang,
                                        ref string? item_value, ref PropsBits? props_bits)
                                        requires (generic_lang != "")
                                        requires (specific_lang != "") {
            uint32 bits = 0x0;
            String x_actual = new String (), x_value = new String ();
            bool retval = get_localized_text_xmp (schema, name, generic_lang, specific_lang,
                                                  x_actual, x_value, out bits);
            if (actual_lang != null) {
                actual_lang = x_actual.to_string ();
            }
            if (item_value != null) {
                item_value = x_value.to_string ();
            }
            if (props_bits != null) {
                props_bits = (PropsBits) bits;
            }
            return retval;
        }
        [CCode (cname = "xmp_get_localized_text")]
        private bool get_localized_text_xmp (string schema, string name, string generic_lang, string specific_lang, String actual_lang, String item_value, out uint32 bits);

        public bool set_localized_text (string schema, string name, string generic_lang, string specific_lang, string @value, uint32 option_bits);
        public bool delete_localized_text (string schema, string name, string generic_lang, string specific_lang);
    }

    [Compact (opaque = true)]
    [CCode (cname = "struct _XmpFile", lower_case_cprefix = "xmp_files_", free_function = "xmp_files_free")]
    public class File {
        [CCode (cname = "xmp_files_new")]
        public File ();
        [CCode (cname = "xmp_files_open_new")]
        public static File? open_new (string path, OpenFileOptions options);

        [CCode (cname = "xmp_files_open")]
        public bool open_file (string path, OpenFileOptions options);
        public bool close (CloseFileOptions options);
        public Packet get_new_xmp ();

        public bool get_xmp (Packet xmp);
        public bool can_put_xmp (Packet xmp);
        public bool put_xmp (Packet xmp);

        [CCode (cname = "xmp_files_can_put_xmp_cstr")]
        public bool can_put_string (string xmp_packet);

        [CCode (cname = "__vala_xmp_files_get_info")]
        public bool get_file_info (ref string? file_path, out OpenFileOptions options, out FileType format, out FileFormatOptions handler_flags) {
            bool retval = false;
            if (file_path != null) {
                var xmp_str = new String ();
                retval = get_file_info_xmp_str (xmp_str, out options, out format, out handler_flags);
                file_path = xmp_str.to_string ();
            } else {
                retval = get_file_info_xmp_str (null, out options, out format, out handler_flags);
            }
            return retval;
        }

        [CCode (cname = "xmp_files_get_file_info")]
        private bool get_file_info_xmp_str (String? file_path, out OpenFileOptions options, out FileType format, out FileFormatOptions handler_flags);
    }

    [CCode (cname = "struct _XmpIterator", lower_case_cprefix = "xmp_iterator_", free_function = "xmp_iterator_free")]
    public class Iterator {
        [CCode (cname = "xmp_iterator_new")]
        public Iterator (Packet xmp, string schema, string prop_name, IterOptions options);

        [CCode (cname = "__vala_xmp_iter_next")]
        public bool next (ref string? schema, ref string? prop_name, ref string? prop_value,
                          ref PropsBits? options) {
            String schema_str = new String (), name_str = new String (), value_str = new String ();
            uint32 bits = 0x0;
            bool retval = next_xmp (schema_str, name_str, value_str, out bits);
            if (schema != null) {
                schema = schema_str.to_string ();
            }
            if (prop_name != null) {
                prop_name = name_str.to_string ();
            }
            if (prop_value != null) {
                prop_value = value_str.to_string ();
            }
            if (options != null) {
                options = (PropsBits) bits;
            }
            return retval;
        }

        [CCode (cname = "xmp_iter_next")]
        private bool next_xmp (String? schema, String? prop_name, String? prop_value, out uint32? options);

        public bool skip (IterSkipOptions options);
    }

    namespace Namespace {
        [CCode (cheader_filename = "exempi/xmpconsts.h", cname = "NS_XMP_META")]
        public const string XMP_META;
        [CCode (cheader_filename = "exempi/xmpconsts.h", cname = "NS_RDF")]
        public const string RDF;
        [CCode (cheader_filename = "exempi/xmpconsts.h", cname = "NS_EXIF")]
        public const string EXIF;
        [CCode (cheader_filename = "exempi/xmpconsts.h", cname = "NS_TIFF")]
        public const string TIFF;
        [CCode (cheader_filename = "exempi/xmpconsts.h", cname = "NS_XAP")]
        public const string XAP;
        [CCode (cheader_filename = "exempi/xmpconsts.h", cname = "NS_XAP_RIGHTS")]
        public const string XAP_RIGHTS;
        [CCode (cheader_filename = "exempi/xmpconsts.h", cname = "NS_DC")]
        public const string DC;
        [CCode (cheader_filename = "exempi/xmpconsts.h", cname = "NS_EXIF_AUX")]
        public const string EXIF_AUX;
        [CCode (cheader_filename = "exempi/xmpconsts.h", cname = "NS_CRS")]
        public const string CRS;
        [CCode (cheader_filename = "exempi/xmpconsts.h", cname = "NS_LIGHTROOM")]
        public const string LIGHTROOM;
        [CCode (cheader_filename = "exempi/xmpconsts.h", cname = "NS_PHOTOSHOP")]
        public const string PHOTOSHOP;
        [CCode (cheader_filename = "exempi/xmpconsts.h", cname = "NS_CAMERA_RAW_SETTINGS")]
        public const string CAMERA_RAW_SETTINGS;
        [CCode (cheader_filename = "exempi/xmpconsts.h", cname = "NS_CAMERA_RAW_SAVED_SETTINGS")]
        public const string CAMERA_RAW_SAVED_SETTINGS;
        [CCode (cheader_filename = "exempi/xmpconsts.h", cname = "NS_IPTC4XMP")]
        public const string IPTC4XMP;
        [CCode (cheader_filename = "exempi/xmpconsts.h", cname = "NS_TPG")]
        public const string TPG;
        [CCode (cheader_filename = "exempi/xmpconsts.h", cname = "NS_DIMENSIONS_TYPE")]
        public const string DIMENSIONS_TYPE;
        [CCode (cheader_filename = "exempi/xmpconsts.h", cname = "NS_CC")]
        public const string CC;
        [CCode (cheader_filename = "exempi/xmpconsts.h", cname = "NS_PDF")]
        public const string PDF;
        [CCode (cheader_filename = "exempi/xmpconsts.h", cname = "NS_XML")]
        public const string XML;

        [CCode (cname = "__vala_xmp_register_namespace")]
        public bool register_namespace (string namespace_uri, string suggested_prefix, out string registered_prefix) {
            var xmp_str = new String ();
            bool retval = register_namespace_xmp_str (namespace_uri, suggested_prefix, xmp_str);
            registered_prefix = xmp_str.to_string ();
            return retval;
        }
        [CCode (cname = "xmp_register_namespace")]
        private bool register_namespace_xmp_str (string namespace_uri, string suggested_prefix, String registered_prefix);

        [CCode (cname = "__vala_xmp_namespace_is_registered")]
        public bool namespace_is_registered (string ns, ref string? prefix) {
            var xmp_str = new String ();
            bool retval = namespace_is_registered_xmp_str (ns, xmp_str);
            if (prefix != null) {
                prefix = xmp_str.to_string ();
            }
            return retval;
        }

        [CCode (cname = "xmp_namespace_prefix")]
        private bool namespace_is_registered_xmp_str (string ns, String? prefix);

        [CCode (cname = "__vala_xmp_prefix_is_registered")]
        public bool prefix_is_registered (string uri, ref string? @namespace) {
            bool retval;
            if (@namespace != null) {
                var xmp_str = new String ();
                retval = prefix_is_registered_xmp_str (uri, xmp_str);
                @namespace = xmp_str.to_string ();
            } else {
                retval = prefix_is_registered_xmp_str (uri, null);
            }
            return retval;
        }

        [CCode (cname = "xmp_prefix_namespace_uri")]
        private bool prefix_is_registered_xmp_str (string uri, String? ns);
    }
}
