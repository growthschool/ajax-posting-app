class PostsController < ApplicationController

  before_action :authenticate_user!, :only => [:create, :destroy]

  def index
    @posts = Post.order("id DESC").limit(10)

    if params[:max_id]
      @posts = @posts.where( "id < ?", params[:max_id])
    end

    respond_to do |format|
      format.html
      format.js
    end
  end

  def toggle_flag
    @post = Post.find(params[:id])

    if @post.flag_at
      @post.flag_at = nil
    else
      @post.flag_at = Time.now
    end

    @post.save!

    render :json => { :message => "ok", :id => @post.id, :flag_at => @post.flag_at }
  end

  def like
    @post = Post.find(params[:id])
    unless @post.find_like(current_user)
      Like.create( :user => current_user, :post => @post)
    end

    #redirect_to posts_path
  end

  def unlike
    @post = Post.find(params[:id])
    like = @post.find_like(current_user)
    like.destroy

    #redirect_to posts_path
    render "like"
  end

  def create
    @post = Post.new(post_params)
    @post.user = current_user
    @post.save
    # redirect_to posts_path

  end

  def destroy
    @post = current_user.posts.find(params[:id])
    @post.destroy

    render :json => { :id => @post.id }
    # redirect_to posts_path
    # render :js => "alert('ok');"
    # destroy.js.erb
  end

  protected

  def post_params
    params.require(:post).permit(:content)
  end

end
