# frozen_string_literal: true

module Admin
  class PartnersController < Admin::ApplicationController
    include LoadUtilities
    before_action :set_partner, only: %i[show edit update destroy]
    before_action :set_tags, only: %i[new create edit]
    before_action :set_neighbourhoods, only: %i[new edit]
    before_action :set_service_area_map_ids, only: %i[new edit]

    def index
      @partners = policy_scope(Partner).order({ updated_at: :desc }, :name).includes(:address)

      respond_to do |format|
        format.html
        format.json do
          render json: PartnerDatatable.new(params,
                                            view_context: view_context,
                                            partners: @partners)
        end
      end
    end

    def new
      @partner = params[:partner] ? Partner.new(permitted_attributes(Partner)) : Partner.new
      @partner.tags = current_user.tags

      authorize @partner
    end

    def show
      authorize @partner
      redirect_to edit_admin_partner_path(@partner)
    end

    def create
      @partner = Partner.new(permitted_attributes(Partner))
      @partner.accessed_by_user = current_user

      authorize @partner

      # prevent someone trying to add the same service_area twice by mistake and causing a crash
      @partner.service_areas = @partner.service_areas.uniq(&:neighbourhood_id)

      respond_to do |format|
        if @partner.save
          format.html do
            flash[:success] = 'Partner was successfully created.'
            redirect_to admin_partners_path
          end

          format.json { render :show, status: :created, location: @partner }
        else
          format.html do
            flash.now[:danger] = 'Partner was not saved.'
            set_neighbourhoods
            set_service_area_map_ids
            render :new, status: :unprocessable_entity
          end
          format.json { render json: @partner.errors, status: :unprocessable_entity }
        end
      end
    end

    def edit
      authorize @partner
      @sites = Site.sites_that_contain_partner(@partner)
    end

    def update
      authorize @partner

      mutated_params = permitted_attributes(@partner)

      @partner.accessed_by_user = current_user

      # prevent someone trying to add the same service_area twice by mistake and causing a crash
      uniq_service_areas = mutated_params[:service_areas_attributes]
                           .to_h
                           .map { |_, val| val }
                           .uniq { |service_area| service_area[:neighbourhood_id] }

      mutated_params[:service_areas_attributes] = uniq_service_areas

      if @partner.update(mutated_params)
        flash[:success] = 'Partner was successfully updated.'
        redirect_to edit_admin_partner_path(@partner)

      else
        flash.now[:danger] = 'Partner was not saved.'
        set_neighbourhoods
        set_service_area_map_ids
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize @partner
      @partner.destroy
      respond_to do |format|
        format.html do
          flash[:success] = 'Partner was successfully destroyed.'
          redirect_to admin_partners_url
        end
        format.json { head :no_content }
      end
    end

    def setup
      @partner = Partner.new
      authorize @partner

      render and return unless request.post?

      @partner.attributes = setup_params
      @partner.accessed_by_user = current_user

      if @partner.valid?
        redirect_to new_admin_partner_url(partner: setup_params)
      else
        render 'setup', status: :unprocessable_entity
      end
    end

    private

    def set_service_area_map_ids
      # maps neighbourhood ID to service_area ID
      @service_area_id_map = if @partner
                               @partner
                                 .service_areas.select(:id, :neighbourhood_id)
                                 .map { |sa| { sa.neighbourhood_id => sa.id } }
                                 .reduce({}, :merge)
                             else
                               {}
                             end
    end

    def set_neighbourhoods
      # if user owns partner let them set any neighbourhood
      if @partner.present? && current_user.admin_for_partner?(@partner.id)
        @all_neighbourhoods = Neighbourhood.order(:name)
        return
      end

      @all_neighbourhoods = policy_scope(Neighbourhood).order(:name)
    end

    def user_not_authorized
      flash[:alert] = 'Unable to access'
      redirect_to admin_partners_url
    end

    def setup_params
      params.require(:partner).permit(:name, address_attributes: %i[street_address postcode])
    end
  end
end
