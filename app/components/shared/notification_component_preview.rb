class Shared::NotificationComponentPreview < ViewComponent::Preview
  layout "preview"

  attr_accessor :variants, :form

  def initialize
    @variants = [
      { id: "success", name: "Success", title: "Success alert", description: "Sometimes dismissable." },
      { id: "notice", name: "Notice", title: "General information alert", description: "Sometimes dismissable." },
      { id: "warning", name: "Warning", title: "Warnings to user", description: "Never dismissable. This is a warning message or something potentially bad for the user." },
      { id: "empty", name: "Empty", title: "Inline emphasis", description: "Basic inline emphasis." },
    ]

    @form = Shared::NotificationComponentPreview::PreviewOptionsForm
  end
end
