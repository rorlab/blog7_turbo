class CommentsController < ApplicationController
  before_action :set_post, only: %i[ create destroy ]

  def create
    @comment = @post.comments.new(comment_params)

    if @comment.save
      respond_to do |format|
        format.turbo_stream
      end
    end
  end

  def destroy
    @comment = @post.comment.find(params[:id])

    if @comment.destroy
      response_to do |format|
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
