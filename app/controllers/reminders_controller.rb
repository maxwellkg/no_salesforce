class RemindersController < ApplicationController
  include SAL::AdvancedSearchable

  before_action :set_reminder, only: %i[ show edit destroy ]

  # index defined by SAL::AdvancedSearchable


  # GET /reminders/1 or /reminders/1.json
  def show
  end

  # GET /reminders/new
  def new
    @reminder = new_reminder
  end

  # GET /reminders/1/edit
  def edit
  end

  # POST /reminders or /reminders.json
  def create
    @reminder = new_reminder

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

  # PATCH/PUT /reminders/1 or /reminders/1.json
  def update
    @reminder = updated_reminder

    respond_to do |format|
      if @reminder.save
        format.html { redirect_to @reminder, notice: "Activity was successfully updated." }
        format.json { render :show, status: :ok, location: @reminder }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @reminder.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /reminders/1 or /reminders/1.json
  def destroy
    @reminder.destroy!

    respond_to do |format|
      format.html { redirect_to reminders_path, status: :see_other, notice: "Activity was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_reminder
      @reminder = Reminder.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def reminder_params
      params.require(:reminder).permit(:reminder, :account_id, { person_ids: [] }, :occurring_at, :type_id, :title, :notes, :complete, :logged_to_sgid, :assigned_to_id)
    end

    def new_reminder
      reminder = Reminder.new

      return reminder unless params[:reminder]

      assign_reminder_attributes(reminder)

      reminder
    end

    def updated_reminder
      reminder = Reminder.find(params.expect(:id))

      assign_reminder_attributes(reminder)

      reminder
    end

    def assign_reminder_attributes(reminder)
      attributes = reminder_params.dup

      sgid = attributes.delete(:logged_to_sgid)

      reminder.assign_attributes(attributes)

      if sgid.present?
        reminder.logged_to = GlobalID::Locator.locate_signed sgid, for: :polymorphic_select
      end

      reminder
    end

    def sal_config_klass
      SAL::Configs::Reminders
    end
end
