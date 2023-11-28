namespace :vacancies do
  desc "Trash vacancies with specific external references"
  task trash_specific: :environment do
    external_references_to_trash = %w[
      10e5719e-6685-46e6-9393-e231ff905fd8
      807ea98e-07c2-4e7d-a2a2-75ad471fba3d
      098bb02b-86ef-4a19-a148-b959213a3e33
      a94c389e-030d-4244-b42d-4ee804d2859c
      5430a89c-c838-4bad-8732-7eb73e9d6533
    ]

    Vacancy.where(external_reference: external_references_to_trash).each do |vacancy|
      vacancy.update!(status: "trashed")
    end
  end
end
