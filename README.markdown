# About

This is a little bit of code that uses the
[LinkedIn](http://www.linkedin.com/) API to calculate the average
length of employment for software developers.

# But, It Doesn't Work

Unfortunately, this code doesn't work yet because of restrictions in
the LinkedIn API.  Currently (Dec. 2009) they only allow you to see
the first entry of employment history.

Without being able to see all entries, you can't calculate a duration
and therefore can't calculate an average length.

# Prerequisites

You should have [RubyGems](http://rubyforge.org/frs/?group_id=126)
installed first.  Then install the required gems with the following
commands:

    sudo gem install gemcutter
    sudo gem install linkedin
    sudo gem install sinatra

# LinkedIn Developer Key

You also need to get a developer key from LinkedIn
[here](https://www.linkedin.com/secure/developer).

# Generate the Access Token

Run the auth.rb script, and then point your browser at
[http://localhost:4567](http://localhost:4567):

    ruby auth.rb

# Generate Some Statistics

    ruby ael.rb
