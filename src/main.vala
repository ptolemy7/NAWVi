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
        var stack = new Gtk.Stack ();
        headerbar.set_show_close_button (true);
        var view_online = new ArchWiki.View ("https://wiki.archlinux.org");
        var back_button = new Gtk.Button.from_icon_name ("go-previous-symbolic",Gtk.IconSize.BUTTON);
        var forward_button = new Gtk.Button.from_icon_name("go-next-symbolic",Gtk.IconSize.BUTTON);

        headerbar.pack_start (back_button);
        headerbar.pack_start (forward_button);
        var go_offline = new Gtk.Button.from_icon_name("airplane-mode",Gtk.IconSize.BUTTON) ();
        

        forward_button.clicked.connect ( () =>
        {
            stack.get_visible_child().go_forward();
        });
        back_button.clicked.connect ( () => {
            stack.get_visible_child().go_back();
        });
        main_box.add(view_online);
        headerbar.set_title ( "Arch Wiki" );
        set_titlebar (headerbar);
        set_default_size (600,400);
        stack.add_title(view, "Online","Online");
        add(stack);
        show_all ();
    }
}

public class ArchWiki.View : WebKit.WebView {
    public string uri {get;construct;}
    public View (string i ) {
        Object (uri: i);
    }
    construct {
        set_hexpand(true);
        set_vexpand(true);
        load_uri(uri);
    }
}

public class ArchWiki.Stack : Gtk.Stack {
    public WebKit.WebView online_view{get;construct}
    public WebKit.WebView offline_view{get;construct}
    public string online_uri {get;construct}
    public string offline_uri {get;construct}
    public Stack (string online, string offline) {
        Object(
            online_uri: online,
            offline_uri: offline
        )
    }
    construct {
        online_view = new ArchWiki.View (online_uri);
        offline_view = new ArchWiki.View (offline_uri);
        add(offline_uri);
        add(online_view);
    }

}

