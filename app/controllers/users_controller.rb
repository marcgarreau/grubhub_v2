class UsersController<ApplicationController

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      session[:user_id] = @user.id
      redirect_to root_path, notice: 'Registration successful, congrats you can use a keyboard.'
    else
      render :new
    end
  end

  def update
    @user = User.find(params[:id])
    @user.update(update_user_params)
    redirect_to user_path(@user)
  end

  def show
    @user = User.find(params[:id])
  end

  def edit
    @user = User.find(params[:id])
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation)
  end

  def update_user_params
    params.require(:user).permit(:first_name, :last_name, :email, :nickname)
  end

end
