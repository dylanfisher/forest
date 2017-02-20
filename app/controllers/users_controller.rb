class UsersController < ForestController
  include FilterControllerScopes

  layout 'admin', except: [:show]

  before_action :set_user, only: [:show, :edit, :update, :destroy]

  has_scope :by_email
  has_scope :by_last_name
  has_scope :by_first_name

  # GET /users
  def index
    @users = apply_scopes(User).by_id.page params[:page]
    authorize @users
  end

  # GET /users/1
  def show
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
      redirect_to @user, notice: 'User was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /users/1
  def update
    authorize @user
    if @user.update(user_params)
      redirect_to @user, notice: 'User was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /users/1
  def destroy
    authorize @user
    @user.destroy
    redirect_to users_url, notice: 'User was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def user_params
      params.require(:user).permit(:email, :first_name, :last_name, :password, :password_confirmation, user_group_ids: [])
    end
end
