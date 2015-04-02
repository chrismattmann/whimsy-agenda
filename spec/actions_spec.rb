#
# This specifies server actions which generally are performed in response
# to a form action.
#

require_relative 'spec_helper'
require_relative '../models/pending'
require 'shellwords'

feature 'server actions' do
  before :each do
    @test_data = File.read('test/work/data/test.yml')
    @transcript = ''
    @cleanup = []
  end

  it "should post a comment" do
    @initials = 'xx'
    @agenda = 'board_agenda_2015_01_21.txt'
    @attach = 'Z'
    @comment = 'testing'

    eval(File.read('views/actions/comment.json.rb'))
    expect(Pending.get('test')['comments']['Z']).to eq('testing')
    expect(Pending.get('test')['initials']).to eq('xx')
  end

  it "should remove a comment" do
    expect(Pending.get('test')['comments']['I']).to eq('Nice report!')

    @initials = 'xx'
    @agenda = 'board_agenda_2015_01_21.txt'
    @attach = 'I'
    @comment = nil

    eval(File.read('views/actions/comment.json.rb'))
    expect(Pending.get('test')['comments']).not_to include('I')
  end

  it "should reset comments when the agenda changes" do
    expect(Pending.get('test')['comments']['I']).to eq('Nice report!')

    @initials = 'xx'
    @agenda = 'board_agenda_2015_02_18.txt'
    @attach = 'Z'
    @comment = nil

    eval(File.read('views/actions/comment.json.rb'))
    expect(Pending.get('test')['comments']).not_to include('I')
  end

  it "should approve a report" do
    @agenda = 'board_agenda_2015_01_21.txt'
    @attach = 'C'
    @request = 'approve'

    eval(File.read('views/actions/approve.json.rb'))
    expect(Pending.get('test')['approved']).to include('C')
  end

  it "should unapprove a report" do
    expect(Pending.get('test')['approved']).to include('7')

    @agenda = 'board_agenda_2015_01_21.txt'
    @attach = '7'
    @request = 'unapprove'

    eval(File.read('views/actions/approve.json.rb'))
    expect(Pending.get('test')['approved']).not_to include('7')
  end

  it "should commit pending comments and approvals" do
    @pending = Pending.get('test')
    expect(@pending['approved']).to include('7')
    expect(@pending['comments']['I']).to eq('Nice report!')

    @message = "Approve W3C Relations\nComment on BookKeeper"
    @initials = 'jt'

    eval(File.read('views/actions/commit.json.rb'), nil, 'commit.json.rb')

    expect(@pending['approved']).not_to include('7')
    expect(@pending['comments']).not_to include('I')

    w3c = @agenda.find {|item| item[:attach] == '7'}
    expect(w3c['approved']).to include('jt')

    avro = @agenda.find {|item| item[:attach] == 'I'}
    expect(avro['comments']).to include('jt: Nice report!')
  end

  # cleanup
  after :each do
    File.write('test/work/data/test.yml', @test_data)

    @cleanup.each do |file| 
      system 'svn', 'revert', file
      AgendaCache[File.basename(file)].replace :mtime=>0
    end
  end

  # 
  # administrivia
  #

  # wunderbar environment
  def _
    self
  end

  # sinatra environment
  def env
    Struct.new(:user, :password).new('test', nil)
  end

  # capture wunderbar 'json' output methods
  def method_missing(method, *args, &block)
    if method =~ /^_(\w+)$/ and args.length == 1
      instance_variable_set "@#$1", args.first
    else
      super
    end
  end

  # run system commands, appending output to transcript.
  # intercept commits, adding the files to the cleanup list
  def system(*args)
    args.flatten!
    if args[1] == 'commit'
      @cleanup <<= args[2]
    else
      @transcript += `#{Shellwords.join(args)}`
    end
  end
end
