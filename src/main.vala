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
    public Gtk.SearchEntry search{get;set;}
    public Window (Application app) {
        Object (application: app);
    }
    construct {
        var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL,1);
        var headerbar = new Gtk.HeaderBar ();
        var online_view = new WebKit.WebView ();
        var stack = new Gtk.Stack ();
        // Need to find a way to get this to look better ...
        online_view.load_uri("file:///usr/share/doc/arch-wiki/html/en/Btrfs.html");
        online_view.set_vexpand(true);
        online_view.set_hexpand(true);

        var search_button = new Gtk.ToggleButton ();
        var icon = new Gtk.Image.from_icon_name ("edit-find",Gtk.IconSize.BUTTON);
        search_button.set_image (icon);
        search = new Gtk.SearchEntry ();
        headerbar.set_custom_title (search);
        search.set_no_show_all (true);
        bool is_shown = false;
        string text_to_display;

        search_button.clicked.connect ( () => {
            if ( ! search.is_visible()) {
                search.show ();
                search.grab_focus ();
            } else {
                search.hide ();
            }
        });
        search.activate.connect ( () => {
            search_changed_cb (out text_to_display);
            show_text (text_to_display);
        });

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
        stack.add(online_view);
        main_box.add (stack);
        headerbar.pack_end (search_button);
        add(main_box);
        show_all ();
    }
    public void search_changed_cb (out string return_text) {
        //  string text = search.get_text ();
        string [] args = { "wiki-search-html",search.get_text () };
        string [] env = Environ.get ();
        string std_out;
        string std_err;
        int cmd_status;
        try {
            Process.spawn_sync ( 
                "/",
                args,
                env,
                SpawnFlags.SEARCH_PATH,
                null,
                out std_out,
                out std_err,
                out cmd_status);

            print(std_out);
            return_text = std_out;
        } catch (Error e) {
            stderr.printf("Error: %s\n", e.message);
        }
    }
    public void show_text (string text) {
        

    }
}


