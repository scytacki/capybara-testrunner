A set of ruby scripts to run and report sproutcore tests in Hudson

The basic snippet that the scripts build from:

	Capybara.current_driver = :selenium
	Capybara.app_host = "http://localhost:4020"
	include Capybara
	# a sproutcore "manual" test url as describe here:
	#  http://wiki.sproutcore.com/UnitTesting-Running+Unit+Tests
	visit("/cc/en/current/tests/views.html")
	results = evaluate_script('CoreTest.plan.results')
	# results is a ruby hash that represents the CoreTest.plan.results hash
	# that is available in the webpage after running the tests.
	puts results.inspect

The rest of the code in the repository is for exporting that results hash into a junit xml file that can be used by Hudson to report the number of passing and failing tests.

This approach could be generalized to run other browser based tests on a continuous integration server.  For example:

* jspec
* qunit

The most functional way of using these frameworks is to open a browser and point it at a testing page configured for the framework.
But that isn't easy to integrate with continuous integration server, because it wants a summary of the tests that it can save with the build and provide a standard report on the results. 

Capybara provides a way to make this work.  It can launch a webbrowser pointed at the testing page, and then introspect the page and its javascript objects to get the results.  

An alternative approach to running tests this way is to is to use env.js with rhino.  Or to use HTMLUnit.  However since that isn't running a real browser with full dom and css rendering there will always be something you can't fully test.

Another related framework for this [testswarm](http://testswarm.com/)
