##! update-twitter.bro
##! add action types to the notice framework, fire off twitter scripts


@load base/frameworks/notice/main
#@load base/utils/site
@load base/frameworks/notice
@load base/utils/site


module Notice;

export {
	redef enum Action += {
		## Indicate that this log should be sent to twitter 
		## We just call the executable 
		UPDATE_TWITTER
	};

	redef record Info += {
		## If we tweet it let's mark it in the logs as tweeted
		tweeted: bool &log &default=F;
	};

	## Notice types which should be tweeted
	const tweeted_types: set[Notice::Type] = {} &redef;
	## ex: 
	redef tweeted_types += {SSH::Login};




	redef Notice::policy += {
		[$pred(n: Notice::Info)= { return (n$note in Notice::tweeted_types); },
		 $action = UPDATE_TWITTER],
	};
}

event notice(n: Notice::Info) &priority=-5
	{
	
	if ( UPDATE_TWITTER in n$actions )
		{

			# TODO: check for conn, may need to use n$src; may not have connection record
			local cmd = fmt("./update-twitter.py '%s'", n$msg);
			# TODO: check for errors & see if this executed
			piped_exec(cmd, fmt(""));
			n$tweeted = T;

		}
	}
