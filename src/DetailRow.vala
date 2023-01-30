/* DetailRow.vala
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

public class HiddenScribe.DetailRow : Adw.ActionRow {
    private Gtk.Label suffix_label = new Gtk.Label ("");
    public string detail {
        get {
            return suffix_label.label;
        }
        set {
            suffix_label.label = value;
        }
    }

    construct {
        suffix_label.add_css_class ("dim-label");
        add_suffix (suffix_label);
    }
}
