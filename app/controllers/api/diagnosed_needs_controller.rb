# frozen_string_literal: true

module Api
  class DiagnosedNeedsController < ApplicationController
    def create
      DiagnosedNeed.transaction do
        @diagnosed_needs = DiagnosedNeed.create create_param_array
      end
      render body: nil, status: :created
    rescue StandardError
      render body: nil, status: :bad_request
    end

    private

    def create_param_array
      param_array = params.permit(diagnosed_needs: %i[question_id content]).require(:diagnosed_needs)
      param_array.each { |need_params| need_params.merge!(diagnosis_id: params[:diagnosis_id]) }
      param_array
    end
  end
end
