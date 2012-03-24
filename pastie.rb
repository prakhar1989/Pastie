require 'sinatra'
require 'data_mapper'
require 'dm-mysql-adapter'
require 'syntaxi'

DataMapper.setup(:default, "mysql://root:password@localhost/pastiedb")


class Snippet
  include DataMapper::Resource

  property :id, Serial
  property :body, Text
  property :created_at, DateTime
  property :updated_at, DateTime

  validates_presence_of :body
  validates_length_of :body, :min => 1

  Syntaxi::line_number_method = 'floating'
  Syntaxi::wrap_enabled = false
  Syntaxi::wrap_at_column = 70

  def formatted_body
    replacer = Time.now.strftime('[code-%d]')
    html = Syntaxi.new("[code lang='ruby']#{self.body.gsub('[/code]', replacer)}[/code]").process
    "<div class=\"syntax syntax_ruby\">#{html.gsub(replacer, '[/code]')}</div>"
  end

  def formatted_body2
    html = Syntaxi.new("[code lang='ruby']#{self.body}[/code]").process
    html
  end
end

DataMapper.auto_upgrade!

#new
get '/' do
  erb :new
end

post '/' do
  @snippet = Snippet.new(:body => params[:snippet_body])
  if @snippet.save
    redirect "/#{@snippet.id}" 
  else
    redirect '/'
  end
end

get '/:id' do
  @snippet = Snippet.get(params[:id])
  if @snippet
    erb :show
  else
    redirect '/'
  end
end


