/* DocumentView.vala
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

[GtkTemplate (ui = "/io/github/diegoivan/hidden_scribe/gtk/document-view.ui")]
public class HiddenScribe.DocumentView : Adw.Bin {
    [GtkChild]
    private unowned Adw.PreferencesGroup property_group;

    private Document _document;
    public Document document {
        get {
            return _document;
        }
        set {
            _document = value;
            update_children ();
        }
    }

    public DocumentView (Document document) {
        Object (document: document);
    }

    construct {
        var klass = (ObjectClass) typeof(Document).class_ref ();
        foreach (unowned ParamSpec property in klass.list_properties ()) {
            if (!(WRITABLE in property.flags)) {
                continue;
            }

            if (property.value_type.is_a (Type.STRING)) {
                var row = new EntryRow ();
                row.property_name = property.name;
                property_group.add (row);
            }
        }
    }

    private void update_children () {
        Gtk.Widget? child = property_group.get_first_child ();
        while (child != null) {
            if (!(child is PropertyRow)) {
                child = child.get_next_sibling ();
                continue;
            }

            unowned var row = (PropertyRow) child;
            row.object = document;

            child = child.get_next_sibling ();
        }
    }
}
