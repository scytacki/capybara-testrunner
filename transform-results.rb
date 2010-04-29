require 'rexml/document'

module TransformResults
  include REXML

  class TestModule
    attr_accessor :name, :tests, :failures, :errors
  
    def initialize(name)
      @name = name
      @tests = []
      @failures = 0
      @errors = 0
    end
  end

  class TestTest
    attr_accessor :name, :assertions, :failed
  
    def initialize(name)
      @name = name
      @assertions = []
      @failed = false
    end
  
    def message
      messages = self.assertions.collect{|assertion| 
        assertion['result'].upcase + ': ' + assertion['message']
      }
      messages.join('\n')
    end
  end

  def self.parseResults(results)
    modules = []
    currentModule = nil
    currentTest = nil

    results['assertions'].each{|assertion| 
      if currentModule.nil? or currentModule.name != assertion['module']
        currentModule = TestModule.new(assertion['module'])    
        modules.push(currentModule)
      end
  
      if currentTest.nil? or currentTest.name != assertion['test']
        currentTest = TestTest.new(assertion['test'])
        currentModule.tests.push(currentTest)
      end
  
      currentModule.failures += 1 if assertion['result'] == ('failed')
      currentModule.errors += 1 if assertion['result'] == ('errors')
      if assertion['result'] != 'passed'
        currentTest.failed = true
      end
      currentTest.assertions.push(assertion)  
    } 
  
    modules
  end

  def self.transform(results, out)
    modules = parseResults(results)
 
    doc = Document.new();
    testsuites = doc.add_element('testsuites')
      # testsuite = testsuites.add_element('testsuite', {
      #    'tests' => results['tests'],
      #    'errors' => results['errors'], 
      #    'failures' => results['failed'],
      #    'timestamp' => results['finish'],
      #    'time' => (results['runtime']),
      #    })

    modules.each{ |currModule|
      testsuite = testsuites.add_element('testsuite', 
        {'name' => currModule.name.split(' ')[1], 'tests' => currModule.tests.length,
          'failures' => currModule.failures, 'errors' => currModule.errors})
      fileName = currModule.name.split(' ')[0]
      className = fileName.sub(/\.js/, '').gsub(/\//, '.')
      currModule.tests.each{ |currTest|
        testcase = testsuite.add_element('testcase',
        {'name' => currTest.name, 'classname' => className})
        if currTest.failed      
          testcase.add_element('failure', {'message' => currTest.message})
        elsif
          testcase.add_element('pass', {'message' => currTest.message})
        end
      }  
    }

    pretty_formatter = Formatters::Pretty.new(2)
    pretty_formatter.compact = true
    pretty_formatter.write(doc, out)

  end
end