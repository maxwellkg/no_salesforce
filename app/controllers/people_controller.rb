class PeopleController < ApplicationController
  #include SAL::Analyzable

  include SAL::AdvancedSearchable

  before_action :set_person, only: %i[ show edit update destroy ]

  # GET /people/1 or /people/1.json
  def show
  end

  # GET /people/new
  def new
    @person = Person.new
  end

  # GET /people/1/edit
  def edit
  end

  # POST /people or /people.json
  def create
    @person = Person.new(person_params)

    respond_to do |format|
      if @person.save
        format.html do
          flash[:success] = "Person was successfully created."
          redirect_to @person
        end

        format.json { render :show, status: :created, location: @person}
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @person.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /people/1 or /people/1.json
  def update
    respond_to do |format|
      if @person.update(person_params)
        
        format.html do 
          flash[:success] = "Person was successfully updated."
          redirect_to @person
        end

        format.json { render :show, status: :ok, location: @person}
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @person.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /people/1 or /people/1.json
  def destroy
    @person.destroy!

    respond_to do |format|
      format.html { redirect_to people_path, status: :see_other, notice: "Contact was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_person
      @person = Person.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def person_params
      params.require(:person).permit(:first_name, :last_name, :email_address, :account_id, :job_title, :owner_id, :lead_source_id)
    end

    def sal_config_klass
      SAL::Configs::People
    end
end
