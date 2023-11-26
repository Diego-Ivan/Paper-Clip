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

    private Gdk.MemoryFormat? _default_format = null;
    private Gdk.MemoryFormat default_format {
        get {
            if (_default_format == null) {
                if (BYTE_ORDER == LITTLE_ENDIAN) {
                    _default_format = B8G8R8A8_PREMULTIPLIED;
                } else {
                    _default_format = A8R8G8B8_PREMULTIPLIED;
                }
            }
            return _default_format;
        }
    }

    construct {
        child = thumbnail_image;
        thumbnail_image.add_css_class ("icon-dropshadow");
    }

    private async void generate_png () {
        try {
            Gdk.Texture thumbnail_texture = yield ThreadManager.run_in_thread (create_thumbnail_in_cache);
            thumbnail_image.clear ();
            thumbnail_image.paintable = scale_thumbnail (thumbnail_texture);
        }
        catch (Error e) {
            critical (e.message);
        }
    }

    private Gdk.Paintable scale_thumbnail (Gdk.Texture thumbnail_texture) {
        int image_width = thumbnail_texture.width;
        int image_height = thumbnail_texture.height;

        if (image_width == image_height) {
            return thumbnail_texture;
        }

        float size = MAX_SIZE * scale_factor;
        float scaled_height, scaled_width;

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

        Gsk.ScalingFilter filter = LINEAR;
        if (scaled_width > image_width || scaled_height > image_height) {
            filter = NEAREST;
        } else {
            filter = TRILINEAR;
        }

        debug (@"Current filter for thumbnail: $filter");

        var thumbnail_rectangle = Graphene.Rect ();
        thumbnail_rectangle = thumbnail_rectangle.init (0, 0, scaled_width, scaled_height);

        var snapshot = new Gtk.Snapshot ();
        // Append White Background in case the image is transparent
        snapshot.append_color ({1, 1, 1, 1}, thumbnail_rectangle);
        snapshot.append_scaled_texture (thumbnail_texture, filter, thumbnail_rectangle);
        thumbnail_image.pixel_size = MAX_SIZE / 2;

        return snapshot.free_to_paintable ({scaled_width, scaled_height});
    }

    private Gdk.Texture? create_thumbnail_in_cache () throws Error {
        Poppler.Page first_page = document.get_page_for_index (0);
        double width, height;

        first_page.get_size (out width, out height);

        var surface = new Cairo.ImageSurface (Cairo.Format.ARGB32, (int) width, (int) height);
        var context = new Cairo.Context (surface);
        first_page.render (context);

        size_t size = (size_t) (width * height * 4);

        /*
         * We have to use this intermediate method, because the array returned by sirface.get_data
         * does not have an array length, and therefore automatically passes -1 to the Bytes.new
         * method, which will then overflow the parameter and will try to allocate an insane amount
         * of memory. A complete mess.
         *
         * So to go around that, we calculated the size above (pixels * number of bytes per pixel),
         * and create a sized array using copy_bytes method. We will use Bytes.take instead
         * of Bytes.new as we will avoid creating another copy.
         */
        var bytes = new Bytes.take (copy_bytes (surface.get_data (), size));
        var memory_texture = new Gdk.MemoryTexture (surface.get_width (), surface.get_height (),
                                                    default_format, bytes,
                                                    surface.get_stride ());

        return memory_texture;
    }

    private uint8[] copy_bytes ([CCode (array_length = false)]uint8[] data, size_t size) {
        uint8[] copy = new uint8[size];
        for (size_t i = 0; i < size; i++) {
            copy[i] = data[i];
        }
        return copy;
    }
}

public errordomain PaperClip.ThumbnailError {
    FAILED_EXPORT
}
