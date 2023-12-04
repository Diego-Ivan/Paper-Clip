/* DocumentThumbnail.vala
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

public class PaperClip.DocumentThumbnail : Adw.Bin {
    private Gtk.Image thumbnail_image = new Gtk.Image ();
    private Services.Thumbnailer thumbnailer = new Services.Thumbnailer ();

    const int MAX_SIZE = 350;

    private unowned Document _document;
    public unowned Document document {
        get {
            return _document;
        }
        set {
            _document = value;
            generate_png.begin ();
        }
    }

    ~DocumentThumbnail () {
        thumbnail_image.clear ();
    }

    construct {
        child = thumbnail_image;
        thumbnail_image.add_css_class ("icon-dropshadow");
        thumbnailer.max_size = MAX_SIZE;
        thumbnail_image.pixel_size = MAX_SIZE / 2;
    }

    private async void generate_png () {
        try {
            Poppler.Page page = document.get_page_for_index (0);
            string basename = document.original_file.get_basename ();
            Gdk.Texture thumbnail_texture = yield thumbnailer.create_thumbnail (page, basename);
            thumbnail_image.clear ();
            thumbnail_image.paintable = scale_thumbnail (thumbnail_texture);
        }
        catch (Error e) {
            critical (e.message);
        }
    }

    private Gdk.Paintable scale_thumbnail (Gdk.Texture thumbnail_texture) {
        float scaled_height, scaled_width;
        compute_scaled_size (thumbnail_texture.height, thumbnail_texture.width,
                             out scaled_height, out scaled_width);

        var snapshot = new Gtk.Snapshot ();
        var thumbnail_rectangle = Graphene.Rect () {
            origin = { 0, 0 },
            size = { scaled_width, scaled_height }
        };

        Gsk.ScalingFilter filter = LINEAR;
        if (scaled_width > thumbnail_texture.width || scaled_height > thumbnail_texture.height) {
            filter = NEAREST;
        } else {
            filter = TRILINEAR;
        }
        debug (@"Current filter for thumbnail: $filter");

        // Append White Background in case the image is transparent
        snapshot.append_color ({1, 1, 1, 1}, thumbnail_rectangle);
        snapshot.append_scaled_texture (thumbnail_texture, filter, thumbnail_rectangle);
        thumbnail_image.pixel_size = MAX_SIZE / 2;

        return snapshot.free_to_paintable (null);
    }

    private void compute_scaled_size (int image_height, int image_width, out float scaled_height,
                                      out float scaled_width) {
        float size = MAX_SIZE * scale_factor;

        // Translated this from AdwAvatar source code. Works nicely :)
        if (image_width > image_height) {
            scaled_height = size;
            scaled_width = image_width * scaled_height / image_height;
        } else if (image_height > image_width) {
            scaled_width = size;
            scaled_height = image_height * scaled_width / image_width;
        } else {
            scaled_width = scaled_height = size;
        }
    }
}
