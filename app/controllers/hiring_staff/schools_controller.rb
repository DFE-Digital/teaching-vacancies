class HiringStaff::SchoolsController < HiringStaff::BaseController
  def show
    @school = SchoolPresenter.new(School.find_by!(urn: params[:id]))
  end

  def edit
    @school = School.find_by!(urn: params[:id])

    return if params[:description].nil?

    @school.description = params[:description].presence
    @school.valid?
  end

  def update
    school = School.find_by!(urn: params[:id])
    school.description = params[:school][:description]

    if school.save
      redirect_to school_path(school)
    else
      redirect_to edit_school_path(school, description: school.description)
    end
  end

  def index
    # Nothing to do here yet
  end

  def search
    @schools = School.where(['name ILIKE ?', "%#{params[:name]}%"])
    render 'search_results'
  end
end
