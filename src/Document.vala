/* Document.vala
 *
 * Copyright 2023 Diego Iván <diegoivan.mae@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

public class PaperClip.Document : Object {
    private ListStore keyword_list = new ListStore (typeof(StringObject));

    private const string PDF_NS = "http://ns.adobe.com/pdf/1.3/";
    private const string XMP_NS = "http://ns.adobe.com/xap/1.0/";

    private Poppler.Document _document;
    private Poppler.Document document {
        get {
            return _document;
        }
        set {
            _document = value;
            deserialize_keywords ();
        }
    }

    public File original_file { get; construct; }
    public File cached_file { get; private set; }

    [CCode (notify = false)]
    public bool has_xmp { get; private set; default = false; }

    public string author {
        owned get {
            return document.author ?? "";
        }
        set {
            document.author = value;
        }
    }

    public string creator {
        owned get {
            return document.creator ?? "";
        }
        set {
            document.creator = value;
        }
    }

    public string subject {
        owned get {
            return document.subject ?? "";
        }
        set {
            document.subject = value;
        }
    }

    public string title {
        owned get {
            return document.title ?? "";
        }
        set {
            document.title = value;
        }
    }

    public string producer {
        owned get {
            return document.producer ?? "";
        }
        set {
            document.producer = value;
        }
    }

    public DateTime creation_date {
        owned get {
            return document.creation_datetime;
        }
        set {
            document.creation_datetime = value;
        }
    }

    public DateTime modification_date {
        owned get {
            return document.mod_datetime;
        }
        set {
            document.mod_datetime = value;
        }
    }

    [CCode (notify = false)]
    public ListModel keywords {
        get {
            return keyword_list;
        }
    }

    [CCode (notify = false)]
    public string format {
        owned get {
            return document.format ?? _("Unknown");
        }
    }

    [CCode (notify = false)]
    public string layout {
        owned get {
            return layout_to_string ();
        }
    }

    [CCode (notify = false)]
    public string print_duplex {
        owned get {
            return print_duplex_to_string ();
        }
    }

    [CCode (notify = false)]
    public string subtype {
        owned get {
            return subtype_to_string ();
        }
    }

    [CCode (notify = false)]
    public string[] viewer_preferences {
        owned get {
            return viewer_preferences_to_string_array ();
        }
    }

    [CCode (notify = false)]
    public string[] permissions {
        owned get {
            return permissions_to_string_array ();
        }
    }

    public signal void keyword_changed ();

    public async Document (File original_file) {
        Object (original_file: original_file);
        yield load_document ();

        try {
            has_xmp = yield ThreadManager.run_in_thread<bool> (load_xmp);
        } catch (Error e) {
            critical (e.message);
        }

        var agent_name = new AgentName (document.creator);
        var agent_name2 = new AgentName (document.producer);
    }

    // This function is intended to be run from a background thread
    private bool load_xmp () throws Error {
        bool success = false;
        var xmp_file = new Xmp.File ();
        bool opened_file = xmp_file.open_file (original_file.get_path (),
                                               READ | INBACKGROUND | ONLYXMP);
        if (!opened_file) {
            debug ("Failed to open file with XMP");
            return false;
        }
        var xmp_meta = new Xmp.Packet.empty ();
        success = xmp_file.get_xmp (xmp_meta);
        if (!success) {
            debug ("File does not have XMP metadata");
        }
        xmp_file?.close (NOOPTION);
        return success;
    }

    public async void save (string uri) {
        try {
            yield ThreadManager.run_in_thread<void> (() => save_thread (uri));
        } catch (Error e) {
            critical (e.message);
        }
    }

    private void save_thread (string uri) throws Error {
        lock (document) {
            document.keywords = serialize_keywords ();
            document.save (uri);
        }
        if (has_xmp) {
            save_xmp (uri);
        }
    }

    private void save_xmp (string uri) throws XmpError {
        var xmp_file = new Xmp.File ();
        Xmp.OpenFileOptions options = FORUPDATE | INBACKGROUND;
        var file = File.new_for_uri (uri);
        string path = file.get_path ();
        bool success = xmp_file.open_file (path, options);

        if (!success) {
            int error = Xmp.get_error ();
            throw new XmpError.FAILED_TO_OPEN (@"Failed to open $path XMP metadata. Error: $error");
        }

        var xmp_meta = new Xmp.Packet.empty ();
        bool has_meta = xmp_file.get_xmp (xmp_meta);
        if (!has_meta) {
            throw new XmpError.NO_XMP (@"$path has no XMP Metadata");
        }

        xmp_meta.set_property (Xmp.Namespace.PDF, "Producer", producer, 0x0);
        xmp_meta.set_property (Xmp.Namespace.XAP, "CreatorTool", creator, 0x0);
        xmp_meta.set_property (Xmp.Namespace.PDF, "Keywords", document.keywords, 0x0);

        if (creation_date == null) {
            xmp_meta.delete_property (Xmp.Namespace.XAP, "CreateDate");
        } else {
            xmp_meta.set_property_date (Xmp.Namespace.XAP, "CreateDate", creation_date, 0x0);
        }

        if (modification_date == null) {
            xmp_meta.delete_property (Xmp.Namespace.XAP, "ModifyDate");
        } else {
            xmp_meta.set_property_date (Xmp.Namespace.XAP, "ModifyDate", modification_date, 0x0);
        }

        var metadata_date = new DateTime.now_local ();
        xmp_meta.set_property_date (Xmp.Namespace.XAP, "MetadataDate", metadata_date, 0x0);

        if (xmp_file.can_put_xmp (xmp_meta)) {
            debug ("Writing XMP Metadata");
            xmp_file.put_xmp (xmp_meta);
        }
        xmp_file.close (SAFEUPDATE);
    }

    public void add_keyword (string keyword) {
        var keyword_object = new StringObject (keyword);
        keyword_object.notify["str"].connect (() => keyword_changed ());
        keyword_list.append (keyword_object);
    }

    public bool remove_keyword (string keyword) {
        for (int i = 0; i < keyword_list.get_n_items (); i++) {
            var item = (StringObject) keyword_list.get_item (i);
            if (keyword == item.str) {
                keyword_list.remove (i);
                return true;
            }
        }
        return false;
    }

    public Poppler.Page get_page_for_index (int index) {
        return document.get_page (index);
    }

    private void deserialize_keywords () {
        if (document.keywords == null) {
            return;
        }

        string[] keyword_array = document.keywords.split (",");
        foreach (string keyword in keyword_array) {
            add_keyword (keyword);
        }
    }

    private string serialize_keywords () {
        string format = "";
        for (int i = 0; i < keyword_list.get_n_items (); i++) {
            var item = (StringObject) keyword_list.get_item (i);
            format += "%s".printf (item.str);
            if (i == keywords.get_n_items () - 1) {
                break;
            }
            format += ",";
        }
        return format;
    }

    private string layout_to_string () {
        switch (document.page_layout) {
            case ONE_COLUMN:
                return _("Pages in one column");

            case SINGLE_PAGE:
                return _("One page at a time");

            case TWO_COLUMN_LEFT:
                return _("Odd numbered pages on the left");

            case TWO_COLUMN_RIGHT:
                return _("Odd numbered pages on the right");

            case TWO_PAGE_LEFT:
                return _("Two odd numbered pages on the left");

            case TWO_PAGE_RIGHT:
                return _("Two odd numbered pages on the right");

            case UNSET:
            default:
                return _("No specific layout");
        }
    }

    private string[] viewer_preferences_to_string_array () {
        string[] preferences_array = {};
        Poppler.ViewerPreferences preferences = document.viewer_preferences;

        if (CENTER_WINDOW in preferences) {
            preferences_array += _("Center document's window");
        }

        if (DIRECTION_RTL in preferences) {
            preferences_array += _("Reading order is right to left");
        }

        if (DISPLAY_DOC_TITLE in preferences) {
            preferences_array += _("Display document's title");
        }

        if (FIT_WINDOW in preferences) {
            preferences_array += _("Fit document to window");
        }

        if (HIDE_MENUBAR in preferences) {
            preferences_array += _("Hide window menubar");
        }

        if (HIDE_TOOLBAR in preferences) {
            preferences_array += _("Hide window toolbars");
        }

        if (HIDE_WINDOWUI in preferences) {
            preferences_array += _("Hide UI elements");
        }

        if (UNSET in preferences) {
            preferences_array += _("No preferences");
        }

        return preferences_array;
    }

    private string[] permissions_to_string_array () {
        string[] permission_array = {};
        Poppler.Permissions permission_flags = document.permissions;

        if (OK_TO_ADD_NOTES in permission_flags) {
            permission_array += _("Adding notes");
        }

        if (OK_TO_ASSEMBLE in permission_flags) {
            permission_array += _("Inserting elements");
        }

        if (OK_TO_COPY in permission_flags) {
            permission_array += _("Copying");
        }

        if (OK_TO_EXTRACT_CONTENTS in permission_flags) {
            permission_array += _("Extracting contents");
        }

        if (OK_TO_FILL_FORM in permission_flags) {
            permission_array += _("Filling interactive forms");
        }

        if (OK_TO_MODIFY in permission_flags) {
            permission_array += _("Modifying");
        }

        if (OK_TO_PRINT in permission_flags) {
            permission_array += _("Printing");
        }

        if (OK_TO_PRINT_HIGH_RESOLUTION in permission_flags) {
            permission_array += _("Printing in high resolution");
        }

        return permission_array;
    }

    private string print_duplex_to_string () {
        switch (document.print_duplex) {
            case DUPLEX_FLIP_LONG_EDGE:
                return _("Flip on the long edge");

            case DUPLEX_FLIP_SHORT_EDGE:
                return _("Flip on the short edge");

            case SIMPLEX:
                return _("Only single sided");

            case NONE:
            default:
                return _("No preference");
        }
    }

    private string subtype_to_string () {
        switch (document.subtype) {
            case PDF_A:
                return "ISO 19005";

            case PDF_E:
                return "ISO 24517";

            case PDF_UA:
                return "ISO 14289";

            case PDF_VT:
                return "ISO 16612";

            case PDF_X:
                return "ISO 15930";

            case UNSET:
            case NONE:
            default:
                return _("Not compliant");
        }
    }

    private async void load_document () {
        cached_file = yield create_copy_from_original ();
        try {
            document = new Poppler.Document.from_gfile (cached_file, null);
        }
        catch (Error e) {
            critical ("%s : %s", e.domain.to_string (), e.message);
        }
    }

    private async File create_copy_from_original () {
        unowned string tmp_dir = Environment.get_tmp_dir ();
        string destination_path = Path.build_path (Path.DIR_SEPARATOR_S,
                                                   tmp_dir,
                                                   "copies");

        int res = DirUtils.create_with_parents (destination_path, 0777);
        return_if_fail (res > -1);

        string destination_file = Path.build_filename (destination_path,
                                                       "%s".printf (original_file.get_basename ()));

        var copy_file = File.new_for_path (destination_file);
        FileCopyFlags flags = NOFOLLOW_SYMLINKS | OVERWRITE | ALL_METADATA;

        try {
            bool success = yield original_file.copy_async (copy_file, flags);
            if (!success) {
                critical ("Copy Unsuccessful");
            }
        }
        catch (Error e) {
            critical (e.message);
        }

        return copy_file;
    }
}

public class PaperClip.StringObject : Object {
    public string str { get; set; default = ""; }

    public StringObject (string str) {
        Object (str: str);
    }
}

public errordomain PaperClip.XmpError {
    NO_XMP,
    FAILED_TO_OPEN;
}
