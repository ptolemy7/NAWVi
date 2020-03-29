public static int main (string[] args ) {
    var app = new Archwiki.Application ();
    return app.run (args);
}

public class Archwiki.Application: Gtk.Application {
    public Application () {
        Object (
        application_id: "com.githb.ptolemy7.arckwiki",
        flags: ApplicationFlags.FLAGS_NONE
        );
    }
    protected override void activate () {
        var window = new Archwiki.Window(this);
        add_window (window);
    }
}

public class Archwiki.Window : Gtk.Window  {
    public Window (Application app) {
        Object (application: app);
    }
    construct {
        var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL,1);
        var headerbar = new Gtk.HeaderBar ();
        var online_view = new WebKit.WebView ();
        online_view.load_uri("file:///usr/share/doc/arch-wiki/html/");
        online_view.set_vexpand(true);
        online_view.set_hexpand(true);

        var search_button = new Gtk.Button.from_icon_name ("edit-find");

        var search = new Gtk.SearchEntry ();

        search_button.clicked.connect ( () => {
            search_button.hide ();
            headerbar.pack_end (search);
            print("clicked!");
            search.show();

        });

        search.
        headerbar.set_show_close_button (true);
        var back_button = new Gtk.Button.from_icon_name ("go-previous-symbolic",Gtk.IconSize.BUTTON);
        var forward_button = new Gtk.Button.from_icon_name("go-next-symbolic",Gtk.IconSize.BUTTON);

        headerbar.pack_start (back_button);
        headerbar.pack_start (forward_button);
        //  var go_offline = new Gtk.Button.from_icon_name("airplane-mode",Gtk.IconSize.BUTTON);

        forward_button.clicked.connect ( () => {
                online_view.go_forward ();
          
        });
        back_button.clicked.connect ( () => {
            online_view.go_back();
        });
        set_titlebar (headerbar);
        set_default_size (600,400);
        main_box.add (online_view);
        headerbar.pack_end (search_button);
        add(main_box);
        show_all ();
    }
}


