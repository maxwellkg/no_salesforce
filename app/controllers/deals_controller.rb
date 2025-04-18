class DealsController < ApplicationController
  include SAL::AdvancedSearchable

  before_action :set_deal, only: %i[ show edit update destroy ]

  # index defined by SAL::AdvancedSearchable

  # GET /deals/1 or /deals/1.json
  def show
  end

  # GET /deals/new
  def new
    @deal = Deal.new
  end

  # GET /deals/1/edit
  def edit
  end

  # POST /deals or /deals.json
  def create
    binding.break
    @deal = Deal.new(deal_params)

    respond_to do |format|
      if @deal.save
        format.html { redirect_to @deal, notice: "Deal was successfully created." }
        format.json { render :show, status: :created, location: @deal }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @deal.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /deals/1 or /deals/1.json
  def update
    respond_to do |format|
      if @deal.update(deal_params)
        format.html { redirect_to @deal, success: "Deal was successfully updated." }
        format.json { render :show, status: :ok, location: @deal }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @deal.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /deals/1 or /deals/1.json
  def destroy
    @deal.destroy!

    respond_to do |format|
      format.html { redirect_to deals_path, status: :see_other, notice: "Deal was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_deal
      @deal = Deal.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def deal_params
      params.require(:deal).permit(:name, :account_id, :owner_id, :close_date, :stage_id, :amount, :description, :source_id)
    end

    def sal_config_klass
      SAL::Configs::Deals
    end
end
