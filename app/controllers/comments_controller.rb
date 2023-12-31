class CommentsController < ApplicationController
  before_action :set_post, only: %i[ edit update create destroy ]

  def edit
    @comment = @post.comments.find(params[:id])
  end

  def create
    @comment = @post.comments.new(comment_params)

    if @comment.save
      respond_to do |format|
        format.turbo_stream
      end
    end
  end

  def update
    @comment = @post.comments.find(params[:id])

    if @comment.update(comment_params)
      respond_to do |format|
        format.turbo_stream
      end
    end
  end

  def destroy
    @comment = @post.comments.find(params[:id])

    if @comment.destroy
      respond_to do |format|
        format.turbo_stream
      end
    end
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end

  def comment_params
    params.require(:comment).permit(:body)
  end
end
