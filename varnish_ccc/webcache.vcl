
import rewrite;
import std;

backend ccc {
	.host = "localhost";
	.port = "8888";
	.connect_timeout = 10m;
	.first_byte_timeout = 10m;
	.between_bytes_timeout = 10m;
}

backend logo {
	.host =  "localhost";
	.port = "80";
}

sub vcl_recv{
	set req.backend = ccc;
	unset req.http.cookie;
	set req.http.host = "events.ccc.de";
	if(req.request == "BAN"){
		ban("req.url ~ " + req.url);
	}


        if (req.request == "P") {
                return (lookup);
        }

}
sub vcl_fetch{
	set beresp.ttl = 5d;
	unset req.http.set-cookie;


	if(beresp.http.location){
		set beresp.http.location = regsub(beresp.http.location, "https?://events.ccc.de", "http://ccc.devsn.se");
		std.log("Rewrite:" + beresp.http.location);
	}

}

sub vcl_deliver{
	rewrite.rewrite_re("https://events.ccc.de","//ccc.devsn.se/");
	rewrite.rewrite_re("http://events.ccc.de","//ccc.devsn.se/");
	rewrite.rewrite_re("//events.ccc.de","//ccc.devsn.se/");
	rewrite.rewrite_re("https:\\\\/\\\\/events.ccc.de", "http:\\/\\/ccc.devsn.se");
	rewrite.rewrite_re("logo.png", "logo.png?mofassa");
}


sub vcl_hit {
        if (req.request == "PURGE") {
                purge;
                error 200 "Purged.";
        }
}

sub vcl_miss {
        if (req.request == "PURGE") {
                purge;
                error 200 "Purged.";
        }
}


