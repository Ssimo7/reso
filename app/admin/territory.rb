# frozen_string_literal: true

ActiveAdmin.register Territory do
  menu priority: 8
  permit_params :name, :insee_codes

  includes :users, :advisors, :experts

  scope :all, default: true
  scope I18n.t("active_admin.territory.scopes.bassins_emploi"), :bassins_emploi

  ## index
  #
  filter :name

  index do
    selectable_column
    id_column
    column :name
    column :bassin_emploi
    column(:communes) { |territory| territory.communes.size }
  end

  ## Show
  #
  show do
    attributes_table do
      row :name
      row :bassin_emploi
      row(:communes) { |t| safe_join(t.communes.map { |commune| link_to commune, admin_commune_path(commune) }, ', '.html_safe) }
    end

    render partial: 'admin/antennes', locals: {
      table_name: I18n.t('activerecord.attributes.territory.antennes'),
      antennes: territory.antennes
    }

    render partial: 'admin/users', locals: {
      table_name: I18n.t('activerecord.attributes.territory.relays'),
      users: territory.users.distinct
    }

    render partial: 'admin/users', locals: {
      table_name: I18n.t('activerecord.attributes.territory.advisors'),
      users: territory.advisors.distinct
    }

    render partial: 'admin/experts', locals: {
      table_name: I18n.t('activerecord.attributes.territory.experts'),
      experts: territory.experts.distinct
    }

    render partial: 'admin/matches', locals: { matches: Match.in_territory(territory).ordered_by_status }
  end

  # Form
  #
  form do |f|
    f.inputs do
      f.input :name
      f.input :bassin_emploi
    end
    f.inputs do
      f.input :insee_codes
    end

    f.actions
  end
end
