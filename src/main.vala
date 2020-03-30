public static int main (string[] args ) {
    var app = new NAWVi.Application ();
    return app.run (args);
}

public class NAWVi.Application: Gtk.Application {
    public Application () {
        Object (
        application_id: "com.githb.ptolemy7.NAWVi",
        flags: ApplicationFlags.FLAGS_NONE
        );
    }
    protected override void activate () {
        var window = new NAWVi.Window(this);
        add_window (window);
    }
}

public class NAWVi.Window : Gtk.Window  {
    public GLib.Settings settings;
    public Gtk.SearchEntry search{get;set;}
    public WebKit.WebView online_view{get;set;}
    public Window (Application app) {
        Object (application: app);
    }
    construct {
        settings = new GLib.Settings ("com.github.ptolemy7.NAWVi");
        move (settings.get_int ("pos-x") , settings.get_int( "pos-y"));
        resize (settings.get_int ("window-width"), settings.get_int ("window-height"));
        delete_event.connect (e => {
            return before_destroy ();
        });
        var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL,1);
        var headerbar = new Gtk.HeaderBar ();
        var list_box = new Gtk.Box (Gtk.Orientation.VERTICAL,1);
        online_view = new WebKit.WebView ();
        var stack = new Gtk.Stack ();
        stack.transition_type = Gtk.StackTransitionType.CROSSFADE;
        // Need to find a way to get this to look better ...
        online_view.load_uri(settings.get_string ("current-uri"));
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
        var search_list = new Gee.ArrayList<string> ();
        var search_buttons = new Gee.ArrayList<Gtk.ModelButton> ();

        search_button.toggled.connect ( () => {
            if ( ! search.is_visible()) {
                search.show ();
                search.grab_focus ();
            } else {
                search.hide ();
            }
        });
        search.activate.connect ( () => {
            search_changed_cb (out text_to_display);
            show_text (text_to_display, out search_list);
            stack.set_visible_child (list_box);
            foreach(var j in search_buttons) {
                j.destroy ();
            };
            foreach (var i in search_list) {
                string pretty;
                make_pretty(i,out pretty);
                var temp = new Gtk.ModelButton ();
                temp.set_label(pretty);
                float align = 0.5f;
                temp.set_alignment (align,align);
                search_buttons.add (temp);
                list_box.pack_start (temp);
                temp.show ();
                temp.clicked.connect ( () => {
                    change_site(i);
                    stack.set_visible_child (online_view);
                    search.set_text ("");
                });

            };
            search_button.set_active (false);
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
        stack.add (online_view);
        stack.add (list_box);
        main_box.add (stack);
        headerbar.pack_end (search_button);
        add(main_box);
        show_all ();
    }
    public bool before_destroy () {
        // setup the varaibles needs
        int width, height, x,y;
        get_size (out width, out height);
        get_position (out x, out y);
        var uri = online_view.get_uri ();
        // Do some cleanup
        //  Posix.system ("rm /tmp/gbtrfs");
        // write them to dconf
        // Commented out right now b/c I can't figure out what is going wrong when ran as root
        settings.set_int("pos-x", x);
        settings.set_int("pos-y", y);
        settings.set_int("window-width",width);
        settings.set_int("window-height",height);
        settings.set_string("current-uri",uri);
        return false;
    }
    public void search_changed_cb (out string return_text) {
        string [] args = { "wiki-search",search.get_text () };
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

            //  print(std_out);
            return_text = std_out;
        } catch (Error e) {
            stderr.printf("Error: %s\n", e.message);
        }
    }
    public void show_text (string text, out Gee.ArrayList<string> return_list) {
        unichar c;
        var list = new Gee.ArrayList<string> ();
        var builder = new GLib.StringBuilder ();
        for (int i = 0; text.get_next_char (ref i, out c);) {
            if (c.to_string() == "\n") {
                list.add (builder.str);
                builder.erase ();
            } else {
                builder.append (c.to_string());
            }
            //  stdout.printf ("%d, %s\n", i, c.to_string ());
        }
        return_list = list ;
    }
    public void make_pretty(string i ,out string exit) {
        //  print(i + "\n");
        string [] args = { "bash","/home/ptolemy/Projects/arch_wiki/src/helper_script.sh","-p",i};
        string [] env = Environ.get ();
        string std_out;
        string std_err;
        int cmd_status;
            Process.spawn_sync ( 
                "/",
                args,
                env,
                SpawnFlags.SEARCH_PATH,
                null,
                out std_out,
                out std_err,
                out cmd_status);

            //  print(std_out);
            exit=std_out;
    }
    public void change_site (string i ) {
        string [] args = { "bash","/home/ptolemy/Projects/arch_wiki/src/helper_script.sh","-h",i};
        string [] env = Environ.get ();
        string std_out;
        string std_err;
        int cmd_status;
        Process.spawn_sync ( 
                "/",
                args,
                env,
                SpawnFlags.SEARCH_PATH,
                null,
                out std_out,
                out std_err,
                out cmd_status);
        string new_uri = "file://" + std_out;
        online_view.load_uri(new_uri);
    }
}


