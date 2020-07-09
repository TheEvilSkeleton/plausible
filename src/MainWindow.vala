/*
* Copyright © 2020 Cassidy James Blaede (https://cassidyjames.com)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 3 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
* Authored by: Cassidy James Blaede <c@ssidyjam.es>
*/

public class Plausible.MainWindow : Gtk.Window {
    private Plausible.WebView web_view;
    // private Gtk.Revealer back_revealer;
    private Gtk.Revealer settings_revealer;
    private Gtk.Revealer sites_revealer;

    public MainWindow (Gtk.Application application) {
        Object (
            application: application,
            border_width: 0,
            icon_name: Application.instance.application_id,
            resizable: true,
            title: "Plausible",
            window_position: Gtk.WindowPosition.CENTER
        );
    }

    construct {
        default_height = 700;
        default_width = 1000;

        Gtk.Settings.get_default ().gtk_application_prefer_dark_theme = true;
        Gdk.RGBA rgba = { 0, 0, 0, 1 };
        rgba.parse ("#5850EC");
        Granite.Widgets.Utils.set_color_primary (this, rgba);

        // var back_button = new Gtk.Button.with_label ("Back") {
        //   valign = Gtk.Align.CENTER
        // };
        // back_button.get_style_context ().add_class ("back-button");

        // back_revealer = new Gtk.Revealer () {
        //     transition_type = Gtk.RevealerTransitionType.SLIDE_RIGHT
        // };
        // back_revealer.add (back_button);

        var sites_button = new Gtk.Button.from_icon_name ("go-home", Gtk.IconSize.LARGE_TOOLBAR) {
            tooltip_text = "Sites"
        };

        sites_revealer = new Gtk.Revealer () {
            transition_type = Gtk.RevealerTransitionType.CROSSFADE
        };
        sites_revealer.add (sites_button);

        var settings_button = new Gtk.Button.from_icon_name ("avatar-default", Gtk.IconSize.LARGE_TOOLBAR) {
            tooltip_text = "Account Settings"
        };

        settings_revealer = new Gtk.Revealer () {
            transition_type = Gtk.RevealerTransitionType.CROSSFADE
        };
        settings_revealer.add (settings_button);

        var header = new Gtk.HeaderBar () {
            has_subtitle = false,
            show_close_button = true
        };
        // header.pack_start (back_revealer);
        header.pack_start (sites_revealer);
        header.pack_end (settings_revealer);

        web_view = new Plausible.WebView ();
        web_view.load_uri ("https://" + Application.instance.domain + "/sites");

        var logo = new Gtk.Image.from_resource ("/com/github/cassidyjames/plausible/logo-dark.png") {
            expand = true,
            margin_bottom = 48
        };

        var stack = new Gtk.Stack () {
            transition_duration = 300,
            transition_type = Gtk.StackTransitionType.UNDER_UP
        };
        stack.get_style_context ().add_class ("loading");
        stack.add_named (logo, "loading");
        stack.add_named (web_view, "web");

        set_titlebar (header);
        add (stack);

        web_view.load_changed.connect ((load_event) => {
            if (load_event == WebKit.LoadEvent.FINISHED) {
                stack.visible_child_name = "web";
            }
        });

        // back_button.clicked.connect (web_view.go_back);

        sites_button.clicked.connect (() => {
            web_view.load_uri ("https://" + Application.instance.domain + "/sites");
        });

        settings_button.clicked.connect (() => {
            web_view.load_uri ("https://" + Application.instance.domain + "/settings");
        });

        web_view.load_changed.connect (on_loading);
        web_view.notify["uri"].connect (on_loading);
        web_view.notify["estimated-load-progress"].connect (on_loading);
        web_view.notify["is-loading"].connect (on_loading);
    }

    private void on_loading () {
        // back_revealer.reveal_child = web_view.can_go_back ();

        sites_revealer.reveal_child = (
            web_view.uri != "https://" + Application.instance.domain + "/login" &&
            web_view.uri != "https://" + Application.instance.domain + "/register" &&
            web_view.uri != "https://" + Application.instance.domain + "/password/request-reset" &&
            web_view.uri != "https://" + Application.instance.domain + "/sites"
        );

        settings_revealer.reveal_child = (
            web_view.uri != "https://" + Application.instance.domain + "/login" &&
            web_view.uri != "https://" + Application.instance.domain + "/register" &&
            web_view.uri != "https://" + Application.instance.domain + "/password/request-reset" &&
            web_view.uri != "https://" + Application.instance.domain + "/settings"
        );
    }
}