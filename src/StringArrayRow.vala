/* StringArrayRow.vala
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

public class PaperClip.StringArrayRow : Adw.ExpanderRow {
    private ContentRow content_row = new ContentRow ();
    public string[] string_array {
        set {
            foreach (string item in value) {
                content_row.append_line (item);
            }
        }
    }

    construct {
        add_row (content_row);
    }
}

public class PaperClip.ContentRow : Gtk.ListBoxRow {
    private Gtk.Label content_label;

    construct {
        content_label = new Gtk.Label ("") {
            css_classes = { "dim-label" },
            halign = START,
            margin_start = 12,
            margin_top = 12,
        };
        content_label.add_css_class ("dim-label");
        child = content_label;
    }

    public void append_line (string line) {
        content_label.label += "• %s\n".printf (line);
    }
}
