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

        public State state { get; set; default = NONE; }

        public Window (Gtk.Application app) {
            Object (application: app);
        }

        construct {
            ActionEntry[] entries = {
                { "open", on_open_action },
                { "save", save_file }
            };

            var action_group = new SimpleActionGroup ();
            action_group.add_action_entries (entries, this);
            insert_action_group ("win", action_group);
        }

        private void on_open_action () {
            state = OPENING_FILE;
            var doc_manager = new Services.DocManager ();
            if (doc_manager.changed) {
                show_unsaved_warning ();
            } else {
                open_file ();
            }
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
            state = NONE;
        }

        private void save_file () {
            var manager = new Services.DocManager ();
            if (manager.document == null) {
                return;
            }

            var filter = new Gtk.FileFilter ();
            filter.add_mime_type ("application/pdf");

            var filechooser = new Gtk.FileChooserNative (null, this,
                                                         SAVE, null, null);
            filechooser.add_filter (filter);

            filechooser.response.connect (on_file_saved);
        }

        private void on_file_saved (Gtk.NativeDialog source, int response) {
            var file_dialog = (Gtk.FileChooser) source;
            if (response == Gtk.ResponseType.ACCEPT) {
                var file = file_dialog.get_file ();

                var manager = new Services.DocManager ();
                manager.save (file.get_uri ());

                proceed_with_state ();
            }
        }

        private void show_unsaved_warning () {
            var manager = new Services.DocManager ();
            var message_dialog = new Adw.MessageDialog (this,
                                                        "%s has changed".printf (manager.document.title),
                                                        "Save, Cancel or Discard?");
            message_dialog.add_response ("cancel", "Cancel");
            message_dialog.add_response ("save", "Save");
            message_dialog.add_response ("discard", "Discard");

            message_dialog.response.connect (on_warning_response);
            message_dialog.show ();
        }

        private void on_warning_response (Adw.MessageDialog sender, string response) {
            if (response == "cancel") {
                state = NONE;
                return;
            }

            if (response == "save") {
                save_file ();
                return;
            }

            proceed_with_state ();
        }

        private void proceed_with_state () {
            switch (state) {
                case NONE:
                    return;
                case OPENING_FILE:
                    open_file ();
                    break;
                case CLOSING:
                    GLib.Application.get_default ().quit ();
                    break;
            }
        }
    }

    public enum State {
        NONE,
        OPENING_FILE,
        CLOSING
    }
}
