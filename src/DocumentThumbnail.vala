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
    }

    private async void generate_png () {
        try {
            Gdk.Texture thumbnail_texture = yield ThreadManager.run_in_thread (create_thumbnail_in_cache);
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
        // Append White Background in case the image is transparent
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

        snapshot.append_color ({1, 1, 1, 1}, thumbnail_rectangle);
        snapshot.append_scaled_texture (thumbnail_texture, filter, thumbnail_rectangle);
        thumbnail_image.pixel_size = MAX_SIZE / 2;

        return snapshot.free_to_paintable (null);
    }

    private Gdk.Texture? create_thumbnail_in_cache () throws Error {
        Poppler.Page first_page = document.get_page_for_index (0);
        double h, w;
        first_page.get_size (out w, out h);
        int height = (int) h, width = (int) w;

        var surface = new Cairo.ImageSurface (Cairo.Format.ARGB32, width, height);
        var context = new Cairo.Context (surface);
        first_page.render (context);

        string save_path = create_cache_file ();
        Cairo.Status status = surface.write_to_png (save_path);

        if (status != SUCCESS) {
            throw new ThumbnailError.FAILED_EXPORT (@"Failed to export $save_path: $status");
        }

        int scaled_height = height / 3, scaled_width = width / 3;

        var pixbuf = new Gdk.Pixbuf.from_file_at_size (save_path, scaled_width, scaled_height);
        var texture = Gdk.Texture.for_pixbuf (pixbuf);
        return texture;
    }

    private string? create_cache_file () throws Error {
        string destination_path = Path.build_path (Path.DIR_SEPARATOR_S,
                                                   Environment.get_tmp_dir (),
                                                   "thumbnails");
        int result = DirUtils.create_with_parents (destination_path, 0777);
        return_if_fail (result > -1);

        string destination_file = Path.build_filename (destination_path,
                                                       "%s.png".printf (document.original_file.get_basename ()));

        var file = File.new_for_path (destination_file);
        if (!file.query_exists ()) {
            file.create (NONE);
        }
        return destination_file;
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

public errordomain PaperClip.ThumbnailError {
    FAILED_EXPORT
}
