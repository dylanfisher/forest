class Admin::UsersController < Admin::ForestController
  include FilterControllerScopes

  before_action :set_user, only: [:show, :edit, :update, :destroy]

  has_scope :by_email
  has_scope :by_last_name
  has_scope :by_first_name

  # GET /users
  def index
    @pagy, @users = pagy apply_scopes(User.includes(:user_groups)).by_id
    authorize @users
  end

  # GET /users/1
  def show
    authorize @user
  end

  # GET /users/new
  def new
    @user = User.new
    authorize @user
  end

  # GET /users/1/edit
  def edit
    authorize @user
  end

  # POST /users
  def create
    @user = User.new(user_params)
    authorize @user

    if @user.save
      redirect_to edit_admin_user_path(@user), notice: 'User was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /users/1
  def update
    authorize @user

    if params[:user][:password].blank? && params[:user][:password_confirmation].blank?
      params[:user].delete(:password)
      params[:user].delete(:password_confirmation)
    end

    if @user.update(user_params)
      redirect_to edit_admin_user_path(@user), notice: 'User was successfully updated.'
    else
      render :edit
    end
  end

  def reset_password
    @user = User.find(params[:user_id])
    authorize @user

    if @user.send_reset_password_instructions
      redirect_to edit_admin_user_path(@user), notice: 'User password reset link was successfully sent.'
    else
      render :edit
    end
  end

  # DELETE /users/1
  def destroy
    authorize @user
    @user.destroy
    redirect_to admin_users_url, notice: 'User was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def user_params
      params.require(:user).permit(:email, :first_name, :last_name, :password, :password_confirmation, *admin_user_params)
    end

    def admin_user_params
      _admin_user_params = []
      _admin_user_params.concat([user_group_ids: []]) if current_user.admin?
      _admin_user_params
    end
end
