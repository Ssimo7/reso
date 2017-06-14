# frozen_string_literal: true

class VisitsController < ApplicationController
  def index
    @visits = Visit.of_advisor current_user
  end

  def new
    @visit = Visit.new siret: params[:siret]
  end

  def create
    @visit = Visit.new visit_params
    @visit.advisor = current_user
    if @visit.save
      redirect_to company_path(siret: @visit.siret)
    else
      render 'new'
    end
  end

  def edit_visitee
    find_visit
    @visit.build_visitee
  end

  def update_visitee
    find_visit
    @visit.assign_attributes update_visitee_params
    @visit.visitee.added_by_advisor = true
    @visit.visitee.skip_confirmation!
    if @visit.save
      update_visitee_redirection
    else
      render 'edit_visitee'
    end
  end

  def prepare_email
    # @assistance = Assistance.find params[:assistance_id]
    find_visit
  end

  private

  def find_visit
    @visit = Visit.find params[:id]
  end

  def update_visitee_redirection
    if params[:question_id].present?
      redirect_to question_diagnosis_index_path(id: params[:question_id])
    else
      redirect_to visits_path
    end
  end

  def visit_params
    params.require(:visit).permit(:siret, :happened_at)
  end

  def update_visitee_params
    params.require(:visit).permit(visitee_attributes: %i[first_name last_name email role institution phone_number])
  end
end
