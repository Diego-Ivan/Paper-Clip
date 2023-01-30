/* DetailsWindow.vala
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

[GtkTemplate (ui = "/io/github/diegoivan/hidden_scribe/gtk/details-window.ui")]
public class HiddenScribe.DetailsWindow : Gtk.Window {
    [GtkChild]
    private unowned DetailRow format_row;
    [GtkChild]
    private unowned DetailRow layout_row;
    [GtkChild]
    private unowned DetailRow duplex_row;
    [GtkChild]
    private unowned DetailRow subtype_row;
    [GtkChild]
    private unowned StringArrayRow preferences_row;
    [GtkChild]
    private unowned StringArrayRow permissions_row;

    private unowned Document _document;
    public unowned Document document {
        get {
            return _document;
        }
        set {
            _document = value;

            format_row.detail = document.format;
            layout_row.detail = document.layout;
            duplex_row.detail = document.print_duplex;
            subtype_row.detail = document.subtype;
            preferences_row.string_array = document.viewer_preferences;
            permissions_row.string_array = document.permissions;
        }
    }
}
