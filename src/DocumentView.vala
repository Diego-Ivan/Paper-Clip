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
    private unowned EntryRow title_row;
    [GtkChild]
    private unowned EntryRow author_row;
    [GtkChild]
    private unowned EntryRow creator_row;
    [GtkChild]
    private unowned EntryRow subject_row;
    [GtkChild]
    private unowned EntryRow producer_row;

    private Document _document;
    public Document document {
        get {
            return _document;
        }
        set {
            _document = value;
            title_row.object = document;
            author_row.object = document;
            creator_row.object = document;
            subject_row.object = document;
            producer_row.object = document;
        }
    }

    static construct {
        typeof(EntryRow).ensure ();
    }
}
