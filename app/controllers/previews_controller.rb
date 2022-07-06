class PreviewsController < ApplicationController
  layout "application"

  before_action :find_preview, only: :previews
  before_action :require_local!, unless: :show_previews?

  def index
    @previews = ViewComponent::Preview.all
    @page_title = "Component Previews"
    render "application/index"
  end

  def previews
    @previews = ViewComponent::Preview.all
    @page_title = "Component Previews"

    @preview_form = @preview.form.new
    @preview_name = @preview.component_name
    @preview_class = @preview.component_class
    @options = @preview.options

    prepend_application_view_paths
    prepend_preview_examples_view_path

    @example_name = File.basename(params[:path])
    @render_args = @preview.render_args(@example_name)
    layout = determine_layout(@render_args[:layout], prepend_views: false)[:layout]
    template = @render_args[:template]
    locals = @render_args[:locals]
    opts = {}
    opts[:layout] = layout if layout.present? || layout == false
    opts[:locals] = locals if locals.present?
    render template, opts
  end

  private

  def default_preview_layout
    ViewComponent::Base.default_preview_layout
  end

  def show_previews?
    ViewComponent::Base.show_previews
  end

  def find_preview
    candidates = []
    params[:path].to_s.scan(%r{/|$}) { candidates << Regexp.last_match.pre_match }
    preview = candidates.detect { |candidate| ViewComponent::Preview.exists?(candidate) }

    raise AbstractController::ActionNotFound, "Component preview '#{params[:path]}' not found" unless preview

    if preview
      @preview = ViewComponent::Preview.find(preview)
    end

    raise AbstractController::ActionNotFound, "Component preview '#{params[:path]}' not found" unless preview
  end

  # Returns either {} or {layout: value} depending on configuration
  def determine_layout(layout_override = nil, prepend_views: true)
    return {} unless defined?(Rails.root)

    layout_declaration = {}

    if !layout_override.nil?
      # Allow component-level override, even if false (thus no layout rendered)
      layout_declaration[:layout] = layout_override
    elsif default_preview_layout.present?
      layout_declaration[:layout] = default_preview_layout
    end

    prepend_application_view_paths if layout_declaration[:layout].present? && prepend_views

    layout_declaration
  end

  def prepend_application_view_paths
    prepend_view_path Rails.root.join("app/views") if defined?(Rails.root)
  end

  def prepend_preview_examples_view_path
    prepend_view_path(ViewComponent::Base.preview_paths)
  end
end
