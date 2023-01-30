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

public class HiddenScribe.Document : Object {
    private ListStore keyword_list = new ListStore (typeof(StringObject));
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

    public File original_file { get; private set; }
    public File cached_file { get; private set; }

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

    public async Document (string uri) {
        yield load_document (uri);
    }

    public void save (string path)
    {
        document.keywords = serialize_keywords ();
        try {
            document.save (path);
        }
        catch (Error e) {
            critical ("%s : %s", e.domain.to_string (), e.message);
        }
    }

    public void add_keyword (string keyword) {
        keyword_list.append (new StringObject (keyword));
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

    private void deserialize_keywords () {
        if (document.keywords == null) {
            return;
        }

        string[] keyword_array = document.keywords.split (",");
        foreach (string keyword in keyword_array) {
            keyword_list.append (new StringObject (keyword));
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
                return _("Not compliant with any standards known");
        }
    }

    private async void load_document (string uri) {
        cached_file = yield create_copy (uri);
        try {
            document = new Poppler.Document.from_gfile (cached_file, null);
        }
        catch (Error e) {
            critical ("%s : %s", e.domain.to_string (), e.message);
        }
    }

    private async File create_copy (string uri) {
        original_file = File.new_for_uri (uri);
        string destination_path = Path.build_path (Path.DIR_SEPARATOR_S,
                                                   Environment.get_user_cache_dir (),
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

public class HiddenScribe.StringObject : Object {
    public string str { get; set; default = ""; }

    public StringObject (string str) {
        Object (str: str);
    }
}
