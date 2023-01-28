/* window.vala
 *
 * Copyright 2023 Diego Iván
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

namespace HiddenScribe {
    [GtkTemplate (ui = "/io/github/diegoivan/hidden_scribe/window.ui")]
    public class Window : Adw.ApplicationWindow {
        [GtkChild]
        private unowned DocumentView doc_view;
        [GtkChild]
        private unowned Gtk.Stack view_stack;

        public Window (Gtk.Application app) {
            Object (application: app);
        }

        construct {
            ActionEntry[] entries = {
                { "open", open_file },
            };

            var action_group = new SimpleActionGroup ();
            action_group.add_action_entries (entries, this);
            insert_action_group ("win", action_group);
        }

        private void open_file () {
            var filter = new Gtk.FileFilter ();
            filter.add_mime_type ("application/pdf");

            var filechooser = new Gtk.FileChooserNative ("Select a PDF file", this,
                                                         OPEN, null, null);
            filechooser.add_filter (filter);

            filechooser.response.connect (on_file_opened);
            filechooser.show ();
        }

        private void on_file_opened (Gtk.NativeDialog source, int response) {
            var file_dialog = (Gtk.FileChooser) source;
            if (response == Gtk.ResponseType.ACCEPT) {
                var file = file_dialog.get_file ();
                doc_view.document = new Document (file.get_uri ());
                view_stack.visible_child_name = "editor";
            }
        }
    }
}
