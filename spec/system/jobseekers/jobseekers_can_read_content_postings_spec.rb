require "rails_helper"

RSpec.describe "Jobseekers can read content postings", :a11y do
  it "has accessible content pages" do
    visit posts_path(section: "jobseeker-guides")

    expect(page).to be_axe_clean
  end

  it "has accessible get help applying subcategory" do
    visit subcategory_path(section: "jobseeker-guides", subcategory: "get-help-applying-for-your-teaching-role")

    expect(page).to be_axe_clean
  end

  it "has accessible return to teaching subcategory" do
    visit subcategory_path(section: "jobseeker-guides", subcategory: "return-to-teaching-in-england")

    expect(page).to be_axe_clean
  end

  describe "get help applying pages" do
    let(:post_names) do
      %w[
        prepare-for-a-teaching-job-interview-lesson
        3-quick-ways-to-find-the-right-teaching-job
        how-to-approach-a-teaching-job-interview
        write-a-great-teaching-job-application-in-five-steps
        how-to-write-teacher-personal-statement
        find-a-teaching-role-at-the-right-school
      ]
    end

    it "has accessible help posts" do
      post_names.each do |post_name|
        visit post_path(section: "jobseeker-guides", subcategory: "get-help-applying-for-your-teaching-role", post_name: post_name)

        expect(page).to be_axe_clean
      end
    end
  end

  describe "return-to-teaching-in-england" do
    let(:post_names) do
      %w[
        return-to-teaching
        return-to-england-after-teaching-overseas
        arrange-your-referees
        find-classroom-experience
        how-to-apply-for-classroom-experience
        show-how-you-meet-the-teachers-standards
        update-your-subject-and-teaching-knowledge
        return-to-teaching-step-by-step
        case-studies
      ]
    end

    it "has accessible returning posts" do
      post_names.each do |post_name|
        visit post_path(section: "jobseeker-guides", subcategory: "return-to-teaching-in-england", post_name: post_name)

        expect(page).to be_axe_clean
      end
    end
  end
end
