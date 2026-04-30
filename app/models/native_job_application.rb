class NativeJobApplication < JobApplication
  def uploaded_file
    baptism_certificate.blob if baptism_certificate.attached?
  end
end
