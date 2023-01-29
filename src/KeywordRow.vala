/* KeywordRow.vala
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

public class HiddenScribe.KeywordRow : EntryRow {
    public unowned Document document { get; set; }

    construct {
        focusable = true;
        var delete_button = new Gtk.Button.from_icon_name ("cross-symbolic") {
            valign = CENTER,
            css_classes = { "flat" },
            tooltip_text = _("Delete Keyword")
        };
        add_prefix (delete_button);

        delete_button.clicked.connect (on_delete_clicked);
    }

    private void on_delete_clicked () {
        document.remove_keyword (text);
    }
}
