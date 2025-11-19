class CoursesController < ApiController
  before_action :authenticate_request!, only: [:create, :update, :destroy]
  after_action :verify_authorized, except: [:index, :show]

  def index
    @courses = Course.all
    render json: @courses
  end

  def show
    @course = Course.find(params[:id])
    if @course
      render json: @course
    else
      render json: @course.errors, status: :not_found
    end
  end

  def create
    @course = current_user.courses.new(course_params)
    authorize @course
    
    if @course.save
      render json: @course, status: :created
    else
      render json: @course.errors, status: :unprocessable_entity
    end
  end

  def update
    @course = Course.find(params[:id])
    authorize @course

    if @course.update(course_params)
      render json: @course
    else
      render json: @course.errors, status: :unprocessable_content
    end
  end

  def destroy
    @course = Course.find(params[:id])
    authorize @course

    if @course.destroy
      head :no_content, message: 'Course deleted successfully', status: :ok
    else
      render json: @course.errors, status: :unprocessable_content
    end
  end

  private

  def course_params
    params.permit(:title, :description, :price)
  end
end
