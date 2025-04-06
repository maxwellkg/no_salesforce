class UsersController < ApplicationController
  include SAL::Analyzable

  before_action :set_user, only: %i[ show edit update destroy ]

  # GET /users or /users.json
  # def index
  #   @users = User.all
  # end
  #
  # index now comes from SAL::Analyzable

  # GET /users/1 or /users/1.json
  def show
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users or /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: "User was successfully created." }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1 or /users/1.json
  def update
    updated_params = user_params.merge(last_updated_by_id: current_user)

    respond_to do |format|
      if @user.update(updated_params)
        format.html do
          flash[:success] = "User was successfully updated."
          redirect_to @user
        end

        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1 or /users/1.json

  NON_ADMIN_DELETE_MESSAGE = "You don't have access to this feature".freeze
  ADMIN_CANT_DELETE_OWN_RECORD_MESSAGE = "Sorry, you are unable to delete your own user record. Please contact another admin user to have them delete your account".freeze

  def destroy

    if !current_user.admin?
      respond_to do |format|
        format.html do
          flash[:error] = NON_ADMIN_DELETE_MESSAGE
          redirect_back fallback_location: user_path(@user)
        end

        format.json do
          render json: { message: NON_ADMIN_DELETE_MESSAGE }, status: :unauthorized
        end
      end

      return true
    end

    if current_user.admin? && @user == current_user
      respond_to do |format|
        format.html do
          flash[:error] = ADMIN_CANT_DELETE_OWN_RECORD_MESSAGE
          redirect_back fallback_location: user_path(@user)
        end

        format.json do
          render json: { message: ADMIN_CANT_DELETE_OWN_RECORD_MESSAGE }
        end
      end

      return true
    end

    @user.destroy!

    respond_to do |format|
      format.html { redirect_to users_path, status: :see_other, notice: "User was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def home
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params.expect(:id))
    end


    # Only allow a list of trusted parameters through.
    def user_params
      params.require(:user).permit(:first_name, :last_name, :email_address, :password, :password_confirmation)
    end


    def sal_config_klass
      SAL::Configs::Users
    end

end
