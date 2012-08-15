require 'sinatra'
require 'sass'
require 'slim'

get '/css/styles.css' do
  scss :styles
end

get '/' do
  slim :index
end

get '/new/riddle' do
  slim :new
end

post '/riddle' do
  slim :show
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
h1 Index Page
p This will list all of the riddles

@@new
== slim :form

@@show
h1 Riddle Show page
p This will show the riddle

@@form
form action="/riddle" method="POST"
  label for="title" Title
  input#title name="riddle[title]"
  label for="html" HTML
  textarea#html cols=60 rows=10
  label for="css" CSS
  textarea#css cols=60 rows=10
  label for="js" JS
  textarea#js cols=60 rows=10
  input.button type="submit" value="Save"

@@styles
form label {display: block;}
