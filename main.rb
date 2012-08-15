require 'sinatra'
require 'dm-core'
require 'dm-migrations'
require 'dm-timestamps'
require 'sass'
require 'slim'

configure do
  DataMapper.setup(:default, ENV['DATABASE_URL'] || File.join("sqlite3://",settings.root, "development.db"))
end

class Riddle
  include DataMapper::Resource
  property    :id,           Serial

  property :created_at, DateTime
  property :updated_at, DateTime

  property :title,           String

  property    :html,         Text
  property    :css,          Text
  property    :js,           Text

  def title=(value) 
    super(value.empty? ? "Yet another untitled Riddle" : value) 
  end 
end

DataMapper.finalize

get '/css/styles.css' do
  scss :styles
end

get '/' do
  @riddles = Riddle.all.reverse
  slim :index
end

get '/new/riddle' do
  slim :new
end

get '/riddle/:id' do
  @riddle = Riddle.get(params[:id])
  slim :show
end

post '/riddle' do
  riddle = Riddle.create(params[:riddle])
  redirect to("/riddle/#{riddle.id}")
end

__END__
########### Views ###########
@@layout
doctype html
html lang="en"
  head
      title== @title || 'Riddle'
      meta charset="utf-8"
      link rel="stylesheet" href="/css/styles.css"
  body
    header role="banner"
      h1 
        a href='/' Riddle
      a href='/new/riddle' New Riddle
    #main.content
      == yield

@@index
- if @riddles
  - @riddles.each do |riddle|
    li
      a href="/riddle/#{riddle.id}"== riddle.title
- else
  p No riddles have been created yet!

@@new
== slim :form

@@show
h1== @riddle.title
h2 Markup
p== @riddle.html
h2 Styles
p== @riddle.css
h2 Javascript
p== @riddle.js

@@form
form action="/riddle" method="POST"
  label for="title" Title
  input#title name="riddle[title]"
  label for="html" HTML
  textarea#html cols=60 rows=10 name="riddle[html]"
  label for="css" CSS
  textarea#css cols=60 rows=10 name="riddle[css]"
  label for="js" JS
  textarea#js cols=60 rows=10 name="riddle[js]"
  input.button type="submit" value="Save"

@@styles
form label {display: block;}
