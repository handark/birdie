namespace Birdie.Utils {

    public class Indicator : GLib.Object {
        public int unread { get; set; }
        
        private Indicate.Server indicator = null;
        private List<Indicate.Indicator> items;
        private Indicate.Indicator tweets;
        private Indicate.Indicator mentions;
        private Indicate.Indicator new_tweet;
        private Indicate.Indicator dm;
        
        Birdie birdie;
        
        public Indicator (Birdie birdie) {
            this.birdie = birdie;

            indicator = Indicate.Server.ref_default ();
            indicator.set_type ("message.email");

            string desktop_file = Constants.DATADIR + "/applications/birdie.desktop";
            
            if (desktop_file == null) {
                debug ("Unable to setup libindicate support: no desktop file found"); 
                return;
            }
                
            indicator.set_desktop_file (desktop_file);

            // indicator entries
            this.tweets = add_indicator (_("Tweets"));
            this.mentions = add_indicator (_("Mentions"));
            this.dm = add_indicator (_("Direct Messages"));
            this.new_tweet = add_indicator (_("New Tweet"));
            //
            
            new_tweet.show ();
            
            // signal connections
            indicator.server_display.connect (on_user_display);
            new_tweet.user_display.connect (on_new_tweet);
            this.tweets.user_display.connect (on_unread_tweets);
            this.mentions.user_display.connect (on_unread_mentions);
            this.dm.user_display.connect (on_unread_dm);
            //
            
            this.indicator.show ();
        }
        
        private void on_unread_tweets () {
            this.birdie.switch_timeline ("home");
            this.birdie.activate ();
        }
        
        private void on_unread_mentions () {
            this.birdie.switch_timeline ("mentions");
            this.birdie.activate ();
        }
        
        private void on_unread_dm () {
            this.birdie.switch_timeline ("dm");
            this.birdie.activate ();
        }
        
        private void on_new_tweet () {
            Widgets.TweetDialog dialog = new Widgets.TweetDialog (birdie); 
            dialog.show_all ();
        }
        
        private void on_user_display () {
            birdie.activate ();
            clean_tweets_indicator ();
        }
        
        private Indicate.Indicator add_indicator (string label) {
            var item = new Indicate.Indicator.with_server (indicator);
            item.set_property_variant ("name", label);
            items.append (item);
            return item;
        }
        
        public void update_tweets_indicator (int unread) {
            debug ("Updating new tweets indicator with %d new tweets.", unread);
            update_indicator (unread, this.tweets);
        }
        
        public void update_mentions_indicator (int unread) {
            debug ("Updating new mentions indicator with %d new mentions.", unread);
            update_indicator (unread, this.mentions);
        }
        
        public void update_dm_indicator (int unread) {
            debug ("Updating new dm indicator with %d new dm.", unread);
            update_indicator (unread, this.dm);
        }
        
        public void clean_tweets_indicator () {
            clean_indicator (this.tweets);
        }
        
        public void clean_mentions_indicator () {
            clean_indicator (this.mentions);
        }
        
        public void clean_dm_indicator () {
            clean_indicator (this.dm);
        }
        
        private void clean_indicator (Indicate.Indicator item) {
            item.set_property_variant ("count", "0");
            item.set_property_bool ("draw-attention", false);
            item.hide ();
        }
        
        private void update_indicator (int unread, Indicate.Indicator item) {
            if (unread > 0) {
                //count is in fact a string property
                item.set_property_variant ("count", unread.to_string ());
                item.set_property_bool ("draw-attention", true);
                item.show();
            }
            else
                item.hide();
        }
     
    }
}
