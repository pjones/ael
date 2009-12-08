#!/usr/bin/env ruby
################################################################################
# Copyright (C) 2009 Peter Jones <pjones@pmade.com>
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
################################################################################
require('erb')

################################################################################
# Ug, add some Ruby 1.9 stuff to Ruby 1.8 for roxml
class Object
  def tap
    yield(self)
    self
  end
end

################################################################################
module ContextualDevelopment
  def self.srequire (gem)
    require(gem)
  rescue LoadError => e
    if gem == 'rubygems'
      $stderr.puts("Please install RubyGems: http://rubyforge.org/frs/?group_id=126")
    else
      $stderr.puts("You need the #{gem} gem, run the following command")
      $stderr.puts("gem install #{gem}")
    end
    
    exit(1)
  end
end

################################################################################
ContextualDevelopment.srequire('rubygems')
ContextualDevelopment.srequire('linkedin')
ContextualDevelopment.srequire('sinatra')

################################################################################
get('/') do
  erb(:index)
end

################################################################################
post('/go') do
  $client = LinkedIn::Client.new(params[:key], params[:secret])
  $client.set_callback_url(request.url.sub('go', 'ready'))
  redirect($client.request_token.authorize_url)
end

################################################################################
get('/ready') do
  rtoken  = $client.request_token.token
  rsecret = $client.request_token.secret
  @token = $client.authorize_from_request(rtoken, rsecret, params[:oauth_verifier])
  erb(:token)
end
