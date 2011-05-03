# -*- encoding: utf-8 -*-

require 'rubygems'
require 'sinatra'
require 'rack-flash'
require 'sass'
require 'haml'
require 'dm-core'
require 'dm-migrations'
require 'dm-timestamps'
require 'dm-validations'
require 'RMagick'
#require 'ruby-debug'

# datastorage configuration
DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, "sqlite:///#{File.expand_path(File.dirname(__FILE__))}/hb.db")

# sessions config & flashing
enable :sessions
use Rack::Flash, :sweep => true

# dm models
class Layout
	include DataMapper::Resource
	
	property :id, Serial
	property :title, String, :length => 128, :required =>  true
	property :body, Text, :required =>  true	
	
	property :created_on, DateTime
	property :updated_on, DateTime

	has 0..n, :pages
	
end

class Style
  include DataMapper::Resource
  
  property :id, Serial
  property :title, String, :length => 128, :required =>  true, :unique => true
  property :body, Text, :required =>  true  
  
  property :created_on, DateTime
  property :updated_on, DateTime
  
end

class Script
  include DataMapper::Resource
  
  property :id, Serial
  property :title, String, :length => 128, :required =>  true, :unique => true
  property :body, Text, :required =>  true  
  
  property :created_on, DateTime
  property :updated_on, DateTime
  
end

class Page

	include DataMapper::Resource

	property :id, Serial	
	property :title, String, :length => 128, :required =>  true
	property :url, String, :length => 256, :required =>  true, :unique => true
	property :keywords, String, :length => 128, :required =>  true
	property :description, String, :length => 256, :required =>  true
	property :body, Text, :required =>  true
	
	property :created_on, DateTime
	property :updated_on, DateTime
	
	belongs_to :layout
	
end

class Image
  
  include DataMapper::Resource
  
  property :id, Serial
  property :file_name, String, :required => true, :unique => true
  property :title, String, :length => 512
  property :description, String, :length => 256
  property :content_type, String, :length => 128, :required => true  
  property :data, Object, :required => true 
  
  property :created_on, DateTime
  property :updated_on, DateTime
  
  before :save do    
    if self.file
      debugger
      self.data = self.file[:tempfile].read
      self.content_type = self.file[:type]
    end
  end
  
  attr_accessor :file
    
end


DataMapper.finalize
DataMapper.auto_upgrade!

# filter

# dashboard
get '/dashboard/?' do
  haml :dashboard
end

# pages crud
get '/pages/?' do
	@pages = Page.all
	haml :pages
end

get '/pages/new/?' do
  @page = Page.new
  haml :new_page
end

post '/pages/create/?' do
  @page = Page.new(params[:page])
  if @page.save
    flash[:success] = "Страница успешно сохранена"
    redirect "/pages/edit/#{@page.id}/"
  else
    haml :new_page
  end
end

get '/pages/edit/:id/?' do
  @page = Page.get(params[:id])
  haml :edit_page
end

post '/pages/update/:id/?' do
  @page = Page.get(params[:id])
  if @page.update(params[:page])
    flash[:success] = "Страница успешно сохранена"
    redirect "/pages/edit/#{@page.id}/?"
  else
    haml :edit_page
  end
end

get '/pages/delete/:id/?' do
  @page = Page.get(params[:id])
  @page.destroy
  flash[:success] = "Страница успешно удалена"
  redirect '/pages/'
end

# layouts crud
get '/layouts/?' do
	@layouts = Layout.all
	haml :layouts
end

get '/layouts/new/?' do
	@layout = Layout.new
	haml :new_layout
end

post '/layouts/create/?' do
	@layout = Layout.new(params[:layout])
	if @layout.save
	  flash[:success] = "Шаблон успешно сохранен"
		redirect "/layouts/edit/#{@layout.id}/"
	else
		haml :new_layout
	end
end

get '/layouts/edit/:id/?' do
	@layout = Layout.get(params[:id])
	haml :edit_layout
end

post '/layouts/update/:id/?' do
	@layout = Layout.get(params[:id])
	if @layout.update(params[:layout])
	  flash[:success] = "Шаблон успешно сохранен"
		redirect "/layouts/edit/#{@layout.id}/"
	else
		haml :edit_layout
	end	
end

get '/layouts/delete/:id/?' do
	@layout = Layout.get(params[:id])	
	@layout.destroy  
	flash[:success] = "Шаблон успешно удален"
	redirect '/layouts/'
end

# styles crud
get '/styles/?' do
  @styles = Style.all
  haml :styles
end

get '/styles/new/?' do
  @style = Style.new
  haml :new_style
end

post '/styles/create/?' do
  @style = Style.new(params[:style])
  if @style.save
    flash[:success] = 'Таблица стилей успешно сохранена'
    redirect "/styles/edit/#{@style.id}/"
  else
    haml :new_style
  end
end

get '/styles/edit/:id/?' do
  @style = Style.get(params[:id])
  haml :edit_style
end

post '/styles/update/:id/?' do
  @style = Style.get(params[:id])
  if @style.update(params[:style])
    flash[:success] = 'Таблица стилей успешно сохранена'
    redirect "/styles/edit/#{@style.id}/"
  else
    haml :edit_style
  end
end

get '/styles/delete/:id/?' do
  @style = Style.get(params[:id])
  @style.destroy
  flash[:success] = 'Таблица стилей успешно удалена'
  redirect '/styles/'
end

# scripts crud
get '/scripts/?' do
  @scripts = Script.all
  haml :scripts
end

get '/scripts/new/?' do
  @script = Script.new
  haml :new_script
end

post '/scripts/create/?' do
  @script = Script.new(params[:script])
  if @script.save
    flash[:success] = 'Скрипт успешно сохранен'
    redirect "/scripts/edit/#{@script.id}/"
  else
    haml :new_script
  end
end

get '/scripts/edit/:id/?' do
  @script = Script.get(params[:id])
  haml :edit_script
end

post '/scripts/update/:id/?' do
  @script = Script.get(params[:id])
  if @script.update(params[:script])
    flash[:success] = 'Скрипт успешно сохранен'
    redirect "/scripts/edit/#{@script.id}/"
  else
    haml :edit_script
  end
end

get '/scripts/delete/:id/?' do
  @script = Script.get(params[:id])
  @script.destroy
  flash[:success] = 'Скирпт успешно удален'
  redirect '/scripts/'
end

# images crud
def get_image_data(params={})
  i = {}
  i[:file_name] =  params[:filename]    
  i[:data] =  params[:tempfile].read
  i[:content_type] = params[:type]
  return i
end

get '/images/upload/?' do
  haml :upload
end

post '/images/upload/' do
  unless params[:images]
    flash[:notice] = 'Не выбран не один файл'
    redirect '/images/'
  end
  
  params[:images].each do |image|
    i = get_image_data(image)
    file = Image.new(i)
    file.save
  end
  
  flash[:notice] = "Загружено #{params[:images].count} изображений" 
  redirect '/images/'
  
end

get '/images/?' do
  @images = Image.all 
  haml :images
end

get '/images/edit/:id/?' do
  @image = Image.get(params[:id])
  haml :edit_image
end

post '/images/update/:id/?' do
  @image = Image.get(params[:id])
  if @image.update(params[:image])    
    flash[:success] = 'Изображение успешно сохранено'
    redirect "/images/edit/#{@image.id}/"
  else
    haml :edit_image
  end
end

get '/images/delete/:id/?' do
  @image = Image.get(params[:id])
  @image.destroy
  flash[:success] = "Запись успешно удалена" 
  redirect '/images/'
end

# main routes
get '/stylesheet.css' do
  sass :stylesheet, :style => :expanded
end

get '/stylesheets/:style.css' do
  @style = Style.first(:title => params[:style])
  content_type :css
  @style.body
end

get '/javascripts/:script.js' do
  @script = Script.first(:title => params[:script])
  content_type 'text/javascript'
  @script.body
end

get '/images/:size/:name' do
  @image = Image.first(:file_name => params[:name])
  width, height = params[:size].split('x')
  img = Magick::Image.from_blob(@image.data).first
  thumb = img.change_geometry("#{width}x#{height}") do |cols, rows, obj|
    obj.resize(cols, rows)
  end
  content_type @image.content_type
  thumb.to_blob
end

get '/images/:name' do
  @image = Image.first(:file_name => params[:name])
  content_type @image.content_type
  @image.data
end

get '/' do
  @page = Page.first(:url => '/')
  unless @page
    flash[:notice] = "Создайте шаблон и стартовую страницу сайта"
    redirect '/layouts/'
  end
  erb @page.body, :layout => @page.layout.body  
end

get '/:url/?' do
  @page = Page.first(:url => request.path)
  unless @page
    flash[:notice] = "Создайте шаблон и страницу сайта"
  end
  erb @page.body, :layout => @page.layout.body
end

# helpers
helpers do
  
  def stylesheet_link_tag(title)
    "<link rel='stylesheet' href='/stylesheets/#{title}.css?#{Time.new.strftime("%s")}' />"
  end
  
  def javascript_include_tag(title)
    "<script type='text/javascript' src='/javascripts/#{title}.js?#{Time.new.strftime("%s")}'></script>"
  end
  
  def image_tag(file_name, size=nil)
    unless size
      "<img src='/images/#{file_name}' alt='#{file_name}' />"
    else
      "<img src='/images/#{size}/#{file_name}' alt='#{file_name}' />"
    end 
  end
  
	def render_partial(name, locals={})
		haml name.to_sym, :layout => false, :locals => locals
	end
	
	def content_for(key, &block)
    @content_for[key.to_sym] << block if block_given?
  end
  
  def layout_select_tag(model, layout)
    options = '' 
    @layouts = Layout.all
    @layouts.each do |l|
      unless layout && l.id = layout.id
        options << "<option value='#{l.id}'>#{l.title}</option>"
      else
        options << "<option selected='selected' value='#{l.id}'>#{l.title}</option>"
      end
    end
    "<select id='#{model}_layout_id' name='#{model}[layout_id]'>#{options}</select>"
  end
  
end

__END__

@@stylesheet
body
  font-family: Verdana, Arial, sans-serif
  font-size: .7em
  
#container
  margin: 0 auto
  width: 1024px
  background: #fff

#header
  background: #ccc
  padding: 20px
  h1
    margin: 0

.navigation
  float: left
  width: 1024px
  background: #333
  ul
    margin: 0
    padding: 0
    li
      list-style-type: none
      display: inline
  li a
    display: block
    float: left
    padding: 5px 10px
    color: #fff
    text-decoration: none
    border-right: 1px solid#fff
    &:hover
      background: #383
  li ul
    position: absolute    
    left: 0
    z-index: 598
    width: 100%
    dsiplay:none
    clear: both
    float: none
  li:hover ul
    display: block
  li:hover ul li
    float: none
#content
  clear: left
  padding: 1px  
  h2
    color: #000
    margin: 0 0 .5em
    
#footer
  background: #ccc
  text-align: right
  padding: 20px
  height: 1%
  clear: both
  
.clear
  clear: both

/* icons
.dashboard
  ul
    margin-top: 20px
    list-style: none
    li
      width: 80px
      margin: 0 20px 20px 0
      display: -moz-inline-stack
      display: inline-block
      vertical-align: top
      text-align: center      
      zoom: 1    
      a
        display: block
        padding: 5px
        border: 1px solid #F1F1F1
        text-decoration: none        
        span
          font: 11px Tahoma,sans-serif
          color: #383
          display: block
/* form
  
form label
  clear: left
  display: block
  float: left
  width: 100px
  padding-right: 10px
  margin-bottom: 5px

form input[type=text]
  width: 850px
  padding: 3px
  margin-bottom: 5px

form select
  margin-left: 5px

form textarea
  width: 960px
  height: 768px
  padding: 5px
  overflow: auto
  
form ol, form ul
  list-style: none
  padding: 15px
  margin: 0

form ol li, form ul li
  clear: both
  
form .buttons
  padding: 15px
  
/* table

table
  border-collapse: collapse
  margin: 0px 0px 0px 0px
  width: 100%

tr
  background: #FFF

th, td
  text-align: left
  border-width: 1px
  border-style: solid
  font-size: 11px
  
td a
  color: #383

th
  font-family: tahoma, verdana, arial, helvetica, sans-serif  
  color: white
  font-weight: bold
  background-color: #606060
  background-position: top left
  background-repeat: repeat-x
  margin-top: 0px
  margin-bottom: 1px
  padding: 10px 15px 10px 15px

td
  border-color: #E9E9E9
  padding: .7em 1em

tr
  &.odd
    background: #E9E9E9
  &:hover
    color: #000
    background-color: #EEF8FB
    
/* boxes

.roundcorner
  -moz-border-radius-topleft: 5px
  -moz-border-radius-topright: 5px
  -webkit-border-top-left-radius: 5px
  -webkit-border-top-right-radius: 5px
  border-top-left-radius: 5px 5px
  border-top-right-radius: 5px 5px
    
.box  
  background: #FBFCFC  
  padding: 1px
  margin-bottom: 20px  

.box-head
  height: 32px
  color: white
  padding: 0 10px
  line-height: 32px
  white-space: nowrap
  border-bottom: solid 1px white
  background-color: #606060
  background-position: top left
  background-repeat: repeat-x
  h2
    font-size: 15px !important
    font-weight: bold
    margin: 0 !important
    padding: 0 !important
    color: #fff !important

/* -- Form message --

.form-message
  display: block
  padding: 10px 20px 10px 35px
  margin: 20px 5px
  border: 1px solid
  -webkit-border-radius: 6px
  border-radius: 6px
  -moz-border-radius: 6px
  &.success
    border-color: #a8f383
    background: #e4ffd4 url(/images/correct.gif) 10px 11px no-repeat
  &.error
    border-color: #f3a48c
    background: #ffded4 url(/images/error.gif) 10px 11px no-repeat   
  &.notice
    border-color: #fbea81    
    background: #fff9d4 url(/images/warning.gif) 10px 11px no-repeat
  p
    margin: 0 !important
    padding: 0 !important
    
.validation_summary
  display: block
  padding: 0px 20px 10px 35px
  margin: 0px 5px 20px
  border: 1px solid
  background: #ffded4 url(/images/error.gif) 10px 11px no-repeat
  border-color: #f3a48c
  -webkit-border-radius: 6px
  border-radius: 6px
  -moz-border-radius: 6px
  
.validation_summary ol
  padding: 0
  list-style: decimal
  
.validation_summary ol li
  margin-left: 15px
  font-weight: bold


/* gallery
.raduis
  -moz-border-radius: 3px
  -webkit-border-radius: 3px
  border-radius: 3px
   
.gallery li
  display: inline-block
  float: left
  vertical-align: top
  
.gallery li
  width: 98px
  margin: 5px 5px 0px 5px
  padding-bottom: 10px

.gallery .thumb
  display: block
  width: 90px
  height: 90px
  border: 1px solid #BBBBBB
  padding: 3px
  background: #FFFFFF
  margin-bottom: 4px

.gallery .title
  color: #333333
  display: block
  font-size: 11px
  line-height: 18px
  padding: 0px 6px 0px 6px  
  text-align: center
  height: 20px

.gallery .title .wrap
  display: block
  white-space: nowrap
  overflow: hidden

.gallery li:hover .title
  color: #FFFFFF  
  position: relative  

.gallery li:hover .wra      
  overflow: visible
  position: absolute
  top: 0px
  left: 0px
  
.gallery li .wrap a
  text-decoration: none
  color: #383  

.gallery li .wrap a:hover
  text-decoration: underline
  
/* inputs
#page_description, #image_description  
  height: 75px  

@@ layout
%html
  %head
    %title
      =request.host
    %link{:rel => 'stylesheet', :type => 'text/css', :href => '/stylesheet.css'}
    %link{:rel => 'stylesheet', :type => 'text/css', :href => '/cm/lib/codemirror.css'}
    %script{:type => 'text/javascript', :src => '/cm/lib/codemirror.js' }
    %link{:rel => 'stylesheet', :type => 'text/css', :href => '/cm/mode/css/css.css'}
    %script{:type => 'text/javascript', :src => '/cm/mode/css/css.js' }
    %link{:rel => 'stylesheet', :type => 'text/css', :href => '/cm/mode/xml/xml.css'}
    %script{:type => 'text/javascript', :src => '/cm/mode/xml/xml.js' }
    %link{:rel => 'stylesheet', :type => 'text/css', :href => '/cm/mode/javascript/javascript.css'}
    %script{:type => 'text/javascript', :src => '/cm/mode/javascript/javascript.js' }
    %script{:type => 'text/javascript', :src => '/cm/mode/htmlmixed/htmlmixed.js' }
    
    %script{:type => 'text/javascript', :src => 'http://ajax.googleapis.com/ajax/libs/jquery/1.5.2/jquery.min.js' }
    %script{:type => 'text/javascript', :src => '/javascripts/core.js' }
  %body
    #container
      #header.roundcorner
        %h1
          =request.host
      .navigation
        %ul
          %li
            %a{:href => "/"} Домой
          %li
            %a{:href => "/dashboard/"} Панель управления
          %li
            %a{:href => "/layouts/"} Шаблоны            
          %li
            %a{:href => "/pages/"} Страницы
          %li
            %a{:href => "/styles/"} Таблицы стилей
          %li
            %a{:href => "/scripts/"} Скрипты          
          %li
            %a{:href => "/images/"} Изображения
        .clear
      #content
        -if flash[:notice]
          .form-message.notice
            =flash[:notice]
        -if flash[:error]
          .form-message.error
            =flash[:error]
        -if flash[:success]
          .form-message.success
            =flash[:success]
        = yield
      .clear
      .navigation
        %ul
          %li
            %a{:href => "/layouts/new/"} Добавить шаблон            
          %li
            %a{:href => "/pages/new/"} Добавить страницу
          %li
            %a{:href => "/styles/new/"} Добавить таблицу стилей
          %li
            %a{:href => "/scripts/new/"} Добавить скрипт          
          %li
            %a{:href => "/images/upload/"} Загрузить изображения
      #footer
        Copyright (c) 
        =request.host
        , 
        =Time.now.strftime('%Y')
        
@@dashboard
.box
  .box-head.roundcorner
    %h2
      Панель управления
  .dashboard
    %ul
      %li
        %a{:href => "/pages/new/", :title => 'Добавить страницу' }
          %img{:alt => 'Добавить страницу', :title => 'Добавить страницу', :src => "/images/page.png" }
          %span
            Добавить страницу
      %li
        %a{:href => "/layouts/new/", :title => 'Добавить шаблон' }
          %img{:alt => 'Добавить шаблон', :title => 'Добавить шаблон', :src => "/images/layout.png" }
          %span
            Добавить шаблон
      %li
        %a{:href => "/styles/new/", :title => 'Добавить таблицу стилей' }
          %img{:alt => 'Добавить таблицу стилей', :title => 'Добавить таблицу стилей', :src => "/images/stylesheets.png" }
          %span
            Добавить таблицу стилей
      %li
        %a{:href => "/scripts/new/", :title => 'Добавить скрипт' }
          %img{:alt => 'Добавить скрипт', :title => 'Добавить скрипт', :src => "/images/javascript.png" }
          %span
            Добавить скрипт
      %li
        %a{:href => "/images/upload/", :title => 'Загрузить изображения' }
          %img{:alt => 'Загрузить изображения', :title => 'Загрузить изображения', :src => "/images/photos.png" }
          %span
            Загрузить файлы изображений
  .clear

@@pages
.box
  .box-head.roundcorner
    %h2 Страницы
  %table
    %tr
      %th
        Название
      %th
        Ссылка
      %th
        Описание      
      %th
        Добавлено
      %th
        Изменено
      %th
    - @pages.each_with_index do |page, i|
      %tr{ :class => ((i % 2 == 0) ? 'even' : 'odd') }
        %td
          =page.title
        %td
          %a{:href => page.url, :target => '_blank', :title => page.title}=page.url
        %td
          =page.description
        %td
          =page.created_on.strftime('%d.%m.%Y %H:%M')
        %td
          =page.updated_on.strftime('%d.%m.%Y %H:%M')
        %td
          %a{ :href => "/pages/edit/#{page.id}/", :title => 'Редактировать' } Редактировать
          &nbsp;|&nbsp;
          %a{ :href => "/pages/delete/#{page.id}/", :title => 'Удалить', :onclick => 'return window.confirm("Вы уверенны что хотите удалить запись?")' } Удалить
          
@@page_form
%ul
  - unless @page.errors.empty?
    .validation_summary
      %h3
        При сохраненнии записи возникли следующие ошибки:
      %ol
        - @page.errors.each do |e|
          %li=e
  %li
    %label{:for => 'page_title'} Название
    %input{:type => 'text', :id => 'page_title', :name=> 'page[title]', :value => @page.title}
  %li
    %label{:for => 'page_url'} Ссылка
    %input{:type => 'text', :id => 'page_url', :name=> 'page[url]', :value => @page.url}
  %li
    %label{:for => 'page_keywords'} Ключевые слова
    %input{:type => 'text', :id => 'page_keywords', :name=> 'page[keywords]', :value => @page.keywords}
  %li
    %label{:for => 'page_description'} Описание
    %textarea{:id => 'page_description', :name=> 'page[description]'}=@page.description
  %li
    %label{:for => 'page_layout'} Шаблон
    =layout_select_tag(:page, @page.layout)
  %li
    %label{:for => 'page_body'} Страница
    %textarea{ :id => 'page_body', :name => 'page[body]'}=@page.body
%div.buttons
  %input{:type => 'submit', :value => 'Сохранить'}
  
:javascript
  var editor = CodeMirror.fromTextArea(document.getElementById("page_body"), {mode: "text/html", tabMode: "indent"});

@@new_page
.box
  .box-head.roundcorner
    %h2 Добавить страницу
  %form{:action => '/pages/create/', :method => 'post'}
    = render_partial(:page_form)
  
@@ edit_page
.box
  .box-head.roundcorner
    %h2 Редактировать страницу
  %form{:action => "/pages/update/#{@page.id}/", :method => 'post'}
    = render_partial(:page_form)  

@@layouts
.box
  .box-head.roundcorner
    %h2 Шаблоны
  %table
    %tr
      %th
        Название    
      %th
        Добавлено
      %th
        Изменено
      %th
    - @layouts.each do |layout|
      %tr
        %td
          =layout.title
        %td
          =layout.created_on.strftime('%d.%m.%Y %H:%M')
        %td
          =layout.updated_on.strftime('%d.%m.%Y %H:%M')
        %td
          %a{ :href => "/layouts/edit/#{layout.id}/", :title => 'Редактировать' }Редактировать
          &nbsp;|&nbsp;
          %a{ :href => "/layouts/delete/#{layout.id}/", :title => 'Удалить', :onclick => 'return window.confirm("Вы уверенны что хотите удалить запись?")' }Удалить

@@layout_form
%ul
  - unless @layout.errors.empty?
    .validation_summary
      %h3
        При сохраненнии записи возникли следующие ошибки:
      %ol
        - @layout.errors.each do |e|
          %li=e
  %li
    %label{:for => 'layout_title'} Название шаблона
    %input{:type => 'text', :id => 'layout_title', :name=> 'layout[title]', :value => @layout.title}
  %li
    %label{:for => 'layout_body'} Тело шаблона
    %textarea{ :id => 'layout_body', :name => 'layout[body]'}=@layout.body
%div.buttons
  %input{:type => 'submit', :value => 'Сохранить'}
  
:javascript
  var editor = CodeMirror.fromTextArea(document.getElementById("layout_body"), {mode: "text/html", tabMode: "indent"});

@@new_layout
.box
  .box-head.roundcorner
    %h2 Добавить шаблон
  %form{:action => '/layouts/create/', :method => 'post'}
    = render_partial(:layout_form)
  
@@edit_layout
.box
  .box-head.roundcorner
    %h2 Редактировать шаблон
  %form{:action => "/layouts/update/#{@layout.id}/", :method => 'post'}
    = render_partial(:layout_form)
    
@@styles
.box
  .box-head.roundcorner
    %h2 Таблицы стилей
  %table
    %tr
      %th
        Название    
      %th
        Добавлено
      %th
        Изменено
      %th
    - @styles.each do |style|
      %tr
        %td
          =style.title
        %td
          =style.created_on.strftime('%d.%m.%Y %H:%M')
        %td
          =style.updated_on.strftime('%d.%m.%Y %H:%M')
        %td
          %a{ :href => "/styles/edit/#{style.id}/", :title => 'Редактировать' } Редактировать
          &nbsp;|&nbsp;
          %a{ :href => "/styles/delete/#{style.id}/", :title => 'Удалить', :onclick => 'return window.confirm("Вы уверенны что хотите удалить запись?")' } Удалить
          
@@style_form
%ul
  - unless @style.errors.empty?
    .validation_summary
      %h3
        При сохраненнии записи возникли следующие ошибки:
      %ol
        - @style.errors.each do |e|
          %li=e
  %li
    %label{:for => 'style_title'} Название таблицы стилей
    %input{:type => 'text', :id => 'style_title', :name=> 'style[title]', :value => @style.title}
  %li
    %label{:for => 'style_body'} Таблица стилей
    %textarea{ :id => 'style_body', :name => 'style[body]'}=@style.body
%div.buttons
  %input{:type => 'submit', :value => 'Сохранить'}
  
:javascript
  var editor = CodeMirror.fromTextArea(document.getElementById("style_body"), {mode: "text/css", tabMode: "indent"});

@@new_style
.box
  .box-head.roundcorner
    %h2 Добавить таблицу стилей
  %form{:action => '/styles/create/', :method => 'post'}
    = render_partial(:style_form)
  
@@edit_style
.box
  .box-head.roundcorner
    %h2 Редактировать таблицу стилей
  %form{:action => "/styles/update/#{@style.id}/", :method => 'post'}
    = render_partial(:style_form)
    
@@scripts
.box
  .box-head.roundcorner
    %h2 Таблицы стилей
  %table
    %tr
      %th
        Название    
      %th
        Добавлено
      %th
        Изменено
      %th
    - @scripts.each do |script|
      %tr
        %td
          =script.title
        %td
          =script.created_on.strftime('%d.%m.%Y %H:%M')
        %td
          =script.updated_on.strftime('%d.%m.%Y %H:%M')
        %td
          %a{ :href => "/scripts/edit/#{script.id}/", :title => 'Редактировать' } Редактировать
          &nbsp;|&nbsp;
          %a{ :href => "/scripts/delete/#{script.id}/", :title => 'Удалить', :onclick => 'return window.confirm("Вы уверенны что хотите удалить запись?")' } Удалить
          
@@script_form
%ul
  - unless @script.errors.empty?
    .validation_summary
      %h3
        При сохраненнии записи возникли следующие ошибки:
      %ol
        - @script.errors.each do |e|
          %li=e
  %li
    %label{:for => 'script_title'} Название скрипта
    %input{:type => 'text', :id => 'script_title', :name=> 'script[title]', :value => @script.title}
  %li
    %label{:for => 'script_body'} Скрипт
    %textarea{ :id => 'script_body', :name => 'script[body]'}=@script.body
%div.buttons
  %input{:type => 'submit', :value => 'Сохранить'}
  
:javascript
  var editor = CodeMirror.fromTextArea(document.getElementById("script_body"), {mode: "text/javascript", tabMode: "indent"});

@@new_script
.box
  .box-head.roundcorner
    %h2 Добавить таблицу стилей
  %form{:action => '/scripts/create/', :method => 'post'}
    = render_partial(:script_form)
  
@@edit_script
.box
  .box-head.roundcorner
    %h2 Редактировать таблицу стилей
  %form{:action => "/scripts/update/#{@script.id}/", :method => 'post'}
    = render_partial(:script_form)
    
@@upload
.box
  .box-head.roundcorner
    %h2 Загрузить изображения
  %form{:action => '/images/upload/', :method => 'post', :enctype => 'multipart/form-data'}
    %ul#files
      %li
        %input{:type => 'file', :name => 'images[]'}
    %div.buttons
      %input{:type => 'button', :value => 'Добавить файл', :onclick => 'return addUploadField("images", "#files")'}
      %input{:type => 'submit', :value => 'Загрузить'}
      
@@images
.box
  .box-head.roundcorner
    %h2
      Изображения
  .gallery
    %ul
    - @images.each do |image|
      %li
        %a{:href => "/images/edit/#{image.id}/", :title => image.title }
          %img{:class => 'thumb', :alt => image.file_name, :title => image.title, :src => "/images/80x80/#{image.file_name}" }
        %span.title
          %span.wrap
            %a{:href => "/images/edit/#{image.id}/", :title => 'Редактировать' }
              Редактировать
        %span.title
          %span.wrap
            %a{:href => "/images/delete/#{image.id}/", :title => 'Удалить', :onclick => 'return window.confirm("Вы уверенны что хотите удалить запись?")' }
              Удалить
            
@@edit_image
.box
  .box-head.roundcorner
    %h2 Редактировать изображение
  %form{:action => "/images/update/#{@image.id}/", :method => 'post', :enctype => 'multipart/form-data'}
    = render_partial(:image_form)

@@image_form
%ul
  - unless @image.errors.empty?
    .validation_summary
      %h3
        При сохраненнии записи возникли следующие ошибки:
      %ol
        - @image.errors.each do |e|
          %li=e
  %li
    %label{:for => 'image_title'} Название
    %input{:type => 'text', :id => 'image_title', :name=> 'image[title]', :value => @image.title}
  %li
    %label{:for => 'image_description'} Скрипт
    %textarea{ :id => 'image_description', :name => 'image[description]'}=@image.description
  %li
    %label{:for => 'image_file'} Загрузить изображение
    %input{:type => 'file', :name => 'image[file]', :id => 'image_file'}
  %li
    %img{:class => 'full', :alt => @image.file_name, :title => @image.title, :src => "/images/#{@image.file_name}" }/
%div.buttons
  %input{:type => 'submit', :value => 'Сохранить'}

                