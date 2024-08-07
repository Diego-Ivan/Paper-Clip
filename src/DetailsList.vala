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

[GtkTemplate (ui = "/io/github/diegoivan/pdf_metadata_editor/gtk/details-list.ui")]
public class PaperClip.DetailsList : Adw.Bin {
    [GtkChild]
    private unowned Adw.ActionRow format_row;
    [GtkChild]
    private unowned Adw.ActionRow layout_row;
    [GtkChild]
    private unowned Adw.ActionRow duplex_row;
    [GtkChild]
    private unowned Adw.ActionRow subtype_row;
    [GtkChild]
    private unowned Adw.ActionRow javascript_row;
    [GtkChild]
    private unowned Adw.ActionRow attachments_row;
    [GtkChild]
    private unowned Adw.ActionRow pages_row;
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

            format_row.subtitle = document.format;
            layout_row.subtitle = document.layout;
            duplex_row.subtitle = document.print_duplex;
            subtype_row.subtitle = document.subtype;
            preferences_row.string_array = document.viewer_preferences;
            permissions_row.string_array = document.permissions;
            attachments_row.subtitle = document.contains_attachments ?
                                       _("Yes") : _("No");
            javascript_row.subtitle = document.contains_javascript ?
                                      _("Yes") : _("No");

            if (document.n_pages > 0) {
                pages_row.visible = true;
                pages_row.subtitle = document.n_pages.to_string ();
            } else {
                pages_row.visible = false;
            }
        }
    }
}
