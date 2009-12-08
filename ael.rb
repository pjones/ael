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
require('yaml')
require('time')
require('./common')

################################################################################
ContextualDevelopment.srequire {'rubygems'}
ContextualDevelopment.srequire {'linkedin'}

################################################################################
class Person
  
  ##############################################################################
  def initialize
    @start_times = []
  end
  
  ##############################################################################
  def << (position)
    year  = position.start_year  || Time.now.year
    month = position.start_month || 1
    @start_times << Time.parse("#{year}/#{month}").to_i
  end
  
  ##############################################################################
  def to_durations
    durations = []
    @start_times.sort!
    
    @start_times.each_with_index do |time, index|
      next if (index+1) == @start_times.size
      durations << @start_times[index+1] - time
    end
    
    # convert to fractional years
    durations.map {|t| t/31556926.0}
  end
end

################################################################################
class Stats
  
  ##############################################################################
  def initialize
    @data = []
    @people = 0
  end
  
  ##############################################################################
  def << (person)
    durations = person.to_durations
    return if durations.empty?
    @data.concat(durations)
    @people += 1
  end
  
  ##############################################################################
  def calculate
    sum = @data.inject {|s, n| s+n}
    avg = sum/@data.size.to_f
    sd  = @data.inject(0.0) {|s, n| s += Math.sqrt(n - sum)} / (@data.size - 1)
    sdp = sd + avg
    sdm = sd - avg
    
    File.open('tmp/data.yml', 'w') do |file|
      data = {:avg => avg, :sd => sd, :sdp => sdp, :sdm => sdm}
      file.write(data.to_yaml)
    end
    
    $stdout.puts("People: #@people Average Employment: #{avg} (fractional years)")
  end
end

################################################################################
class Driver
  
  ##############################################################################
  TOKEN_FILE = 'tmp/token.yml'
  
  ##############################################################################
  def initialize
    token = YAML.load_file(TOKEN_FILE)
    @client = LinkedIn::Client.new(token[:key], token[:secret]);
    @client.authorize_from_access(token[:atoken], token[:asecret]);
    @stats = Stats.new
  end
  
  ##############################################################################
  def run
    search('software developer') {|p| add_person(p)}
    search('software engineer')  {|p| add_person(p)}
    @stats.calculate
  end
  
  ##############################################################################
  private
  
  ##############################################################################
  def search (title, &block)
    total = 1
    index = 0

    while index < total do
      people = @client.search(:title => title, :start => index)
      return if people.count.zero?
      index += people.count
      total = people.total
      people.profiles.each {|p| block.call(p)}
    end
  end
  
  ##############################################################################
  def add_person (profile)
    person = Person.new
    profile.positions.each {|p| person << p}
    @stats << person
  end
end

################################################################################
begin
  raise('run auth.rb first') unless File.exist?(Driver::TOKEN_FILE)
  Driver.new.run
rescue RuntimeError => e
  $stderr.puts("ERROR: #{e}")
  exit(1)
end
