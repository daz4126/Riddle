require 'sinatra'
require 'dm-core'
require 'dm-migrations'
require 'sass'
require 'redcarpet'
require 'slim'
require 'haml'
require 'RedCloth'
require "coffee-script"
require "v8"
require "liquid"
require "markaby"
require "less"

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
  property    :html_engine,  String
  property    :css,          Text
  property    :css_engine,   String
  property    :js,           Text
  property    :js_engine,    String

  def title=(value) 
    super(value.empty? ? "Yet another untitled Riddle" : value) 
  end 
end

DataMapper.finalize

get('/css/styles.css'){ scss :styles }

get '/css/riddle/:id/styles.css' do
  riddle = Riddle.get(params[:id])
  scss riddle.css
end

get '/js/riddle/:id/script.js' do
  riddle = Riddle.get(params[:id])
  content_type 'text/javascript'
  render :str, riddle.js, :layout => false
end

get '/' do
  @riddles = Riddle.all.reverse
  slim :index
end

get '/new/riddle' do
  @riddle = Riddle.new
  slim :new
end

get '/edit/riddle/:id' do
  riddle = Riddle.get(params[:id])
  @riddle = Riddle.new(riddle.attributes.merge(id: nil))
  slim :new
end

get '/riddle/:id' do
  @riddle = Riddle.get(params[:id])
  slim :show
end

get '/:id' do
  @riddle = Riddle.get(params[:id])
  slim :riddle, layout: false
end

post '/riddle' do
  riddle = Riddle.create(params[:riddle])
  redirect to("/riddle/#{riddle.id}")
end

__END__
@@layout
doctype html
html lang="en"
  head
    title== @title || 'Riddle'
    meta charset="utf-8"
    link rel="stylesheet" href="/css/styles.css"
  body
    header role="banner"
      h1.logo
        a href='/' ? Riddle
      a.button href='/new/riddle' New Riddle
      - if @riddle && @riddle.id
        a.button href="/edit/riddle/#{@riddle.id}" Edit this Riddle
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
form action="/riddle" method="POST"
  label for="title" Title
  input#title name="riddle[title]" value="#{@riddle.title}"
  select name="riddle[html_engine]"
    option value="markdown" HTML
    option value="markdown" MARKDOWN
    option value="textile" TEXTILE
    option value="haml" HAML
    option value="slim" SLIM
    option value="erb" ERB
    option value="liquid" LIQUID
    option value="markaby" MARKABY
  textarea#html cols=60 rows=10 name="riddle[html]"=@riddle.html
  select name="riddle[css_engine]"
    option value="css" CSS
    option value="scss" SCSS
    option value="sass" SASS
    option value="less" LESS
  textarea#css cols=60 rows=10 name="riddle[css]"=@riddle.css
  select name="riddle[js_engine]"
    option value="javascript" JAVASCRIPT
    option value="coffee" COFFEESCRIPT
  textarea#js cols=60 rows=10 name="riddle[js]"=@riddle.js
  input.button type="submit" value="Save Riddle"

@@show
h1.title== @riddle.title
#riddle
  iframe src="/#{@riddle.id}"

@@riddle
doctype html
html lang="en"
  head
    title== @riddle.title
    meta charset="utf-8"
    style
      - if @riddle.css_engine =="css"
        == @riddle.css
      - else
        == send(@riddle.css_engine, @riddle.css)
    script
      - if @riddle.js_engine == "javascript"
        == @riddle.js
      - else
        == send(@riddle.js_engine, @riddle.js)
  body
    == send(@riddle.html_engine, @riddle.html)

@@styles
@import url(http://fonts.googleapis.com/css?family=Pacifico);
$purple:#639;
$green:#396;
body{ font: 13px/1.4 arial, sans-serif; }
header{ overflow: hidden; }
.logo{float:left;overflow: hidden;}
.logo a{ color: $purple; font: 64px/1 pacifico; text-decoration: none; &:hover{color:$green;}}
.title{ color: $green; font: 32px/1 pacifico; }
.button {text-decoration: none; font-weight: bold; padding: 4px 8px; border-radius: 10px; background: $green; color: white; border:none; &:hover{background:$purple;}}
header .button{ float:left; margin: 36px 10px 0;}
form label, input.button {display: block;}
form select {display: block;}
iframe {width: 100%; min-height: 600px; border: none; }
