class Admin::ResponsesController < Admin::BaseController
  before_action :find_consultation
  before_action :limit_edition_access!
  before_action :enforce_edition_permissions!
  before_action :prevent_modification_of_unmodifiable_edition
  before_action :find_response, only: %i[edit update]
  layout :get_layout

  def show
    @response = response_class.find_by(edition_id: @edition) || response_class.new(published_on: Time.zone.today)
    render_design_system("show", "show_legacy", next_release: false)
  end

  def create
    @response = response_class.new(response_params)
    @response.consultation = @edition
    if @response.save
      redirect_to [:admin, @edition, @response.singular_routing_symbol], notice: "#{@response.friendly_name.capitalize} saved"
    else
      render_design_system("show", "show_legacy", next_release: false)
    end
  end

  def edit
    render_design_system("edit", "edit_legacy", next_release: false)
  end

  def update
    if @response.update(response_params)
      redirect_to [:admin, @edition, @response.singular_routing_symbol], notice: "#{@response.friendly_name.capitalize} updated"
    else
      render_design_system("edit", "edit_legacy", next_release: false)
    end
  end

private

  def get_layout
    design_system_actions = []
    design_system_actions += %w[show create edit update] if preview_design_system?(next_release: false)

    if design_system_actions.include?(action_name)
      "design_system"
    else
      "admin"
    end
  end

  def find_consultation
    @edition = Consultation.find(params[:consultation_id])
  end

  def find_response
    @response = response_class.find_by(edition_id: @edition)
    raise(ActiveRecord::RecordNotFound, "Could not find Response for Consulatation with ID #{@edition.id}") unless @response
  end

  def enforce_edition_permissions!
    enforce_permission!(:update, @edition)
  end

  def response_class
    case params[:type]
    when "ConsultationOutcome"
      ConsultationOutcome
    when "ConsultationPublicFeedback"
      ConsultationPublicFeedback
    end
  end

  def response_key
    response_class.to_s.underscore
  end

  def response_params
    params.require(response_key).permit(:summary, :published_on)
  end
end
