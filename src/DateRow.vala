/* DateRow.vala
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

[GtkTemplate (ui = "/io/github/diegoivan/hidden_scribe/gtk/date-row.ui")]
public class HiddenScribe.DateRow : Adw.ActionRow, PropertyRow {
    [GtkChild]
    private unowned Gtk.Calendar calendar;

    private unowned Object _object;
    public unowned Object object {
        get {
            return _object;
        }
        set {
            _object = value;
            object.bind_property (property_name, this, "date", SYNC_CREATE | BIDIRECTIONAL);
        }
    }

    public string property_name { get; set; }

    private DateTime? _date;
    public DateTime? date {
        get {
            return _date;
        }
        set {
            _date = value;
            subtitle = date != null ?  date.format ("%x") : "No date set";
        }
    }

    [GtkCallback]
    private void on_day_selected () {
        date = calendar.get_date ();
    }

    [GtkCallback]
    private void on_today_button_clicked () {
        var today_time = new DateTime.now_local ();

        int year, month, day;
        today_time.get_ymd (out year, out month, out day);

        calendar.year = year;
        calendar.month = month - 1;
        calendar.day = day;

        date = today_time;
    }

    [GtkCallback]
    private void on_tomorrow_button_clicked () {
        var tomorrow_time = new DateTime.now_local ();
        tomorrow_time = tomorrow_time.add_days (1);

        int year, month, day;
        tomorrow_time.get_ymd (out year, out month, out day);

        calendar.year = year;
        calendar.month = month - 1;
        calendar.day = day;

        date = tomorrow_time;
    }
}
