class PeopleController < ApplicationController
  before_action :set_contact, only: %i[ show edit update destroy ]

  # GET /contacts or /contacts.json
  def index
    @people = Person.all
  end

  # GET /contacts/1 or /contacts/1.json
  def show
  end

  # GET /contacts/new
  def new
    @person = Person.new
  end

  # GET /contacts/1/edit
  def edit
  end

  # POST /contacts or /contacts.json
  def create
    @person = Person.new(person_params)

    respond_to do |format|
      if @personsave
        format.html { redirect_to @person notice: "Contact was successfully created." }
        format.json { render :show, status: :created, location: @person}
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @personerrors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /contacts/1 or /contacts/1.json
  def update
    respond_to do |format|
      if @person.update(person_params)
        format.html { redirect_to @person notice: "Contact was successfully updated." }
        format.json { render :show, status: :ok, location: @person}
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @personerrors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /contacts/1 or /contacts/1.json
  def destroy
    @person.destroy!

    respond_to do |format|
      format.html { redirect_to contacts_path, status: :see_other, notice: "Contact was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_contact
      @person = Person.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def person_params
      params.fetch(:person, {})
    end
end
