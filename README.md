WHAT THE FORK!!!
==============

I finally got sick of js templates that were all single-line obfuscated and indecipherable messes.  Debugging was harder than it had to be so I scratched my own itch and rewrote the main compilation logic.

This is a fork of EJS preserves lines, so your line # in your js console should be the same as the line number in the actual template.  This will also make it easier to set debugging points in your template.

This is essentially a rewrite of the core compiler logic, though the interface is 100% compatible with upstream.  In fact, I have not modified the tests at all (they still pass, of course!)

I used the same gem name and reset the version to 1.0.0 so I could use it with rails-backbone.

To use with rails-backbone instead of the default, just put

		gem 'ejs', :git => 'https://github.com/aaronblohowiak/ruby-ejs.git'

above the line where you have:

		gem "rails-backbone"


and then `bundle install`


*About the rewrite:* Unfortunately, the code grew about %25.  The original version just runs gsub to escape special chars and then un-escapes them within the matching `<% ... %>` tags.  Unfortunately, that didn't let you treat line endings differently outside of the matching tags.  So, in order to process the line endings in the rendered html template in a way that js can handle (no multi-line strings!) I had to convert it from a simple three-pass gsub! to a more complicated system that essentially splits the source code and treats each section appropriately.

I am more than interested in accepting pull requests that clean up the code while making the tests pass.


EJS (Embedded JavaScript) template compiler for Ruby
====================================================

EJS templates embed JavaScript code inside `<% ... %>` tags, much like
ERB. This library is a port of
[Underscore.js](http://documentcloud.github.com/underscore/)'s
[`_.template`
function](http://documentcloud.github.com/underscore/#template) to
Ruby, and strives to maintain the same syntax and semantics.

Pass an EJS template to `EJS.compile` to generate a JavaScript
function:

    EJS.compile("Hello <%= name %>")
    # => "function(obj){...}"

Invoke the function in a JavaScript environment to produce a string
value. You can pass an optional object specifying local variables for
template evaluation.

The EJS tag syntax is as follows:

* `<% ... %>` silently evaluates the statement inside the tags.
* `<%= ... %>` evaluates the expression inside the tags and inserts
  its string value into the template output.
* `<%- ... %>` behaves like `<%= ... %>` but HTML-escapes its output.

If you have the [ExecJS](https://github.com/sstephenson/execjs/)
library and a suitable JavaScript runtime installed, you can pass a
template and an optional hash of local variables to `EJS.evaluate`:

    EJS.evaluate("Hello <%= name %>", :name => "world")
    # => "Hello world"

-----

&copy; 2012 Sam Stephenson

Released under the MIT license
