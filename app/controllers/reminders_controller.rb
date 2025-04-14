class RemindersController < ApplicationController
  before_action :set_activity, only: %i[ show edit update destroy ]

  # GET /activities or /activities.json
  def index
    @activities = Reminder.all
  end

  # GET /activities/1 or /activities/1.json
  def show
  end

  # GET /activities/new
  def new
    @reminder = Reminder.new
  end

  # GET /activities/1/edit
  def edit
  end

  # POST /activities or /activities.json
  def create
    @reminder = Reminder.new(reminder_params)

    respond_to do |format|
      if @reminder.save
        format.html { redirect_to @reminder, notice: "Activity was successfully created." }
        format.json { render :show, status: :created, location: @reminder }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @reminder.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /activities/1 or /activities/1.json
  def update
    respond_to do |format|
      if @reminder.update(reminder_params)
        format.html { redirect_to @reminder, notice: "Activity was successfully updated." }
        format.json { render :show, status: :ok, location: @reminder }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @reminder.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /activities/1 or /activities/1.json
  def destroy
    @reminder.destroy!

    respond_to do |format|
      format.html { redirect_to activities_path, status: :see_other, notice: "Activity was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_activity
      @reminder = Reminder.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def reminder_params
      params.fetch(:reminder, {})
    end
end
