class Admin::UserGroupsController < Admin::ForestController
  include FilterControllerScopes

  before_action :set_user_group, only: [:show, :edit, :update, :destroy]

  has_scope :by_name

  # GET /user_groups
  def index
    @pagy, @user_groups = pagy apply_scopes(UserGroup).by_name
    authorize @user_groups
  end

  # GET /user_groups/1
  def show
    authorize @user_group
  end

  # GET /user_groups/new
  def new
    @user_group = UserGroup.new
    authorize @user_group
  end

  # GET /user_groups/1/edit
  def edit
    authorize @user_group
  end

  # POST /user_groups
  def create
    @user_group = UserGroup.new(user_group_params)
    authorize @user_group

    if @user_group.save
      redirect_to edit_admin_user_group_path(@user_group), notice: 'User group was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /user_groups/1
  def update
    authorize @user_group
    if @user_group.update(user_group_params)
      redirect_to edit_admin_user_group_path(@user_group), notice: 'User group was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /user_groups/1
  def destroy
    authorize @user_group
    @user_group.destroy
    redirect_to admin_user_groups_url, notice: 'User group was successfully destroyed.'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_user_group
    @user_group = UserGroup.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def user_group_params
    params.require(:user_group).permit(:name)
  end
end
