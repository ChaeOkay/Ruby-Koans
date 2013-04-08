require File.expand_path(File.dirname(__FILE__) + '/edgecase')

# Project: Create a Proxy Class
#
# In this assignment, create a proxy class (one is started for you
# below).  You should be able to initialize the proxy object with any
# object.  Any messages sent to the proxy object should be forwarded
# to the target object.  As each message is sent, the proxy should
# record the name of the method sent.
#
# The proxy class is started for you.  You will need to add a method
# missing handler and any other supporting methods.  The specification
# of the Proxy class is given in the AboutProxyObjectProject koan.

class Proxy
# this proxy is recording what is passed through to class Television. 
  attr_reader :messages  
# We need a variable that records what's passed. Koans will only accept the variable "messages". 
# also, since we are only recording and retreiving info, we only need
# to have "read" access, so attr_reader
  
  def initialize(target_object)
    @target_object = target_object
    @messages = []
  end
  
  
  def method_missing(method_name, *args)
# From the project description, we know a "method_missing" handler is needed.
# Additionally, we need to both record the message, and pass the message.
# For "tv.channel = 10" we know there are additional pieces of 
# information being provided, that need to passed. We can accomodate this by adding in *args
    @messages.push(method_name)
# we are only recording the method names, not the additinal arguments
    @target_object.send(method_name, *args)
# the "about_message_passing" lesson, showed us that messages can be invoked
# with the send message, which will fulfill the requirement of "passing" the message. 
  end
  
  
  def called?(method_name)
# our next message from Koans is that we need a called? method
# my first try was "return true if @messages.respond_to?(method_name)"
# but koans sent back a message that <nil> is not true. 

  return true unless @messages.index(method_name).nil?
# since the message has already been recorded, we can see if the 
# the message is an index inside of the @messages array as an alternative
# to respond_to? 
# In this syntax, we can find out if the method is 'nil' 
  end
  
  
  def number_of_times_called(method_name)
# this one is pretty easy, just counting the number of occurances of each method inside of the @messages array
    @messages.count(method_name)
  end
  
end


# The proxy object should pass the following Koan:
#
class AboutProxyObjectProject < EdgeCase::Koan
  def test_proxy_method_returns_wrapped_object
    # NOTE: The Television class is defined below
    tv = Proxy.new(Television.new)

    # HINT: Proxy class is defined above, may need tweaking...

    assert tv.instance_of?(Proxy)
  end

  def test_tv_methods_still_perform_their_function
    tv = Proxy.new(Television.new)

    tv.channel = 10
    tv.power

    assert_equal 10, tv.channel
    assert tv.on?
  end

  def test_proxy_records_messages_sent_to_tv
    tv = Proxy.new(Television.new)

    tv.power
    tv.channel = 10

    assert_equal [:power, :channel=], tv.messages
  end

  def test_proxy_handles_invalid_messages
    tv = Proxy.new(Television.new)

    assert_raise(NoMethodError) do
      tv.no_such_method
    end
  end

  def test_proxy_reports_methods_have_been_called
    tv = Proxy.new(Television.new)

    tv.power
    tv.power

    assert tv.called?(:power)
    assert ! tv.called?(:channel)
  end

  def test_proxy_counts_method_calls
    tv = Proxy.new(Television.new)

    tv.power
    tv.channel = 48
    tv.power

    assert_equal 2, tv.number_of_times_called(:power)
    assert_equal 1, tv.number_of_times_called(:channel=)
    assert_equal 0, tv.number_of_times_called(:on?)
  end

  def test_proxy_can_record_more_than_just_tv_objects
    proxy = Proxy.new("Code Mash 2009")

    proxy.upcase!
    result = proxy.split

    assert_equal ["CODE", "MASH", "2009"], result
    assert_equal [:upcase!, :split], proxy.messages
  end
end


# ====================================================================
# The following code is to support the testing of the Proxy class.  No
# changes should be necessary to anything below this comment.

# Example class using in the proxy testing above.
class Television
  attr_accessor :channel

  def power
    if @power == :on
      @power = :off
    else
      @power = :on
    end
  end

  def on?
    @power == :on
  end
end

# Tests for the Television class.  All of theses tests should pass.
class TelevisionTest < EdgeCase::Koan
  def test_it_turns_on
    tv = Television.new

    tv.power
    assert tv.on?
  end

  def test_it_also_turns_off
    tv = Television.new

    tv.power
    tv.power

    assert ! tv.on?
  end

  def test_edge_case_on_off
    tv = Television.new

    tv.power
    tv.power
    tv.power

    assert tv.on?

    tv.power

    assert ! tv.on?
  end

  def test_can_set_the_channel
    tv = Television.new

    tv.channel = 11
    assert_equal 11, tv.channel
  end
end
