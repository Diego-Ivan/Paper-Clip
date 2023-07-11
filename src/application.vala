/* application.vala
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

namespace PaperClip {
    public class Application : Adw.Application {
        private Window main_window;

        public Application () {
            Object (application_id: "io.github.diegoivan.pdf_metadata_editor",
                    flags: ApplicationFlags.HANDLES_OPEN);

            Intl.setlocale (LocaleCategory.ALL, "");
            Intl.bindtextdomain (Config.GETTEXT_PACKAGE, Config.GNOMELOCALEDIR);
            Intl.textdomain (Config.GETTEXT_PACKAGE);
        }

        construct {
            ActionEntry[] action_entries = {
                { "about", this.on_about_action },
                { "shortcuts", shortcuts_action }
            };
            this.add_action_entries (action_entries, this);
            set_accels_for_action ("app.shortcuts", { "<Ctrl>question" });
        }

        public override void activate () {
            base.activate ();
            if (main_window == null) {
                main_window = new PaperClip.Window (this);
            }
            main_window.present ();
        }

        public override void open (File[] files, string hint) {
            activate ();
            if (files.length <= 0) {
                return;
            }

            main_window.open_command_line_file (files[0]);
        }

        private void shortcuts_action () {
            var window = (Window) active_window;
            window.shortcuts ();
        }

        private void on_about_action () {
            string[] developers = { "Diego Iván" };
            string[] artists = { "Brage Fuglseth" };
            var about = new Adw.AboutWindow () {
                application_icon = Config.APP_ID,
                application_name = "Paper Clip",
                copyright = "© 2023 Diego Iván",
                developer_name = "Diego Iván",
                developers = developers,
                artists = artists,
                issue_url = "https://github.com/Diego-Ivan/HiddenScribe/issues",
                license_type = GPL_3_0,
                transient_for = this.active_window,
                // translators: Write your name<email> here :D
                translator_credits = _("translator_credits"),
                version = Config.VERSION,
                website = "https://github.com/Diego-Ivan/HiddenScribe",
            };

            about.present ();
        }
    }
}
