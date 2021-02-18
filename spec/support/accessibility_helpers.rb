module AccessibilityHelpers
  def meet_accessibility_standards
    be_axe_clean.according_to(:wcag2a, :wcag2aa, :wcag21a, :wcag21aa)
  end
end
