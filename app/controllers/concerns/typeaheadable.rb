module Typeaheadable
  extend ActiveSupport::Concern

  included do
    allow_unauthenticated_access

    rate_limit to: 20, within: 1.second
  end

  DEFAULT_LIMIT = 50.freeze

  def index
    @target = target
    @options = options
    @existing = existing

    @value_method = params[:value_method]
    @text_method = params[:text_method]

    respond_to do |format|
      format.turbo_stream do
        render 'typeaheads/index'
      end
    end
  end

  private

    def target
      params[:target]
    end

    def search_term
      params[:search_term]
    end

    def search_method
      :search
    end

    def order_by
      nil
    end

    def limit
      nil
    end

    def options
      klass.send(search_method, search_term).order(order_by).limit(limit || DEFAULT_LIMIT)
    end

    def existing_options
      params[:existing]
    end

    def existing
      klass.find(existing_options) if existing_options.present?
    end

end
