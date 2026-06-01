class ApiTokensController < ApplicationController
  def index
    @tokens = ApiToken.order(created_at: :desc)
    @new_token = session.delete(:new_token)
  end

  def create
    token = ApiToken.create!(token_params)
    session[:new_token] = token.plain_token
    redirect_to api_tokens_path, notice: "Token created. Copy it now — it won't be shown again."
  end

  def destroy
    token = ApiToken.find(params[:id])
    token.destroy
    redirect_to api_tokens_path, notice: "Token revoked."
  end

  private

  def token_params
    params.require(:api_token).permit(:name, :scopes, :expires_at)
  end
end
