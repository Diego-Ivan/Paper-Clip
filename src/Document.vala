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

    public string uri {
        set {
            try {
                document = new Poppler.Document.from_file (value, null);
            }
            catch (Error e) {
                critical (e.message);
            }
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

    public ListModel keywords {
        get {
            return keyword_list;
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

    private async void load_document (string uri) {
        File document_file = yield create_copy (uri);
        try {
            document = new Poppler.Document.from_gfile (document_file, null);
        }
        catch (Error e) {
            critical ("%s : %s", e.domain.to_string (), e.message);
        }
    }

    private async File create_copy (string uri) {
        var original = File.new_for_uri (uri);
        string destination_path = Path.build_path (Path.DIR_SEPARATOR_S,
                                                   Environment.get_user_cache_dir (),
                                                   "copies");

        int res = DirUtils.create_with_parents (destination_path, 0777);
        return_if_fail (res > -1);

        string destination_file = Path.build_filename (destination_path,
                                                       "%s".printf (original.get_basename ()));

        var copy_file = File.new_for_path (destination_file);
        FileCopyFlags flags = NOFOLLOW_SYMLINKS | OVERWRITE | ALL_METADATA;

        try {
            bool success = yield original.copy_async (copy_file, flags);
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
