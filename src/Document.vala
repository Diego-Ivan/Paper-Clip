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
    private Poppler.Document document;
    private Gtk.StringList keyword_list = new Gtk.StringList (null);

    public string author { get; set; }
    public string creator { get; set; }
    public string subject { get; set; }
    public string title { get; set; }
    public string producer { get; set; }
    public string uri { get; private set; }

    public ListModel keywords {
        get {
            return keyword_list;
        }
    }

    public Document (string uri, string? password = null) {
        this.uri = uri;
        try {
            document = new Poppler.Document.from_file (uri, password);
            bind ();
        }
        catch (Error e) {
            critical (e.message);
        }
    }

    private void bind () {
        ObjectClass klass = get_class ();
        foreach (unowned ParamSpec property in klass.list_properties ()) {
            if (!(WRITABLE in property.flags)) {
                continue;
            }
            bind_property (property.name, document, property.name);
        }
    }

    public void save () {
        document.keywords = serialize_keywords ();
        try {
            document.save (uri);
        }
        catch (Error e) {
            critical ("Error Saving: %s", e.message);
        }
    }

    public void add_keyword (string keyword) {
        keyword_list.append (keyword);
    }

    public bool remove_keyword (string keyword) {
        for (int i = 0; i < keyword_list.get_n_items (); i++) {
            if (keyword == keyword_list.get_string (i)) {
                keyword_list.remove (i);
                return true;
            }
        }
        return false;
    }

    private string serialize_keywords () {
        string format = "";
        for (int i = 0; i < keyword_list.get_n_items (); i++) {
            format += "%s".printf (keyword_list.get_string (i));
            if (i == keywords.get_n_items () - 1) {
                break;
            }
            format += ",";
        }
        return format;
    }
}
